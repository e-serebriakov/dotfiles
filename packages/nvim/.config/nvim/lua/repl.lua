vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'typescript', 'typescriptreact' },
  group = vim.api.nvim_create_augroup('repl-mappings', { clear = true }),
  callback = function(event)
    vim.keymap.set('x', '<localleader>E', function()
      local lines = vim.fn.getregion(vim.fn.getpos 'v', vim.fn.getpos '.', {
        type = vim.fn.mode(),
        exclusive = vim.o.selection == 'exclusive',
      })
      -- Type the selection into the REPL pane of this Rex session. rex send reads REX_SESSION.
      vim.system({ 'rex', 'send', '-b', 'REPL' }, {
        stdin = table.concat(lines, '\n') .. '\n',
        text = true,
        timeout = 3000,
      }, function(result)
        if result.code ~= 0 then
          vim.schedule(function()
            vim.notify('REPL send failed. Does this Rex session have a REPL pane?\n' .. (result.stderr or ''), vim.log.levels.ERROR)
          end)
        end
      end)
    end, { buffer = event.buf, desc = 'Evaluate selection in external REPL' })
    vim.b.undo_ftplugin = (vim.b.undo_ftplugin or '') .. '\nsilent! xunmap <buffer> <localleader>E'
  end,
})
