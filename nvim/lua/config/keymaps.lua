-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- K is handled by noice.nvim with border configured in plugins/noice.lua

-- Git file history
vim.keymap.set("n", "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git File History" })

-- Markdown checkbox toggle
vim.keymap.set("n", "<leader>ux", function()
  local line = vim.api.nvim_get_current_line()
  local new_line
  if line:match("%[ %]") then
    new_line = line:gsub("%[ %]", "[x]", 1)
  elseif line:match("%[x%]") then
    new_line = line:gsub("%[x%]", "[ ]", 1)
  end
  if new_line then
    vim.api.nvim_set_current_line(new_line)
  end
end, { desc = "Toggle checkbox" })

-- Insert Python/Jupyter cell divider
vim.keymap.set("n", "<leader>j", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, { "# %%", "" })
  vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
  vim.cmd("startinsert")
end, { desc = "Insert Jupyter Cell" })

-- Move right in insert mode (jump past auto-pairs)
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })

-- Search marks (only letter marks, no automatic ones)
local function open_marks_picker()
  local items = {}
  local current_buf = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(current_buf)

  -- Get global marks (A-Z)
  for _, mark in ipairs(vim.fn.getmarklist()) do
    local label = mark.mark:sub(2, 2)
    if label:match("^[A-Z]$") then
      table.insert(items, {
        text = label .. " " .. (mark.file or ""),
        label = label,
        file = mark.file,
        pos = { mark.pos[2], mark.pos[3] },
      })
    end
  end

  -- Get local marks (a-z)
  for _, mark in ipairs(vim.fn.getmarklist(current_buf)) do
    local label = mark.mark:sub(2, 2)
    if label:match("^[a-z]$") then
      table.insert(items, {
        text = label .. " " .. bufname,
        label = label,
        file = bufname,
        pos = { mark.pos[2], mark.pos[3] },
      })
    end
  end

  table.sort(items, function(a, b)
    return a.label < b.label
  end)

  Snacks.picker({
    title = "Marks",
    items = items,
    format = "file",
    actions = {
      delete_mark = function(picker)
        local item = picker:current()
        if item and item.label then
          vim.cmd("delmarks " .. item.label)
          picker:close()
          vim.schedule(open_marks_picker)
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-x>"] = { "delete_mark", mode = { "n", "i" } },
        },
      },
      list = {
        keys = {
          ["dd"] = "delete_mark",
        },
      },
    },
  })
end

vim.keymap.set("n", "<leader>sm", open_marks_picker, { desc = "Marks" })

-- Delete/change to register x (keeps unnamed register intact)
vim.keymap.set({ "n", "v" }, "d", [["xd]], { desc = "Delete to x register" })
vim.keymap.set({ "n", "v" }, "D", [["xD]], { desc = "Delete to EOL to x register" })
vim.keymap.set({ "n", "v" }, "c", [["xc]], { desc = "Change to x register" })
vim.keymap.set({ "n", "v" }, "C", [["xC]], { desc = "Change to EOL to x register" })

-- Grep with prefilled glob filter in input
vim.keymap.set("n", "<leader>sg", function()
  Snacks.picker.grep({
    search = " -- -g *",
    on_show = function()
      vim.schedule(function()
        vim.cmd("stopinsert")
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        vim.cmd("startinsert")
      end)
    end,
  })
end, { desc = "Grep (glob filter)" })
