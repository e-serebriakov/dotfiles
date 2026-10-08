vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'typescript', 'typescriptreact' },
  group = vim.api.nvim_create_augroup('reple-mappings', { clear = true }),
  callback = function(event)
    vim.keymap.set('x', '<localleader>E', function()
      if vim.fn.executable 'reple' == 0 then
        vim.notify('reple is not on PATH. Install it with mise and restart Neovim.', vim.log.levels.ERROR)
        return
      end
      local lines = vim.fn.getregion(vim.fn.getpos 'v', vim.fn.getpos '.', {
        type = vim.fn.mode(),
        exclusive = vim.o.selection == 'exclusive',
      })
      vim.system({ 'reple', 'eval' }, {
        stdin = table.concat(lines, '\n') .. '\n',
        text = true,
        timeout = 3000,
      }, function(result)
        if result.code ~= 0 then
          vim.schedule(function()
            vim.notify('REPL send failed. Is reple running?\n' .. (result.stderr or ''), vim.log.levels.ERROR)
          end)
        end
      end)
    end, { buffer = event.buf, desc = 'Evaluate selection in external REPL' })
    vim.b.undo_ftplugin = (vim.b.undo_ftplugin or '') .. '\nsilent! xunmap <buffer> <localleader>E'
  end,
})
