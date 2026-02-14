return {
  'christoomey/vim-tmux-navigator',
  init = function()
    vim.g.tmux_navigator_disable_when_zoomed = 1
  end,
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown',
    'TmuxNavigateUp',
    'TmuxNavigateRight',
  },
  keys = {
    { '<C-h>', '<cmd>TmuxNavigateLeft<cr>', mode = { 'n', 't' }, desc = 'Navigate left (vim/tmux)' },
    { '<C-j>', '<cmd>TmuxNavigateDown<cr>', mode = { 'n', 't' }, desc = 'Navigate down (vim/tmux)' },
    { '<C-k>', '<cmd>TmuxNavigateUp<cr>', mode = { 'n', 't' }, desc = 'Navigate up (vim/tmux)' },
    { '<C-l>', '<cmd>TmuxNavigateRight<cr>', mode = { 'n', 't' }, desc = 'Navigate right (vim/tmux)' },
  },
}
