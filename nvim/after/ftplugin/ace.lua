-- Attempto Controlled English language server. The ace-lsp binary is provided
-- by the logical_english project's Nix flake (its devShell puts it on PATH via
-- direnv), so attach only when it is actually available. It spawns `ape` from
-- PATH for diagnostics/hover, so it is likewise only useful inside that shell.
if vim.fn.executable("ace-lsp") == 0 then
  return
end

-- LazyVim does not start semantic tokens by itself; ace-lsp colors words by
-- their lexicon class (ape's -csyntaxd: noun/verb/adjective/...), so start
-- them wherever the ace-lsp client attaches. Registered once.
if not vim.g.ace_lsp_semantic_tokens then
  vim.g.ace_lsp_semantic_tokens = true
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("ace_lsp", { clear = false }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "ace-lsp" and client.server_capabilities.semanticTokensProvider then
        vim.lsp.semantic_tokens.start(args.buf, client.id)
      end
    end,
  })
end

vim.lsp.start({
  name = "ace-lsp",
  cmd = { "ace-lsp" },
  root_dir = vim.fs.root(0, "flake.nix") or vim.fn.getcwd(),
})

-- vim.lsp.start reuses an already-running client without firing LspAttach.
for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
  if client.name == "ace-lsp" then
    vim.lsp.semantic_tokens.start(0, client.id)
  end
end
