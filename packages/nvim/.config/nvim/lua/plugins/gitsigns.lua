return {
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add          = { text = '│' },
      change       = { text = '┃' }, -- Use a thicker symbol than add so the shapes differ without color.
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
    attach_to_untracked = true,
    on_attach = function(bufnr)
      local gs = require 'gitsigns'

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Hunk navigation
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gs.nav_hunk 'next'
        end
      end, { desc = 'Next hunk' })

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gs.nav_hunk 'prev'
        end
      end, { desc = 'Previous hunk' })

      -- Hunk actions
      map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
      map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
      map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
      map('n', '<leader>hb', gs.blame_line, { desc = 'Blame line' })
    end,
  },
}
