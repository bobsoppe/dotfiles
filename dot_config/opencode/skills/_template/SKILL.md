---
name: <skill-name>
description: |
  One-sentence description of what this skill does.
  Use when: <trigger condition>.
type: mcp-backed  # mcp-backed | composite | workflow | voice-guide
# mcp: (include only for mcp-backed skills)
#   type: stdio
#   command: npx
#   args: ["--yes", "mcp-remote", "<MCP_URL>"]
---

<!-- See AGENTS.md ## Skill Protocol for behavioral expectations -->
<!-- Template: copy with `cp -r _template <new-skill-name>` then edit SKILL.md -->

## When to use

- List each trigger condition as a bullet.
- Be specific: name the user intent, the tool, or the workflow that activates this skill.
- Example: "When the user asks to search Jira for open tickets assigned to them."

## When NOT to use

<!-- mcp-backed: REQUIRED | composite: REQUIRED | workflow: REQUIRED | voice-guide: N/A -->

- List anti-patterns and negative examples.
- Name the skill or tool the user should reach for instead.
- Example: "Don't use this to create tickets — use `create-jira-ticket` instead."

## Tool Reference

<!-- mcp-backed: REQUIRED (verify names via introspection recipe) | composite: list sub-skills | workflow: list MCP tools used | voice-guide: N/A -->

List every tool this skill exposes or depends on.

| Tool | Purpose | Required params | Returns |
|------|---------|-----------------|---------|
| `tool_name_here` | What it does in one phrase | `param1`, `param2` | Description of return value |

### Source of truth

Verify tool names and signatures via the introspection recipe documented in `.sisyphus/research/tool-list-introspection.md`. Tool names drift — always confirm before documenting.

## Pagination Model

<!-- mcp-backed: REQUIRED | composite: REQUIRED if any sub-skill paginates | workflow: REQUIRED if uses paginated MCP | voice-guide: N/A -->

State the pagination model used by this skill's tools.

- **Model**: cursor / offset / page-token / none
- **Param name**: e.g. `nextPageToken`, `startAt`, `cursor`
- **Detecting last page**: describe the signal (empty array, missing token field, `total <= startAt + maxResults`, etc.)
- **Recommended page size**: e.g. `maxResults: 5` for Jira, `limit: 10` for others

Example loop pattern:

```
1. Call tool with maxResults=<N>, no cursor.
2. Process results.
3. If response contains nextPageToken, call again with that token.
4. Stop when nextPageToken is absent or results array is empty.
```

## Output Size & Truncation

<!-- mcp-backed: REQUIRED | composite: REQUIRED with cascade-warning | workflow: REQUIRED if uses MCP | voice-guide: N/A -->

Document expected response sizes and truncation behaviour.

- **Typical response size**: e.g. "~2–4 KB per page of 5 Jira issues"
- **Runtime/UI cap**: responses may be silently truncated at ~3044 bytes by the runtime or UI layer
- **Recommended maxResults**: keep at ≤5 for rich objects, ≤20 for lightweight lists
- **When output looks truncated** (abrupt end, missing closing brackets, partial JSON):
  1. Re-fetch with a smaller `maxResults`.
  2. Paginate to retrieve the rest.
  3. NEVER fabricate or infer missing data from a truncated response.

## Common Pitfalls

<!-- mcp-backed: REQUIRED | composite: REQUIRED | workflow: REQUIRED | voice-guide: OPTIONAL -->

Document failure modes specific to this skill.

- **Wrong tool name**: MCP tool names are exact-match. A single character difference returns "tool not found". Verify via introspection recipe.
- **Auth expiry**: describe how auth tokens expire and how to detect it (e.g. 401 response, specific error message).
- **Field name mismatch**: list any fields that differ between API docs and actual MCP response shape.
- Add more pitfalls specific to this skill's domain.

## Recovery Patterns

<!-- mcp-backed: REQUIRED | composite: REQUIRED | workflow: REQUIRED | voice-guide: N/A -->

When a tool call fails, follow these steps in order:

1. **Wrong tool name**: run the introspection recipe from `.sisyphus/research/tool-list-introspection.md` to get the exact name. Do not guess.
2. **Truncated response**: reduce `maxResults` by half and retry. Paginate if needed.
3. **Rate limited**: wait the duration specified in the error, then retry once. If it fails again, report to the user.
4. **Auth expired**: describe the re-auth flow for this skill (e.g. re-run `npx mcp-remote <URL>`, refresh token, re-export env var).
5. **Unexpected schema**: log the raw response shape, compare against Tool Reference table above, update the table if the schema has changed.

## Examples

<!-- mcp-backed: REQUIRED | composite: REQUIRED | workflow: REQUIRED | voice-guide: OPTIONAL -->

### Simple call

```
// Describe what the user asked for
skill_mcp(
  mcp_name: "<mcp-name>",
  tool_name: "tool_name_here",
  arguments: { param1: "value", maxResults: 5 }
)
```

### Paginated call

```
// First page
skill_mcp(
  mcp_name: "<mcp-name>",
  tool_name: "tool_name_here",
  arguments: { param1: "value", maxResults: 5 }
)
// → response contains nextPageToken: "abc123"

// Second page
skill_mcp(
  mcp_name: "<mcp-name>",
  tool_name: "tool_name_here",
  arguments: { param1: "value", maxResults: 5, nextPageToken: "abc123" }
)
// → response has no nextPageToken → done
```

## Notes

<!-- all types: OPTIONAL -->

- List env vars required (e.g. `JIRA_API_TOKEN`, `SLACK_BOT_TOKEN`).
- List dependencies on other skills (e.g. "Requires `atlassian` skill for MCP access").
- Note any setup steps the user must complete before this skill works.
- Document known limitations or version constraints.
