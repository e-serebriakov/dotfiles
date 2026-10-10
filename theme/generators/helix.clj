(ns generators.helix
  (:require
   [clojure.string :as str]
   [engine :refer [generated-banner]]))

;; Map each Helix scope to its attributes. String values are semantic tokens.
;; Keywords are literal Helix values: modifiers and underline styles.
;; A vector of pairs keeps the order.
(def ^:private scopes
  [["ui.background" {:fg "text.primary" :bg "surface.base"}]
   ["ui.background.separator" {:fg "border.default"}]

   ["ui.cursor" {:fg "surface.base" :bg "cursor.secondary"}]
   ["ui.cursor.normal" {:fg "surface.base" :bg "cursor.secondary"}]
   ["ui.cursor.insert" {:fg "surface.base" :bg "cursor.secondary"}]
   ["ui.cursor.select" {:fg "surface.base" :bg "cursor.secondary"}]
   ["ui.cursor.match" {:fg "text.primary" :bg "selection.match" :modifiers [:bold]}]

   ["ui.cursor.primary" {:fg "surface.base" :bg "cursor.primary"}]
   ["ui.cursor.primary.normal" {:fg "surface.base" :bg "cursor.primary"}]
   ["ui.cursor.primary.insert" {:fg "surface.base" :bg "cursor.primary"}]
   ["ui.cursor.primary.select" {:fg "surface.base" :bg "cursor.primary"}]

   ["ui.cursorline.primary" {:bg "surface.cursorline"}]
   ["ui.cursorline.secondary" {:bg "surface.cursorline"}]
   ["ui.cursorcolumn.primary" {:bg "surface.column"}]
   ["ui.cursorcolumn.secondary" {:bg "surface.column"}]

   ["ui.window" {:fg "border.default" :bg "surface.base"}]
   ["ui.help" {:fg "text.primary" :bg "surface.base"}]

   ["ui.gutter" {:fg "text.muted" :bg "surface.base"}]
   ["ui.gutter.selected" {:fg "text.primary" :bg "surface.base" :modifiers [:bold]}]

   ["ui.linenr" {:fg "text.muted"}]
   ["ui.linenr.selected" {:fg "text.accent" :modifiers [:bold]}]

   ["ui.statusline" {:fg "text.primary" :bg "surface.raised"}]
   ["ui.statusline.inactive" {:fg "text.secondary" :bg "surface.raised"}]
   ["ui.statusline.normal" {:fg "text.strong" :bg "mode.normal" :modifiers [:bold]}]
   ["ui.statusline.insert" {:fg "text.strong" :bg "mode.insert" :modifiers [:bold]}]
   ["ui.statusline.select" {:fg "text.strong" :bg "mode.select" :modifiers [:bold]}]
   ["ui.statusline.separator" {:fg "border.default" :bg "surface.raised"}]

   ["ui.bufferline" {:fg "text.secondary" :bg "surface.raised"}]
   ["ui.bufferline.active" {:fg "text.strong" :bg "surface.active" :modifiers [:bold]}]
   ["ui.bufferline.background" {:fg "text.primary" :bg "surface.raised"}]

   ["ui.menu" {:fg "text.primary" :bg "surface.popup"}]
   ["ui.menu.selected" {:fg "text.strong" :bg "selection.secondary" :modifiers [:bold]}]
   ["ui.menu.scroll" {:fg "text.muted" :bg "surface.popup"}]

   ["ui.popup" {:fg "text.primary" :bg "surface.popup"}]
   ["ui.popup.info" {:fg "text.primary" :bg "surface.popup"}]
   ["ui.popup.header" {:fg "text.primary" :bg "surface.popupHeader" :modifiers [:bold]}]

   ["ui.picker.header" {:fg "text.primary" :bg "surface.base" :modifiers [:bold]}]
   ["ui.picker.header.column" {:fg "text.secondary" :bg "surface.base" :modifiers [:bold]}]
   ["ui.picker.header.column.active" {:fg "text.primary" :bg "surface.base" :modifiers [:bold]}]

   ["ui.text" {:fg "text.primary"}]
   ["ui.text.focus" {:fg "text.primary" :bg "selection.secondary"}]
   ["ui.text.inactive" {:fg "text.secondary" :bg "surface.raised"}]
   ["ui.text.info" {:fg "text.secondary"}]
   ["ui.text.directory" {:fg "text.accent"}]

   ["ui.virtual.ruler" {:bg "surface.ruler"}]
   ["ui.virtual.whitespace" {:fg "border.default"}]
   ["ui.virtual.indent-guide" {:fg "border.default"}]
   ["ui.virtual.wrap" {:fg "border.default"}]
   ["ui.virtual.inlay-hint" {:fg "text.muted"}]
   ["ui.virtual.inlay-hint.parameter" {:fg "text.muted" :modifiers [:italic]}]
   ["ui.virtual.inlay-hint.type" {:fg "text.muted"}]

   ["ui.virtual.jump-label" {:fg "text.strong" :bg "search.current" :modifiers [:bold]}]

   ["ui.selection" {:fg "text.primary" :bg "selection.secondary"}]
   ["ui.selection.primary" {:fg "text.primary" :bg "selection.primary"}]

   ["ui.highlight" {:bg "search.match" :modifiers [:bold]}]
   ["ui.highlight.frameline" {:fg "text.primary" :bg "surface.raised"}]

   ["ui.debug.breakpoint" {:fg "status.warning"}]
   ["ui.debug.active" {:fg "status.info"}]

   ["warning" {:fg "status.warning"}]
   ["error" {:fg "status.error"}]
   ["info" {:fg "status.info"}]
   ["hint" {:fg "status.hint"}]

   ;; Diagnostics. Code under a diagnostic keeps its syntax color; the underline carries the severity.
   ["diagnostic" {:fg "text.primary"}]
   ["diagnostic.hint" {:underline {:color "status.hint" :style :dotted}}]
   ["diagnostic.info" {:underline {:color "status.info" :style :dashed}}]
   ["diagnostic.warning" {:underline {:color "status.warning" :style :curl}}]
   ["diagnostic.error" {:underline {:color "status.errorMark" :style :curl}}]
   ["diagnostic.unnecessary" {:fg "comment.fg" :modifiers [:dim :italic]}]
   ["diagnostic.deprecated" {:underline {:color "comment.fg" :style :double_line}}]

   ["diagnostic.error.inline" {:fg "status.error" :bg "surface.raised"}]
   ["diagnostic.warning.inline" {:fg "status.warning" :bg "surface.raised"}]
   ["diagnostic.info.inline" {:fg "status.info" :bg "surface.raised"}]
   ["diagnostic.hint.inline" {:fg "status.hint" :bg "surface.raised"}]

   ;; Diff
   ["diff.plus" {:bg "diff.add" :fg "text.primary"}]
   ["diff.plus.gutter" {:fg "status.success"}]
   ["diff.minus" {:bg "diff.delete" :fg "text.primary"}]
   ["diff.minus.gutter" {:fg "status.error"}]
   ["diff.delta" {:bg "diff.change" :fg "text.primary"}]
   ["diff.delta.gutter" {:fg "status.info"}]
   ["diff.delta.moved" {:bg "diff.change" :fg "text.primary"}]
   ["diff.delta.conflict" {:bg "diff.conflict" :fg "text.primary"}]

   ;; Syntax
   ["comment" {:fg "comment.fg" :bg "comment.bg"}]
   ["comment.line" {:fg "comment.fg" :bg "comment.bg"}]
   ["comment.block" {:fg "comment.fg" :bg "comment.bg"}]

   ["comment.documentation" {:fg "doc.fg" :bg "doc.bg"}]
   ["comment.block.documentation" {:fg "doc.fg" :bg "doc.bg"}]
   ["comment.line.documentation" {:fg "doc.fg" :bg "doc.bg"}]

   ["comment.unused" {:fg "comment.fg" :modifiers [:dim :italic]}]

   ["string" {:fg "syntax.string"}]
   ["string.regexp" {:fg "syntax.string" :underline {:style :line}}]
   ["string.special" {:fg "syntax.string"}]
   ["string.special.path" {:fg "syntax.string" :underline {:style :line}}]
   ["string.special.url" {:fg "syntax.link" :underline {:style :line}}]
   ["string.special.symbol" {:fg "syntax.string"}]

   ["constant" {:fg "syntax.constant"}]
   ["constant.builtin" {:fg "syntax.constant" :modifiers [:bold]}]
   ["constant.boolean" {:fg "syntax.constant"}]
   ["constant.character" {:fg "syntax.constant"}]
   ["constant.character.escape" {:fg "syntax.constant" :underline {:style :line}}]
   ["constant.numeric" {:fg "syntax.constant"}]

   ["type" {:fg "text.primary"}]
   ["constructor" {:fg "syntax.function"}]

   ["label" {:fg "text.secondary" :underline {:style :line}}]
   ["tag" {:fg "text.primary"}]
   ["tag.builtin" {:fg "text.primary"}]
   ["attribute" {:fg "text.primary"}]

   ["variable" {:fg "text.primary"}]
   ["variable.builtin" {:fg "text.primary"}]
   ["variable.parameter" {:fg "text.primary"}]
   ["variable.other.member" {:fg "text.secondary"}]
   ["variable.other.member.private" {:fg "text.secondary"}]

   ["keyword" {:fg "text.primary"}]
   ["keyword.storage" {:fg "text.secondary"}]
   ["keyword.storage.type" {:fg "text.secondary" :modifiers [:bold]}]
   ["keyword.storage.modifier" {:fg "text.secondary" :modifiers [:italic]}]

   ["operator" {:fg "text.primary"}]

   ["function" {:fg "syntax.function"}]
   ["function.method.private" {:fg "text.secondary"}]
   ["function.macro" {:fg "syntax.function" :underline {:style :line}}]

   ["namespace" {:fg "text.secondary"}]
   ["module" {:fg "text.secondary"}]
   ["special" {:fg "text.secondary"}]

   ["punctuation" {:fg "text.secondary"}]
   ["punctuation.delimiter" {:fg "text.secondary"}]
   ["punctuation.bracket" {:fg "text.secondary"}]
   ["punctuation.special" {:fg "text.secondary"}]

   ["markup.heading" {:fg "doc.heading" :modifiers [:bold]}]
   ["markup.heading.marker" {:fg "doc.fg" :modifiers [:bold]}]
   ["markup.heading.1" {:fg "doc.heading" :modifiers [:bold]}]
   ["markup.heading.2" {:fg "doc.heading" :modifiers [:bold]}]
   ["markup.heading.3" {:fg "doc.heading" :modifiers [:bold]}]
   ["markup.heading.4" {:fg "doc.heading" :modifiers [:bold]}]
   ["markup.heading.5" {:fg "doc.heading" :modifiers [:bold]}]
   ["markup.heading.6" {:fg "doc.heading" :modifiers [:bold]}]

   ["markup.list" {:fg "doc.fg"}]
   ["markup.list.unnumbered" {:fg "doc.fg"}]
   ["markup.list.numbered" {:fg "doc.fg"}]
   ["markup.list.checked" {:fg "doc.fg"}]
   ["markup.list.unchecked" {:fg "doc.fg"}]

   ["markup.bold" {:modifiers [:bold]}]
   ["markup.italic" {:modifiers [:italic]}]
   ["markup.strikethrough" {:modifiers [:crossed_out]}]

   ["markup.link" {:fg "doc.fg"}]
   ["markup.link.url" {:fg "syntax.link" :underline {:style :line}}]
   ["markup.link.label" {:fg "doc.fg" :underline {:style :line}}]
   ["markup.link.text" {:fg "text.primary" :modifiers [:bold]}]

   ["markup.quote" {:fg "doc.fg" :bg "doc.quoteBg"}]
   ["markup.raw.inline" {:fg "text.primary" :bg "doc.codeBg"}]
   ["markup.raw.block" {:bg "doc.codeBg"}]

   ["markup.normal.completion" {:fg "text.primary"}]
   ["markup.normal.hover" {:fg "text.primary"}]
   ["markup.heading.completion" {:fg "text.primary" :modifiers [:bold]}]
   ["markup.heading.hover" {:fg "text.primary" :modifiers [:bold]}]
   ["markup.raw.inline.completion" {:fg "text.primary" :bg "doc.codeBg"}]
   ["markup.raw.inline.hover" {:fg "text.primary" :bg "doc.codeBg"}]

   ["tabstop" {:fg "text.primary" :bg "selection.secondary"}]])

(defn- toml-value [theme v]
  (cond
    (string? v) (str "\"" (theme v) "\"")
    (keyword? v) (str "\"" (name v) "\"")
    (vector? v) (str "[" (str/join ", " (map #(toml-value theme %) v)) "]")
    (map? v) (str "{ " (str/join ", " (for [[k x] v] (str (name k) " = " (toml-value theme x)))) " }")))

(defn render [theme]
  (str
   "# " generated-banner "\n"
   "# Edit the tokens in theme/, then run `bb -m generate`.\n"
   "\n"
   (str/join "\n" (for [[scope attrs] scopes] (str "\"" scope "\" = " (toml-value theme attrs))))
   "\n"))
