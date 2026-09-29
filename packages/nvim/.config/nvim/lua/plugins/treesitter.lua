-- Highlight, edit, and navigate code
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate',
  -- The main branch does not use nvim-treesitter.configs.
  -- See :help nvim-treesitter.
  opts = {
    ensure_installed = {
      'bash',
      'c',
      'clojure',
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
    },
    -- Install missing language parsers automatically.
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = { enable = true },
  },
}
