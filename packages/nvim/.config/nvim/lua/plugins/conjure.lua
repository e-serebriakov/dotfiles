return {
  'Olical/conjure',
  ft = { 'clojure' },
  init = function()
    -- Conjure's form extraction wants `nvim-treesitter.ts_utils`, dropped in the
    -- `main` branch rewrite. It only calls `get_node_at_cursor`, which Neovim has.
    package.preload['nvim-treesitter.ts_utils'] = function()
      return {
        get_node_at_cursor = function()
          return vim.treesitter.get_node { ignore_injections = false }
        end,
      }
    end
  end,
}
