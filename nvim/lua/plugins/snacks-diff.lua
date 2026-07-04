local context = 3

vim.opt.diffopt:append("context:" .. context)

local function set_diff_context(n)
  context = n
  vim.opt.diffopt = vim.tbl_filter(function(v)
    return not v:match("^context:")
  end, vim.opt.diffopt:get())
  vim.opt.diffopt:append("context:" .. context)
end

vim.keymap.set("n", "<leader>ucd", function()
  local input = vim.fn.input("Diff context lines [" .. context .. "]: ")
  if input == "" then
    return
  end
  local n = tonumber(input)
  if n and n > 0 then
    set_diff_context(n)
  end
end, { desc = "Diff context lines" })

vim.keymap.set("n", "<leader>uci", function()
  set_diff_context(context + 1)
end, { desc = "Increase diff context" })

vim.keymap.set("n", "<leader>ucD", function()
  if context > 1 then
    set_diff_context(context - 1)
  end
end, { desc = "Decrease diff context" })

return {
  "folke/snacks.nvim",
  opts = {},
}