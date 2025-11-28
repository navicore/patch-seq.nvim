-- seq-lsp.nvim
-- Neovim LSP configuration for the Seq programming language

local M = {}

M.setup = function(opts)
  opts = opts or {}

  -- Register .seq filetype
  vim.filetype.add({
    extension = {
      seq = "seq",
    },
  })

  -- Default command - assumes seq-lsp is in PATH
  local cmd = opts.cmd or { "seq-lsp" }

  -- Set up LSP when opening .seq files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "seq",
    callback = function(args)
      vim.lsp.start({
        name = "seq-lsp",
        cmd = cmd,
        root_dir = vim.fs.dirname(
          vim.fs.find({ ".git", "Cargo.toml", "justfile" }, {
            upward = true,
            path = vim.fs.dirname(args.file),
          })[1]
        ) or vim.fn.getcwd(),
        capabilities = opts.capabilities,
        on_attach = opts.on_attach,
      })
    end,
  })
end

return M
