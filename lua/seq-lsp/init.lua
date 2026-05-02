-- seq-lsp.nvim
-- Neovim LSP configuration for the Seq programming language

local M = {}

local function register_user_command()
  local quick = require("seq-lsp.quick")
  local subcommands = {
    quick = function() quick.show_quick() end,
    doc = function(arg) quick.show_doc(arg) end,
    cat = function(arg) quick.show_category(arg) end,
  }

  vim.api.nvim_create_user_command("Seq", function(cmdline)
    local args = vim.split(cmdline.args, "%s+", { trimempty = true })
    local sub = args[1] or "quick"
    local handler = subcommands[sub]
    if not handler then
      vim.notify(
        "Unknown :Seq subcommand: " .. sub .. " (try quick|doc|cat)",
        vim.log.levels.ERROR
      )
      return
    end
    handler(args[2])
  end, {
    nargs = "*",
    desc = "Seq language quick reference",
    complete = function(arg_lead, cmdline)
      local parts = vim.split(cmdline, "%s+", { trimempty = true })
      local trailing_space = cmdline:sub(-1) == " "
      -- parts[1] is "Seq" itself; subcommand is the second token
      local typing_subcommand =
        (#parts == 1) or (#parts == 2 and not trailing_space)
      if typing_subcommand then
        return vim.tbl_filter(
          function(s) return s:find(arg_lead, 1, true) == 1 end,
          { "quick", "doc", "cat" }
        )
      end
      -- Completion for the argument to doc/cat would require a synchronous
      -- LSP call; skip for now and let the user type the word themselves.
      return {}
    end,
  })
end

M.setup = function(opts)
  opts = opts or {}

  -- Register .seq filetype
  vim.filetype.add({
    extension = {
      seq = "seq",
    },
  })

  register_user_command()

  -- Default command - assumes seq-lsp is in PATH
  local cmd = opts.cmd or { "seq-lsp" }

  -- Build initialization options for LSP
  local init_options = {
    inlay_hints = opts.inlay_hints or false,
  }

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
        init_options = init_options,
      })
    end,
  })
end

return M
