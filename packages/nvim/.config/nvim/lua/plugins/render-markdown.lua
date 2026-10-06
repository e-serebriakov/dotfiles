return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown' },
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  ---@type render.md.UserConfig
  opts = {
    heading = {
      icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
      width = 'block',
      left_pad = 0,
      right_pad = 2,
      backgrounds = { '', '', '', '', '', '' },
    },
    code = {
      width = 'block',
      left_pad = 2,
      right_pad = 2,
      border = 'thin',
    },
    pipe_table = {
      cell = 'padded',
    },
    bullet = {
      icons = { '•', '◦', '‣', '⁃' },
    },
    anti_conceal = {
      enabled = true,
    },
  },
}
