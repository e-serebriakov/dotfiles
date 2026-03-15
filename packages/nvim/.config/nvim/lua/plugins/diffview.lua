return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview open' },
    { '<leader>gD', '<cmd>DiffviewClose<cr>', desc = 'Diffview close' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'Diffview file history' },
    { '<leader>gm', '<cmd>DiffviewOpen<cr>', desc = 'Diffview merge conflicts' },
  },
}
