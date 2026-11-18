-- Inline AI completion via Venice.
--
-- Venice has no FIM endpoint (/v1/completions and /v1/fim/completions both
-- 404), so this uses the chat provider with minuet's completion-tuned prompt.
-- Launch nvim as `with-nono ai nvim` so the proxy can inject the key; the
-- env var is a phantom placeholder and auth happens at 127.0.0.1:20174.
--
-- Two settings are load-bearing, both measured:
--   * reasoning.enabled = false -> deepseek defaults to effort "high", which
--     burns the whole max_tokens budget on thinking and returns empty content
--   * include_venice_system_prompt = false -> otherwise ~1700 prompt tokens
--     of Venice boilerplate ride along on every keystroke request
return {
  "milanglacier/minuet-ai.nvim",
  event = "InsertEnter",
  config = function()
    -- Outside the proxy there is no key and no CA, so minuet would only 401.
    -- Stay silent instead of shouting on every start.
    if not vim.env.VENICE_API_KEY then
      vim.notify("minuet: no VENICE_API_KEY (run nvim via `with-nono ai nvim`)", vim.log.levels.DEBUG)
      return
    end

    require("minuet").setup({
      provider = "openai_compatible",
      request_timeout = 3,
      -- one request per 700ms at most, fired 250ms after you stop typing
      throttle = 700,
      debounce = 250,
      n_completions = 1,
      context_window = 8000,
      provider_options = {
        openai_compatible = {
          -- name of the env var, not the key. Phantom under with-nono.
          api_key = "VENICE_API_KEY",
          end_point = "https://api.venice.ai/api/v1/chat/completions",
          model = "deepseek-v4-1-flash-1017-uncensored",
          name = "Venice",
          stream = true,
          optional = {
            max_tokens = 128,
            temperature = 0.2,
            reasoning = { enabled = false },
            venice_parameters = { include_venice_system_prompt = false },
          },
        },
      },
      -- Manual only: at ~0.9s per suggestion, auto-triggering ghosts text that
      -- is already stale by the time it renders. Add filetypes here to enable.
      virtualtext = {
        auto_trigger_ft = {},
        keymap = {
          accept = "<A-A>",
          accept_line = "<A-a>",
          accept_n_lines = "<A-z>",
          prev = "<A-[>",
          next = "<A-]>", -- also manually invokes completion
          dismiss = "<A-e>",
        },
      },
    })
  end,
}
