-- Smart confirm for Snacks file picker: binary files open a readonly
-- message buffer in nvim instead of loading garbage bytes.
-- Per-source `confirm` shortcut avoids the keymap override bug (#554).
local system_exts = {
  png = true, jpg = true, jpeg = true, gif = true, bmp = true,
  webp = true, tiff = true, svg = true, xcf = true,
  pdf = true, epub = true,
  mp4 = true, mkv = true, webm = true, avi = true, mov = true,
  mp3 = true, flac = true, wav = true, ogg = true,
  odt = true, ods = true, odp = true,
  doc = true, docx = true, xlsx = true, pptx = true,
  zip = true, gz = true, tgz = true, bz2 = true, ["7z"] = true, rar = true,
}

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

              local ext = (vim.fn.fnamemodify(path, ":e") or ""):lower()

              if system_exts[ext] then
                picker:close()
                local buf = vim.api.nvim_create_buf(false, true)
                local rel = vim.fn.fnamemodify(path, ":~")
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
                  "",
                  "  Binary file: " .. rel,
                  "",
                  "  This file cannot be displayed as text.",
                  "  Press gx to open with system application.",
                  "",
                })
                vim.bo[buf].filetype = "binary"
                vim.bo[buf].modifiable = false
                vim.bo[buf].readonly = true
                vim.api.nvim_set_current_buf(buf)
                vim.keymap.set("n", "gx", function()
                  vim.system({ "xdg-open", path }, { detach = true })
                end, { buffer = buf, nowait = true, silent = true })
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
