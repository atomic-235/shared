-- Connection details for minuet, resolved from the environment.
--
-- minuet talks to any OpenAI-compatible chat endpoint. Under `with-nono ai`
-- (dotfiles) the proxy exports OPENAI_BASE_URL and a phantom OPENAI_API_KEY;
-- portable sets the same two variables in local.nix. With either one missing
-- the plugin stays disabled instead of firing requests that can only fail.
local M = {}

local function env(name)
  local value = vim.env[name]
  if value == nil or value == "" then
    return nil
  end
  return value
end

M.key_env = env("MINUET_KEY_ENV") or "OPENAI_API_KEY"

local base_url = env("OPENAI_BASE_URL")
if base_url then
  M.end_point = base_url:gsub("/+$", "") .. "/chat/completions"
end

-- AI_MODEL_* carry a "provider/" prefix; the HTTP API wants the bare id.
local model = env("MINUET_MODEL") or env("AI_MODEL_FAST") or "default"
M.model = model:match("([^/]+)$")

-- Venice accepts extra body parameters that other OpenAI-compatible
-- endpoints would reject, so only send them when talking to Venice.
M.is_venice = M.end_point ~= nil and M.end_point:find("venice", 1, true) ~= nil

function M.enabled()
  return env(M.key_env) ~= nil and M.end_point ~= nil
end

return M
