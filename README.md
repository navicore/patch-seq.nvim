# patch-seq.nvim

Neovim support for the [Seq programming language](https://github.com/navicore/patch-seq).

**Home Code Repository** is at [git.navicore.tech](https://git.navicore.tech/navicore/patch-seq.nvim)

**PRs and issues** welcome at the [GitHub mirror](https://github.com/navicore/patch-seq.nvim)

## Features

- **Syntax highlighting** - Keywords, builtins, strings, comments, stack effects
- **Auto-indentation** - Smart indentation for word definitions and control flow
- **LSP integration** - Real-time diagnostics (parse errors, type errors, undefined words)
- **Completions** - Builtins, local words, included modules
- **Hover** - Stack effect signatures for words
- **Breadcrumbs** - Document symbols showing word definitions in your statusline
- **Inlay hints** - Inline type signatures (opt-in, off by default)

## Requirements

- Neovim 0.10+ (for `vim.lsp.start` and `vim.filetype.add`)
- `seq-lsp` binary in your PATH

### Installing seq-lsp

Install from crates.io:

```bash
cargo install seq-lsp
```

Or build from source:

```bash
git clone https://github.com/navicore/patch-seq
cd patch-seq
cargo install --path lsp
```

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "navicore/patch-seq.nvim",
  ft = "seq",
  opts = {},
}
```

### With custom configuration

```lua
{
  "navicore/patch-seq.nvim",
  ft = "seq",
  opts = {
    -- Enable inlay hints (off by default)
    inlay_hints = true,

    -- Custom path to seq-lsp binary (optional)
    cmd = { "/path/to/seq-lsp" },

    -- LSP capabilities (optional, for completion plugins)
    capabilities = require("cmp_nvim_lsp").default_capabilities(),

    -- on_attach callback (optional)
    on_attach = function(client, bufnr)
      -- Your keymaps here
    end,
  },
}
```

### Manual setup

If you prefer manual configuration:

```lua
require("seq-lsp").setup({})
```

## Usage

Once installed, open any `.seq` file and the LSP will start automatically. Diagnostics appear inline as you type.

## License

MIT
