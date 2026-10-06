-- Inline virtual-text git blame for the current line (complements gitsigns' on-demand blame)
return {
  'f-person/git-blame.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>gb', '<cmd>GitBlameToggle<cr>', desc = 'Git blame toggle' },
    { '<leader>gB', '<cmd>GitBlameOpenCommitURL<cr>', desc = 'Git blame open commit' },
  },
  config = function()
    local ok, p = pcall(require, 'colorschemes.baked_palette')
    local function baked_blame_hl()
      if ok then
        vim.api.nvim_set_hl(0, 'GitBlameVirtualText', { fg = p.hint_fg, italic = true })
      else
        vim.api.nvim_set_hl(0, 'GitBlameVirtualText', { link = 'Comment' })
      end
    end
    baked_blame_hl()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = baked_blame_hl })

    require('gitblame').setup {
      enabled = true,
      message_template = '  <author> • <date> • <summary>',
      date_format = '%r', -- relative, e.g. "3 days ago"
      highlight_group = 'GitBlameVirtualText',
      message_when_not_committed = '  Not committed yet',
      display_virtual_text = true,
    }
  end,
}
