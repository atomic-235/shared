-- yaml-language-server does not hot-reload YAML schema files (upstream
-- vscode-yaml#639: JSON schemas reload, YAML schemas do not). Saving the
-- schema therefore leaves validation and hover serving the old contract.
--
-- Workaround: restart the client after a schema write. `:lsp restart` reattaches
-- to all previously attached buffers, so open data buffers pick up the new
-- schema immediately. Debounced, because saving several files at once would
-- otherwise queue several restarts.
return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      local pending = false

      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "schema.yaml", "schema.yml", "schema.json" },
        callback = function()
          if pending then
            return
          end
          if #vim.lsp.get_clients({ name = "yamlls" }) == 0 then
            return
          end

          pending = true
          vim.defer_fn(function()
            pending = false
            if #vim.lsp.get_clients({ name = "yamlls" }) > 0 then
              vim.cmd("silent! lsp restart yamlls")
            end
          end, 300)
        end,
      })
    end,
  },
}
