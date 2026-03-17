# Roadmap

## Current State

The plugin provides a complete editing experience for Seq files: syntax highlighting, smart indentation, and LSP integration (diagnostics, completions, hover, symbols, inlay hints). All semantic features depend on the external `seq-lsp` server.

## Known Gaps

- **No treesitter grammar** — syntax highlighting uses Vim regex patterns. A treesitter parser would enable better highlighting, code folding, and structural editing.
- **No tests** — no test framework or CI pipeline exists.
- **No `:help` docs** — Neovim vimdoc (`doc/*.txt`) is not yet provided.

## Possible Next Steps

- Add vimdoc for `:help seq-lsp`
- Track builtins list against `seq-lsp` as the language evolves
