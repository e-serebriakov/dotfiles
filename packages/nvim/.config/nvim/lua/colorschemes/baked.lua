local M = {}

-- theme/generators/nvim.clj generates the highlights from the active theme/*.tokens.json.
-- Edit the tokens or the generator. Do not edit the generated highlights.
local ok, baked = pcall(require, 'colorschemes.baked_highlights')

function M.setup()
  if not ok then
    vim.notify('baked: the generated highlights are missing. Run `bb -m generate` from the theme/ directory in the dotfiles repository.', vim.log.levels.WARN)
    return
  end
  local hi = vim.api.nvim_set_hl

  -- Clear existing highlights
  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end

  vim.g.colors_name = 'baked'
  vim.o.background = 'light'

  for _, h in ipairs(baked.highlights) do
    hi(0, h[1], h[2])
  end

  -- Remove comment and TODO backgrounds in diff windows so added and deleted lines keep their colors.
  -- Use a window-local highlight namespace for vimdiff and diffview. The two tools set 'diff'.
  -- setup() rebuilds this namespace, so it follows the current highlights.
  local ns = vim.api.nvim_create_namespace('baked_diff_nobg')
  for _, g in ipairs(baked.diff_nobg) do
    local h = vim.api.nvim_get_hl(0, { name = g, link = false })
    h.bg, h.ctermbg = nil, nil
    vim.api.nvim_set_hl(ns, g, h)
  end
  local aug = vim.api.nvim_create_augroup('BakedDiffNoBg', { clear = true })
  vim.api.nvim_create_autocmd('OptionSet', {
    group = aug,
    pattern = 'diff',
    callback = function()
      local win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_hl_ns(win, vim.wo[win].diff and ns or 0)
    end,
  })
  -- Apply the highlights to windows in diff mode when the theme loads.
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.wo[win].diff then vim.api.nvim_win_set_hl_ns(win, ns) end
  end

  -- nvim_set_hl does not trigger ColorScheme. Send the event to refresh plugin color caches.
  -- This refreshes the borders around code blocks in render-markdown after :BakedReload clears the highlights.
  vim.api.nvim_exec_autocmds('ColorScheme', { pattern = 'baked', modeline = false })
end

return M
