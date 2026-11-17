return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      ["<CR>"] = false,
      ["<Tab>"] = { "accept", "snippet_forward", "fallback" },
      ["<S-CR>"] = { "accept", "snippet_forward", "fallback" },
    },
  },
}
