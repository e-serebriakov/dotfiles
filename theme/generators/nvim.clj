(ns generators.nvim
  (:require
   [clojure.string :as str]
   [engine :refer [generated-banner]]))

;; Map each highlight group to its attributes. String values are semantic tokens.
;; Other values go to nvim_set_hl unchanged: true for flags, :none for 'NONE'.
;; A vector of pairs keeps the order.
(def ^:private highlights
  (concat
   [;; UI background
    ["Normal" {:fg "text.primary" :bg "surface.base"}]
    ;; Bordered floats are white cards. The window behind a focused float shades to NormalNC gray.
    ;; Borderless menus (Pmenu, WhichKeyNormal) keep surface.popup, so they stand out on the white editor.
    ["NormalFloat" {:fg "text.primary" :bg "surface.base"}]
    ["FloatBorder" {:fg "border.default" :bg "surface.base"}]
    ;; Windows without focus use surface.raised. The focused window uses surface.base.
    ["NormalNC" {:fg "text.primary" :bg "surface.raised"}]

    ;; Cursor
    ["Cursor" {:fg "surface.base" :bg "cursor.primary"}]
    ["lCursor" {:fg "surface.base" :bg "cursor.primary"}]
    ["CursorIM" {:fg "surface.base" :bg "cursor.primary"}]
    ["CursorLine" {:bg "surface.cursorline"}]
    ["CursorColumn" {:bg "surface.column"}]
    ["CursorLineNr" {:fg "text.accent" :bold true}]

    ;; Line numbers. The gutter uses text.muted. Only comments use the comment color.
    ["LineNr" {:fg "text.muted"}]
    ["LineNrAbove" {:fg "text.muted"}]
    ["LineNrBelow" {:fg "text.muted"}]

    ;; Status line
    ["StatusLine" {:fg "text.primary" :bg "surface.raised" :bold true}]
    ["StatusLineNC" {:fg "text.secondary" :bg "surface.raised"}]
    ["StatusLineSeparator" {:fg "border.default" :bg "surface.raised"}]

    ;; Menu and popup
    ["Pmenu" {:fg "text.primary" :bg "surface.popup"}]
    ["PmenuSel" {:fg "text.strong" :bg "selection.secondary" :bold true}]
    ["PmenuSbar" {:bg "surface.popup"}]
    ["PmenuThumb" {:bg "text.muted"}]
    ["WildMenu" {:fg "text.strong" :bg "selection.secondary" :bold true}]

    ;; Selection
    ["Visual" {:fg "text.primary" :bg "selection.primary"}]
    ["VisualNOS" {:fg "text.primary" :bg "selection.primary"}]
    ["Search" {:fg "text.primary" :bg "search.match" :bold true}]
    ["IncSearch" {:fg "text.strong" :bg "search.current" :bold true}]
    ["CurSearch" {:fg "text.strong" :bg "search.current" :bold true}]

    ;; Syntax highlighting
    ["Comment" {:fg "comment.fg" :bg "comment.bg"}]
    ["String" {:fg "syntax.string"}]
    ;; Use dark text and the documentation background for documentation strings and comments.
    ["@string.documentation" {:fg "doc.fg" :bg "doc.bg"}]
    ["@comment.documentation" {:fg "doc.fg" :bg "doc.bg"}]]
   ;; Emphasize TODO, FIXME, WARNING, and NOTE with bold text and the attention color.
   (for [g ["@comment.todo" "@comment.note" "@comment.warning" "@comment.error" "Todo"]]
     [g {:fg "text.primary" :bg "comment.markerBg" :bold true}])
   [["Constant" {:fg "syntax.constant"}]
    ["Number" {:fg "syntax.constant"}]
    ["Boolean" {:fg "syntax.constant"}]
    ["Character" {:fg "syntax.constant"}]
    ["Float" {:fg "syntax.constant"}]
    ["Function" {:fg "syntax.function"}]
    ["Identifier" {:fg "text.primary"}]
    ["Keyword" {:fg "text.primary"}]
    ["Operator" {:fg "text.primary"}]
    ["Type" {:fg "text.primary"}]
    ["Structure" {:fg "text.primary"}]
    ["StorageClass" {:fg "text.secondary" :italic true}]
    ["Typedef" {:fg "text.secondary" :bold true}]
    ["Special" {:fg "text.secondary"}]
    ["SpecialChar" {:fg "syntax.constant"}]
    ["Tag" {:fg "text.primary"}]
    ["Delimiter" {:fg "text.secondary"}]
    ["Bracket" {:fg "text.secondary"}]
    ["Punctuation" {:fg "text.secondary"}]
    ["Variable" {:fg "text.primary"}]
    ["PreProc" {:fg "text.secondary"}]
    ["Macro" {:fg "syntax.function" :underline true}]
    ["Label" {:fg "text.secondary" :underline true}]
    ["Namespace" {:fg "text.secondary"}]
    ["Module" {:fg "text.secondary"}]

    ;; Markdown and documentation
    ["markdownHeadingDelimiter" {:fg "doc.fg" :bold true}]]
   (for [n (range 1 7)]
     [(str "markdownHeading" n) {:fg "doc.heading" :bold true}])
   [["markdownLinkText" {:fg "text.primary" :bold true}]
    ["markdownUrl" {:fg "syntax.link" :underline true}]
    ["markdownCode" {:fg "text.primary" :bg "doc.codeBg"}]
    ["markdownCodeBlock" {:bg "doc.codeBg"}]
    ["markdownBlockquote" {:fg "doc.fg" :bg "doc.quoteBg"}]
    ["markdownBold" {:bold true}]
    ["markdownItalic" {:italic true}]
    ["markdownStrikethrough" {:strikethrough true}]

    ;; Use status.errorMark for diagnostic marks and status.error for text.
    ;; Floats and Trouble link to the base groups, so only DiagnosticUnderline* carry underlines.
    ["DiagnosticError" {:fg "status.error"}]
    ["DiagnosticWarn" {:fg "status.warning"}]
    ["DiagnosticInfo" {:fg "status.info"}]
    ["DiagnosticHint" {:fg "status.hint"}]
    ["DiagnosticUnnecessary" {:fg "comment.fg" :italic true}]
    ["DiagnosticDeprecated" {:fg "comment.fg" :underdouble true}]
    ;; Errors and warnings use curved underlines. Information uses dashed underlines. Hints use dotted underlines.
    ["DiagnosticUnderlineError" {:undercurl true :sp "status.errorMark"}]
    ["DiagnosticUnderlineWarn" {:undercurl true :sp "status.warning"}]
    ["DiagnosticUnderlineInfo" {:underdashed true :sp "status.info"}]
    ["DiagnosticUnderlineHint" {:underdotted true :sp "status.hint"}]

    ["DiagnosticVirtualTextError" {:fg "status.error" :bold true}]
    ["DiagnosticVirtualTextWarn" {:fg "status.warning" :bold true}]
    ["DiagnosticVirtualTextInfo" {:fg "status.info"}]
    ["DiagnosticVirtualTextHint" {:fg "status.hint"}]

    ["DiagnosticSignError" {:fg "status.errorMark" :bold true}]
    ["DiagnosticSignWarn" {:fg "status.warning" :bold true}]
    ["DiagnosticSignInfo" {:fg "status.info"}]
    ["DiagnosticSignHint" {:fg "status.hint"}]

    ;; Diff
    ["DiffAdd" {:fg "text.primary" :bg "diff.add"}]
    ["DiffChange" {:fg "text.primary" :bg "diff.change"}]
    ["DiffDelete" {:fg "text.primary" :bg "diff.delete"}]
    ["DiffText" {:fg "text.primary" :bg "diff.changeWord"}]]
   (for [g ["DiffFile" "DiffNewFile" "DiffOldFile" "DiffLine"]]
     [g {:fg "text.secondary"}])
   [;; Patch buffers such as fugitive
    ["DiffAdded" {:fg "status.success"}]
    ["DiffRemoved" {:fg "status.error"}]

    ;; Git signs
    ["GitSignsAdd" {:fg "status.success"}]
    ["GitSignsChange" {:fg "status.info"}]
    ["GitSignsDelete" {:fg "status.error"}]

    ;; Gutter
    ["SignColumn" {:fg "text.muted"}]
    ["FoldColumn" {:fg "text.muted"}]
    ["Folded" {:fg "text.muted" :bg "surface.raised"}]

    ;; Separators and borders
    ["VertSplit" {:fg "border.default" :bg "surface.base"}]
    ["WinSeparator" {:fg "border.default" :bg "surface.base"}]
    ["NonText" {:fg "border.default"}]
    ["Whitespace" {:fg "border.default"}]
    ["EndOfBuffer" {:fg "surface.base"}]

    ["ColorColumn" {:bg "surface.ruler"}]

    ;; Indent guides
    ["IndentBlanklineChar" {:fg "border.default"}]
    ["IndentBlanklineContextChar" {:fg "text.secondary"}]

    ;; Inlay hints
    ["LspInlayHint" {:fg "text.muted"}]
    ["LspInlayHintParameter" {:fg "text.muted" :italic true}]
    ["LspInlayHintType" {:fg "text.muted"}]

    ["MatchParen" {:fg "text.primary" :bg "selection.match" :bold true}]
    ;; LSP document highlight. Without these, references fall back to Visual and look selected.
    ["LspReferenceText" {:bg "selection.match"}]
    ["LspReferenceRead" {:bg "selection.match"}]
    ["LspReferenceWrite" {:bg "selection.match" :bold true}]

    ;; Spelling uses dotted underlines so it does not look like an error diagnostic.
    ["SpellBad" {:underdotted true :sp "status.warning"}]
    ["SpellCap" {:underdotted true :sp "status.hint"}]
    ["SpellRare" {:underdotted true :sp "status.hint"}]
    ["SpellLocal" {:underdotted true :sp "status.hint"}]

    ;; Quickfix
    ["QuickFixLine" {:bg "selection.secondary"}]
    ["qfLineNr" {:fg "text.muted"}]

    ;; Tabline. The active tab is a keycap, as in the Helix bufferline.
    ["TabLine" {:fg "text.secondary" :bg "surface.raised"}]
    ["TabLineFill" {:bg "surface.raised"}]
    ["TabLineSel" {:fg "text.strong" :bg "surface.active" :bold true}]

    ["Terminal" {:fg "text.primary" :bg "surface.base"}]
    ["Title" {:fg "text.primary" :bold true}]
    ["Underlined" {:underline true}]

    ;; Messages
    ["ErrorMsg" {:fg "status.error" :bold true}]
    ["WarningMsg" {:fg "status.warning" :bold true}]
    ["ModeMsg" {:fg "text.primary"}]
    ["MoreMsg" {:fg "status.info"}]

    ;; mini.statusline. Each mode is a keycap with dark text on its mode.* tint, as in Helix.
    ["MiniStatuslineModeNormal" {:fg "text.strong" :bg "mode.normal" :bold true}]
    ["MiniStatuslineModeInsert" {:fg "text.strong" :bg "mode.insert" :bold true}]
    ["MiniStatuslineModeVisual" {:fg "text.strong" :bg "mode.select" :bold true}]
    ["MiniStatuslineModeReplace" {:fg "text.strong" :bg "mode.replace" :bold true}]
    ["MiniStatuslineModeCommand" {:fg "text.strong" :bg "mode.command" :bold true}]
    ["MiniStatuslineModeOther" {:fg "text.strong" :bg "mode.normal" :bold true}]
    ["BakedSignal" {:fg "signal.mark" :bg "surface.raised"}]
    ["MiniStatuslineDevinfo" {:fg "text.primary" :bg "surface.raised"}]
    ["MiniStatuslineFileinfo" {:fg "text.primary" :bg "surface.raised"}]
    ["MiniStatuslineFilename" {:fg "text.primary" :bg "surface.raised"}]]

   ;; Telescope
   (for [g ["TelescopeBorder" "TelescopePromptBorder" "TelescopeResultsBorder" "TelescopePreviewBorder"]]
     [g {:fg "border.default" :bg "surface.base"}])
   ;; One white card for the whole picker, like NormalFloat.
   (for [g ["TelescopeNormal" "TelescopePromptNormal" "TelescopeResultsNormal" "TelescopePreviewNormal"]]
     [g {:fg "text.primary" :bg "surface.base"}])
   (for [g ["TelescopePromptTitle" "TelescopeResultsTitle" "TelescopePreviewTitle"]]
     [g {:fg "text.primary" :bg "surface.popupHeader" :bold true}])
   [["TelescopeSelection" {:fg "text.strong" :bg "selection.secondary" :bold true}]
    ["TelescopeMatching" {:fg "text.primary" :bg "search.match" :bold true}]

    ;; Which-key
    ["WhichKeyNormal" {:fg "text.primary" :bg "surface.popup"}]
    ["WhichKeyBorder" {:fg "border.default" :bg "surface.popup"}]
    ["WhichKey" {:fg "text.accent" :bg :none}]
    ["WhichKeyDesc" {:fg "text.primary" :bg :none}]
    ["WhichKeySeparator" {:fg "text.secondary" :bg :none}]
    ["WhichKeyGroup" {:fg "text.primary" :bg :none :bold true}]
    ["WhichKeyValue" {:fg "text.secondary" :bg :none}]

    ;; Flash. Dim the backdrop text instead of Comment's background, and show labels like Helix jump labels.
    ["FlashBackdrop" {:fg "text.muted"}]
    ["FlashLabel" {:fg "text.strong" :bg "search.current" :bold true}]

    ;; Oil.nvim file explorer
    ["OilEntry" {:fg "text.primary" :bg :none}]
    ["OilEntryDir" {:fg "text.accent" :bg :none}]
    ["OilEntryFile" {:fg "text.primary" :bg :none}]
    ["OilDir" {:fg "text.accent" :bg :none}]
    ["OilFile" {:fg "text.primary" :bg :none}]
    ["OilHidden" {:fg "text.primary" :bg :none}]
    ["OilCursorLine" {:bg "surface.cursorline"}]
    ["OilSelected" {:fg "text.strong" :bg "selection.secondary"}]

    ;; Plugins
    ["GitBlameVirtualText" {:fg "status.hint" :italic true}]
    ;; Octo shows editable text on doc.quoteBg. Headings and dates use secondary and hint colors.
    ["OctoEditable" {:bg "doc.quoteBg"}]
    ["OctoTimelineItemHeading" {:fg "text.secondary" :bold true}]
    ["OctoDate" {:fg "status.hint"}]
    ["OctoSymbol" {:fg "status.hint"}]]))

;; Octo takes its own named colors in setup().
(def ^:private octo-colors
  [["white" "surface.base"]
   ["grey" "text.secondary"]
   ["black" "text.primary"]
   ["red" "diff.delete"]
   ["dark_red" "status.error"]
   ["green" "diff.add"]
   ["dark_green" "status.success"]
   ["yellow" "comment.markerBg"]
   ["dark_yellow" "status.warning"]
   ["blue" "syntax.link"]
   ["dark_blue" "text.accent"]
   ["purple" "terminal.ansi.magenta"]])

;; Diff windows remove the backgrounds of comment and documentation groups so added and deleted lines keep their colors.
;; @comment links to Comment by default. The diff namespace falls back to the global link, so list it explicitly.
(def diff-nobg
  (into ["@comment"]
        (for [[group {bg :bg}] highlights
              :when (or (and (string? bg) (str/starts-with? bg "comment.")) (= bg "doc.bg"))]
          group)))

(defn- lua-value [theme v]
  (cond
    (string? v) (str "'" (theme v) "'")
    (= :none v) "'NONE'"
    :else (str v)))

(defn render [theme]
  (str
   "-- " generated-banner "\n"
   "return {\n"
   "  highlights = {\n"
   (str/join "\n"
             (for [[group attrs] highlights]
               (str "    { '" group "', { "
                    (str/join ", " (for [[k v] attrs] (str (name k) " = " (lua-value theme v))))
                    " } },")))
   "\n  },\n"
   "  diff_nobg = { " (str/join ", " (for [g diff-nobg] (str "'" g "'"))) " },\n"
   "  octo = {\n"
   (str/join "\n" (for [[k token] octo-colors] (str "    " k " = '" (theme token) "',")))
   "\n  },\n"
   "}\n"))
