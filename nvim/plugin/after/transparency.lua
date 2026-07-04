-- Tokyo Night accent color from Hyprland config
local accent = "#7aa2f7"

-- Helper to apply transparency while preserving fg colors
local function apply_transparency()
  -- Get existing fg colors before clearing bg
  local function clear_bg(name)
    local hl = vim.api.nvim_get_hl(0, { name = name })
    vim.api.nvim_set_hl(0, name, { bg = "none", fg = hl.fg, sp = hl.sp, bold = hl.bold, italic = hl.italic })
  end

  -- Simple bg clear (for groups where we don't care about fg)
  local function clear_bg_only(name)
    vim.api.nvim_set_hl(0, name, { bg = "none" })
  end

  -- Core UI - preserve fg
  clear_bg("Normal")
  clear_bg("NormalFloat")

  -- Set border color to match Hyprland window borders
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = accent, bg = "none" })
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = accent, bg = "none" })
  clear_bg("Pmenu")
  clear_bg_only("Terminal")
  clear_bg_only("EndOfBuffer")
  clear_bg_only("FoldColumn")
  clear_bg_only("Folded")
  clear_bg_only("SignColumn")
  clear_bg("NormalNC")
  clear_bg_only("WhichKeyFloat")

  -- Telescope
  clear_bg("TelescopeBorder")
  clear_bg_only("TelescopeNormal")
  clear_bg("TelescopePromptBorder")
  clear_bg_only("TelescopePromptTitle")

  -- NeoTree
  clear_bg_only("NeoTreeNormal")
  clear_bg_only("NeoTreeNormalNC")
  clear_bg_only("NeoTreeVertSplit")
  clear_bg_only("NeoTreeWinSeparator")
  clear_bg_only("NeoTreeEndOfBuffer")

  -- NvimTree
  clear_bg_only("NvimTreeNormal")
  clear_bg_only("NvimTreeVertSplit")
  clear_bg_only("NvimTreeEndOfBuffer")
  clear_bg_only("NvimTreeNormalNC")

  -- Notify
  clear_bg_only("NotifyERRORBody")
  clear_bg_only("NotifyWARNBody")
  clear_bg_only("NotifyTRACEBody")
  clear_bg_only("NotifyDEBUGBody")
  clear_bg_only("NotifyINFOTitle")
  clear_bg_only("NotifyERRORTitle")
  clear_bg_only("NotifyWARNTitle")
  clear_bg_only("NotifyTRACETitle")
  clear_bg_only("NotifyDEBUGTitle")
  clear_bg_only("NotifyINFOBorder")
  clear_bg_only("NotifyERRORBorder")
  clear_bg_only("NotifyWARNBorder")
  clear_bg_only("NotifyTRACEBorder")
  clear_bg_only("NotifyDEBUGBorder")
end

-- Apply on startup and whenever colorscheme changes
apply_transparency()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = apply_transparency,
})
