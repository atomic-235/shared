-- le2 infoview — like lean.nvim's infoview, for Logical English.
--
-- A full-height right-hand split. Put the cursor on a rule or a fact and the
-- pane shows the sheet section that statement cites, in full, plus the LE
-- statement itself. The pane is a *markdown* buffer, so whatever markdown
-- ftplugin/plugin you use (treesitter, render-markdown.nvim, …) applies to it
-- by default — headings, math and prose are not re-implemented here.
--
-- Data comes from the engine:  le2 - --sources-at OFFSET --base DIR   (JSON),
-- so it works on an unsaved buffer and relative includes resolve against the
-- file's folder. The JSON carries whole sections; nothing is cut here.
--
-- This file belongs to the dotfiles repo (submodules/shared/nvim/), like
-- le.lua's LSP wiring. Install it as a module, e.g. lua/le_infoview.lua, and
-- from after/ftplugin/le.lua call
--   require('le_infoview').attach(0)
-- The pane opens automatically on attach(). Close it with :q (the WinClosed
-- autocmd resets state); reopen with require('le_infoview').open().
--
-- Requires le2 on PATH (i.e. inside the logical_english dev shell).

local M = {}

M.opts = {
  cmd = { "le2" },
  width = 64,          -- columns of the right-hand split
  debounce = 150,
}

local state = { buf = nil, win = nil, timer = nil, seq = 0, open = false, attached = {} }

local function buf_text(buf)
  return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
end

local function base_dir(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then return vim.fn.getcwd() end
  return vim.fn.fnamemodify(name, ":h")
end

-- character offset (not byte) of the cursor, as le2 and SWI count characters
local function cursor_offset(buf)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = vim.api.nvim_buf_get_lines(buf, 0, row - 1, false)
  local cur = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
  local before = table.concat(lines, "\n")
  if #lines > 0 then before = before .. "\n" end
  return vim.fn.strchars(before .. cur:sub(1, col))
end

-- the pane content: valid markdown, so the markdown ftplugin applies as usual
local function markdown_lines(data)
  local out = {}
  local function add(text)
    for _, line in ipairs(vim.split(text or "", "\n", { plain = true })) do
      out[#out + 1] = line
    end
  end

  for _, c in ipairs(data.citations or {}) do
    local who = c.name ~= "" and (c.kind .. " " .. c.name) or c.kind
    add("# " .. who)
    add("")
    add(("%s, line %s"):format(c.file, c.line))
    add("")
    add("```le")
    add(c.le ~= "" and c.le or "-- no source")
    add("```")
    add("")
    add("---")
    add("")
    for _, line in ipairs(c.section or {}) do
      add(line)
    end
    add("")
  end

  while #out > 0 and out[#out] == "" do table.remove(out) end
  return out
end

local function placeholder_lines()
  return {
    "# le2 infoview",
    "",
    "No citation at this position.",
    "",
    "Move onto a rule or a fact that cites a document.",
  }
end

-- run the engine; cb(lines, data); cb(nil) when the call fails or finds nothing
function M.text(buf, cb)
  local off = cursor_offset(buf)
  local cmd = vim.list_extend(vim.deepcopy(M.opts.cmd),
    { "-", "--sources-at", tostring(off), "--base", base_dir(buf) })
  state.seq = state.seq + 1
  local seq = state.seq
  local ok, proc = pcall(vim.system, cmd,
    { text = true, stdin = buf_text(buf) },
    vim.schedule_wrap(function(res)
      if seq ~= state.seq then return end -- superseded
      if res.code ~= 0 then
        vim.notify("le2 infoview: " .. (res.stderr ~= "" and res.stderr
          or ("le2 exited " .. res.code)), vim.log.levels.WARN)
        return cb(nil, nil)
      end
      if res.stdout == "" then return cb(nil, nil) end
      local parsed, data = pcall(vim.json.decode, res.stdout)
      if not parsed or not data.ok or #(data.citations or {}) == 0 then
        return cb(nil, nil)
      end
      cb(markdown_lines(data), data)
    end))
  if not ok then cb(nil, nil) end
end

local function set_win_options(win)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].list = false
  vim.wo[win].winfixwidth = true
  -- wrap, conceallevel, etc. are the markdown ftplugin's business
end

local function paint(lines)
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return end
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
  vim.bo[state.buf].modified = false
end

function M.refresh()
  if not state.open then return end
  local buf = vim.api.nvim_get_current_buf()
  M.text(buf, function(lines)
    paint(lines or placeholder_lines())   -- stay open with an empty state
  end)
end

-- a real full-height window: a right-hand vertical split, focus left in the code
function M.open()
  if state.open and state.win and vim.api.nvim_win_is_valid(state.win) then
    return
  end
  local here = vim.api.nvim_get_current_win()
  vim.cmd(("botright %dvsplit"):format(math.max(20, M.opts.width)))
  vim.cmd("enew")
  state.buf = vim.api.nvim_get_current_buf()
  state.win = vim.api.nvim_get_current_win()
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false
  vim.bo[state.buf].modifiable = false
  -- filetype last, so the FileType autocmds run with the pane window current
  vim.bo[state.buf].filetype = "markdown"
  set_win_options(state.win)
  state.open = true
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(state.win),
    once = true,
    callback = function()
      state.open, state.win, state.buf = false, nil, nil
    end,
  })
  vim.api.nvim_set_current_win(here)
  paint(placeholder_lines())
  M.refresh()
end

function M.close()
  state.open = false
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win, state.buf = nil, nil
end

function M.toggle()
  if state.open and state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close()
  else
    M.open()
  end
end

function M.attach(buf)
  if buf == nil or buf == 0 then buf = vim.api.nvim_get_current_buf() end
  if state.attached[buf] then return end
  state.attached[buf] = true
  local group = vim.api.nvim_create_augroup("le2_infoview_" .. buf, { clear = true })
  local function debounced()
    if not state.open then return end
    if state.timer then state.timer:stop() end
    state.timer = vim.uv.new_timer()
    state.timer:start(M.opts.debounce, 0, vim.schedule_wrap(M.refresh))
  end
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "InsertLeave" },
    { buffer = buf, group = group, callback = debounced })
  vim.api.nvim_create_autocmd("BufWipeout",
    { buffer = buf, group = group, callback = M.close })
  M.open()
end

return M
