return {
  "nvim-neo-tree/neo-tree.nvim",
  init = function()
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("neotree_reveal_on_open", { clear = true }),
      callback = function(ev)
        if vim.bo[ev.buf].filetype == "neo-tree" or vim.bo[ev.buf].filetype == "neo-tree-popup" then
          return
        end
        local path = vim.api.nvim_buf_get_name(ev.buf)
        if path == "" then
          return
        end
        local win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_get_config(win).relative ~= "" then
          return
        end
        vim.schedule(function()
          if not package.loaded["neo-tree"] then
            return
          end
          local manager = require("neo-tree.sources.manager")
          local state = manager.get_state("filesystem")
          if not state or not state.path then
            return
          end
          if path:sub(1, #state.path) ~= state.path then
            return
          end
          manager.navigate("filesystem", nil, path)
        end)
      end,
    })
  end,
  opts = {
    filesystem = {
      hijack_netrw_behavior = "open_current", -- opens neo-tree when opening a directory
      use_libuv_file_watcher = true,
      follow_current_file = {
        enabled = true,
        leave_dirs_open = true,
      },
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
