local M = {}

M.system_exts = {
  png = true, jpg = true, jpeg = true, gif = true, bmp = true,
  webp = true, tiff = true, svg = true, xcf = true,
  pdf = true, epub = true,
  mp4 = true, mkv = true, webm = true, avi = true, mov = true,
  mp3 = true, flac = true, wav = true, ogg = true,
  odt = true, ods = true, odp = true,
  doc = true, docx = true, xlsx = true, pptx = true,
  zip = true, gz = true, tgz = true, bz2 = true, ["7z"] = true, rar = true,
}

function M.is_binary(path)
  local ext = (vim.fn.fnamemodify(path, ":e") or ""):lower()
  return M.system_exts[ext] or false
end

function M.open_binary(path)
  local existing = vim.fn.bufnr("^" .. path .. "$")
  local buf
  if existing > 0 and vim.bo[existing].filetype == "binary" then
    buf = existing
  else
    if existing > 0 then
      vim.api.nvim_buf_delete(existing, { force = true })
    end
    buf = vim.api.nvim_create_buf(true, false)
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
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].modifiable = false
    vim.api.nvim_buf_set_name(buf, path)
    vim.keymap.set("n", "gx", function()
      vim.system({ "xdg-open", path }, { detach = true })
    end, { buffer = buf, nowait = true, silent = true, desc = "Open with system app" })
  end
  vim.api.nvim_set_current_buf(buf)
end

return M
