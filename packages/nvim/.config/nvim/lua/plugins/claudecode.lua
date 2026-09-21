return {
  'coder/claudecode.nvim',
  -- Claude runs in the zellij "agent" pane (see zellij/layouts/work.kdl); this
  -- plugin only provides the WebSocket/MCP server for selection context and
  -- native diffs. Eager load so the lockfile exists before the agent pane runs
  -- claude — the claude() wrapper in .zshrc reads it to auto-connect.
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
