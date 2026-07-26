-- LaTeX: texlab LSP with Zathura synctex forward/inverse search
-- Forward search: cursor in nvim → jump to matching position in Zathura PDF
-- Inverse search: Ctrl+click in Zathura → jump to matching line in nvim
--   (requires zathurarc: set synctex-editor-command "nvr --remote-silent +%{line} %{input}")
--   or: set synctex-editor-command "texlab forward"

local function texlab_request(method, params)
  local clients = vim.lsp.get_clients({ bufnr = 0, name = "texlab" })
  if #clients == 0 then
    vim.notify("texlab LSP not attached", vim.log.levels.WARN)
    return
  end
  clients[1]:request(method, params, function(err, result)
    if err then
      vim.notify("texlab error: " .. vim.inspect(err), vim.log.levels.ERROR)
    elseif result and result.status then
      if result.status == 0 then
        vim.notify("texlab: success", vim.log.levels.INFO)
      else
        vim.notify("texlab: " .. (result.message or "failed"), vim.log.levels.WARN)
      end
    end
  end)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          mason = false,
          cmd = { "texlab" },
          settings = {
            texlab = {
              build = {
                executable = "latexmk",
                args = {
                  "-pdf",
                  "-interaction=nonstopmode",
                  "-synctex=1",
                  "%f",
                },
                forwardSearchAfter = true,
                onSave = false,
              },
              forwardSearch = {
                executable = "zathura",
                args = {
                  "--synctex-forward",
                  "%l:1:%f",
                  "%p",
                },
              },
              chktex = {
                onOpenAndSave = true,
                onEdit = false,
              },
            },
          },
        },
      },
    },
    keys = {
      { "<leader>lb", "", desc = "LaTeX Build", ft = "tex" },
      { "<leader>lf", "", desc = "LaTeX Forward Search", ft = "tex" },
      { "<leader>lv", "", desc = "LaTeX View PDF", ft = "tex" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          -- Build document (latexmk via texlab)
          vim.keymap.set("n", "<leader>lb", function()
            texlab_request("textDocument/build", {
              textDocument = vim.lsp.util.make_text_document_params(0),
            })
          end, { buffer = true, desc = "LaTeX Build" })

          -- Forward search: jump to cursor position in Zathura
          vim.keymap.set("n", "<leader>lf", function()
            local client = vim.lsp.get_clients({ bufnr = 0, name = "texlab" })[1]
            local offset_encoding = client and client.offset_encoding or "utf-16"
            texlab_request("textDocument/forwardSearch", {
              textDocument = vim.lsp.util.make_text_document_params(0),
              position = vim.lsp.util.make_position_params(0, offset_encoding),
            })
          end, { buffer = true, desc = "LaTeX Forward Search" })

          -- View PDF in Zathura (open without forward search)
          vim.keymap.set("n", "<leader>lv", function()
            local fname = vim.fn.expand("%:p:r") .. ".pdf"
            if vim.fn.filereadable(fname) == 1 then
              vim.fn.jobstart({ "zathura", fname }, { detach = true })
            else
              vim.notify("PDF not found: " .. fname .. " — build first", vim.log.levels.WARN)
            end
          end, { buffer = true, desc = "LaTeX View PDF" })
        end,
      })
    end,
  },
}
