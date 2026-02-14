return {
  'stevearc/oil.nvim',
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  lazy = false,
  opts = {},
  keys = {
    { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' },
  },
}
