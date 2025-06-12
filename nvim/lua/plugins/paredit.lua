return {
  'julienvincent/nvim-paredit',
  ft = { 'clojure', 'fennel', 'scheme', 'lisp' },
  config = function()
    local paredit = require 'nvim-paredit'

    paredit.setup {
      use_default_keys = false,
      filetypes = { 'clojure', 'fennel', 'scheme', 'lisp' },

      keys = {
        -- Structural editing
        ['<leader>p@'] = { paredit.unwrap.unwrap_form_under_cursor, 'Splice sexp' },
        ['<leader>pr'] = { paredit.api.raise_form, 'Raise form' },
        ['<leader>pR'] = { paredit.api.raise_element, 'Raise element' },

        -- Slurp/Barf
        ['<leader>p>)'] = { paredit.api.slurp_forwards, 'Slurp forwards' },
        ['<leader>p>('] = { paredit.api.barf_backwards, 'Barf backwards' },
        ['<leader>p<)'] = { paredit.api.barf_forwards, 'Barf forwards' },
        ['<leader>p<('] = { paredit.api.slurp_backwards, 'Slurp backwards' },

        -- Drag
        ['<leader>p>e'] = { paredit.api.drag_element_forwards, 'Drag element →' },
        ['<leader>p<e'] = { paredit.api.drag_element_backwards, 'Drag element ←' },
        ['<leader>p>p'] = { paredit.api.drag_pair_forwards, 'Drag pair →' },
        ['<leader>p<p'] = { paredit.api.drag_pair_backwards, 'Drag pair ←' },
        ['<leader>p>f'] = { paredit.api.drag_form_forwards, 'Drag form →' },
        ['<leader>p<f'] = { paredit.api.drag_form_backwards, 'Drag form ←' },

        -- Movement
        ['<leader>pE'] = {
          paredit.api.move_to_next_element_tail,
          'Next element tail',
          repeatable = false,
          mode = { 'n', 'x', 'o', 'v' },
        },
        ['<leader>pW'] = {
          paredit.api.move_to_next_element_head,
          'Next element head',
          repeatable = false,
          mode = { 'n', 'x', 'o', 'v' },
        },
        ['<leader>pB'] = {
          paredit.api.move_to_prev_element_head,
          'Prev element head',
          repeatable = false,
          mode = { 'n', 'x', 'o', 'v' },
        },
        ['<leader>pgE'] = {
          paredit.api.move_to_prev_element_tail,
          'Prev element tail',
          repeatable = false,
          mode = { 'n', 'x', 'o', 'v' },
        },
        ['<leader>p('] = {
          paredit.api.move_to_parent_form_start,
          'Parent form head',
          repeatable = false,
          mode = { 'n', 'x', 'v' },
        },
        ['<leader>p)'] = {
          paredit.api.move_to_parent_form_end,
          'Parent form tail',
          repeatable = false,
          mode = { 'n', 'x', 'v' },
        },

        -- Text objects
        ['<leader>paf'] = {
          paredit.api.select_around_form,
          'Around form',
          repeatable = false,
          mode = { 'o', 'v' },
        },
        ['<leader>pif'] = {
          paredit.api.select_in_form,
          'In form',
          repeatable = false,
          mode = { 'o', 'v' },
        },
        ['<leader>paF'] = {
          paredit.api.select_around_top_level_form,
          'Around top-level form',
          repeatable = false,
          mode = { 'o', 'v' },
        },
        ['<leader>piF'] = {
          paredit.api.select_in_top_level_form,
          'In top-level form',
          repeatable = false,
          mode = { 'o', 'v' },
        },
        ['<leader>pae'] = {
          paredit.api.select_element,
          'Around element',
          repeatable = false,
          mode = { 'o', 'v' },
        },
        ['<leader>pie'] = {
          paredit.api.select_element,
          'Element',
          repeatable = false,
          mode = { 'o', 'v' },
        },

        -- Optional: Wrap
        ['<leader>pww'] = {
          function()
            paredit.wrap.wrap_element_under_cursor('(', ')')
          end,
          'Wrap element with ()',
        },
        ['<leader>pwW'] = {
          function()
            paredit.wrap.wrap_enclosing_form_under_cursor('(', ')')
          end,
          'Wrap form with ()',
        },
      },
    }

    -- Optional: Register which-key group
    local wk = require 'which-key'
    wk.add({
      { '<leader>p', group = '[P]aredit' },
    }, { mode = { 'n', 'v' } })
  end,
}
