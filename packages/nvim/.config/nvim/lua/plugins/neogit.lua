return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
  },
  opts = {
    integrations = {
      diffview = true,
    },
  },
  keys = {
    { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Neogit' },
    { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Neogit commit' },
  },
}
