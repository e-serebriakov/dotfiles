-- GitHub issues, PRs and reviews inside Neovim (uses gh CLI)
return {
  'pwntester/octo.nvim',
  cmd = 'Octo',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>go', '<cmd>Octo<cr>', desc = 'Octo commands' },
    { '<leader>gp', '<cmd>Octo pr list<cr>', desc = 'Octo PRs' },
    { '<leader>gi', '<cmd>Octo issue list<cr>', desc = 'Octo issues' },
    { '<leader>gr', '<cmd>Octo review<cr>', desc = 'Octo review PR' },
  },
  config = function()
    require('octo').setup {
      picker = 'telescope',
      enable_builtin = true,
      -- Ergo Light — matches colorschemes/ergo_light.lua
      colors = {
        white = '#FAFAF8', -- paper: text on colored bubbles
        grey = '#4A4F55', -- text_soft
        black = '#121212', -- text
        red = '#F6E9E8', -- diff_del_bg
        dark_red = '#B2473F', -- err_fg
        green = '#E9F2EA', -- diff_add_bg
        dark_green = '#4F9A5A', -- string_fg
        yellow = '#C9AE56', -- mid amber, readable both as fg and bubble bg
        dark_yellow = '#8A6A1F', -- warn_fg
        blue = '#3A6B90', -- info/link blue
        dark_blue = '#4F78A8', -- function_fg
        purple = '#6F63C6', -- const_fg
      },
    }

    -- Markdown highlighting in octo buffers
    vim.treesitter.language.register('markdown', 'octo')

    -- Make comments easier to tell apart:
    --  * each comment body gets a soft-blue "card" background (OctoEditable)
    --    instead of ergo's near-invisible panel tint
    --  * comment headers become a deliberate gray line instead of inheriting
    --    ergo's cream Comment background
    local function ergo_octo_highlights()
      vim.api.nvim_set_hl(0, 'OctoEditable', { bg = '#EAF1F7' }) -- comment body card
      vim.api.nvim_set_hl(0, 'OctoTimelineItemHeading', { fg = '#4A4F55', bold = true })
      vim.api.nvim_set_hl(0, 'OctoDate', { fg = '#6B7076' })
      vim.api.nvim_set_hl(0, 'OctoSymbol', { fg = '#6B7076' })
    end
    ergo_octo_highlights()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = ergo_octo_highlights })
  end,
}
