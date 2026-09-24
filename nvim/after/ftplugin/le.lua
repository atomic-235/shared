-- Logical English 2.0 language server. The le2-lsp binary is provided by the
-- logical_english project's Nix flake (its devShell puts it on PATH via
-- direnv), so attach only when it is actually available.
if vim.fn.executable("le2-lsp") == 0 then
  return
end

-- LazyVim does not start semantic tokens by itself; the server provides
-- instance-level coloring (template words vs variable arguments), so start
-- them wherever the le2-lsp client attaches. Registered once.
if not vim.g.le2_lsp_semantic_tokens then
  vim.g.le2_lsp_semantic_tokens = true
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("le2_lsp", { clear = false }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "le2-lsp" and client.server_capabilities.semanticTokensProvider then
        vim.lsp.semantic_tokens.start(args.buf, client.id)
      end
    end,
  })
end

vim.lsp.start({
  name = "le2-lsp",
  cmd = { "le2-lsp" },
  root_dir = vim.fs.root(0, "flake.nix") or vim.fn.getcwd(),
})

-- vim.lsp.start reuses an already-running client without firing LspAttach.
for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
  if client.name == "le2-lsp" then
    vim.lsp.semantic_tokens.start(0, client.id)
  end
end
