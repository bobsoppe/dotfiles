---
name: obsidian-vault
description: |
  Read/write access to a local Obsidian-compatible vault via mcpvault.
  Tools cover note CRUD, frontmatter, tags, search, and directory listing.
  Use when a task references the vault, todo notes, daily notes, or
  anything stored under ~/.local/share/obsidian-vault.
type: mcp-backed
mcp:
  obsidian-vault:
    command: sh
    args:
      - -c
      - |
        VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/.local/share/obsidian-vault}"
        exec npx --yes @bitbonsai/mcpvault@latest "$VAULT"
---

<!-- See AGENTS.md ## Skill Protocol for behavioral expectations -->

## When to use

- Reading or writing vault notes by path (daily notes, inbox, archive).
- Searching the vault for notes matching a keyword or tag.
- Updating frontmatter fields on a note (e.g. `last_sync`, `tags`).
- Appending content to a specific section of an existing note.
- Listing files in a vault directory to discover what exists before reading.
- Managing tags on a note (add or remove).

## When NOT to use

- Codebase questions — use grep/LSP tools instead.
- Sending Slack messages or posting to Jira — use those skills directly.
- Reading files outside the vault root (`~/.local/share/obsidian-vault`).
- Any operation that requires the Obsidian GUI to be running.
- Searching across git repos or project files — this skill is vault-only.

## Tool Reference

Verified via live introspection against `@bitbonsai/mcpvault@latest`.

| Tool | Purpose | Required params | Returns |
|------|---------|-----------------|---------|
| `read_note` | Read full note content and frontmatter | `path` (vault-relative) | `{ fm: object, content: string }` |
| `write_note` | Create or overwrite a note | `path`, `content` | Success/error object |
| `patch_note` | Append or insert content into a named section | `path`, `section`, `content` | Success/error object |
| `get_frontmatter` | Read YAML frontmatter only | `path` | Frontmatter as flat object |
| `update_frontmatter` | Update frontmatter keys | `path`, `data`, `merge?` | Updated frontmatter object |
| `manage_tags` | Add or remove tags on a note | `path`, `tags` (array) | `{ path, tags, success, message }` |
| `list_directory` | List files and subdirs in a vault directory | `path` | `{ dirs: string[], files: string[] }` |
| `search_notes` | Full-text search across the vault | `query`, `limit?` | Array of `{ p, t, ex, mc, ln, uri }` |

### Source of truth

Verify tool names via `skill_mcp(mcp_name="obsidian-vault", tool_name="tools/list")` — note: as of May 2026 this returns "Unknown tool"; use the table above (confirmed by live calls). `write_note`, `patch_note`, and `update_frontmatter` are documented by the mcpvault package but were not destructively tested.

## Pagination Model

- **Model**: limit-only (no cursor, no offset)
- **Param name**: `limit` on `search_notes`
- **Detecting last page**: results array length less than requested `limit`, or empty array
- **Recommended limit**: `limit: 10` for search; omit for directory listing (always returns full list)

`search_notes` does not support offset or cursor pagination. To narrow results, refine the query rather than paginate.

```
1. Call search_notes with query="<term>", limit=10.
2. Process results.
3. If results.length < limit, you have all matches.
4. If results.length == limit, refine the query — no next-page mechanism exists.
```

## Output Size & Truncation

- **Typical response size**: `read_note` on a large note can exceed 3 KB; `search_notes` returns compact excerpts (~200 bytes per result)
- **Runtime/UI cap**: opencode truncates tool results at ~3 KB
- **search_notes result shape**: `p` = path, `t` = match type, `ex` = excerpt, `mc` = match count, `ln` = line number, `uri` = obsidian URI
- **When a note is large**: read it in sections using `patch_note` to target specific headings, or use `search_notes` to locate the relevant section first
- **When output looks truncated** (abrupt end, missing closing brace):
  1. Use `search_notes` with a narrow query to locate the relevant section.
  2. Re-read with a more targeted path or section.
  3. Never fabricate or infer missing content from a truncated response.

## Common Pitfalls

- **Path is vault-relative**: always pass paths relative to the vault root (e.g. `inbox/todo.md`, not `/Users/.../inbox/todo.md`). Absolute paths fail silently or error.
- **`manage_tags` message misleads**: the `message` field always says "Successfully removed tags" regardless of whether tags were added or removed. Check the returned `tags` array to confirm the actual state.
- **`update_frontmatter` without `merge: true`**: omitting `merge` overwrites all existing frontmatter keys. Always pass `merge: true` unless a full replacement is intended.
- **`.obsidian/` directory**: mcpvault filters this directory. Do not attempt to read or write it.
- **Tag syntax**: tags in frontmatter are stored as plain strings (e.g. `"todo"`), not with a `#` prefix. `manage_tags` expects the same plain-string format.
- **Vault path override**: if `OBSIDIAN_VAULT_PATH` is set in the environment, it overrides the default `~/.local/share/obsidian-vault`. Check this if tools return unexpected results.
- **`search_notes` returns empty**: the vault may have no matching content, or the query may be too specific. Broaden the query or use `list_directory` to confirm the note exists.

## Recovery Patterns

When a tool call fails, follow these steps in order:

1. **File not found**: call `list_directory` on the parent path first to confirm the file exists and check the exact filename.
2. **Wrong tool name**: the table in Tool Reference above lists verified names. Do not guess variants.
3. **Truncated response**: use `search_notes` with a narrow query to locate the relevant excerpt instead of reading the full note.
4. **Permission error / vault not found**: check that `OBSIDIAN_VAULT_PATH` points to a readable directory, or that the default `~/.local/share/obsidian-vault` exists.
5. **`search_notes` returns empty**: try a shorter, broader query term. Confirm the note exists via `list_directory`.
6. **Unexpected schema**: log the raw response and compare against the Tool Reference table. The `read_note` response wraps content in `{ fm, content }` — do not expect a flat string.

## Examples

### Read a note by path

```
skill_mcp(
  mcp_name: "obsidian-vault",
  tool_name: "read_note",
  arguments: { path: "inbox/todo.md" }
)
// Returns: { fm: { title: "...", tags: [...] }, content: "- [ ] ..." }
```

### Search notes with a limit

```
skill_mcp(
  mcp_name: "obsidian-vault",
  tool_name: "search_notes",
  arguments: { query: "DEVOPS-10891", limit: 5 }
)
// Returns: [{ p: "inbox/todo.md", ex: "...", mc: 1, ln: 3, uri: "obsidian://..." }]
```

### Append to a section

```
skill_mcp(
  mcp_name: "obsidian-vault",
  tool_name: "patch_note",
  arguments: {
    path: "inbox/todo.md",
    section: "## Manual",
    content: "- [ ] Follow up on DEVOPS-11180\n"
  }
)
```

## Notes

- Override vault path: set `OBSIDIAN_VAULT_PATH` env var before loading this skill.
- mcpvault requires no Obsidian plugin — it reads/writes the filesystem directly.
- `.obsidian/` directory is filtered by mcpvault; do not attempt to read/write it via this skill.
- No authentication required; vault is filesystem-only.
