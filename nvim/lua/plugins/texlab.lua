-- LaTeX: texlab LSP with Zathura synctex forward/inverse search
-- Forward search: cursor in nvim → jump to matching position in Zathura PDF
-- Inverse search: Ctrl+click in Zathura → jump to matching line in nvim
--   (requires zathurarc: set synctex-editor-command "nvr --remote-silent +%{line} %{input}")
-- Auto-sync: moving cursor in nvim (Normal mode) or scrolling auto-jumps Zathura

local function texlab_request(method, params)
  local clients = vim.lsp.get_clients({ bufnr = 0, name = "texlab" })
  if #clients == 0 then
    return
  end
  clients[1]:request(method, params, function(err, result)
    if err then
      vim.notify("texlab error: " .. vim.inspect(err), vim.log.levels.ERROR)
    end
  end)
end

local function forward_search(buf)
  local client = vim.lsp.get_clients({ bufnr = buf, name = "texlab" })[1]
  if not client then return end
  local enc = client.offset_encoding or "utf-16"
  local pos = vim.lsp.util.make_position_params(0, enc)
  texlab_request("textDocument/forwardSearch", {
    textDocument = vim.lsp.util.make_text_document_params(buf),
    position = pos.position,
  })
end

local function build_document(buf)
  texlab_request("textDocument/build", {
    textDocument = vim.lsp.util.make_text_document_params(buf),
  })
end

local function view_pdf()
  local fname = vim.fn.expand("%:p:r") .. ".pdf"
  if vim.fn.filereadable(fname) == 1 then
    vim.fn.jobstart({ "zathura", fname }, { detach = true })
  else
    vim.notify("PDF not found: " .. fname .. " — build first", vim.log.levels.WARN)
  end
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
                executable = vim.fn.exepath("latexmk-docker"),
                args = {
                  "-pdf",
                  "-interaction=nonstopmode",
                  "-synctex=1",
                  "%f",
                },
                forwardSearchAfter = true,
                onSave = true,
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
    init = function()
      local sync_group = vim.api.nvim_create_augroup("TexlabSync", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        group = sync_group,
        callback = function(event)
          local buf = event.buf

          -- Set NVIM env var for nvr (inverse search from zathura)
          -- Use fixed socket path so zathura's nvr can find this nvim instance
          local socket = "/run/user/" .. vim.fn.getuid() .. "/nvim.texlab"
          vim.fn.serverstart(socket)
          vim.env.NVIM = socket

          -- Manual keymaps
          vim.keymap.set("n", "<leader>lb", function() build_document(buf) end, { buffer = buf, desc = "LaTeX Build" })
          vim.keymap.set("n", "<leader>lf", function() forward_search(buf) end, { buffer = buf, desc = "LaTeX Forward Search" })
          vim.keymap.set("n", "<leader>lv", view_pdf, { buffer = buf, desc = "LaTeX View PDF" })

          -- Auto forward search on CursorHold (cursor stops moving in Normal mode)
          vim.api.nvim_create_autocmd("CursorHold", {
            group = sync_group,
            buffer = buf,
            callback = function()
              forward_search(buf)
            end,
          })

          -- Auto forward search on scroll
          vim.api.nvim_create_autocmd({ "WinScrolled" }, {
            group = sync_group,
            buffer = buf,
            callback = function()
              forward_search(buf)
            end,
          })
        end,
      })
    end,
  },
}
