# Design: vimdoc for `:help seq-lsp`

## Intent

Add a `doc/seq-lsp.txt` vimdoc file so users can run `:help seq-lsp` inside Neovim to get usage reference without leaving their editor. This is a standard expectation for Neovim plugins and was identified as a gap in the roadmap.

## Constraints

- **Must not break lazy loading** — the `doc/` directory is indexed by `:helptags` at install time, not at runtime. No impact on startup.
- **Must stay accurate** — document only what the plugin actually does today. No aspirational features.
- **Out of scope**: generating docs from code, adding a doc build step, or documenting the Seq language itself. This is plugin usage docs only.

## Approach

Create `doc/seq-lsp.txt` in standard vimdoc format. Cover:

1. **Introduction** — what the plugin is, link to patch-seq repo
2. **Requirements** — Neovim 0.10+, `seq-lsp` binary
3. **Setup** — `require("seq-lsp").setup(opts)` with the options table:
   - `cmd` (string list, default `{"seq-lsp"}`)
   - `inlay_hints` (boolean, default `false`)
   - `capabilities` (table, optional)
   - `on_attach` (function, optional)
4. **Features** — brief list: syntax highlighting, indentation, LSP diagnostics/completions/hover/symbols/inlay hints
5. **Filetype detection** — `.seq` → `seq`, comment format `# %s`

Single file, one help tag per section. Follow the vimdoc conventions used by nvim-lspconfig and similar plugins (right-aligned tags, fixed-width layout, `~` for section headers).

## Domain Events

- **Produces**: `doc/seq-lsp.txt` file in the plugin's runtime path
- **Consumed by**: Neovim's `:helptags` generator (runs automatically on plugin install via lazy.nvim or manually via `:helptags ALL`)
- **User trigger**: `:help seq-lsp` after install

No code changes to existing modules. No new dependencies.

## Checkpoints

1. File exists at `doc/seq-lsp.txt` and passes `vim.cmd("helptags doc/")` without errors
2. `:help seq-lsp` opens the doc in Neovim
3. All four setup options are documented with types and defaults
4. Content matches what `lua/seq-lsp/init.lua` and `README.md` actually describe — no drift
