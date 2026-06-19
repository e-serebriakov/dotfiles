return {
  'gaoDean/autolist.nvim',
  ft = { 'markdown', 'text' },
  config = function()
    require('autolist').setup()

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'markdown', 'text' },
      callback = function()
        local opts = { buffer = true }
        vim.keymap.set('i', '<CR>', '<CR><cmd>AutolistNewBullet<cr>', opts)
        vim.keymap.set('n', 'o', 'o<cmd>AutolistNewBullet<cr>', opts)
        vim.keymap.set('n', 'O', 'O<cmd>AutolistNewBulletBefore<cr>', opts)
        vim.keymap.set('i', '<Tab>', '<cmd>AutolistTab<cr>', opts)
        vim.keymap.set('i', '<S-Tab>', '<cmd>AutolistShiftTab<cr>', opts)
        vim.keymap.set('n', '>>', '>><cmd>AutolistRecalculate<cr>', opts)
        vim.keymap.set('n', '<<', '<<<cmd>AutolistRecalculate<cr>', opts)
        vim.keymap.set('n', 'dd', 'dd<cmd>AutolistRecalculate<cr>', opts)
      end,
    })
  end,
}
