-- Inline virtual-text git blame for the current line (complements gitsigns' on-demand blame)
return {
  'f-person/git-blame.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>gb', '<cmd>GitBlameToggle<cr>', desc = 'Git blame toggle' },
    { '<leader>gB', '<cmd>GitBlameOpenCommitURL<cr>', desc = 'Git blame open commit' },
  },
  config = function()
    -- The baked colorscheme sets GitBlameVirtualText.
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
