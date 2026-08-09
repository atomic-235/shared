---
name: lua
description: >
  Use when writing, editing, or reviewing Lua code. Covers general Lua coding
  best practices: module structure, variable naming, function definitions,
  string handling, table usage, error handling, scope management, performance
  idioms, code formatting, Lua-specific idioms, and critical pitfalls.
  Applies to any Lua project regardless of domain (Hyprland, Neovim, AwesomeWM,
  LuaRocks packages, embedded scripting, etc.).
---

# Lua Coding Best Practices

## Lua is a family of dialects

Lua 5.1/LuaJIT, 5.2, 5.3, 5.4, 5.5, and Luau are **incompatible** in features.
Always know your target dialect before writing code.

| Dialect | Key features | Used by |
|---------|-------------|---------|
| 5.1 / LuaJIT | No integer/float split, no goto, no `_ENV` | Neovim (legacy), LuaJIT projects, World of Warcraft |
| 5.2 | `_ENV`, no `goto` yet | Rare in embedded |
| 5.3 | Integer/float split, `//` floor division, bitwise ops | General use |
| 5.4 | `<const>` and `<close>` attributes | Hyprland (5.5), modern projects |
| 5.5 | Latest stable | Hyprland 0.56.1+ |
| Luau | Gradual typing, `continue`, string interpolation | Roblox, some game engines |

---

## 1. Always use `local`

Locals are register-accessed (array index into activation record). Globals are
`_ENV` table lookups (hash string key, traverse environment table). Locals are
both faster and safer (no accidental global pollution).

```lua
-- GOOD
local function process(data)
  local result = transform(data)
  return result
end

-- BAD: leaks into global scope
function process(data)
  result = transform(data)  -- global!
  return result
end
```

---

## 2. Function definitions: `local function f()` as default

`local function f()` pre-declares the local, enabling recursion with zero
downside. Use `local f = function()` only when you need an anonymous function
assigned to a local (non-recursive).

```lua
-- PREFERRED: enables recursion, no downside
local function factorial(n)
  return n <= 1 and 1 or n * factorial(n - 1)
end

-- Anonymous function assigned to local (non-recursive, fine)
local greet = function(name) return "hi " .. name end

-- Forward declarations for mutual recursion
local is_even, is_odd

function is_even(n) return n == 0 or is_odd(n - 1) end
function is_odd(n)  return n == 1 or is_even(n - 1) end
```

---

## 3. Module structure

Define modules as a local table, populate it, return it. Never use the
deprecated `module()` function.

```lua
-- foo/bar.lua
local bar = {}

local function helper() end  -- private, not exported

function bar.public_method(greeting)
  print(greeting)
end

return bar
```

Require with parentheses and a meaningful local name:

```lua
local bar = require("foo.bar")  -- good
-- NOT: local b = require "foo.bar"  -- bad: renamed + no parens
```

---

## 4. Scope management: `do...end` blocks

`do...end` introduces a lexical scope boundary without a function call. Locals
declared inside go out of scope at `end`, allowing register reuse. Zero call
overhead — same stack frame.

```lua
local get_id
do
  local last_id = 0
  function get_id()
    last_id = last_id + 1
    return last_id
  end
end  -- last_id not accessible outside, but captured by closure
```

Declare variables with the smallest possible scope, not all at the top:

```lua
local function process(data)
  local result = transform(data)  -- declare when needed
  if result == nil then return nil end
  return validate(result)
end
```

---

## 5. Variable naming conventions

No community-wide standard. Each major project defines its own. Pick one and be
consistent.

| Convention | Used by |
|------------|---------|
| `snake_case` functions/vars | LuaRocks, Neovim, Luanti |
| `camelCase` functions/vars | Roblox/Luau, MediaWiki |
| `UPPER_CASE` constants | Near-universal |
| `PascalCase` classes/types | Roblox/Luau, Luanti |

Recommended defaults: `snake_case` for functions/variables, `UPPER_CASE` for
constants, `is_`/`has_` prefix for boolean functions, `_` for intentionally
ignored variables.

---

## 6. String handling

### Quotes

No community standard. Double quotes `"..."` is most common (LuaRocks, Roblox,
Luanti). Single quotes `'...'` preferred by Neovim. **Pick one and be
consistent.** Use the other when the string contains your default quote
character — avoid escaping.

### Concatenation

Use `table.concat` for building strings in loops. `..` is fine for short
one-off concatenation.

```lua
-- GOOD: O(N) — single allocation
local parts = {}
for i = 1, 1000 do parts[i] = tostring(i) end
local result = table.concat(parts, ",")

-- BAD: O(N²) — each iteration copies entire accumulated string
local s = ""
for i = 1, 1000 do s = s .. tostring(i) .. "," end
```

**Why:** Lua strings are immutable and interned. Each `..` allocates a new
string copying both operands. `table.concat` collects pointers then does one
C-level allocation. The VM optimizes single-line chains (`a .. b .. c`) but
cannot see across loop iterations.

### Multi-line strings

```lua
local sql = [[
  SELECT * FROM users WHERE name = 'test'
]]

-- Use [==[ ]==] when content contains ]]
local sql = [==[
  SELECT * FROM users WHERE name = ']]'
]==]
```

---

## 7. Table usage

Arrays are **1-indexed**. `ipairs` for arrays, `pairs` for dictionaries.

```lua
-- array iteration (ordered, 1 to n)
for i, v in ipairs(arr) do print(i, v) end

-- dictionary iteration (unordered)
for k, v in pairs(dict) do print(k, v) end
```

### Appending

```lua
t[#t + 1] = v       -- faster
table.insert(t, v)   -- clearer
```

### Holes

Never create holes (nil gaps) in sequence tables. `#t` returns *a* boundary
but with holes it's non-deterministic. Use `false` as a sentinel for "present
but no value":

```lua
t[3] = false  -- not nil — preserves sequence integrity
```

**Why:** Lua tables have a dual structure (array part + hash part). `#` finds a
boundary where `t[i]` is non-nil and `t[i+1]` is nil — with holes, multiple
boundaries exist, making `#t` unspecified.

### Trailing commas

Acceptable in multi-line tables:

```lua
local config = {
  name = "foo",
  timeout = 5000,
}
```

---

## 8. Error handling

| Tool | Use case |
|------|----------|
| `pcall` | Catch errors from risky operations |
| `assert` | Validate preconditions |
| `error(msg, level)` | Throw with controlled error position |
| `xpcall` | Protected call with traceback |

```lua
-- pcall: catch errors from risky operations
local ok, result = pcall(function()
  return risky_operation()
end)
if not ok then
  print("Error: " .. result)  -- result is the error message
  return nil, result
end

-- assert: validate preconditions
assert(type(name) == "string", "name must be a string")

-- error with level: blame the caller, not your function
function foo(str)
  if type(str) ~= "string" then
    error("string expected, got " .. type(str), 2)  -- level 2 = caller
  end
end
```

**Convention:** Return `nil, err_msg` for expected failures (caller handles
gracefully). Throw `error()` for API misuse/programming errors (caller
shouldn't catch).

---

## 9. Performance idioms

### Localize library functions at module scope (safe, helps PUC Lua)

```lua
local t_concat = table.concat
local s_format = string.format
local m_floor = math.floor
```

### Cache table lookups in hot paths

```lua
local config = a.b.c.config
for i = 1, #items do
  process(items[i], config.timeout)
end
```

### LuaJIT caveat

Under LuaJIT, manual hoisting inside hot loops can **prevent** trace
compilation. The JIT compiler does its own constant folding and CSE. Localize
at module scope (safe), but don't micro-optimize inside hot loops without
profiling first.

### Version-specific notes

| Feature | Lua 5.1/LuaJIT | 5.3+ | 5.4+ |
|---------|---------------|------|------|
| Integer/float split | No (all doubles) | Yes | Yes |
| `//` floor division | Error | Works | Works |
| Bitwise operators (`& \| ~ << >>`) | Error | Works | Works |
| `<const>` attribute | N/A | N/A | Yes |
| `<close>` attribute | N/A | N/A | Yes |
| `goto`/labels | LuaJIT only | 5.2+ | Yes |

### LuaJIT-specific

- `pairs`/`next` is NOT JIT-compiled (only `ipairs` and numeric `for` get traces)
- C calls (`string.format`, stdlib functions) break traces
- Closure creation (`FNEW`) is never JIT-compiled

---

## 10. Lua idioms

### Default values: `x or default`

Only `nil` and `false` are falsy in Lua. `0`, `""`, `{}` are all truthy.

```lua
local port = config.port or 8080  -- nil -> default
```

### Ternary simulation (use with caution)

```lua
-- SAFE: "active" is truthy
local label = is_active and "active" or "inactive"

-- DANGER: breaks when middle value can be falsy
local val = is_admin and false or true  -- ALWAYS returns true! BUG!
```

**Why:** `and`/`or` are value-returning expressions, not boolean operators.
`a and b` returns `a` if `a` is falsy, else `b`. `a or b` returns `a` if `a`
is truthy, else `b`. `x and y or z` = ternary ONLY when `y` is guaranteed
truthy.

### Array length and emptiness

```lua
#t                        -- array length (unsafe with holes)
next(t) == nil            -- table is empty (including non-integer keys)
```

### OOP via metatables

```lua
local Animal = {}
Animal.__index = Animal  -- class looks up methods here

function Animal.new(sound)
  local self = setmetatable({}, Animal)
  self.sound = sound
  return self
end

function Animal:speak()  -- : passes self automatically
  return self.sound
end

-- usage
local dog = Animal.new("woof")
print(dog:speak())  -- "woof"
```

**Why:** `__index` is a *fallback* — fires only when a key is absent from the
table. All instances share one metatable (one method table), making it O(1)
per instance pointer. More efficient than closures for many instances.

### Closures as objects (true privacy)

```lua
local function make_counter()
  local count = 0  -- truly private, no way to access from outside
  return {
    increment = function() count = count + 1; return count end,
    reset = function() count = 0 end,
  }
end
```

**Tradeoff:** Closures give encapsulation but create per-instance function
overhead. Metatables share methods but expose all fields. Choose based on need.

### Tail call optimization

Lua guarantees proper tail calls. Use for state machines and recursion without
stack growth:

```lua
function state_machine(state)
  return handlers[state]()  -- proper tail call — no stack growth
end
```

---

## 11. Code formatting

No community-wide standard. No semicolons is near-universal. Everything else
varies.

| Aspect | Recommended default |
|--------|-------------------|
| Indentation | 2 spaces |
| Quotes | Double `"..."` |
| Line length | 80-100 chars |
| Semicolons | Don't use them |
| Trailing commas | Acceptable in multi-line tables |
| Vertical alignment | Discouraged (creates noisy diffs) |

### Tooling

- `luacheck` — standard linter (catches unused vars, undefined globals, redefined locals)
- StyLua — auto-formatter
- lua-format — auto-formatter

---

## 12. Critical pitfalls

### `and`/`or` ternary breaks with falsy middle value

```lua
local val = is_admin and false or true  -- ALWAYS returns true! BUG!
```

### No native Unicode support

`string.len` counts **bytes**, not characters. `string.upper`/`string.lower`
are ASCII-only. Use `utf8` library (5.3+) or `luautf8` for Unicode.

### Lua patterns are NOT regex

No alternation (`|`), limited captures. Don't expect PCRE behavior.

```lua
-- Lua pattern: character classes, no |
string.match("foo", "[a-z]+")  -- works
string.match("foo", "foo|bar") -- does NOT work — | is literal
```

### `#t` with holes is unspecified

Multiple nil boundaries exist, result is non-deterministic. Use `false` as
sentinel, not `nil`.

### Lua 5.4+ attributes

```lua
local PI <const> = 3.14159  -- can't reassign
local file <close> = io.open("data.txt")  -- auto-closed when out of scope
```

### Sandboxing

For embedded scripting, use `load` with custom `_ENV` to restrict access:

```lua
local sandbox = { print = print, math = math }
local fn = load(chunk, "sandbox", "t", sandbox)
-- loaded code can only access sandbox globals
```
