return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
  },
  init = function()
    local notes_path = vim.fn.expand("~/projects/personal/notes")
    local daily_folder = "private/daily"

    local function is_in_notes()
      local cwd = vim.fn.getcwd()
      local file_path = vim.fn.expand("%:p")
      return cwd:find(notes_path, 1, true) == 1 or file_path:find(notes_path, 1, true) == 1
    end

    local function obs_cmd(cmd, prompt)
      return function()
        if is_in_notes() then
          require("lazy").load({ plugins = { "obsidian.nvim" } })
          if prompt then
            vim.ui.input({ prompt = prompt }, function(input)
              if input and input ~= "" then
                vim.cmd(cmd .. " " .. input)
              end
            end)
          else
            vim.cmd(cmd)
          end
        else
          vim.notify("Not in Obsidian workspace", vim.log.levels.WARN)
        end
      end
    end

    -- Function to open/create daily note for a given date
    local function open_daily_note(target_date)
      local target_time_str = os.date("%H:%M")
      local daily_path = notes_path .. "/" .. daily_folder .. "/" .. target_date .. ".md"

      -- If file exists, just open it
      if vim.fn.filereadable(daily_path) == 1 then
        vim.cmd("edit " .. daily_path)
        return
      end

      -- Build frontmatter
      local frontmatter = table.concat({
        "---",
        'id: "' .. target_date .. '"',
        "aliases: []",
        "tags:",
        "  - daily-notes",
        "---",
        "",
      }, "\n")

      -- Read template and substitute date/time
      local template_path = notes_path .. "/templates/daily-note.md"
      local template = vim.fn.readfile(template_path)
      local content = table.concat(template, "\n")
      content = content:gsub("{{date}}", target_date)
      content = content:gsub("{{time}}", target_time_str)

      -- Combine frontmatter + template content
      local full_content = frontmatter .. content

      -- Write new file and open it
      local lines = vim.split(full_content, "\n")
      vim.fn.writefile(lines, daily_path)
      vim.cmd("edit " .. daily_path)
    end

    -- Calendar picker for daily notes
    local function open_calendar_picker()
      if not is_in_notes() then
        vim.notify("Not in Obsidian workspace", vim.log.levels.WARN)
        return
      end

      -- Get existing daily notes
      local daily_dir = notes_path .. "/" .. daily_folder
      local existing_notes = {}
      local files = vim.fn.glob(daily_dir .. "/*.md", false, true)
      for _, file in ipairs(files) do
        local date = vim.fn.fnamemodify(file, ":t:r")
        existing_notes[date] = true
      end

      -- Calendar state
      local current = os.date("*t")
      local view_year = current.year
      local view_month = current.month
      local selected_day = current.day

      local buf = vim.api.nvim_create_buf(false, true)
      local width = 28
      local height = 12

      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = "minimal",
        border = "single",
        title = " Daily Note Calendar ",
        title_pos = "center",
      })

      -- Highlight groups
      vim.api.nvim_set_hl(0, "CalendarHeader", { fg = "#7aa2f7", bold = true })
      vim.api.nvim_set_hl(0, "CalendarToday", { fg = "#1a1b26", bg = "#7aa2f7", bold = true })
      vim.api.nvim_set_hl(0, "CalendarSelected", { fg = "#1a1b26", bg = "#bb9af7", bold = true })
      vim.api.nvim_set_hl(0, "CalendarHasNote", { fg = "#9ece6a", bold = true })
      vim.api.nvim_set_hl(0, "CalendarWeekend", { fg = "#f7768e" })
      vim.api.nvim_set_hl(0, "CalendarDay", { fg = "#c0caf5" })

      local function render_calendar()
        local lines = {}
        local highlights = {}

        -- Month/Year header
        local month_names = { "January", "February", "March", "April", "May", "June",
          "July", "August", "September", "October", "November", "December" }
        local header = string.format("  < %s %d >  ", month_names[view_month], view_year)
        local header_padding = string.rep(" ", math.floor((width - #header) / 2))
        table.insert(lines, header_padding .. header)
        table.insert(highlights, { line = 0, col = 0, end_col = width, hl = "CalendarHeader" })

        table.insert(lines, "")
        table.insert(lines, "  Su Mo Tu We Th Fr Sa  ")
        table.insert(highlights, { line = 2, col = 2, end_col = 4, hl = "CalendarWeekend" })
        table.insert(highlights, { line = 2, col = 20, end_col = 22, hl = "CalendarWeekend" })

        -- Get first day of month and days in month
        local first_day = os.time({ year = view_year, month = view_month, day = 1 })
        local first_wday = tonumber(os.date("%w", first_day)) + 1 -- 1=Sunday
        local days_in_month = tonumber(os.date("%d", os.time({ year = view_year, month = view_month + 1, day = 0 })))

        local day = 1
        local line_num = 3
        while day <= days_in_month do
          local week_line = "  "
          for wday = 1, 7 do
            if (line_num == 3 and wday < first_wday) or day > days_in_month then
              week_line = week_line .. "   "
            else
              local day_str = string.format("%2d ", day)
              local col_start = 2 + (wday - 1) * 3
              local date_str = string.format("%04d-%02d-%02d", view_year, view_month, day)

              local is_today = (day == current.day and view_month == current.month and view_year == current.year)
              local is_selected = (day == selected_day)
              local has_note = existing_notes[date_str]

              if is_selected then
                table.insert(highlights, { line = line_num, col = col_start, end_col = col_start + 2, hl = "CalendarSelected" })
              elseif is_today then
                table.insert(highlights, { line = line_num, col = col_start, end_col = col_start + 2, hl = "CalendarToday" })
              elseif has_note then
                table.insert(highlights, { line = line_num, col = col_start, end_col = col_start + 2, hl = "CalendarHasNote" })
              elseif wday == 1 or wday == 7 then
                table.insert(highlights, { line = line_num, col = col_start, end_col = col_start + 2, hl = "CalendarWeekend" })
              end

              week_line = week_line .. day_str
              day = day + 1
            end
          end
          table.insert(lines, week_line)
          line_num = line_num + 1
        end

        -- Footer with instructions
        table.insert(lines, "")
        table.insert(lines, " hjkl/arrows:nav </>:mon ")
        table.insert(lines, " <CR>:select  q:close    ")

        vim.api.nvim_buf_set_option(buf, "modifiable", true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)

        -- Apply highlights
        for _, hl in ipairs(highlights) do
          vim.api.nvim_buf_add_highlight(buf, -1, hl.hl, hl.line, hl.col, hl.end_col)
        end
      end

      local function days_in_current_month()
        return tonumber(os.date("%d", os.time({ year = view_year, month = view_month + 1, day = 0 })))
      end

      local function move_day(delta)
        selected_day = selected_day + delta
        local dim = days_in_current_month()
        if selected_day < 1 then
          view_month = view_month - 1
          if view_month < 1 then
            view_month = 12
            view_year = view_year - 1
          end
          selected_day = days_in_current_month() + selected_day
        elseif selected_day > dim then
          selected_day = selected_day - dim
          view_month = view_month + 1
          if view_month > 12 then
            view_month = 1
            view_year = view_year + 1
          end
        end
        render_calendar()
      end

      local function move_month(delta)
        view_month = view_month + delta
        if view_month < 1 then
          view_month = 12
          view_year = view_year - 1
        elseif view_month > 12 then
          view_month = 1
          view_year = view_year + 1
        end
        local dim = days_in_current_month()
        if selected_day > dim then
          selected_day = dim
        end
        render_calendar()
      end

      local function select_date()
        local date_str = string.format("%04d-%02d-%02d", view_year, view_month, selected_day)
        vim.api.nvim_win_close(win, true)
        open_daily_note(date_str)
      end

      -- Keymaps
      local opts = { buffer = buf, nowait = true }
      vim.keymap.set("n", "h", function() move_day(-1) end, opts)
      vim.keymap.set("n", "l", function() move_day(1) end, opts)
      vim.keymap.set("n", "j", function() move_day(7) end, opts)
      vim.keymap.set("n", "k", function() move_day(-7) end, opts)
      vim.keymap.set("n", "<Left>", function() move_day(-1) end, opts)
      vim.keymap.set("n", "<Right>", function() move_day(1) end, opts)
      vim.keymap.set("n", "<Down>", function() move_day(7) end, opts)
      vim.keymap.set("n", "<Up>", function() move_day(-7) end, opts)
      vim.keymap.set("n", "<", function() move_month(-1) end, opts)
      vim.keymap.set("n", ">", function() move_month(1) end, opts)
      vim.keymap.set("n", "<CR>", select_date, opts)
      vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, opts)
      vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, opts)

      render_calendar()
    end

    vim.keymap.set("n", "<leader>on", obs_cmd("ObsidianNew"), { desc = "New note" })
    vim.keymap.set("n", "<leader>oo", obs_cmd("ObsidianQuickSwitch"), { desc = "Quick switch" })
    vim.keymap.set("n", "<leader>os", obs_cmd("ObsidianSearch"), { desc = "Search notes" })
    vim.keymap.set("n", "<leader>od", obs_cmd("ObsidianToday"), { desc = "Today's daily note" })
    vim.keymap.set("n", "<leader>of", open_calendar_picker, { desc = "Daily note (calendar)" })
    vim.keymap.set("n", "<leader>oy", obs_cmd("ObsidianYesterday"), { desc = "Yesterday's daily note" })
    vim.keymap.set("n", "<leader>ob", obs_cmd("ObsidianBacklinks"), { desc = "Backlinks" })
    vim.keymap.set("n", "<leader>ol", obs_cmd("ObsidianLinks"), { desc = "Links in current note" })
    vim.keymap.set("n", "<leader>ot", obs_cmd("ObsidianTemplate"), { desc = "Insert template" })
    vim.keymap.set("n", "<leader>op", obs_cmd("ObsidianPasteImg"), { desc = "Paste image" })
  end,
  opts = {
    workspaces = {
      {
        name = "notes",
        path = "~/projects/personal/notes",
      },
    },
    daily_notes = {
      folder = "private/daily",
      date_format = "%Y-%m-%d",
      template = "daily-note.md",
    },
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },
    notes_subdir = "private/slipbox",
    new_notes_location = "notes_subdir",
    picker = {
      name = "fzf-lua",
    },
    completion = {
      nvim_cmp = false,
      min_chars = 2,
    },
    mappings = {
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ["<cr>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },
    ui = {
      enable = true,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
      },
    },
    follow_url_func = function(url)
      vim.fn.jobstart({ "xdg-open", url })
    end,
  },
}
