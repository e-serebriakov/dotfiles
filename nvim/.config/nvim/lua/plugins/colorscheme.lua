return {
  {
    'yorickpeterse/nvim-grey',
    opts = {},
    priority = 1000,
    config = function()
      vim.cmd [[colorscheme grey]]
      local hi = function(name, data)
        vim.api.nvim_set_hl(0, name, data)
      end
      hi('MiniStatuslineModeNormal', {
        fg = '#2B2B2B', -- Dark grey
        bg = '#E8E8E8', -- Light grey
        bold = false,
      })
      hi('MiniStatuslineModeInsert', {
        fg = '#E8E8E8', -- Light grey
        bg = '#2B2B2B', -- Dark grey
        bold = true,
      })
      hi('MiniStatuslineDevinfo', {
        fg = '#2B2B2B', -- Dark grey
        bg = '#E8E8E8', -- Light grey
        bold = false,
      })
      hi('MiniStatuslineFileinfo', {
        fg = '#2B2B2B', -- Dark grey
        bg = '#E8E8E8', -- Light grey
        bold = false,
      })
      hi('MiniStatuslineFilename', {
        fg = '#2B2B2B', -- Dark grey
        bg = '#E8E8E8', -- Light grey
        bold = false,
      })
      hi('NormalFloat', { bg = '#E8E8E8' })
    end,
  },
}
