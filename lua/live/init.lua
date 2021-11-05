local M = {}

local allowed_commands = {
  "norm",
  "d",
  "m",
  "pu",
  ""
}

local function startswith(str, prefix)
  return str:sub(1, #prefix) == prefix
end

local function execute_cmd(cmdline)
  local tick = vim.b.changedtick

  pcall(vim.cmd, cmdline)

  -- update_screen() is not called when in 
  -- command line mode, so force a redraw
  -- then undo the change right after
  vim.cmd("silent redraw!")
  if tick ~= vim.b.changedtick then
    vim.cmd("silent undo")
  end
end

local function check_cmd_allowed(cmdline)
  local match = cmdline:match("/.-/(.*)")
  if not match then
    return false
  end
  for _, cmd in ipairs(allowed_commands) do
    if startswith(match, cmd) then
      return true
    end
  end
  return false
end

local function generate_main()
  local recursive = false

  local function main(char)
    if char == "" or char == "" or recursive then
      return
    end

    local function try_preview()
      local cmdline = vim.fn.getcmdline()

      if cmdline:find("g/.*/") or cmdline:find("v/.*/") and
          check_cmd_allowed(cmdline) then
        execute_cmd(cmdline)
      elseif cmdline:find("g/.*") or cmdline:find("v/.*") then
        -- fake incsearch highlighting
        execute_cmd(cmdline .. "/")
      elseif cmdline:find("norm") then
        execute_cmd(cmdline)
      end

      recursive = false
    end

    -- try_preview() calls vim.cmd("norm ..."), which will trigger on_key again.
    -- so we set recursive, in order to avoid getting stuck in an infinite loop.
    recursive = true
    vim.schedule(try_preview)
  end

  return main
end

function M.attach()
  M.saved_incsearch = vim.opt.incsearch
  vim.opt.incsearch = false
  vim.on_key(M.main, M.ns)
end

function M.detach()
  vim.opt.incsearch = M.saved_incsearch
  vim.on_key(nil, M.ns)
end

function M.setup()
  M.ns = vim.api.nvim_create_namespace("multi")
  M.main = generate_main()

  vim.cmd [[
    autocmd CmdLineEnter * lua vim.on_key(require'live'.main, require'live'.ns)
    autocmd CmdLineLeave * lua vim.on_key(nil, require'live'.ns)
  ]]
end

return M
