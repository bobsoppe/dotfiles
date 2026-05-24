# Skill Authoring Guide

Copy this directory to create a new skill.

```bash
cp -r ~/.config/opencode/skills/_template ~/.config/opencode/skills/<new-skill-name>
```

Then edit `SKILL.md` and remove sections that don't apply to your skill type.

---

## Skill Types

| Type | Description |
|---|---|
| **mcp-backed** | Wraps a single MCP server, exposes its tools |
| **composite** | Orchestrates multiple skills/MCPs into a workflow |
| **workflow** | Multi-step process (may use MCPs), focused on a specific task |
| **voice-guide** | Style/tone guide only, no MCP calls |

---

## Section Applicability Matrix

| Section | mcp-backed | composite | workflow | voice-guide |
|---|---|---|---|---|
| When to use | REQUIRED | REQUIRED | REQUIRED | REQUIRED |
| When NOT to use | REQUIRED | REQUIRED | REQUIRED | N/A |
| Tool Reference | REQUIRED | list sub-skills | if uses MCP | N/A |
| Pagination Model | REQUIRED | if sub-skill paginates | if uses paginated MCP | N/A |
| Output Size & Truncation | REQUIRED | REQUIRED (cascade) | if uses MCP | N/A |
| Common Pitfalls | REQUIRED | REQUIRED | REQUIRED | OPTIONAL |
| Recovery Patterns | REQUIRED | REQUIRED | REQUIRED | N/A |
| Examples | REQUIRED | REQUIRED | REQUIRED | OPTIONAL |
| Notes | OPTIONAL | OPTIONAL | OPTIONAL | OPTIONAL |

---

## References

- See [Skill Protocol](../../AGENTS.md#skill-protocol) for behavioral expectations.
- Tool introspection recipe: [.sisyphus/research/tool-list-introspection.md](../../.sisyphus/research/tool-list-introspection.md)
