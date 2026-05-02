-- Quick-reference / pocket guide for the Seq language.
--
-- Talks to the seq-lsp `seq/listWords` custom request and renders a dense,
-- categorised view of every built-in and stdlib word. Used by the :Seq user
-- command (see init.lua).

local M = {}

local function get_client()
  local clients = vim.lsp.get_clients({ name = "seq-lsp" })
  return clients[1]
end

local function request_words(cb)
  local client = get_client()
  if not client then
    vim.notify(
      "seq-lsp is not running. Open a .seq file first.",
      vim.log.levels.WARN
    )
    return
  end
  client:request("seq/listWords", vim.empty_dict(), function(err, result)
    if err then
      vim.notify("seq/listWords failed: " .. vim.inspect(err), vim.log.levels.ERROR)
      return
    end
    cb(result)
  end)
end

local function open_float(lines, title)
  local width = math.min(120, vim.o.columns - 4)
  local height = math.min(#lines + 2, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "seq-quick"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, silent = true })
end

-- Wrap a list of word names into lines no wider than `width` columns,
-- separated by two spaces. Each output line is prefixed with `indent`.
local function wrap_words(words, width, indent)
  local lines = {}
  local current = indent
  local body_width = width - #indent
  for i, w in ipairs(words) do
    local sep = (i == 1) and "" or "  "
    if #current - #indent + #sep + #w > body_width and current ~= indent then
      table.insert(lines, current)
      current = indent .. w
    else
      current = current .. sep .. w
    end
  end
  if current ~= indent then
    table.insert(lines, current)
  end
  return lines
end

local function render_quick(result, width)
  local lines = {}
  local function section(header)
    if #lines > 0 then table.insert(lines, "") end
    table.insert(lines, header)
    table.insert(lines, string.rep("─", math.min(width, 80)))
  end

  section("Built-ins")
  for _, group in ipairs(result.builtins or {}) do
    local names = {}
    for _, w in ipairs(group.words) do table.insert(names, w.name) end
    if #names > 0 then
      table.insert(lines, string.format("[%s]", group.name))
      for _, l in ipairs(wrap_words(names, width, "  ")) do
        table.insert(lines, l)
      end
    end
  end

  section("Stdlib")
  for _, group in ipairs(result.stdlib or {}) do
    local names = {}
    for _, w in ipairs(group.words) do table.insert(names, w.name) end
    if #names > 0 then
      table.insert(lines, string.format("[%s]", group.name))
      for _, l in ipairs(wrap_words(names, width, "  ")) do
        table.insert(lines, l)
      end
    end
  end

  return lines
end

-- Find a word by name across builtins + stdlib. Returns (word_info, group_name).
local function find_word(result, name)
  for _, group in ipairs(result.builtins or {}) do
    for _, w in ipairs(group.words) do
      if w.name == name then return w, group.name end
    end
  end
  for _, group in ipairs(result.stdlib or {}) do
    for _, w in ipairs(group.words) do
      if w.name == name then return w, group.name end
    end
  end
  return nil, nil
end

-- Find a group (builtin category or stdlib module) by name.
local function find_group(result, name)
  for _, group in ipairs(result.builtins or {}) do
    if group.name == name then return group, "builtin" end
  end
  for _, group in ipairs(result.stdlib or {}) do
    if group.name == name then return group, "stdlib" end
  end
  return nil, nil
end

function M.show_quick()
  request_words(function(result)
    local width = math.min(116, vim.o.columns - 8)
    local lines = render_quick(result, width)
    vim.schedule(function() open_float(lines, " Seq quick reference ") end)
  end)
end

function M.show_doc(word_name)
  request_words(function(result)
    local word, group = find_word(result, word_name)
    vim.schedule(function()
      if not word then
        vim.notify("seq: no such word: " .. word_name, vim.log.levels.WARN)
        return
      end
      local lines = {
        string.format("%s  %s", word.name, word.signature),
        string.format("(%s)", group),
      }
      if word.doc then
        table.insert(lines, "")
        for _, l in ipairs(vim.split(word.doc, "\n", { plain = true })) do
          table.insert(lines, l)
        end
      end
      open_float(lines, " " .. word.name .. " ")
    end)
  end)
end

function M.show_category(group_name)
  request_words(function(result)
    local group = find_group(result, group_name)
    vim.schedule(function()
      if not group then
        vim.notify("seq: no such category: " .. group_name, vim.log.levels.WARN)
        return
      end
      local lines = {}
      for _, w in ipairs(group.words) do
        table.insert(lines, string.format("%-28s %s", w.name, w.signature))
      end
      open_float(lines, " " .. group.name .. " ")
    end)
  end)
end

-- Returns a flat list of every group name (for command completion).
function M.all_group_names(cb)
  request_words(function(result)
    local names = {}
    for _, g in ipairs(result.builtins or {}) do table.insert(names, g.name) end
    for _, g in ipairs(result.stdlib or {}) do table.insert(names, g.name) end
    cb(names)
  end)
end

-- Returns a flat list of every word name (for command completion).
function M.all_word_names(cb)
  request_words(function(result)
    local names = {}
    for _, g in ipairs(result.builtins or {}) do
      for _, w in ipairs(g.words) do table.insert(names, w.name) end
    end
    for _, g in ipairs(result.stdlib or {}) do
      for _, w in ipairs(g.words) do table.insert(names, w.name) end
    end
    cb(names)
  end)
end

return M
