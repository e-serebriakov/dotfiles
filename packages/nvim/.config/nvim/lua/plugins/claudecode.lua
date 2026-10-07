return {
  'coder/claudecode.nvim',
  -- Claude runs in the Zellij agent pane. See zellij/layouts/work.kdl.
  -- This plugin provides the WebSocket/MCP server for selection context and native diffs.
  -- The claude() wrapper in .zshrc needs the server lockfile to connect automatically.
  event = 'VeryLazy',
  opts = { terminal = { provider = 'none' } },
  keys = {
    { '<leader>a', nil, desc = 'AI/Claude Code' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
    { '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>', desc = 'Add file', ft = { 'oil', 'minifiles' } },
    { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
    { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
  },
}
