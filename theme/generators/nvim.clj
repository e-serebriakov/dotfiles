(ns generators.nvim
  (:require
   [clojure.string :as str]
   [engine :refer [generated-banner]]))

;; Map each highlight group to its attributes. String values are semantic tokens.
;; Other values pass through to nvim_set_hl: true for flags, :none for 'NONE'.
;; A vector of pairs keeps the order.
(def ^:private highlights
  (concat
   [;; UI background
    ["Normal" {:fg "text.primary" :bg "surface.base"}]
    ["NormalFloat" {:fg "text.primary" :bg "surface.raised"}]
    ["FloatBorder" {:fg "border.default" :bg "surface.raised"}]
    ;; Windows without focus use the panel gray. The focused window has a lighter background.
    ["NormalNC" {:fg "text.primary" :bg "surface.raised"}]

    ;; Cursor
    ["Cursor" {:fg "surface.base" :bg "cursor.primary"}]
    ["lCursor" {:fg "surface.base" :bg "cursor.primary"}]
    ["CursorIM" {:fg "surface.base" :bg "cursor.primary"}]
    ["CursorLine" {:bg "surface.cursorline"}]
    ["CursorColumn" {:bg "surface.column"}]
    ["CursorLineNr" {:fg "text.primary" :bold true}]

    ;; Line numbers. The gutter uses text.muted. Only comments use the comment color.
    ["LineNr" {:fg "text.muted"}]
    ["LineNrAbove" {:fg "text.muted"}]
    ["LineNrBelow" {:fg "text.muted"}]

    ;; Status line
    ["StatusLine" {:fg "text.primary" :bg "surface.raised" :bold true}]
    ["StatusLineNC" {:fg "text.secondary" :bg "surface.raised"}]
    ["StatusLineSeparator" {:fg "border.default" :bg "surface.raised"}]

    ;; Bufferline (with the bufferline plugin)
    ["BufferLineFill" {:fg "text.primary" :bg "surface.raised"}]
    ["BufferLineBackground" {:fg "text.primary" :bg "surface.raised"}]
    ["BufferLineBufferSelected" {:fg "text.primary" :bg "surface.base" :bold true}]

    ;; Menu and popup
    ["Pmenu" {:fg "text.primary" :bg "surface.raised"}]
    ["PmenuSel" {:fg "text.primary" :bg "selection.secondary" :bold true}]
    ["PmenuSbar" {:bg "surface.raised"}]
    ["PmenuThumb" {:bg "text.muted"}]
    ["WildMenu" {:fg "text.primary" :bg "selection.secondary" :bold true}]

    ;; Selection
    ["Visual" {:fg "text.primary" :bg "selection.primary"}]
    ["VisualNOS" {:fg "text.primary" :bg "selection.primary"}]
    ["Search" {:fg "text.primary" :bg "search.soft" :bold true}]
    ["IncSearch" {:fg "text.strong" :bg "search.active" :bold true}]
    ["CurSearch" {:fg "text.strong" :bg "search.active" :bold true}]

    ;; Syntax highlighting
    ["Comment" {:fg "comment.fg" :bg "comment.bg"}]
    ["String" {:fg "accent.string"}]
    ;; Use dark text and the comment background for documentation strings and comments.
    ["@string.documentation" {:fg "doc.fg" :bg "comment.bg"}]
    ["@comment.documentation" {:fg "doc.fg" :bg "comment.bg"}]]
   ;; Emphasize TODO, FIXME, WARNING, and NOTE with bold text and the attention color.
   (for [g ["@comment.todo" "@comment.note" "@comment.warning" "@comment.error" "Todo"]]
     [g {:fg "text.primary" :bg "comment.high" :bold true}])
   [["Constant" {:fg "accent.constant"}]
    ["Number" {:fg "accent.constant"}]
    ["Boolean" {:fg "accent.constant"}]
    ["Character" {:fg "accent.constant"}]
    ["Float" {:fg "accent.constant"}]
    ["Function" {:fg "accent.function"}]
    ["Identifier" {:fg "text.primary"}]
    ["Keyword" {:fg "text.primary"}]
    ["Operator" {:fg "text.primary"}]
    ["Type" {:fg "text.primary"}]
    ["Structure" {:fg "text.primary"}]
    ["StorageClass" {:fg "text.secondary" :italic true}]
    ["Typedef" {:fg "text.secondary" :bold true}]
    ["Special" {:fg "text.secondary"}]
    ["SpecialChar" {:fg "accent.constant"}]
    ["Tag" {:fg "text.primary"}]
    ["Delimiter" {:fg "text.secondary"}]
    ["Bracket" {:fg "text.secondary"}]
    ["Punctuation" {:fg "text.secondary"}]
    ["Variable" {:fg "text.primary"}]
    ["PreProc" {:fg "text.secondary"}]
    ["Macro" {:fg "accent.function" :underline true}]
    ["Label" {:fg "text.secondary" :underline true}]
    ["Namespace" {:fg "text.secondary"}]
    ["Module" {:fg "text.secondary"}]

    ;; Markdown and documentation
    ["markdownHeadingDelimiter" {:fg "doc.fg" :bold true}]]
   (for [n (range 1 7)]
     [(str "markdownHeading" n) {:fg "doc.heading" :bold true}])
   [["markdownLinkText" {:fg "text.primary" :bold true}]
    ["markdownUrl" {:fg "accent.link" :underline true}]
    ["markdownCode" {:fg "text.primary" :bg "surface.code"}]
    ["markdownCodeBlock" {:bg "surface.code"}]
    ["markdownBlockquote" {:fg "doc.fg" :bg "doc.quote"}]
    ["markdownBold" {:bold true}]
    ["markdownItalic" {:italic true}]
    ["markdownStrikethrough" {:strikethrough true}]

    ;; Use alert.fg for diagnostic marks and status.error for text.
    ;; Errors and warnings use curved underlines. Information uses dashed underlines. Hints use dotted underlines.
    ["DiagnosticError" {:fg "status.error" :undercurl true :sp "alert.fg"}]
    ["DiagnosticWarn" {:fg "status.warning" :undercurl true :sp "status.warning"}]
    ["DiagnosticInfo" {:fg "status.info" :underdashed true}]
    ["DiagnosticHint" {:fg "status.hint" :underdotted true}]
    ["DiagnosticUnnecessary" {:fg "comment.fg" :italic true}]
    ["DiagnosticDeprecated" {:fg "comment.fg" :underdouble true}]
    ;; Some language servers use DiagnosticUnderline* groups for underlines.
    ["DiagnosticUnderlineError" {:undercurl true :sp "alert.fg"}]
    ["DiagnosticUnderlineWarn" {:undercurl true :sp "status.warning"}]
    ["DiagnosticUnderlineInfo" {:underdashed true :sp "status.info"}]
    ["DiagnosticUnderlineHint" {:underdotted true :sp "status.hint"}]

    ["DiagnosticVirtualTextError" {:fg "status.error" :bold true}]
    ["DiagnosticVirtualTextWarn" {:fg "status.warning" :bold true}]
    ["DiagnosticVirtualTextInfo" {:fg "status.info"}]
    ["DiagnosticVirtualTextHint" {:fg "status.hint"}]

    ["DiagnosticSignError" {:fg "alert.fg" :bold true}]
    ["DiagnosticSignWarn" {:fg "status.warning" :bold true}]
    ["DiagnosticSignInfo" {:fg "status.info"}]
    ["DiagnosticSignHint" {:fg "status.hint"}]

    ;; Diff
    ["DiffAdd" {:fg "text.primary" :bg "diff.add"}]
    ["DiffChange" {:fg "text.primary" :bg "diff.change"}]
    ["DiffDelete" {:fg "text.primary" :bg "diff.delete"}]
    ["DiffText" {:fg "text.primary" :bg "diff.changeText"}]]
   (for [g ["DiffAdded" "DiffRemoved" "DiffFile" "DiffNewFile" "DiffOldFile" "DiffLine"]]
     [g {:fg "text.secondary"}])
   [;; Git signs
    ["GitSignsAdd" {:fg "accent.string"}]
    ["GitSignsChange" {:fg "status.warning"}]
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

    ["ColorColumn" {:bg "surface.column"}]

    ;; Indent guides
    ["IndentBlanklineChar" {:fg "border.default"}]
    ["IndentBlanklineContextChar" {:fg "text.secondary"}]

    ;; Inlay hints
    ["LspInlayHint" {:fg "text.muted"}]
    ["LspInlayHintParameter" {:fg "text.muted" :italic true}]
    ["LspInlayHintType" {:fg "text.muted"}]

    ["MatchParen" {:fg "text.primary" :bg "selection.match" :bold true}]

    ;; Quickfix
    ["QuickFixLine" {:bg "selection.secondary"}]
    ["qfLineNr" {:fg "text.muted"}]

    ;; Tabline
    ["TabLine" {:fg "text.primary" :bg "surface.raised"}]
    ["TabLineFill" {:bg "surface.raised"}]
    ["TabLineSel" {:fg "text.primary" :bg "surface.base" :bold true}]

    ["Terminal" {:fg "text.primary" :bg "surface.base"}]
    ["Title" {:fg "text.primary" :bold true}]
    ["Underlined" {:underline true}]

    ;; Messages
    ["ErrorMsg" {:fg "alert.fg" :bold true}]
    ["WarningMsg" {:fg "status.warning" :bold true}]
    ["ModeMsg" {:fg "text.primary"}]
    ["MoreMsg" {:fg "status.info"}]

    ;; mini.statusline. Normal mode uses a gray background.
    ;; Other modes keep mini.statusline's default Diff* links.
    ["MiniStatuslineModeNormal" {:fg "text.strong" :bg "surface.key"}]
    ["BakedSignal" {:fg "signal.mark" :bg "surface.raised"}]
    ["MiniStatuslineDevinfo" {:fg "text.primary" :bg "surface.raised"}]
    ["MiniStatuslineFileinfo" {:fg "text.primary" :bg "surface.raised"}]
    ["MiniStatuslineFilename" {:fg "text.primary" :bg "surface.raised"}]]

   ;; Telescope
   (for [g ["TelescopeBorder" "TelescopePromptBorder" "TelescopeResultsBorder" "TelescopePreviewBorder"]]
     [g {:fg "border.default" :bg "surface.popup"}])
   [["TelescopePromptNormal" {:fg "text.primary" :bg "surface.popup"}]]
   (for [g ["TelescopePromptTitle" "TelescopeResultsTitle" "TelescopePreviewTitle"]]
     [g {:fg "text.primary" :bg "surface.popupHeader" :bold true}])
   [["TelescopeSelection" {:fg "text.primary" :bg "selection.secondary" :bold true}]
    ["TelescopeMatching" {:fg "text.primary" :bg "search.soft" :bold true}]

    ;; Which-key (darker window background)
    ["WhichKeyFloat" {:bg "selection.match"}]
    ["WhichKey" {:fg "accent.function" :bg :none}]
    ["WhichKeyDesc" {:fg "text.primary" :bg :none}]
    ["WhichKeySeparator" {:fg "text.secondary" :bg :none}]
    ["WhichKeyGroup" {:fg "text.primary" :bg :none :bold true}]
    ["WhichKeyValue" {:fg "text.secondary" :bg :none}]

    ;; Oil.nvim file explorer
    ["OilEntry" {:fg "text.primary" :bg :none}]
    ["OilEntryDir" {:fg "accent.function" :bg :none}]
    ["OilEntryFile" {:fg "text.primary" :bg :none}]
    ["OilDir" {:fg "accent.function" :bg :none}]
    ["OilFile" {:fg "text.primary" :bg :none}]
    ["OilHidden" {:fg "text.primary" :bg :none}]
    ["OilCursorLine" {:bg "surface.cursorline"}]
    ["OilSelected" {:fg "text.primary" :bg "surface.cursorline"}]

    ;; Plugins
    ["GitBlameVirtualText" {:fg "status.hint" :italic true}]
    ;; Octo: a blue background for editable text, subdued headings and dates.
    ["OctoEditable" {:bg "doc.bg"}]
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
   ["dark_green" "accent.string"]
   ["yellow" "comment.high"]
   ["dark_yellow" "status.warning"]
   ["blue" "accent.link"]
   ["dark_blue" "accent.function"]
   ["purple" "accent.constant"]])

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
   "  octo = {\n"
   (str/join "\n" (for [[k token] octo-colors] (str "    " k " = '" (theme token) "',")))
   "\n  },\n"
   "}\n"))
