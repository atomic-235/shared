-- Use Nix-provided LSPs instead of Mason on NixOS
return {
  -- Disable Mason
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  -- Disable mason-nvim-dap; debugpy is provided by Nix (pkgs.debugpy)
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },

  -- Remove mason deps from nvim-lspconfig so it loads without them
  {
    "neovim/nvim-lspconfig",
    dependencies = {},
    opts = {
      servers = {
        basedpyright = {
          mason = false,
          cmd = { "basedpyright-langserver", "--stdio" },
        },
        lua_ls = {
          mason = false,
          cmd = { "lua-language-server" },
        },
        ruff = {
          mason = false,
          cmd = { "ruff", "server" },
        },
        nixd = {
          mason = false,
          cmd = { "nixd" },
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import <nixpkgs> { }",
              },
              formatting = {
                command = { "nixfmt" },
              },
              options = {
                nixos = {
                  expr = "(builtins.getFlake (toString ./nix)).nixosConfigurations.default.options",
                },
                home_manager = {
                  expr = "(builtins.getFlake (toString ./nix)).nixosConfigurations.default.options.home-manager.users.type.getSubOptions []",
                },
              },
            },
          },
        },
        yamlls = {
          mason = false,
          cmd = { "yaml-language-server", "--stdio" },
        },
      },
    },
  },

  -- Configure formatters to use system binaries
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        shfmt = {
          command = "shfmt",
        },
        stylua = {
          command = "stylua",
        },
        prettier = {
          command = "prettier",
        },
        nixfmt = {
          command = "nixfmt",
        },
      },
      formatters_by_ft = {
        nix = { "nixfmt" },
        json = { "prettier" },
        jsonc = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
      },
    },
  },
}
