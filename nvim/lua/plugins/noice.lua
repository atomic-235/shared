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

-- Noice renders markdown docs with its own tree-sitter pass, but it drops the
-- `#offset!` directive. nvim-treesitter relies on it to conceal only the
-- backslash of an escape: `(backslash_escape) @conceal (#offset! @conceal 0 0 0
-- -1) (#set! conceal "")`. Noice applies the conceal to the whole node, so
-- `variable\_card: integer` renders as `variablecard: integer`. Honour the
-- offset before setting the extmark.
local function patch_markdown_offsets()
  local ok, treesitter = pcall(require, "noice.text.treesitter")
  if not ok then
    return
  end

  treesitter.highlight = function(buf, ns, range, lang)
    lang = treesitter.get_lang(lang)
    lang = lang == "markdown" and "markdown_inline" or lang
    lang = lang:lower()
    buf = (buf == 0 or buf == nil) and vim.api.nvim_get_current_buf() or buf

    local LanguageTree = require("vim.treesitter.languagetree")
    local parser = LanguageTree.new(buf, lang, { injections = { php = "", html = "" } })
    parser:set_included_regions({ { range } })
    parser:parse(true)

    parser:for_each_tree(function(tstree, tree)
      if not tstree then
        return
      end
      local query = treesitter.get_query(tree:lang())
      if not query then
        return
      end

      for capture, node, metadata in query:iter_captures(tstree:root(), buf, range[1], range[3]) do
        local start_row, start_col, end_row, end_col = node:range()
        local offset = (metadata[capture] or {}).offset or metadata.offset
        if offset then
          start_row = start_row + (tonumber(offset[1]) or 0)
          start_col = start_col + (tonumber(offset[2]) or 0)
          end_row = end_row + (tonumber(offset[3]) or 0)
          end_col = end_col + (tonumber(offset[4]) or 0)
        end

        local name = query.captures[capture]
        local hl = 0
        if not vim.startswith(name, "_") then
          hl = vim.api.nvim_get_hl_id_by_name("@" .. name .. "." .. lang)
        end

        if hl and name ~= "spell" then
          pcall(vim.api.nvim_buf_set_extmark, buf, ns, start_row, start_col, {
            end_line = end_row,
            end_col = end_col,
            hl_group = hl,
            priority = (tonumber(metadata.priority) or 100) + 10,
            conceal = metadata.conceal,
          })
        end
      end
    end)
  end
end

return {
  {
    "folke/noice.nvim",
    init = patch_markdown_offsets,
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
