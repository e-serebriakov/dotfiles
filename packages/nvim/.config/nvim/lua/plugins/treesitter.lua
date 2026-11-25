-- Highlight, edit, and navigate code
-- The main branch only installs parsers and queries. Neovim starts highlighting, so the FileType autocmd enables it.
-- See :help nvim-treesitter.
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false, -- The main branch does not support lazy loading.
  build = ':TSUpdate',
  config = function()
    -- install() runs in the background and skips installed parsers.
    require('nvim-treesitter').install {
      'bash',
      'c',
      'clojure',
      'comment', -- TODO, FIXME, and NOTE: the theme styles @comment.todo and its siblings
      'css',
      'diff',
      'html',
      'javascript',
      'json',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'toml',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
    }

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
      callback = function(args)
        -- start() fails for a filetype without a parser. That buffer keeps the regex syntax.
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
