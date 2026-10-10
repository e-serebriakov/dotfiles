-- Highlight todo, notes, etc in comments
return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  -- keyword = '' and after = '': todo-comments draws no colors, so the theme's @comment.todo style applies.
  opts = { signs = false, highlight = { keyword = '', after = '' } },
}
