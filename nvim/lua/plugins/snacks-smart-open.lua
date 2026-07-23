-- Smart confirm: open images/PDFs/media with xdg-open instead of as buffers.
-- For text files, delegates to Snacks' built-in jump action
-- so split/vtab/reuse_win/jumplist/tagstack all keep working.
local binary_exts = {
  png = true, jpg = true, jpeg = true, gif = true, bmp = true,
  webp = true, svg = true, ico = true, tiff = true,
  pdf = true, eps = true, ps = true,
  mp4 = true, mkv = true, webm = true, avi = true, mov = true,
  mp3 = true, flac = true, wav = true, ogg = true,
  xlsx = true, xls = true, docx = true, doc = true, pptx = true, ppt = true,
  zip = true, tar = true, gz = true, bz2 = true, xz = true, zst = true,
  ["7z"] = true, rar = true,
  odg = true,
}

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        win = {
          input = {
            keys = {
              ["<CR>"] = "smart_confirm",
            },
          },
        },
        actions = {
          smart_confirm = function(picker, item)
            if not item then
              return
            end
            local ext = item.file:match("%.([^.]+)$")
            if ext and binary_exts[ext:lower()] then
              -- Binary file: open with system handler (xdg-open on Linux).
              picker:close()
              vim.ui.open(item.file)
            else
              -- Text file: delegate to Snacks' built-in jump action.
              -- jump() handles close, jumplist, tagstack, split/vtab, etc.
              require("snacks.picker.actions").jump(picker, item)
            end
          end,
        },
      },
    },
  },
}
