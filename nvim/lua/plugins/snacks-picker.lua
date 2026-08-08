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
      sources = {
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
