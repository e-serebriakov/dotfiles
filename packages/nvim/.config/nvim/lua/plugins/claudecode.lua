return {
  'coder/claudecode.nvim',
  -- Claude itself runs in the zellij "agent" pane (see zellij/layouts/work.kdl).
  -- This plugin is here only for the WebSocket/MCP server: selection context,
  -- @-mentions and native diffs. Connect from the agent pane with /ide.
  opts = { terminal = { provider = 'none' } },
  cmd = {
    'ClaudeCodeStart',
    'ClaudeCodeStop',
    'ClaudeCodeStatus',
    'ClaudeCodeAdd',
    'ClaudeCodeSend',
    'ClaudeCodeTreeAdd',
    'ClaudeCodeDiffAccept',
    'ClaudeCodeDiffDeny',
  },
  keys = {
    { '<leader>a', nil, desc = 'AI/Claude Code' },
    { '<leader>ac', '<cmd>ClaudeCodeStart<cr>', desc = 'Start Claude server' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
    { '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>', desc = 'Add file', ft = { 'oil', 'minifiles' } },
    { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
    { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
  },
}
