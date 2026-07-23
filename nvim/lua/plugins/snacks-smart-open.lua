-- Smart confirm: open images/PDFs with xdg-open instead of as buffers.
-- Applied to Snacks picker confirm action globally.
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
              vim.ui.open(item.file)
              picker:close()
            else
              picker:close()
              vim.schedule(function()
                vim.cmd("edit " .. vim.fn.fnameescape(item.file))
              end)
            end
          end,
        },
      },
    },
  },
}
