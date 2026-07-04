-- Clean HTML entities from hover docs
local function clean_html_entities(contents)
  if type(contents) == "string" then
    return contents
      :gsub("&nbsp;", " ")
      :gsub("&lt;", "<")
      :gsub("&gt;", ">")
      :gsub("&amp;", "&")
      :gsub("&quot;", '"')
      :gsub("&#39;", "'")
      :gsub("&#x27;", "'")
  elseif type(contents) == "table" then
    for i, v in ipairs(contents) do
      if type(v) == "string" then
        contents[i] = clean_html_entities(v)
      elseif type(v) == "table" and v.value then
        v.value = clean_html_entities(v.value)
      end
    end
  end
  return contents
end

return {
  {
    "folke/noice.nvim",
    opts = {
      -- Single borders match Hyprland system style (no rounding)
      presets = {
        lsp_doc_border = true,
      },
      lsp = {
        hover = {
          enabled = true,
        },
        signature = {
          enabled = true,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },

    },
  },
}
