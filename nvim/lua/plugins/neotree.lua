return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      hijack_netrw_behavior = "open_current", -- opens neo-tree when opening a directory
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          ".git",
          ".DS_Store",
          "__pycache__",
          "__pypackages__",
          ".ruff_cache",
          ".mypy_cache",
          ".pytest_cache",
          ".tox",
          ".venv",
          "venv",
          ".direnv",
          ".airflow",
          ".julia",
        },
        hide_by_pattern = {
          "*.egg-info",
          "*.eggs",
        },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      icon = {
        folder_closed = "󰉍",
        folder_open = "󰝰",
        folder_empty = "󰉖",
        default = "",
      },
      git_status = {
        symbols = {
          added = "",
          modified = "",
          deleted = "",
          renamed = "➜",
          untracked = "★",
          ignored = "◌",
          unstaged = "✗",
          staged = "✓",
          conflict = "",
        },
      },
    },
    window = {
      position = "left",
      width = 35,
      mappings = {
        ["<space>"] = "none", -- disable space to avoid conflict with leader
        ["<cr>"] = function(state)
          local node = state.tree:get_node()
          if not node or node.type ~= "file" then
            state.commands["open"](state)
            return
          end
          local binary = require("utils.binary")
          if binary.is_binary(node.path) then
            require("neo-tree.sources.manager").navigate("filesystem", nil, node.path)
            vim.schedule(function()
              binary.open_binary(node.path)
            end)
            return
          end
          state.commands["open"](state)
        end,
        ["gx"] = function(state)
          local node = state.tree:get_node()
          if node and node.path then
            vim.ui.open(node.path)
          end
        end,
      },
    },
    event_handlers = {
      {
        event = "file_opened",
        handler = function()
          require("neo-tree.command").execute({ action = "close" })
        end,
      },
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          vim.opt_local.relativenumber = true
        end,
      },
    },
  },
}
