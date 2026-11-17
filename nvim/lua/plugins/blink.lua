return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "accept", "snippet_forward", "fallback" },
    },
  },
}
