-- Highlight todo, notes, etc in comments
return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  -- after = '': only the keyword uses the highlight color. The text after it keeps the comment colors.
  opts = { signs = false, highlight = { after = '' } },
}
