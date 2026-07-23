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
      commands = {
        smart_open = function(state)
          local node = state.tree:get_node()
          if node and node.type == "file" then
            local binary = require("utils.binary")
            if binary.is_binary(node.path) then
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                local wb = vim.api.nvim_win_get_buf(win)
                if vim.bo[wb].filetype ~= "neo-tree" and vim.bo[wb].filetype ~= "neo-tree-popup" then
                  vim.api.nvim_set_current_win(win)
                  break
                end
              end
              vim.schedule(function()
                binary.open_binary(node.path)
              end)
              require("neo-tree.command").execute({ action = "close" })
              return
            end
          end
          state.commands["open"](state)
        end,
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
        ["<cr>"] = "smart_open",
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
