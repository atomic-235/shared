return {
  -- Customize basedpyright settings (Python extra is imported in lazy.lua)
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = true,
      },
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard", -- "off", "basic", "standard", "strict", "all"
                inlayHints = {
                  callArgumentNames = true,
                  functionReturnTypes = true,
                  variableTypes = true,
                  genericTypes = true,
                },
              },
            },
          },
        },
      },
    },
  },
}
