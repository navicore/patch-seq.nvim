# Architecture

## Context & Scope

patch-seq.nvim is a Neovim plugin that provides IDE features for the **Seq** programming language (a stack-based/concatenative language). It handles presentation concerns — syntax highlighting, indentation, filetype detection — and delegates semantic analysis to an external LSP server.

**Boundaries:**
- **Inside**: syntax rules, indentation logic, filetype registration, LSP client configuration
- **Outside**: `seq-lsp` binary (Rust LSP server from [patch-seq](https://github.com/navicore/patch-seq)) provides diagnostics, completions, hover, document symbols, and inlay hints
- **Host**: Neovim 0.10+ (provides `vim.lsp.start`, `vim.filetype.add`, treesitter-independent syntax engine)

## Solution Strategy

- **Pure Lua/Vim** — no build step, no external Lua dependencies. Plugin loads lazily on the `seq` filetype.
- **LSP for semantics** — all type-aware features (diagnostics, completions, hover, breadcrumbs, inlay hints) come from `seq-lsp` over stdio. The plugin is a thin LSP client config.
- **Vim regex syntax highlighting** — chosen over treesitter since Seq has no treesitter grammar. Covers keywords, 60+ builtins, strings, comments, stack effect signatures, and control flow.
- **Vimscript indentation** — `indentexpr` for context-aware indent/dedent around word definitions (`: ... ;`), control flow (`if/else/then`), and quotations (`[ ... ]`).

## Building Blocks

| Module | File | Responsibility |
|--------|------|----------------|
| **LSP client** | `lua/seq-lsp/init.lua` | `setup(opts)` entry point. Creates LSP client config, auto-starts on `FileType=seq`, handles root detection (`.git`, `Cargo.toml`, `justfile`). Passes `inlay_hints` as `init_options` to server. |
| **Syntax** | `syntax/seq.vim` | Regex-based highlighting for all Seq constructs: comments (`#`), strings, numbers, booleans, word definitions, stack effects `( ... -- ... )`, builtins, control flow, quotations. |
| **Indentation** | `indent/seq.vim` | `GetSeqIndent()` — increases indent after `:`, `if`, `else`, `[`; decreases on `then`, `else`, `]`, `;`. |
| **Filetype detect** | `ftdetect/seq.lua` | Registers `.seq` extension to `seq` filetype. |
| **Filetype config** | `ftplugin/seq.lua` | Sets comment format to `# %s`. |

No inter-module dependencies — each file is independently loaded by Neovim's runtime path conventions.

## Crosscutting Concepts

- **Lazy loading**: plugin is designed for `lazy.nvim` with `ft = "seq"` so nothing loads until a `.seq` file is opened.
- **Root detection**: LSP client walks upward from the file looking for `.git`, `Cargo.toml`, or `justfile` to establish the project root. Falls back to the file's directory.
- **No state**: the plugin holds no mutable state. All semantic state lives in the `seq-lsp` server process.
