local M = {}

local ns = vim.api.nvim_create_namespace("clingo")
local timers = {}
local cmp_done = false

local DIRECTIVES = {
  { label = "#show", snippet = "show ${1:p/n}.\n$0", doc = "Show atoms/terms in output" },
  { label = "#const", snippet = "const ${1:c} = ${2:t}.\n$0", doc = "Define constant" },
  { label = "#external", snippet = "external ${1:A}.\n$0", doc = "Declare external atom" },
  { label = "#program", snippet = "program ${1:p}.\n$0", doc = "Begin program part" },
  { label = "#include", snippet = 'include "${1:file}".\n$0', doc = "Include file" },
  { label = "#minimize", snippet = "minimize{${1:w}@${2:p},${3:t} : ${4:L}}.\n$0", doc = "Minimization constraint" },
  { label = "#maximize", snippet = "maximize{${1:w}@${2:p},${3:t} : ${4:L}}.\n$0", doc = "Maximization constraint" },
  { label = "#edge", snippet = "edge(${1:u},${2:v}).\n$0", doc = "Edge directive" },
  { label = "#heuristic", snippet = "heuristic ${1:A} : ${2:B}. [${3:w}@${4:p},${5:m}]$0", doc = "Domain-specific heuristic" },
  { label = "#project", snippet = "project ${1:p/n}.\n$0", doc = "Project atoms" },
  { label = "#defined", snippet = "defined ${1:p/n}.\n$0", doc = "Mark predicate as externally defined" },
  { label = "#script", snippet = "script ${1:python}\n$0\n#end.", doc = "Embedded script block" },
  { label = "#theory", snippet = "theory ${1:t} {\n$0\n}.\n", doc = "Theory atom specification" },
}

local BUILTINS = {
  { label = "#count", snippet = "count{${1:t} : ${2:L}}$0", doc = "Count aggregate" },
  { label = "#sum", snippet = "sum{${1:w},${2:t} : ${3:L}}$0", doc = "Sum aggregate" },
  { label = "#sum+", snippet = "sum+{${1:w},${2:t} : ${3:L}}$0", doc = "Sum positive aggregate" },
  { label = "#min", snippet = "min{${1:w},${2:t} : ${3:L}}$0", doc = "Min aggregate" },
  { label = "#max", snippet = "max{${1:w},${2:t} : ${3:L}}$0", doc = "Max aggregate" },
  { label = "#inf", snippet = "inf$0", doc = "Infimum constant" },
  { label = "#sup", snippet = "sup$0", doc = "Supremum constant" },
  { label = "#true", snippet = "true$0", doc = "Boolean true" },
  { label = "#false", snippet = "false$0", doc = "Boolean false" },
  { label = "not", snippet = "not $0", doc = "Default negation" },
}

local function has_clingo()
  return vim.fn.executable("clingo") == 1
end

local function get_parser(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "clingo")
  if not ok then return nil end
  parser:parse()
  return parser
end

local function get_arity(symbolic_atom_node)
  local arity = 0
  local args = symbolic_atom_node:field("arguments")
  if args then
    for _, terms_node in ipairs(args) do
      arity = arity + terms_node:named_child_count()
    end
  end
  return arity
end

local function get_field_node(node, field_name)
  local fields = node:field(field_name)
  if fields and fields[1] then
    return fields[1]
  end
  return nil
end

local function parse_clingo_stderr(stderr)
  local diags = {}
  local pattern = "^(.-):(%d+):(%d+)-(%d+):%s*(%a+):%s*(.+)$"
  for line in stderr:gmatch("[^\n]+") do
    local _, lineno, scol, ecol, severity, msg = line:match(pattern)
    if lineno then
      local l = tonumber(lineno) - 1
      local sc = tonumber(scol) - 1
      local ec = tonumber(ecol) - 1
      local sev
      if severity == "error" then
        sev = vim.diagnostic.severity.ERROR
      elseif severity == "warning" then
        sev = vim.diagnostic.severity.WARN
      else
        sev = vim.diagnostic.severity.INFO
      end
      table.insert(diags, {
        lnum = l, col = sc, end_lnum = l, end_col = ec,
        severity = sev, message = msg, source = "clingo",
      })
    end
  end
  return diags
end

local function run_clingo(bufnr, ts_diags)
  if not has_clingo() or not vim.api.nvim_buf_is_valid(bufnr) then return end
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local tmp = os.tmpname()
  local f = io.open(tmp, "w")
  if not f then return end
  f:write(table.concat(lines, "\n"))
  f:close()
  vim.system({ "clingo", "--text", tmp }, { stdout = false, stderr = true }, function(obj)
    os.remove(tmp)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      local clingo_diags = parse_clingo_stderr(obj.stderr or "")
      local merged = {}
      for _, d in ipairs(ts_diags) do table.insert(merged, d) end
      for _, d in ipairs(clingo_diags) do table.insert(merged, d) end
      vim.diagnostic.set(ns, bufnr, merged)
    end)
  end)
end

local function walk_ts_errors(node, diags)
  if not node:has_error() then return end
  if node:type() == "ERROR" then
    local sr, sc, er, ec = node:range()
    table.insert(diags, {
      lnum = sr, col = sc, end_lnum = er, end_col = ec,
      severity = vim.diagnostic.severity.ERROR,
      message = "syntax error", source = "tree-sitter",
    })
  elseif node:missing() then
    local sr, sc, er, ec = node:range()
    table.insert(diags, {
      lnum = sr, col = sc, end_lnum = er, end_col = ec,
      severity = vim.diagnostic.severity.ERROR,
      message = "expected: " .. node:type(), source = "tree-sitter",
    })
  end
  for i = 0, node:named_child_count() - 1 do
    walk_ts_errors(node:named_child(i), diags)
  end
end

local function ts_diagnostics(bufnr)
  local parser = get_parser(bufnr)
  if not parser then return {} end
  local root = parser:trees()[1]:root()
  local diags = {}
  walk_ts_errors(root, diags)
  return diags
end

local function debounce_diagnostics(bufnr)
  if timers[bufnr] then
    timers[bufnr]:stop()
    timers[bufnr]:close()
  end
  timers[bufnr] = vim.uv.new_timer()
  timers[bufnr]:start(300, 0, vim.schedule_wrap(function()
    if timers[bufnr] then timers[bufnr]:close() end
    timers[bufnr] = nil
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    local diags = ts_diagnostics(bufnr)
    vim.diagnostic.set(ns, bufnr, diags)
    if has_clingo() then
      run_clingo(bufnr, diags)
    end
  end))
end

local function get_predicates(bufnr)
  local parser = get_parser(bufnr)
  if not parser then return {} end
  local root = parser:trees()[1]:root()
  local preds = {}
  local seen = {}
  local ok, query = pcall(vim.treesitter.query.parse, "clingo", [[
    (symbolic_atom name: (identifier) @name)
  ]])
  if not ok then return {} end
  for _, node in query:iter_captures(root, bufnr) do
    local name = vim.treesitter.get_node_text(node, bufnr)
    local parent = node:parent()
    if parent and parent:type() == "symbolic_atom" then
      local arity = get_arity(parent)
      local key = name .. "/" .. arity
      if not seen[key] then
        seen[key] = true
        table.insert(preds, { name = name, arity = arity })
      end
    end
  end
  return preds
end

local function get_variables(bufnr, row)
  local parser = get_parser(bufnr)
  if not parser then return {} end
  local root = parser:trees()[1]:root()
  local node = root:descendant_for_range(row, 0, row, 999)
  if not node then return {} end
  while node and node:parent() and node:type() ~= "rule" and node:type() ~= "weak_constraint" and node:type() ~= "integrity_constraint" do
    node = node:parent()
  end
  if not node then return {} end
  local vars = {}
  local seen = {}
  local ok, query = pcall(vim.treesitter.query.parse, "clingo", [[
    (variable) @var
  ]])
  if not ok then return {} end
  for _, var_node in query:iter_captures(node, bufnr) do
    local name = vim.treesitter.get_node_text(var_node, bufnr)
    if not seen[name] then
      seen[name] = true
      table.insert(vars, name)
    end
  end
  return vars
end

local function get_doc_comments(bufnr)
  local parser = get_parser(bufnr)
  if not parser then return {} end
  local root = parser:trees()[1]:root()
  local docs = {}
  local ok, query = pcall(vim.treesitter.query.parse, "clingo", [[
    (line_comment) @comment
  ]])
  if not ok then return {} end
  local current_pred = nil
  for _, node in query:iter_captures(root, bufnr) do
    local text = vim.treesitter.get_node_text(node, bufnr)
    local doc_line = text:match("^%%!%s*(.*)$")
    if doc_line then
      local name, desc = doc_line:match("^(%a[%w_]*)%s*:%s*(.*)$")
      if name and name:match("^%u") then
        if current_pred and docs[current_pred] then
          table.insert(docs[current_pred].args, { name = name, desc = desc })
        end
      elseif name then
        current_pred = name
        docs[name] = { description = desc, args = {} }
      end
    else
      current_pred = nil
    end
  end
  -- Trailing comments: `fact(...). % description` documents the head predicate.
  -- In the tree these are line_comment siblings following a rule on the same row.
  for i = 0, root:named_child_count() - 2 do
    local node = root:named_child(i)
    if node:type() == "rule" then
      local head = get_field_node(node, "head")
      local atom = head and get_field_node(head, "atom")
      local name_node = atom and get_field_node(atom, "name")
      if name_node then
        local name = vim.treesitter.get_node_text(name_node, bufnr)
        local _, _, erow = node:range()
        local sib = root:named_child(i + 1)
        if not docs[name] and sib:type() == "line_comment" then
          local srow = sib:range()
          if srow == erow then
            local desc = vim.treesitter.get_node_text(sib, bufnr):match("^%%%s*(.*)$") or ""
            docs[name] = { description = desc, args = {} }
          end
        end
      end
    end
  end
  return docs
end

local function find_predicate_ref(bufnr, row, col)
  local parser = get_parser(bufnr)
  if not parser then return nil end
  local root = parser:trees()[1]:root()
  local node = root:descendant_for_range(row, col, row, col)
  while node and node:type() ~= "symbolic_atom" and node:type() ~= "signature" do
    node = node:parent()
  end
  if not node then return nil end
  local name_node = get_field_node(node, "name")
  if not name_node then return nil end
  local name = vim.treesitter.get_node_text(name_node, bufnr)
  local arity
  if node:type() == "signature" then
    local arity_node = get_field_node(node, "arity")
    arity = arity_node and tonumber(vim.treesitter.get_node_text(arity_node, bufnr)) or 0
  else
    arity = get_arity(node)
  end
  return { name = name, arity = arity }
end

local function show_hover(bufnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local ref = find_predicate_ref(bufnr, row, col)
  if not ref then return end
  local docs = get_doc_comments(bufnr)
  local doc = docs[ref.name]
  local lines = { "**" .. ref.name .. "/" .. ref.arity .. "**", "" }
  if doc then
    if doc.description and doc.description ~= "" then
      for line in doc.description:gmatch("[^\n]+") do
        table.insert(lines, line)
      end
    end
    if #doc.args > 0 then
      table.insert(lines, "")
      table.insert(lines, "Parameters:")
      for _, arg in ipairs(doc.args) do
        local line = "- `" .. arg.name .. "`"
        if arg.desc and arg.desc ~= "" then
          line = line .. ": " .. arg.desc
        end
        table.insert(lines, line)
      end
    end
  else
    table.insert(lines, "No documentation available.")
  end
  vim.lsp.util.open_floating_preview(lines, "markdown", {
    border = "rounded",
    close_events = { "CursorMoved", "BufLeave", "InsertEnter", "FocusLost" },
  })
end

local function goto_definition(bufnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local ref = find_predicate_ref(bufnr, row, col)
  if not ref then return end
  local name = ref.name
  local parser = get_parser(bufnr)
  if not parser then return end
  local root = parser:trees()[1]:root()
  local ok, query = pcall(vim.treesitter.query.parse, "clingo", [[
    (rule head: (literal atom: (symbolic_atom name: (identifier) @head_name)))
  ]])
  if not ok then return end
  for _, head_node in query:iter_captures(root, bufnr) do
    if vim.treesitter.get_node_text(head_node, bufnr) == name then
      local srow, scol = head_node:start()
      vim.api.nvim_buf_set_mark(bufnr, "'", row + 1, col, {})
      vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
      return
    end
  end
  vim.notify("No definition found for: " .. name, vim.log.levels.INFO)
end

local function get_completion_items(bufnr, base)
  local items = {}
  if base:match("^#") then
    for _, kw in ipairs(DIRECTIVES) do
      if kw.label:find(base, 1, true) then
        table.insert(items, {
          label = kw.label,
          insertText = kw.snippet,
          insertTextFormat = 2,
          kind = 14,
          detail = kw.doc,
        })
      end
    end
    for _, kw in ipairs(BUILTINS) do
      if kw.label:find(base, 1, true) then
        table.insert(items, {
          label = kw.label,
          insertText = kw.snippet,
          insertTextFormat = 2,
          kind = 14,
          detail = kw.doc,
        })
      end
    end
  end
  for _, pred in ipairs(get_predicates(bufnr)) do
    if pred.name:find(base, 1, true) then
      local args = {}
      for i = 1, pred.arity do
        table.insert(args, "${" .. i .. ":arg" .. i .. "}")
      end
      table.insert(items, {
        label = pred.name,
        insertText = pred.name .. "(" .. table.concat(args, ", ") .. ")$0",
        insertTextFormat = 2,
        kind = 3,
        detail = pred.name .. "/" .. pred.arity,
      })
    end
  end
  local row = vim.fn.line(".") - 1
  for _, var in ipairs(get_variables(bufnr, row)) do
    if var:find(base, 1, true) then
      table.insert(items, {
        label = var,
        kind = 6,
        detail = "variable",
      })
    end
  end
  return items
end

M.omnifunc = function(findstart, base)
  if findstart == 1 then
    local line = vim.fn.getline(".")
    local col = vim.fn.col(".") - 1
    while col > 0 and line:sub(col, col):match("[%w_#]") do
      col = col - 1
    end
    return col
  else
    local bufnr = vim.api.nvim_get_current_buf()
    local items = get_completion_items(bufnr, base)
    local vim_items = {}
    for _, item in ipairs(items) do
      table.insert(vim_items, {
        word = item.label,
        menu = item.detail or "",
        kind = item.kind == 3 and "f" or item.kind == 6 and "v" or "k",
        icase = 1,
      })
    end
    return vim_items
  end
end

function M.setup(bufnr)
  local group = vim.api.nvim_create_augroup("ClingoLSP_" .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost" }, {
    group = group,
    buffer = bufnr,
    callback = function() debounce_diagnostics(bufnr) end,
  })
  vim.api.nvim_create_autocmd("BufUnload", {
    group = group,
    buffer = bufnr,
    callback = function()
      if timers[bufnr] then
        timers[bufnr]:stop()
        timers[bufnr]:close()
        timers[bufnr] = nil
      end
      vim.diagnostic.reset(ns, bufnr)
    end,
  })
  debounce_diagnostics(bufnr)
  vim.bo[bufnr].omnifunc = "v:lua.require('clingo_lsp').omnifunc"
  if not cmp_done then
    cmp_done = true
    local ok, cmp = pcall(require, "cmp")
    if ok then
      local source = {}
      function source:is_available() return true end
      function source:complete(params, callback)
        local line = params.context.cursor_line
        local col = params.context.cursor.col
        local base = line:sub(col, col):match("[%w_#]") and line:sub(1, col):match("[%w_#]*$") or ""
        callback(get_completion_items(vim.api.nvim_get_current_buf(), base))
      end
      cmp.register_source("clingo", source)
      cmp.setup.filetype("clingo", {
        sources = cmp.config.sources({ { name = "clingo" }, { name = "buffer" } }),
      })
    end
  end
  vim.keymap.set("n", "K", function() show_hover(bufnr) end, { buffer = bufnr, desc = "Clingo hover" })
  vim.keymap.set("n", "gd", function() goto_definition(bufnr) end, { buffer = bufnr, desc = "Clingo go to definition" })
end

M._get_predicates = get_predicates
M._get_doc_comments = get_doc_comments
M._show_hover = show_hover
M._goto_definition = goto_definition

return M
