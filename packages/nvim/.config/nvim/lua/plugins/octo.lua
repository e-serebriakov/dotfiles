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
    -- Colours from the generated Ergo Light palette, so octo re-tunes with the theme.
    local ok, p = pcall(require, 'colorschemes.ergo_light_palette')

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

    -- octo's own defaults are near-invisible on this theme: give comment bodies a
    -- soft-blue card and headers/dates a deliberate muted line.
    local function ergo_octo_highlights()
      if not ok then
        return
      end
      vim.api.nvim_set_hl(0, 'OctoEditable', { bg = p.doc_bg })
      vim.api.nvim_set_hl(0, 'OctoTimelineItemHeading', { fg = p.text_soft, bold = true })
      vim.api.nvim_set_hl(0, 'OctoDate', { fg = p.hint_fg })
      vim.api.nvim_set_hl(0, 'OctoSymbol', { fg = p.hint_fg })
    end
    ergo_octo_highlights()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = ergo_octo_highlights })
  end,
}
