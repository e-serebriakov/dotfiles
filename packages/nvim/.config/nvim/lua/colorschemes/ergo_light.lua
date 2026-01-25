local M = {}

local colors = {
  -- Base colors
  paper = '#FAFAF8',
  panel = '#F3F3F1',
  line_primary = '#E8EEF4',
  line = '#EFEFEF',
  line_column = '#F2F2F2',
  ruler_bg = '#F1F1EE',
  divider = '#DDDDDA',
  code_bg = '#F6F6F6',

  -- Text colors
  text = '#121212',
  text_soft = '#4A4F55',
  comment_fg = '#6B7076',
  comment_bg = '#FFFACD',

  -- Documentation colors
  doc_fg = '#3E444A',
  doc_bg = '#F4F5F7',
  doc_quote_bg = '#F0F1F3',
  doc_heading = '#222426',
  link_fg = '#3A6B90',

  -- Accent colors
  string_fg = '#4F9A5A',
  const_fg = '#6F63C6',
  function_fg = '#4F78A8',

  -- Cursor and selection
  match_bg = '#E6EDF3',
  cursor_primary = '#0E0E0E',
  cursor_secondary = '#707070',
  sel_secondary = '#E6E6E6',
  sel_primary = '#C8D0D8',

  -- Search colors
  search_soft = '#F2EFD9',
  search_mid = '#E7E1B0',

  -- Diagnostic colors
  diag_bg = '#FAFAF6',
  err_fg = '#B2473F',
  warn_fg = '#8A6A1F',
  info_fg = '#3A6B90',
  hint_fg = '#6F6F6F',

  -- Diff colors
  diff_add_bg = '#E9F2EA',
  diff_change_bg = '#F6F2E4',
  diff_del_bg = '#F6E9E8',
  diff_move_bg = '#EDF1F6',
  diff_conflict_bg = '#F5EAEA',

  -- Popup colors
  popup_bg = '#F8F8F6',
  popup_header_bg = '#F0F0EE',
}

function M.setup()
  local hi = vim.api.nvim_set_hl

  -- Clear existing highlights
  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end

  vim.g.colors_name = 'ergo_light'
  vim.o.background = 'light'

  -- UI Background
  hi(0, 'Normal', { fg = colors.text, bg = colors.paper })
  hi(0, 'NormalFloat', { fg = colors.text, bg = colors.panel })
  hi(0, 'FloatBorder', { fg = colors.divider, bg = colors.panel })
  hi(0, 'NormalNC', { fg = colors.text, bg = colors.paper })

  -- Cursor
  hi(0, 'Cursor', { fg = colors.paper, bg = colors.cursor_primary })
  hi(0, 'lCursor', { fg = colors.paper, bg = colors.cursor_primary })
  hi(0, 'CursorIM', { fg = colors.paper, bg = colors.cursor_primary })
  hi(0, 'CursorLine', { bg = colors.line })
  hi(0, 'CursorColumn', { bg = colors.line_column })
  hi(0, 'CursorLineNr', { fg = colors.text, bold = true })

  -- Line numbers
  hi(0, 'LineNr', { fg = colors.comment_fg })
  hi(0, 'LineNrAbove', { fg = colors.comment_fg })
  hi(0, 'LineNrBelow', { fg = colors.comment_fg })

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
  hi(0, 'PmenuThumb', { bg = colors.comment_fg })
  hi(0, 'WildMenu', { fg = colors.text, bg = colors.sel_secondary, bold = true })

  -- Selection
  hi(0, 'Visual', { fg = colors.text, bg = colors.sel_secondary })
  hi(0, 'VisualNOS', { fg = colors.text, bg = colors.sel_secondary })
  hi(0, 'Search', { fg = colors.text, bg = colors.search_soft, bold = true })
  hi(0, 'IncSearch', { fg = colors.text, bg = colors.search_mid, bold = true })
  hi(0, 'CurSearch', { fg = colors.text, bg = colors.search_mid, bold = true })

  -- Syntax highlighting
  hi(0, 'Comment', { fg = colors.comment_fg, bg = colors.comment_bg })
  hi(0, 'String', { fg = colors.string_fg })
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

  -- Diagnostics
  hi(0, 'DiagnosticError', { fg = colors.err_fg, undercurl = true })
  hi(0, 'DiagnosticWarn', { fg = colors.warn_fg, underdashed = true })
  hi(0, 'DiagnosticInfo', { fg = colors.info_fg, undercurl = true })
  hi(0, 'DiagnosticHint', { fg = colors.hint_fg, underdotted = true })
  hi(0, 'DiagnosticUnnecessary', { fg = colors.comment_fg, italic = true })
  hi(0, 'DiagnosticDeprecated', { fg = colors.comment_fg, underdouble = true })

  -- Diagnostic virtual text
  hi(0, 'DiagnosticVirtualTextError', { fg = colors.err_fg, bg = colors.diag_bg })
  hi(0, 'DiagnosticVirtualTextWarn', { fg = colors.warn_fg, bg = colors.diag_bg })
  hi(0, 'DiagnosticVirtualTextInfo', { fg = colors.info_fg, bg = colors.diag_bg })
  hi(0, 'DiagnosticVirtualTextHint', { fg = colors.hint_fg, bg = colors.diag_bg })

  -- Diagnostic signs
  hi(0, 'DiagnosticSignError', { fg = colors.err_fg })
  hi(0, 'DiagnosticSignWarn', { fg = colors.warn_fg })
  hi(0, 'DiagnosticSignInfo', { fg = colors.info_fg })
  hi(0, 'DiagnosticSignHint', { fg = colors.hint_fg })

  -- Diff
  hi(0, 'DiffAdd', { fg = colors.text, bg = colors.diff_add_bg })
  hi(0, 'DiffChange', { fg = colors.text, bg = colors.diff_change_bg })
  hi(0, 'DiffDelete', { fg = colors.text, bg = colors.diff_del_bg })
  hi(0, 'DiffText', { fg = colors.text, bg = colors.diff_move_bg })
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
  hi(0, 'SignColumn', { fg = colors.comment_fg, bg = colors.paper })
  hi(0, 'FoldColumn', { fg = colors.comment_fg, bg = colors.paper })
  hi(0, 'Folded', { fg = colors.comment_fg, bg = colors.panel })

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
  hi(0, 'LspInlayHint', { fg = colors.comment_fg, bg = colors.paper })
  hi(0, 'LspInlayHintParameter', { fg = colors.comment_fg, bg = colors.paper, italic = true })
  hi(0, 'LspInlayHintType', { fg = colors.comment_fg, bg = colors.paper })

  -- Match pairs
  hi(0, 'MatchParen', { fg = colors.text, bg = colors.match_bg, bold = true })

  -- Quickfix
  hi(0, 'QuickFixLine', { bg = colors.sel_secondary })
  hi(0, 'qfLineNr', { fg = colors.comment_fg })

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
  hi(0, 'ErrorMsg', { fg = colors.err_fg })
  hi(0, 'WarningMsg', { fg = colors.warn_fg })
  hi(0, 'ModeMsg', { fg = colors.text })
  hi(0, 'MoreMsg', { fg = colors.info_fg })

  -- Mini.statusline (if using mini.nvim)
  hi(0, 'MiniStatuslineModeNormal', { fg = colors.text, bg = colors.panel, bold = true })
  hi(0, 'MiniStatuslineModeInsert', { fg = colors.text, bg = colors.panel, bold = true })
  hi(0, 'MiniStatuslineModeVisual', { fg = colors.text, bg = colors.panel, bold = true })
  hi(0, 'MiniStatuslineModeReplace', { fg = colors.text, bg = colors.panel, bold = true })
  hi(0, 'MiniStatuslineModeCommand', { fg = colors.text, bg = colors.panel, bold = true })
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

  -- Oil.nvim file explorer (grey highlight)
  hi(0, 'OilEntry', { fg = colors.text, bg = 'NONE' })
  hi(0, 'OilEntryDir', { fg = colors.function_fg, bg = 'NONE' })
  hi(0, 'OilEntryFile', { fg = colors.text, bg = 'NONE' })
  hi(0, 'OilDir', { fg = colors.function_fg, bg = 'NONE' })
  hi(0, 'OilFile', { fg = colors.text, bg = 'NONE' })
  hi(0, 'OilHidden', { fg = colors.text, bg = 'NONE' })
  hi(0, 'OilCursorLine', { bg = colors.line })
  hi(0, 'OilSelected', { fg = colors.text, bg = colors.line })
end

return M
