-- Show available keys after a key prefix.
return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  opts = {
    -- This delay does not depend on vim.opt.timeoutlen.
    delay = 0,

    -- Document existing key chains
    spec = {
      { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
      { '<leader>d', group = '[D]ebug' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>g', group = '[G]it', mode = { 'n', 'v' } },
      { '<leader>h', group = '[H]unk' },
      { '<leader>x', group = 'Diagnostics' },
    },
  },
}
