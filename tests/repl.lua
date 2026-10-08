-- Run from the repository root: nvim --clean --headless -l tests/repl.lua
vim.opt.rtp:prepend 'packages/nvim/.config/nvim'
vim.g.maplocalleader = ','
vim.cmd 'filetype plugin on'
require 'repl'

local dir = vim.fn.tempname()
vim.fn.mkdir(dir, 'p')
local old_path = vim.env.PATH
vim.env.PATH = dir .. ':' .. old_path
vim.env.REPLE_TEST_OUTPUT = dir .. '/selection'
vim.fn.writefile({ '#!/bin/sh', 'cat > "$REPLE_TEST_OUTPUT"' }, dir .. '/reple')
vim.fn.setfperm(dir .. '/reple', 'rwx------')

local function buffer(ft, lines)
  vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(true, false))
  vim.bo.filetype = ft
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local function send(keys, expected)
  vim.fn.delete(vim.env.REPLE_TEST_OUTPUT)
  local before = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  vim.fn.setreg('"', 'keep this register')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>' .. keys .. ',E', true, false, true), 'xt', false)
  assert(vim.wait(2000, function() return vim.fn.filereadable(vim.env.REPLE_TEST_OUTPUT) == 1 end))
  assert(vim.wait(2000, function()
    return table.concat(vim.fn.readfile(vim.env.REPLE_TEST_OUTPUT, 'b'), '\n') == expected
  end), 'Selection differs from expected text')
  assert(vim.deep_equal(before, vim.api.nvim_buf_get_lines(0, 0, -1, false)))
  assert(vim.fn.getreg '"' == 'keep this register')
end

local ok, err = pcall(function()
  buffer('python', { 'x = "héllo $HOME"', 'print(x)' })
  send('ggVj', 'x = "héllo $HOME"\nprint(x)\n')
  buffer('typescript', { 'abc def' })
  send('gg02lv2h', 'abc\n')
  vim.bo.filetype = 'clojure'
  assert(vim.fn.maparg(',E', 'x') == '', 'REPL mapping leaked after filetype change')
  buffer('clojure', { '(inc 1)' })
  assert(vim.fn.maparg(',E', 'x') == '', 'Clojure must keep Conjure mappings')
end)
vim.env.PATH = old_path
vim.fn.delete(dir, 'rf')
assert(ok, err)
print('PASS: selections, buffer scope, and registers')
