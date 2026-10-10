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
    -- The baked colorscheme sets the Octo* highlight groups.
    local ok, baked = pcall(require, 'colorschemes.baked_highlights')

    local opts = { picker = 'telescope', enable_builtin = true }
    if ok then
      opts.colors = baked.octo
    end
    require('octo').setup(opts)

    vim.treesitter.language.register('markdown', 'octo')
  end,
}
