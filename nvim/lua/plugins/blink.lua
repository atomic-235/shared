return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    local minuet = require("config.minuet")

    opts.keymap = opts.keymap or {}
    opts.keymap["<CR>"] = { "accept", "fallback" }
    opts.keymap["<Tab>"] = { "snippet_forward", "fallback" }

    opts.sources = opts.sources or {}
    -- opts_extend does not append across separate specs, so spell out
    -- LazyVim's default list plus minuet.
    opts.sources.default = { "lsp", "path", "snippets", "buffer" }

    if minuet.enabled() then
      -- Manual minuet invocation: opens the menu and asks the LLM. Resolved
      -- here rather than at spec-load so the plugin dir is on the rtp by now.
      opts.keymap["<S-Tab>"] = require("minuet").make_blink_map()

      table.insert(opts.sources.default, "minuet")
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.minuet = {
        name = "minuet",
        module = "minuet.blink",
        async = true, -- LSP items render while the LLM request is still open
        timeout_ms = 3000, -- >= minuet request_timeout (3s) * 1000
        score_offset = 50, -- rank AI suggestions above lsp/path
      }
    end

    -- LSP signature help (parameter hints inside call parens). Pure LSP —
    -- minuet only runs on <S-Tab>, so nothing here reaches the LLM.
    opts.signature = opts.signature or {}
    opts.signature.enabled = true

    -- Minuet is manual-only (minuet.blink.enable_auto_complete = false), so
    -- there is nothing to prefetch on InsertEnter.
    opts.completion = opts.completion or {}
    opts.completion.trigger = opts.completion.trigger or {}
    opts.completion.trigger.prefetch_on_insert = false
  end,
}
