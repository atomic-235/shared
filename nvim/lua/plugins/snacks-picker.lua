return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader><space>",
      function()
        Snacks.picker.smart({ filter = { cwd = true } })
      end,
      desc = "Smart Find Files (cwd)",
    },
  },
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<C-h>"] = { "focus_list", mode = { "n", "i" } },
            ["<C-l>"] = { "focus_preview", mode = { "n", "i" } },
          },
        },
        list = {
          keys = {
            ["<C-h>"] = "focus_input",
            ["<C-k>"] = "focus_input",
            ["<C-l>"] = "focus_preview",
            ["<C-j>"] = "focus_preview",
          },
        },
        preview = {
          keys = {
            ["<C-h>"] = "focus_list",
            ["<C-l>"] = "focus_input",
            ["<C-k>"] = "focus_input",
            ["<C-j>"] = "focus_list",
          },
        },
      },
      sources = {
        -- nls (Nickel) reports every document symbol as SymbolKind.VARIABLE,
        -- which is not in snacks' default kind filter. Include all kinds for
        -- .ncl files, or the outline is always empty.
        lsp_symbols = {
          filter = {
            nickel = true,
          },
        },
        files = {
          hidden = true,
          ignored = true,
          exclude = {
            ".git",
            ".venv",
            "venv",
            ".direnv",
            ".ruff_cache",
            ".mypy_cache",
            ".pytest_cache",
            ".tox",
            "__pycache__",
            "__pypackages__",
            "node_modules",
            ".next",
            ".nuxt",
            ".angular",
            ".cache",
            ".airflow",
            ".julia",
            "*.egg-info",
            "*.eggs",
          },
        },
        grep = {
          hidden = true,
          ignored = true,
          exclude = {
            ".git",
            ".venv",
            "venv",
            ".direnv",
            ".ruff_cache",
            ".mypy_cache",
            ".pytest_cache",
            ".tox",
            "__pycache__",
            "__pypackages__",
            "node_modules",
            ".next",
            ".nuxt",
            ".angular",
            ".cache",
            ".airflow",
            ".julia",
            "*.egg-info",
            "*.eggs",
          },
        },
        git_status = {
          layout = "left",
        },
      },
    },
  },
}
