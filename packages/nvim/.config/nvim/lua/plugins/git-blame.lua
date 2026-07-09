-- Inline virtual-text git blame for the current line (complements gitsigns' on-demand blame)
return {
  'f-person/git-blame.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>gb', '<cmd>GitBlameToggle<cr>', desc = 'Git blame toggle' },
    { '<leader>gB', '<cmd>GitBlameOpenCommitURL<cr>', desc = 'Git blame open commit' },
  },
  config = function()
    -- Ergo Light — faint italic gray, no background (ergo's Comment has a cream bg)
    local function ergo_blame_hl()
      vim.api.nvim_set_hl(0, 'GitBlameVirtualText', { fg = '#6B7076', italic = true }) -- comment_fg
    end
    ergo_blame_hl()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = ergo_blame_hl })

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
