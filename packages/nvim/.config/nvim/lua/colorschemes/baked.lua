local M = {}

-- Generate the palette from the active theme/*.tokens.json with theme/generate.clj.
-- Edit the tokens, then regenerate. Do not edit generated palette values.
local ok, colors = pcall(require, 'colorschemes.baked_palette')

function M.setup()
  if not ok then
    vim.notify('baked: generated palette missing — run `bb -m generate` in the dotfiles repo theme/ dir', vim.log.levels.WARN)
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

  -- UI Background
  hi(0, 'Normal', { fg = colors.text, bg = colors.paper })
  hi(0, 'NormalFloat', { fg = colors.text, bg = colors.panel })
  hi(0, 'FloatBorder', { fg = colors.divider, bg = colors.panel })
  -- Unfocused windows sit on the panel grey, so the focused split reads as the lit one.
  hi(0, 'NormalNC', { fg = colors.text, bg = colors.panel })

  -- Cursor
  hi(0, 'Cursor', { fg = colors.paper, bg = colors.cursor_primary })
  hi(0, 'lCursor', { fg = colors.paper, bg = colors.cursor_primary })
  hi(0, 'CursorIM', { fg = colors.paper, bg = colors.cursor_primary })
  hi(0, 'CursorLine', { bg = colors.line })
  hi(0, 'CursorColumn', { bg = colors.line_column })
  hi(0, 'CursorLineNr', { fg = colors.text, bold = true })

  -- Line numbers
  -- The gutter uses text_muted so the comment colour only ever means a comment.
  hi(0, 'LineNr', { fg = colors.text_muted })
  hi(0, 'LineNrAbove', { fg = colors.text_muted })
  hi(0, 'LineNrBelow', { fg = colors.text_muted })

  -- Status line
  hi(0, 'StatusLine', { fg = colors.text, bg = colors.panel, bold = true })
  hi(0, 'StatusLineNC', { fg = colors.text_soft, bg = colors.panel })
  hi(0, 'StatusLineSeparator', { fg = colors.divider, bg = colors.panel })

  -- Bufferline (if using bufferline plugin)
  hi(0, 'BufferLineFill', { fg = colors.text, bg = colors.panel })
  hi(0, 'BufferLineBackground', { fg = colors.text, bg = colors.panel })
  hi(0, 'BufferLineBufferSelected', { fg = colors.text, bg = colors.paper, bold = true })

  -- Menu and popup
  hi(0, 'Pmenu', { fg = colors.text, bg = colors.panel })
  hi(0, 'PmenuSel', { fg = colors.text, bg = colors.sel_secondary, bold = true })
  hi(0, 'PmenuSbar', { bg = colors.panel })
  hi(0, 'PmenuThumb', { bg = colors.text_muted })
  hi(0, 'WildMenu', { fg = colors.text, bg = colors.sel_secondary, bold = true })

  -- Selection
  hi(0, 'Visual', { fg = colors.text, bg = colors.sel_primary })
  hi(0, 'VisualNOS', { fg = colors.text, bg = colors.sel_primary })
  hi(0, 'Search', { fg = colors.text, bg = colors.search_soft, bold = true })
  hi(0, 'IncSearch', { fg = colors.text_strong, bg = colors.search_mid, bold = true })
  hi(0, 'CurSearch', { fg = colors.text_strong, bg = colors.search_mid, bold = true })

  -- Syntax highlighting
  hi(0, 'Comment', { fg = colors.comment_fg, bg = colors.comment_bg })
  hi(0, 'String', { fg = colors.string_fg })
  -- Use dark text and the comment background for documentation strings and comments.
  hi(0, '@string.documentation', { fg = colors.doc_fg, bg = colors.comment_bg })
  hi(0, '@comment.documentation', { fg = colors.doc_fg, bg = colors.comment_bg })
  -- Emphasize TODO, FIXME, WARNING, and NOTE with bold text and the attention color.
  for _, g in ipairs({ '@comment.todo', '@comment.note', '@comment.warning', '@comment.error', 'Todo' }) do
    hi(0, g, { fg = colors.text, bg = colors.comment_high_bg, bold = true })
  end
  hi(0, 'Constant', { fg = colors.const_fg })
  hi(0, 'Number', { fg = colors.const_fg })
  hi(0, 'Boolean', { fg = colors.const_fg })
  hi(0, 'Character', { fg = colors.const_fg })
  hi(0, 'Float', { fg = colors.const_fg })
  hi(0, 'Function', { fg = colors.function_fg })
  hi(0, 'Identifier', { fg = colors.text })
  hi(0, 'Keyword', { fg = colors.text })
  hi(0, 'Operator', { fg = colors.text })
  hi(0, 'Type', { fg = colors.text })
  hi(0, 'Structure', { fg = colors.text })
  hi(0, 'StorageClass', { fg = colors.text_soft, italic = true })
  hi(0, 'Typedef', { fg = colors.text_soft, bold = true })
  hi(0, 'Special', { fg = colors.text_soft })
  hi(0, 'SpecialChar', { fg = colors.const_fg })
  hi(0, 'Tag', { fg = colors.text })
  hi(0, 'Delimiter', { fg = colors.text_soft })
  hi(0, 'Bracket', { fg = colors.text_soft })
  hi(0, 'Punctuation', { fg = colors.text_soft })
  hi(0, 'Variable', { fg = colors.text })
  hi(0, 'PreProc', { fg = colors.text_soft })
  hi(0, 'Macro', { fg = colors.function_fg, underline = true })
  hi(0, 'Label', { fg = colors.text_soft, underline = true })
  hi(0, 'Namespace', { fg = colors.text_soft })
  hi(0, 'Module', { fg = colors.text_soft })

  -- Markdown/Documentation
  hi(0, 'markdownHeadingDelimiter', { fg = colors.doc_fg, bold = true })
  hi(0, 'markdownHeading1', { fg = colors.doc_heading, bold = true })
  hi(0, 'markdownHeading2', { fg = colors.doc_heading, bold = true })
  hi(0, 'markdownHeading3', { fg = colors.doc_heading, bold = true })
  hi(0, 'markdownHeading4', { fg = colors.doc_heading, bold = true })
  hi(0, 'markdownHeading5', { fg = colors.doc_heading, bold = true })
  hi(0, 'markdownHeading6', { fg = colors.doc_heading, bold = true })
  hi(0, 'markdownLinkText', { fg = colors.text, bold = true })
  hi(0, 'markdownUrl', { fg = colors.link_fg, underline = true })
  hi(0, 'markdownCode', { fg = colors.text, bg = colors.code_bg })
  hi(0, 'markdownCodeBlock', { bg = colors.code_bg })
  hi(0, 'markdownBlockquote', { fg = colors.doc_fg, bg = colors.doc_quote_bg })
  hi(0, 'markdownBold', { bold = true })
  hi(0, 'markdownItalic', { italic = true })
  hi(0, 'markdownStrikethrough', { strikethrough = true })

  -- Use alert_fg for diagnostic marks and err_fg for text. See the alert.fg tokens.
  hi(0, 'DiagnosticError', { fg = colors.err_fg, undercurl = true, sp = colors.alert_fg })
  -- Undercurl means error or warning only; info is dashed and hint dotted.
  hi(0, 'DiagnosticWarn', { fg = colors.warn_fg, undercurl = true, sp = colors.warn_fg })
  hi(0, 'DiagnosticInfo', { fg = colors.info_fg, underdashed = true })
  hi(0, 'DiagnosticHint', { fg = colors.hint_fg, underdotted = true })
  hi(0, 'DiagnosticUnnecessary', { fg = colors.comment_fg, italic = true })
  hi(0, 'DiagnosticDeprecated', { fg = colors.comment_fg, underdouble = true })
  -- Some language servers use DiagnosticUnderline* groups for underlines.
  hi(0, 'DiagnosticUnderlineError', { undercurl = true, sp = colors.alert_fg })
  hi(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = colors.warn_fg })
  hi(0, 'DiagnosticUnderlineInfo', { underdashed = true, sp = colors.info_fg })
  hi(0, 'DiagnosticUnderlineHint', { underdotted = true, sp = colors.hint_fg })

  hi(0, 'DiagnosticVirtualTextError', { fg = colors.err_fg, bold = true })
  hi(0, 'DiagnosticVirtualTextWarn', { fg = colors.warn_fg, bold = true })
  hi(0, 'DiagnosticVirtualTextInfo', { fg = colors.info_fg })
  hi(0, 'DiagnosticVirtualTextHint', { fg = colors.hint_fg })

  hi(0, 'DiagnosticSignError', { fg = colors.alert_fg, bold = true })
  hi(0, 'DiagnosticSignWarn', { fg = colors.warn_fg, bold = true })
  hi(0, 'DiagnosticSignInfo', { fg = colors.info_fg })
  hi(0, 'DiagnosticSignHint', { fg = colors.hint_fg })

  -- Diff
  hi(0, 'DiffAdd', { fg = colors.text, bg = colors.diff_add_bg })
  hi(0, 'DiffChange', { fg = colors.text, bg = colors.diff_change_bg })
  hi(0, 'DiffDelete', { fg = colors.text, bg = colors.diff_del_bg })
  hi(0, 'DiffText', { fg = colors.text, bg = colors.diff_change_text_bg })
  hi(0, 'DiffAdded', { fg = colors.text_soft })
  hi(0, 'DiffRemoved', { fg = colors.text_soft })
  hi(0, 'DiffFile', { fg = colors.text_soft })
  hi(0, 'DiffNewFile', { fg = colors.text_soft })
  hi(0, 'DiffOldFile', { fg = colors.text_soft })
  hi(0, 'DiffLine', { fg = colors.text_soft })

  -- Git signs
  hi(0, 'GitSignsAdd', { fg = colors.string_fg })
  hi(0, 'GitSignsChange', { fg = colors.warn_fg })
  hi(0, 'GitSignsDelete', { fg = colors.err_fg })

  -- Gutter
  hi(0, 'SignColumn', { fg = colors.text_muted })
  hi(0, 'FoldColumn', { fg = colors.text_muted })
  hi(0, 'Folded', { fg = colors.text_muted, bg = colors.panel })

  -- Separators and borders
  hi(0, 'VertSplit', { fg = colors.divider, bg = colors.paper })
  hi(0, 'WinSeparator', { fg = colors.divider, bg = colors.paper })
  hi(0, 'NonText', { fg = colors.divider })
  hi(0, 'Whitespace', { fg = colors.divider })
  hi(0, 'EndOfBuffer', { fg = colors.paper })

  -- ColorColumn (very light, subtle)
  hi(0, 'ColorColumn', { bg = colors.line_column })

  -- Indent guides
  hi(0, 'IndentBlanklineChar', { fg = colors.divider })
  hi(0, 'IndentBlanklineContextChar', { fg = colors.text_soft })

  -- Inlay hints
  hi(0, 'LspInlayHint', { fg = colors.text_muted })
  hi(0, 'LspInlayHintParameter', { fg = colors.text_muted, italic = true })
  hi(0, 'LspInlayHintType', { fg = colors.text_muted })

  -- Match pairs
  hi(0, 'MatchParen', { fg = colors.text, bg = colors.match_bg, bold = true })

  -- Quickfix
  hi(0, 'QuickFixLine', { bg = colors.sel_secondary })
  hi(0, 'qfLineNr', { fg = colors.text_muted })

  -- Tabline
  hi(0, 'TabLine', { fg = colors.text, bg = colors.panel })
  hi(0, 'TabLineFill', { bg = colors.panel })
  hi(0, 'TabLineSel', { fg = colors.text, bg = colors.paper, bold = true })

  -- Terminal
  hi(0, 'Terminal', { fg = colors.text, bg = colors.paper })

  -- Title
  hi(0, 'Title', { fg = colors.text, bold = true })

  -- Underlined
  hi(0, 'Underlined', { underline = true })

  -- Error messages
  hi(0, 'ErrorMsg', { fg = colors.alert_fg, bold = true })
  hi(0, 'WarningMsg', { fg = colors.warn_fg, bold = true })
  hi(0, 'ModeMsg', { fg = colors.text })
  hi(0, 'MoreMsg', { fg = colors.info_fg })

  -- Mini.statusline (if using mini.nvim)
  -- Every mode uses this keycap block (see plugins/minivim.lua); the label tells modes apart.
  hi(0, 'MiniStatuslineModeNormal', { fg = colors.text_strong, bg = colors.key_bg })
  hi(0, 'BakedSignal', { fg = colors.signal_mark, bg = colors.panel })
  hi(0, 'MiniStatuslineDevinfo', { fg = colors.text, bg = colors.panel })
  hi(0, 'MiniStatuslineFileinfo', { fg = colors.text, bg = colors.panel })
  hi(0, 'MiniStatuslineFilename', { fg = colors.text, bg = colors.panel })

  -- Telescope
  hi(0, 'TelescopeBorder', { fg = colors.divider, bg = colors.popup_bg })
  hi(0, 'TelescopePromptBorder', { fg = colors.divider, bg = colors.popup_bg })
  hi(0, 'TelescopeResultsBorder', { fg = colors.divider, bg = colors.popup_bg })
  hi(0, 'TelescopePreviewBorder', { fg = colors.divider, bg = colors.popup_bg })
  hi(0, 'TelescopePromptNormal', { fg = colors.text, bg = colors.popup_bg })
  hi(0, 'TelescopePromptTitle', { fg = colors.text, bg = colors.popup_header_bg, bold = true })
  hi(0, 'TelescopeResultsTitle', { fg = colors.text, bg = colors.popup_header_bg, bold = true })
  hi(0, 'TelescopePreviewTitle', { fg = colors.text, bg = colors.popup_header_bg, bold = true })
  hi(0, 'TelescopeSelection', { fg = colors.text, bg = colors.sel_secondary, bold = true })
  hi(0, 'TelescopeMatching', { fg = colors.text, bg = colors.search_soft, bold = true })

  -- Which-key (darker window background)
  hi(0, 'WhichKeyFloat', { bg = colors.line_primary })
  hi(0, 'WhichKey', { fg = colors.function_fg, bg = 'NONE' })
  hi(0, 'WhichKeyDesc', { fg = colors.text, bg = 'NONE' })
  hi(0, 'WhichKeySeparator', { fg = colors.text_soft, bg = 'NONE' })
  hi(0, 'WhichKeyGroup', { fg = colors.text, bg = 'NONE', bold = true })
  hi(0, 'WhichKeyValue', { fg = colors.text_soft, bg = 'NONE' })

  -- Oil.nvim file explorer (gray highlight)
  hi(0, 'OilEntry', { fg = colors.text, bg = 'NONE' })
  hi(0, 'OilEntryDir', { fg = colors.function_fg, bg = 'NONE' })
  hi(0, 'OilEntryFile', { fg = colors.text, bg = 'NONE' })
  hi(0, 'OilDir', { fg = colors.function_fg, bg = 'NONE' })
  hi(0, 'OilFile', { fg = colors.text, bg = 'NONE' })
  hi(0, 'OilHidden', { fg = colors.text, bg = 'NONE' })
  hi(0, 'OilCursorLine', { bg = colors.line })
  hi(0, 'OilSelected', { fg = colors.text, bg = colors.line })

  -- Remove comment and TODO backgrounds in diff windows so added and deleted lines keep their colors.
  -- Use a window-local highlight namespace for vimdiff and diffview; both set 'diff'.
  -- Rebuild the namespace when the palette changes.
  local ns = vim.api.nvim_create_namespace('baked_diff_nobg')
  for _, g in ipairs({ 'Comment', '@comment', '@comment.documentation', '@string.documentation',
                      '@comment.todo', '@comment.note', '@comment.warning', '@comment.error', 'Todo' }) do
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
  -- Catch windows already in diff mode when the theme (re)loads.
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.wo[win].diff then vim.api.nvim_win_set_hl_ns(win, ns) end
  end

  -- nvim_set_hl does not trigger ColorScheme. Send the event to refresh plugin color caches.
  -- This prevents stale render-markdown code block borders after :BakedReload clears highlights.
  vim.api.nvim_exec_autocmds('ColorScheme', { pattern = 'baked', modeline = false })
end

return M
