return {
  "LintaoAmons/bookmarks.nvim",
  tag = "v4.0.0",
  dependencies = {
    { "kkharji/sqlite.lua" },
    { "nvim-telescope/telescope.nvim" }, -- required by bookmarks.nvim internals
  },
  event = { "BufReadPost", "BufNewFile" },
  cmd = {
    "BookmarksMark",
    "BookmarksGoto",
    "BookmarksTree",
    "BookmarksCommands",
    "BookmarksLists",
    "BookmarksInfo",
    "BookmarksGotoNext",
    "BookmarksGotoPrev",
  },
  keys = {
    -- Toggle bookmark: prompts for a name, renames if one exists, removes if empty
    {
      "<leader>mt",
      "<cmd>BookmarksMark<cr>",
      desc = "Bookmark toggle/rename",
    },
    -- Search bookmarks via Snacks picker
    {
      "<leader>ms",
      function()
        local Service = require("bookmarks.domain.service")
        local Sign = require("bookmarks.sign")
        local bookmarks = Service.get_all_bookmarks_of_active_list()

        local items = {}
        for _, bm in ipairs(bookmarks) do
          if bm.location then
            local rel = vim.fn.fnamemodify(bm.location.path, ":~:.")
            table.insert(items, {
              text = (bm.name or "") .. " " .. rel .. ":" .. bm.location.line,
              file = bm.location.path,
              pos = { bm.location.line, bm.location.col or 0 },
              _bm = bm,
              _name = bm.name or "",
              _rel = rel,
            })
          end
        end

        if #items == 0 then
          vim.notify("No bookmarks in active list", vim.log.levels.INFO)
          return
        end

        Snacks.picker({
          title = "Bookmarks",
          items = items,
          format = function(item)
            local ret = {}
            if item._name ~= "" then
              ret[#ret + 1] = { item._name, "SnacksPickerLabel" }
              ret[#ret + 1] = { "  ", "SnacksPickerDimmed" }
            end
            ret[#ret + 1] = { item._rel, "SnacksPickerFile" }
            ret[#ret + 1] = { ":" .. item.pos[1], "SnacksPickerDimmed" }
            return ret
          end,
          confirm = function(picker, item)
            picker:close()
            if item and item._bm then
              Service.goto_bookmark(item._bm.id)
              Sign.safe_refresh_signs()
            end
          end,
          actions = {
            delete_bookmark = function(picker)
              local item = picker:current()
              if item and item._bm then
                Service.remove_bookmark(item._bm.id)
                Sign.safe_refresh_signs()
                picker:close()
                vim.notify("Bookmark deleted", vim.log.levels.INFO)
              end
            end,
            rename_bookmark = function(picker)
              local item = picker:current()
              if not item or not item._bm then return end
              picker:close()
              vim.ui.input({ prompt = "Bookmark name: ", default = item._bm.name or "" }, function(name)
                if name == nil then return end
                if name == "" then
                  Service.remove_bookmark(item._bm.id)
                  vim.notify("Bookmark removed", vim.log.levels.INFO)
                else
                  Service.rename_node(item._bm.id, name)
                  vim.notify("Bookmark renamed", vim.log.levels.INFO)
                end
                Sign.safe_refresh_signs()
              end)
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-x>"] = { "delete_bookmark", mode = { "n", "i" } },
                ["<c-r>"] = { "rename_bookmark", mode = { "n", "i" } },
              },
            },
            list = {
              keys = {
                ["dd"] = "delete_bookmark",
                ["R"] = "rename_bookmark",
              },
            },
          },
        })
      end,
      desc = "Bookmark search",
    },
    -- Treeview for organizing bookmarks and lists
    {
      "<leader>mm",
      "<cmd>BookmarksTree<cr>",
      desc = "Bookmark tree",
    },
    -- Next/prev navigation within current file
    {
      "<leader>mn",
      "<cmd>BookmarksGotoNext<cr>",
      desc = "Bookmark next",
    },
    {
      "<leader>mp",
      "<cmd>BookmarksGotoPrev<cr>",
      desc = "Bookmark prev",
    },
    -- Commands picker (all available bookmark commands)
    {
      "<leader>mc",
      "<cmd>BookmarksCommands<cr>",
      desc = "Bookmark commands",
    },
    -- Switch active bookmark list
    {
      "<leader>ml",
      "<cmd>BookmarksLists<cr>",
      desc = "Bookmark lists",
    },
    -- Switch to project-scoped list (creates it if missing)
    {
      "<leader>mw",
      function()
        local Service = require("bookmarks.domain.service")
        local Repo = require("bookmarks.domain.repo")
        local Sign = require("bookmarks.sign")

        -- Use git root if available, otherwise cwd
        local git_root = vim.fn.system("git -C " .. vim.fn.shellescape(vim.fn.getcwd()) .. " rev-parse --show-toplevel 2>/dev/null")
        git_root = vim.trim(git_root)
        local project = vim.fn.fnamemodify(git_root ~= "" and git_root or vim.fn.getcwd(), ":t")

        -- Find existing list with this name
        local lists = Repo.find_lists and Repo.find_lists() or {}
        for _, list in ipairs(lists) do
          if list.name == project then
            Service.set_active_list(list.id)
            Sign.safe_refresh_signs()
            vim.notify("Switched to list: " .. project, vim.log.levels.INFO)
            return
          end
        end

        -- Create new list and set it active
        Service.create_list(project)
        vim.notify("Created list: " .. project, vim.log.levels.INFO)
      end,
      desc = "Bookmark workspace (project list)",
    },
  },
  config = function()
    require("bookmarks").setup({
      signs = {
        mark = {
          icon = "󰃁",
          color = "red",
          line_bg = "#572626",
        },
      },
      picker = {
        sort_by = "last_visited",
      },
      treeview = {
        window_split_dimension = 35,
      },
    })
  end,
}
