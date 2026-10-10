local function biome_or(bufnr, biome_fmts, fallback)
  local cfg = vim.fs.find({ 'biome.json', 'biome.jsonc' }, {
    upward = true,
    path = vim.api.nvim_buf_get_name(bufnr),
  })[1]
  return cfg and biome_fmts or fallback
end

local prettier = { 'prettierd', 'prettier', stop_after_first = true }

local formatters_by_ft = {
  json = function(b) return biome_or(b, { 'biome' }, prettier) end,
  jsonc = function(b) return biome_or(b, { 'biome' }, prettier) end,
  css = function(b) return biome_or(b, { 'biome' }, prettier) end,
  html = prettier,
  yaml = prettier,
  lua = { 'stylua' },
  clojure = { 'cljfmt' },
}
for _, ft in ipairs { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } do
  formatters_by_ft[ft] = function(b) return biome_or(b, { 'biome-check' }, prettier) end
end

return {
  -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable automatic formatting on save for C and C++. Their style conventions vary.
      -- Edit this table to change the excluded languages.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = formatters_by_ft,
  },
}
