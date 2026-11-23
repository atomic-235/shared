-- Inline AI completion via any OpenAI-compatible chat endpoint.
--
-- The endpoint and key come from OPENAI_BASE_URL / OPENAI_API_KEY (see
-- config/minuet.lua): under `with-nono ai` the proxy exports both, portable
-- sets them in local.nix, and with either missing the plugin never loads.
--
-- Venice has no FIM endpoint (/v1/completions and /v1/fim/completions both
-- 404), so this uses the chat provider with minuet's completion-tuned prompt.
-- The two Venice body parameters are load-bearing and only sent to Venice:
--   * reasoning.enabled = false -> deepseek defaults to effort "high", which
--     burns the whole max_tokens budget on thinking and returns empty content
--   * include_venice_system_prompt = false -> otherwise ~1700 prompt tokens
--     of Venice boilerplate ride along on every keystroke request
local minuet = require("config.minuet")

local optional = {
  max_tokens = 128,
  temperature = 0.2,
}
if minuet.is_venice then
  optional.reasoning = { enabled = false }
  optional.venice_parameters = { include_venice_system_prompt = false }
end

return {
  "milanglacier/minuet-ai.nvim",
  event = "InsertEnter",
  enabled = minuet.enabled(),
  config = function()
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
          api_key = minuet.key_env,
          end_point = minuet.end_point,
          model = minuet.model,
          name = minuet.is_venice and "Venice" or "OpenAI",
          stream = true,
          optional = optional,
        },
      },
      -- Menu mode: minuet items come through blink on <A-y>, never
      -- automatically. Ghost text (<A-]>) stays available for the other path.
      blink = { enable_auto_complete = false },

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
