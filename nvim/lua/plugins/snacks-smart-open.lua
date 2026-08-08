-- Smart confirm for Snacks file picker: binary files open a readonly
-- message buffer in nvim instead of loading garbage bytes.
-- Per-source `confirm` shortcut avoids the keymap override bug (#554).
local binary = require("utils.binary")

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            exclude = {
              ".Trash", ".Trash-1000", ".playwright", ".playwright-mcp", ".direnv",
              ".venv", ".ruff_cache", ".pytest_cache", ".mypy_cache", "__pycache__",
              ".eggs", "*.egg-info",
              ".databricks", ".dbx", ".dagster", ".airflow", ".dlt",
              ".buildozer", ".angular", ".vite",
              ".claude", ".opencode", ".agent_loop", ".generated",
              ".obsidian", ".idea", ".vscode",
              ".aws-sam", ".circleci", ".azuredevops", ".gitlab",
              ".husky", ".tx", ".devcontainer", ".git-crypt",
              ".secrets", ".ivpn-data", ".local",
            },
            confirm = function(picker, item, action)
              if not item then
                return Snacks.picker.actions.jump(picker, item, action)
              end

              local path = Snacks.picker.util.path(item)
              if not path then
                return Snacks.picker.actions.jump(picker, item, action)
              end

              if binary.is_binary(path) then
                picker:close()
                vim.schedule(function()
                  binary.open_binary(path)
                end)
                return true
              end

              return Snacks.picker.actions.jump(picker, item, action)
            end,
          },
        },
      },
    },
  },
}
