-- Set the leader keys before you load plugins.
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.g.have_nerd_font = true
vim.o.termguicolors = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.colorcolumn = '100'

vim.opt.mouse = 'a'

-- The status line shows the mode.
vim.opt.showmode = false

-- Defer clipboard setup to reduce startup delays.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.undofile = true

-- Ignore case unless the search contains uppercase letters or \C.
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = 'yes'

vim.opt.updatetime = 250

vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.inccommand = 'split'

vim.opt.cursorline = true

-- Use a thin square border for each floating window. Hide the ~ after the end of the buffer.
vim.o.winborder = 'single'
vim.opt.fillchars = { eob = ' ' }

vim.opt.scrolloff = 15

vim.opt.confirm = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = '[B]uffer [D]elete' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Show Markdown and plain text with visual line breaks at word boundaries. Check the spelling.
-- Do not insert line breaks automatically. Use one sentence for each source line.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text' },
  group = vim.api.nvim_create_augroup('markdown-prose', { clear = true }),
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = 'en_us'
    vim.opt_local.textwidth = 0
    vim.opt_local.formatoptions:remove 't'
    vim.opt_local.colorcolumn = ''
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'plugins' },
}, {
  ui = {
    border = 'single',
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- Load the baked colorscheme after Neovim initializes the plugins.
require('colorschemes.baked').setup()

-- :BakedReload reloads the palette and theme after token generation (theme/generate.clj).
-- Clear the Lua module cache so require() reads the updated files.
vim.api.nvim_create_user_command('BakedReload', function()
  for _, m in ipairs { 'colorschemes.baked_palette', 'colorschemes.baked' } do
    package.loaded[m] = nil
  end
  require('colorschemes.baked').setup()
  vim.cmd.redraw { bang = true }
  vim.notify('Baked theme reloaded')
end, { desc = 'Reload the generated baked theme' })

-- vim: ts=2 sts=2 sw=2 et
