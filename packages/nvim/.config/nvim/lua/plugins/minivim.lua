return {
  'echasnovski/mini.nvim',
  config = function()
    -- Around and inside text objects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Status line: plain text, no icons.
    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = false }

    -- Armed states get the signal mark: ● for unsaved, ● rec @q while recording a macro.
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_filename = function()
      local marks = vim.bo.modified and ' %#BakedSignal#●%#MiniStatuslineFilename#' or ''
      local reg = vim.fn.reg_recording()
      if reg ~= '' then
        marks = marks .. ' %#BakedSignal#● rec @' .. reg .. '%#MiniStatuslineFilename#'
      end
      return '%f%r' .. marks
    end
    vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
      callback = function()
        vim.schedule(vim.cmd.redrawstatus)
      end,
    })

    -- Zero-padded LINE:COLUMN, so the status line doesn't shift as you move.
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%03l:%02v'
    end

    -- More options: https://github.com/echasnovski/mini.nvim
  end,
}
