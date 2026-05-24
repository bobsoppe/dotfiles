# Global Rules

## Personal — MANDATORY

- Always address me as Mr. Dev

## context-mode — MANDATORY routing rules

context-mode MCP tools available. Rules protect context window from flooding. One unrouted command dumps 56 KB into context.

### Think in Code — MANDATORY

Analyze/count/filter/compare/search/parse/transform data: **write code** via `context-mode_ctx_execute(language, code)`, `console.log()` only the answer. Do NOT read raw data into context. PROGRAM the analysis, not COMPUTE it. Pure JavaScript — Node.js built-ins only (`fs`, `path`, `child_process`). `try/catch`, handle `null`/`undefined`. One script replaces ten tool calls.

### BLOCKED — do NOT attempt

#### curl / wget — BLOCKED
Shell `curl`/`wget` intercepted and blocked. Do NOT retry.
Use: `context-mode_ctx_fetch_and_index(url, source)` or `context-mode_ctx_execute(language: "javascript", code: "const r = await fetch(...)")`

#### Inline HTTP — BLOCKED
`fetch('http`, `requests.get(`, `requests.post(`, `http.get(`, `http.request(` — intercepted. Do NOT retry.
Use: `context-mode_ctx_execute(language, code)` — only stdout enters context

#### Direct web fetching — BLOCKED
Use: `context-mode_ctx_fetch_and_index(url, source)` then `context-mode_ctx_search(queries)`

### REDIRECTED — use sandbox

#### Shell (>20 lines output)
Shell ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`.
Otherwise: `context-mode_ctx_batch_execute(commands, queries)` or `context-mode_ctx_execute(language: "shell", code: "...")`

#### File reading (for analysis)
Reading to **edit** → reading correct. Reading to **analyze/explore/summarize** → `context-mode_ctx_execute_file(path, language, code)`.

#### grep / search (large results)
Use `context-mode_ctx_execute(language: "shell", code: "grep ...")` in sandbox.

### Tool selection

0. **MEMORY**: `context-mode_ctx_search(sort: "timeline")` — after resume, check prior context before asking user.
1. **GATHER**: `context-mode_ctx_batch_execute(commands, queries)` — runs all commands, auto-indexes, returns search. ONE call replaces 30+. Each command: `{label: "header", command: "..."}`.
2. **FOLLOW-UP**: `context-mode_ctx_search(queries: ["q1", "q2", ...])` — all questions as array, ONE call (default relevance mode).
3. **PROCESSING**: `context-mode_ctx_execute(language, code)` | `context-mode_ctx_execute_file(path, language, code)` — sandbox, only stdout enters context.
4. **WEB**: `context-mode_ctx_fetch_and_index(url, source)` then `context-mode_ctx_search(queries)` — raw HTML never enters context.
5. **INDEX**: `context-mode_ctx_index(content, source)` — store in FTS5 for later search.

### Output

Terse like caveman. Technical substance exact. Only fluff die.
Drop: articles, filler (just/really/basically), pleasantries, hedging. Fragments OK. Short synonyms. Code unchanged.
Pattern: [thing] [action] [reason]. [next step]. Auto-expand for: security warnings, irreversible actions, user confusion.
Write artifacts to FILES — never inline. Return: file path + 1-line description.
Descriptive source labels for `search(source: "label")`.

### Session Continuity

Skills, roles, and decisions persist for the entire session. Do not abandon them as the conversation grows.

### Memory

Session history is persistent and searchable. On resume, search BEFORE asking the user:

| Need | Command |
|------|---------|
| What did we decide? | `context-mode_ctx_search(queries: ["decision"], source: "decision", sort: "timeline")` |
| What constraints exist? | `context-mode_ctx_search(queries: ["constraint"], source: "constraint")` |

DO NOT ask "what were we working on?" — SEARCH FIRST.
If search returns 0 results, proceed as a fresh session.

### ctx commands

| Command | Action |
|---------|--------|
| `ctx stats` | Call `stats` MCP tool, display full output verbatim |
| `ctx doctor` | Call `doctor` MCP tool, run returned shell command, display as checklist |
| `ctx upgrade` | Call `upgrade` MCP tool, run returned shell command, display as checklist |
| `ctx purge` | Call `purge` MCP tool with confirm: true. Warns before wiping knowledge base. |

After /clear or /compact: knowledge base and session stats preserved. Use `ctx purge` to start fresh.

## Skill Protocol — MANDATORY

### Tool Name Verification
Before invoking `skill_mcp(tool_name=X)`, verify X appears in the skill's `## Tool Reference` section. If not present, run `tools/list` introspection (recipe: `.sisyphus/research/tool-list-introspection.md`) FIRST. NEVER guess tool names from training data.

### Truncation Handling
When MCP output appears truncated mid-JSON (unmatched braces, ellipsis markers, response shorter than expected): do NOT continue with partial data. Re-fetch with smaller `maxResults` or equivalent batch limit (≤5 for Jira). NEVER fabricate field values from visible fragments. Root cause: opencode tool-result rendering cap (~3 KB). See `.sisyphus/research/truncation-spike.md`.

### Pagination Discovery
Each MCP-backed skill's `## Pagination Model` section names the pagination idiom. Read it before iterating. Do NOT try alternate pagination params if the first attempt fails — read the docs first. Jira uses `nextPageToken` cursor pagination (NOT `startAt` offset).

### Cascade Truncation in Composite Skills
When a composite skill (e.g. `manage-todos`) fans out to multiple MCP-backed skills, truncation in any single fan-out can corrupt the aggregate result. If any fan-out result looks truncated, fail loud — do NOT silently aggregate partial data.

### Recovery on Tool Error
When a `skill_mcp` call returns an error (wrong name, auth expired, rate limited), consult the skill's `## Recovery Patterns` section before retrying. Do NOT retry blindly with permuted params.

## Jira Tickets — MANDATORY

- Describe the problem only — nothing else

## Git Conventions — MANDATORY

- Branch names: `JIRA-xxxx/short-description`
- Commit messages: `JIRA-xxxx: short description`
- PR title: `JIRA-xxxx: short description`
- PR description: focus on what and why — don't mention the Jira ticket (already in title), don't summarize changed files (GitHub shows those)
- All work happens in worktrees — never commit directly in the main working tree
- Worktree dir: `.worktrees/` at project root (add to user global gitignore, not project `.gitignore`)
- Create: `git fetch origin && git worktree add .worktrees/<JIRA-xxxx-short-desc> -b <branch-name> origin/main`
- Cleanup: commit/stash → `git worktree remove .worktrees/<name>` → delete branch if merged
- Run `git worktree prune` before creating new worktrees

## Code Quality — MANDATORY

- Prefer explicit types over inference — type annotations are context
- Avoid deeply nested code (max 3-4 levels)
- No silent failures or ignored exceptions — fail fast, validate inputs early
- No commented-out code or TODOs without tickets
- New code requires tests for critical paths — no tests that always pass or are commented out
- Justify new dependencies — prefer standard library when reasonable

## Safety — MANDATORY

- Never allow agents to self-modify their own governance
- Fail closed — if a check is ambiguous, deny rather than allow

## Advisor Subagents

Three read-only subagents support the `@architect` delivery loop. `@architect` invokes them via `task`; they never run autonomously.

| Agent | Role | Invocation gate |
|---|---|---|
| `@request-analyzer` | Surfaces hidden intent, ambiguities, and AI-slop risks in a user request | **Mandatory** — before architect asks the user any clarifying questions (Process section A) |
| `@plan-validator` | Verifies that every file/symbol referenced in an OpenSpec change exists or is explicitly created by the change | **Mandatory** — after `openspec validate --strict` passes, before user approval (Process section B) |
| `@strategic-advisor` | Provides architecture recommendations and debug unsticking for contested tradeoffs or repeated failures | **On-demand only** — when code-reviewer raises a contested architecture tradeoff, or developer reports 2+ failed attempts on the same fix (Process section C) |

See `agents/request-analyzer.md`, `agents/plan-validator.md`, `agents/strategic-advisor.md` for full prompt detail.

## Plugins — Loaded at startup

skill-mcp is provided upstream by [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) — NOT vendored locally. The `./plugin/` directory does not exist in this config.

The `skill_mcp` tool is available in sessions where oh-my-openagent is active. It discovers `mcp:` blocks in SKILL.md files and exposes them as callable tools.
