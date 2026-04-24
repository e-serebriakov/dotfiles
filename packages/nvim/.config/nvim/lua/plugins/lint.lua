return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    lint.linters_by_ft = {
      -- biome-first (JS/TS/JSON/CSS)
      javascript = { 'biomejs' },
      javascriptreact = { 'biomejs' },
      typescript = { 'biomejs' },
      typescriptreact = { 'biomejs' },
      json = { 'biomejs' },
      jsonc = { 'biomejs' },
      css = { 'biomejs' },
      -- other
      markdown = { 'markdownlint' },
      clojure = { 'clj-kondo' },
      python = {},
    }

    local function is_linter_available(name)
      local linter = lint.linters[name]
      local cmd = linter and linter.cmd
      if type(cmd) == 'function' then
        cmd = cmd()
      end
      return type(cmd) == 'string' and vim.fn.executable(cmd) == 1
    end

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        if not vim.opt_local.modifiable:get() or vim.bo.buftype ~= '' then
          return
        end

        local linters = lint.linters_by_ft[vim.bo.filetype] or {}
        local available = vim.tbl_filter(is_linter_available, linters)

        if #available > 0 then
          lint.try_lint(available)
        end
      end,
    })
  end,
}
