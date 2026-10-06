-- Highlight todo, notes, etc in comments
return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  -- after = '': the text after a keyword keeps comment colours instead of the keyword's.
  opts = { signs = false, highlight = { after = '' } },
}
