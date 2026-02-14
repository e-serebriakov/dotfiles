return {
  'julienvincent/nvim-paredit',
  ft = { 'clojure', 'fennel', 'scheme', 'lisp' },
  config = function()
    local paredit = require 'nvim-paredit'

    paredit.setup {
      use_default_keys = false,
      filetypes = { 'clojure', 'fennel', 'scheme', 'lisp' },

      keys = {
        -- Slurp / Barf (most used - single prefix)
        ['>)'] = { paredit.api.slurp_forwards, 'Slurp forwards' },
        ['<)'] = { paredit.api.barf_forwards, 'Barf forwards' },
        ['>('] = { paredit.api.barf_backwards, 'Barf backwards' },
        ['<('] = { paredit.api.slurp_backwards, 'Slurp backwards' },

        -- Drag elements / forms
        ['>e'] = { paredit.api.drag_element_forwards, 'Drag element right' },
        ['<e'] = { paredit.api.drag_element_backwards, 'Drag element left' },
        ['>f'] = { paredit.api.drag_form_forwards, 'Drag form right' },
        ['<f'] = { paredit.api.drag_form_backwards, 'Drag form left' },

        -- Raise / Splice
        ['<localleader>r'] = { paredit.api.raise_form, 'Raise form' },
        ['<localleader>R'] = { paredit.api.raise_element, 'Raise element' },
        ['<localleader>@'] = { paredit.unwrap.unwrap_form_under_cursor, 'Splice sexp' },

        -- Wrap
        ['<localleader>w'] = {
          function()
            paredit.wrap.wrap_element_under_cursor('(', ')')
          end,
          'Wrap element with ()',
        },
        ['<localleader>W'] = {
          function()
            paredit.wrap.wrap_enclosing_form_under_cursor('(', ')')
          end,
          'Wrap form with ()',
        },

        -- Movement
        ['E'] = {
          paredit.api.move_to_next_element_tail,
          'Next element tail',
          repeatable = false,
          mode = { 'n', 'x', 'o', 'v' },
        },
        ['W'] = {
          paredit.api.move_to_next_element_head,
          'Next element head',
          repeatable = false,
          mode = { 'n', 'x', 'o', 'v' },
        },
        ['B'] = {
          paredit.api.move_to_prev_element_head,
          'Prev element head',
          repeatable = false,
          mode = { 'n', 'x', 'o', 'v' },
        },
        ['gE'] = {
          paredit.api.move_to_prev_element_tail,
          'Prev element tail',
          repeatable = false,
          mode = { 'n', 'x', 'o', 'v' },
        },
        ['('] = {
          paredit.api.move_to_parent_form_start,
          'Parent form head',
          repeatable = false,
          mode = { 'n', 'x', 'v' },
        },
        [')'] = {
          paredit.api.move_to_parent_form_end,
          'Parent form tail',
          repeatable = false,
          mode = { 'n', 'x', 'v' },
        },

        -- Text objects
        ['af'] = {
          paredit.api.select_around_form,
          'Around form',
          repeatable = false,
          mode = { 'o', 'v' },
        },
        ['if'] = {
          paredit.api.select_in_form,
          'In form',
          repeatable = false,
          mode = { 'o', 'v' },
        },
        ['aF'] = {
          paredit.api.select_around_top_level_form,
          'Around top-level form',
          repeatable = false,
          mode = { 'o', 'v' },
        },
        ['iF'] = {
          paredit.api.select_in_top_level_form,
          'In top-level form',
          repeatable = false,
          mode = { 'o', 'v' },
        },
        ['ae'] = {
          paredit.api.select_element,
          'Around element',
          repeatable = false,
          mode = { 'o', 'v' },
        },
        ['ie'] = {
          paredit.api.select_element,
          'Element',
          repeatable = false,
          mode = { 'o', 'v' },
        },
      },
    }
  end,
}
