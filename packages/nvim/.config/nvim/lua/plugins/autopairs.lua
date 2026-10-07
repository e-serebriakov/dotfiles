return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup()

    -- Insert `()` after the user accepts a function or method completion.
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}
