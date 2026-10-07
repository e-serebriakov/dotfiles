-- Use GitHub issues, PRs, and reviews in Neovim through the gh CLI.
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
    -- Use the generated baked palette for Octo colors.
    local ok, p = pcall(require, 'colorschemes.baked_palette')

    local opts = { picker = 'telescope', enable_builtin = true }
    if ok then
      opts.colors = {
        white = p.paper,
        grey = p.text_soft,
        black = p.text,
        red = p.diff_del_bg,
        dark_red = p.err_fg,
        green = p.diff_add_bg,
        dark_green = p.string_fg,
        yellow = p.comment_high_bg,
        dark_yellow = p.warn_fg,
        blue = p.link_fg,
        dark_blue = p.function_fg,
        purple = p.const_fg,
      }
    end
    require('octo').setup(opts)

    vim.treesitter.language.register('markdown', 'octo')

    -- Improve contrast with a blue comment background and subdued headings and dates.
    local function baked_octo_highlights()
      if not ok then
        return
      end
      vim.api.nvim_set_hl(0, 'OctoEditable', { bg = p.doc_bg })
      vim.api.nvim_set_hl(0, 'OctoTimelineItemHeading', { fg = p.text_soft, bold = true })
      vim.api.nvim_set_hl(0, 'OctoDate', { fg = p.hint_fg })
      vim.api.nvim_set_hl(0, 'OctoSymbol', { fg = p.hint_fg })
    end
    baked_octo_highlights()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = baked_octo_highlights })
  end,
}
