-- Smart confirm for Snacks file picker: open images/PDFs/media with
-- xdg-open instead of loading binary into nvim buffer.
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
                vim.system({ "xdg-open", path }, { detach = true })
                return true
              end

              -- Text file: delegate to jump, then reveal in explorer.
              picker:action("jump")
              vim.defer_fn(function()
                Snacks.explorer.reveal({ file = path })
              end, 50)
              return true
            end,
          },
        },
      },
    },
  },
}
