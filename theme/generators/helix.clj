(ns generators.helix
  (:require
   [clojure.string :as str]
   [generators.common :refer [generated-banner]]))

;; The fixed scope map — helix palette NAMES (resolved by the [palette] section
;; below), so this block is a literal, tokens never touch it.
(def ^:private scopes
  "\"ui.background\" = { fg = \"text\", bg = \"paper\" }
\"ui.background.separator\" = { fg = \"divider\" }

\"ui.cursor\" = { fg = \"paper\", bg = \"cursor_secondary\" }
\"ui.cursor.normal\" = { fg = \"paper\", bg = \"cursor_secondary\" }
\"ui.cursor.insert\" = { fg = \"paper\", bg = \"cursor_secondary\" }
\"ui.cursor.select\" = { fg = \"paper\", bg = \"cursor_secondary\" }

\"ui.cursor.primary\" = { fg = \"paper\", bg = \"cursor_primary\" }
\"ui.cursor.primary.normal\" = { fg = \"paper\", bg = \"cursor_primary\" }
\"ui.cursor.primary.insert\" = { fg = \"paper\", bg = \"cursor_primary\" }
\"ui.cursor.primary.select\" = { fg = \"paper\", bg = \"cursor_primary\" }

\"ui.cursorline.primary\" = { bg = \"line_primary\" }
\"ui.cursorline.secondary\" = { bg = \"line\" }
\"ui.cursorcolumn.primary\" = { bg = \"line_column\" }
\"ui.cursorcolumn.secondary\" = { bg = \"line_column\" }

\"ui.window\" = { fg = \"divider\", bg = \"paper\" }
\"ui.help\" = { fg = \"text\", bg = \"paper\" }

\"ui.gutter\" = { fg = \"comment_fg\", bg = \"paper\" }
\"ui.gutter.selected\" = { fg = \"text\", bg = \"paper\", modifiers = [\"bold\"] }

\"ui.linenr\" = { fg = \"comment_fg\" }
\"ui.linenr.selected\" = { fg = \"text\", modifiers = [\"bold\"] }

\"ui.statusline\" = { fg = \"text\", bg = \"panel\" }
\"ui.statusline.inactive\" = { fg = \"text_soft\", bg = \"panel\" }
\"ui.statusline.normal\" = { fg = \"text\", bg = \"panel\", modifiers = [\"bold\"] }
\"ui.statusline.insert\" = { fg = \"text\", bg = \"panel\", modifiers = [\"bold\"] }
\"ui.statusline.select\" = { fg = \"text\", bg = \"panel\", modifiers = [\"bold\"] }
\"ui.statusline.separator\" = { fg = \"divider\", bg = \"panel\" }

\"ui.bufferline\" = { fg = \"text\", bg = \"panel\" }
\"ui.bufferline.active\" = { fg = \"text\", bg = \"paper\", modifiers = [\"bold\"] }
\"ui.bufferline.background\" = { fg = \"text\", bg = \"panel\" }

\"ui.menu\" = { fg = \"text\", bg = \"panel\" }
\"ui.menu.selected\" = { fg = \"text\", bg = \"sel_secondary\", modifiers = [\"bold\"] }
\"ui.menu.scroll\" = { fg = \"comment_fg\", bg = \"panel\" }

\"ui.popup\" = { fg = \"text\", bg = \"popup_bg\" }
\"ui.popup.info\" = { fg = \"text\", bg = \"popup_bg\" }
\"ui.popup.header\" = { fg = \"text\", bg = \"popup_header_bg\", modifiers = [\"bold\"] }

\"ui.picker.header\" = { fg = \"text\", bg = \"paper\", modifiers = [\"bold\"] }
\"ui.picker.header.column\" = { fg = \"text_soft\", bg = \"paper\", modifiers = [\"bold\"] }
\"ui.picker.header.column.active\" = { fg = \"text\", bg = \"paper\", modifiers = [\"bold\"] }

\"ui.text\" = { fg = \"text\", bg = \"paper\" }
\"ui.text.focus\" = { fg = \"text\", bg = \"sel_secondary\" }
\"ui.text.inactive\" = { fg = \"text_soft\", bg = \"panel\" }
\"ui.text.info\" = { fg = \"text_soft\", bg = \"paper\" }
\"ui.text.directory\" = { fg = \"text\" }

\"ui.virtual.ruler\" = { bg = \"ruler_bg\" }
\"ui.virtual.whitespace\" = { fg = \"divider\" }
\"ui.virtual.indent-guide\" = { fg = \"divider\" }
\"ui.virtual.wrap\" = { fg = \"divider\" }
\"ui.virtual.inlay-hint\" = { fg = \"comment_fg\", bg = \"paper\" }
\"ui.virtual.inlay-hint.parameter\" = { fg = \"comment_fg\", bg = \"paper\", modifiers = [\"italic\"] }
\"ui.virtual.inlay-hint.type\" = { fg = \"comment_fg\", bg = \"paper\" }

\"ui.virtual.jump-label\" = { fg = \"text\", bg = \"search_mid\", modifiers = [\"bold\"] }

\"ui.selection\" = { fg = \"text\", bg = \"sel_secondary\" }
\"ui.selection.primary\" = { fg = \"text\", bg = \"sel_primary\" }

\"ui.highlight\" = { bg = \"search_soft\", modifiers = [\"bold\"] }
\"ui.highlight.frameline\" = { fg = \"text\", bg = \"panel\" }

\"ui.debug.breakpoint\" = { fg = \"warn_fg\" }
\"ui.debug.active\" = { fg = \"info_fg\" }

\"warning\" = { fg = \"warn_fg\" }
\"error\" = { fg = \"err_fg\" }
\"info\" = { fg = \"info_fg\" }
\"hint\" = { fg = \"hint_fg\" }

# Diagnostics
\"diagnostic\" = { fg = \"text\" }
\"diagnostic.hint\" = { fg = \"hint_fg\", underline = { color = \"hint_fg\", style = \"dotted\" } }
\"diagnostic.info\" = { fg = \"info_fg\", underline = { color = \"info_fg\", style = \"curl\" } }
\"diagnostic.warning\" = { fg = \"warn_fg\", underline = { color = \"warn_fg\", style = \"dashed\" } }
\"diagnostic.error\" = { fg = \"err_fg\", underline = { color = \"alert_fg\", style = \"curl\" } }
\"diagnostic.unnecessary\" = { fg = \"comment_fg\", modifiers = [\"dim\", \"italic\"] }
\"diagnostic.deprecated\" = { underline = { color = \"comment_fg\", style = \"double_line\" } }

\"diagnostic.error.inline\" = { fg = \"err_fg\", bg = \"diag_bg\" }
\"diagnostic.warning.inline\" = { fg = \"warn_fg\", bg = \"diag_bg\" }
\"diagnostic.info.inline\" = { fg = \"info_fg\", bg = \"diag_bg\" }
\"diagnostic.hint.inline\" = { fg = \"hint_fg\", bg = \"diag_bg\" }

# Diff
\"diff.plus\" = { bg = \"diff_add_bg\", fg = \"text\" }
\"diff.plus.gutter\" = { fg = \"text_soft\" }
\"diff.minus\" = { bg = \"diff_del_bg\", fg = \"text\" }
\"diff.minus.gutter\" = { fg = \"text_soft\" }
\"diff.delta\" = { bg = \"diff_change_bg\", fg = \"text\" }
\"diff.delta.gutter\" = { fg = \"text_soft\" }
\"diff.delta.moved\" = { bg = \"diff_change_bg\", fg = \"text\" }
\"diff.delta.conflict\" = { bg = \"diff_conflict_bg\", fg = \"text\" }

# Syntax
\"comment\" = { fg = \"comment_fg\", bg = \"comment_bg\" }
\"comment.line\" = { fg = \"comment_fg\" }
\"comment.block\" = { fg = \"comment_fg\" }

\"comment.documentation\" = { fg = \"doc_fg\" }
\"comment.block.documentation\" = { fg = \"doc_fg\" }
\"comment.line.documentation\" = { fg = \"doc_fg\" }

\"comment.unused\" = { fg = \"comment_fg\", modifiers = [\"dim\", \"italic\"] }

\"string\" = { fg = \"string_fg\" }
\"string.regexp\" = { fg = \"string_fg\", underline = { style = \"line\" } }
\"string.special\" = { fg = \"string_fg\" }
\"string.special.path\" = { fg = \"string_fg\", underline = { style = \"line\" } }
\"string.special.url\" = { fg = \"link_fg\", underline = { style = \"line\" } }
\"string.special.symbol\" = { fg = \"string_fg\" }

\"constant\" = { fg = \"const_fg\" }
\"constant.builtin\" = { fg = \"const_fg\", modifiers = [\"bold\"] }
\"constant.boolean\" = { fg = \"const_fg\" }
\"constant.character\" = { fg = \"const_fg\" }
\"constant.character.escape\" = { fg = \"const_fg\", underline = { style = \"line\" } }
\"constant.numeric\" = { fg = \"const_fg\" }

\"type\" = { fg = \"text\" }
\"constructor\" = { fg = \"function_fg\" }

\"label\" = { fg = \"text_soft\", underline = { style = \"line\" } }
\"tag\" = { fg = \"text\" }
\"tag.builtin\" = { fg = \"text\" }
\"attribute\" = { fg = \"text\" }

\"variable\" = { fg = \"text\" }
\"variable.builtin\" = { fg = \"text\" }
\"variable.parameter\" = { fg = \"text\" }
\"variable.other.member\" = { fg = \"text_soft\" }
\"variable.other.member.private\" = { fg = \"text_soft\" }

\"keyword\" = { fg = \"text\" }
\"keyword.storage\" = { fg = \"text_soft\" }
\"keyword.storage.type\" = { fg = \"text_soft\", modifiers = [\"bold\"] }
\"keyword.storage.modifier\" = { fg = \"text_soft\", modifiers = [\"italic\"] }

\"operator\" = { fg = \"text\" }

\"function\" = { fg = \"function_fg\" }
\"function.method.private\" = { fg = \"text_soft\" }
\"function.macro\" = { fg = \"function_fg\", underline = { style = \"line\" } }

\"namespace\" = { fg = \"text_soft\" }
\"module\" = { fg = \"text_soft\" }
\"special\" = { fg = \"text_soft\" }

\"punctuation\" = { fg = \"text_soft\" }
\"punctuation.delimiter\" = { fg = \"text_soft\" }
\"punctuation.bracket\" = { fg = \"text_soft\" }
\"punctuation.special\" = { fg = \"text_soft\" }

\"markup.heading\" = { fg = \"doc_heading\", modifiers = [\"bold\"] }
\"markup.heading.marker\" = { fg = \"doc_fg\", modifiers = [\"bold\"] }
\"markup.heading.1\" = { fg = \"doc_heading\", modifiers = [\"bold\"] }
\"markup.heading.2\" = { fg = \"doc_heading\", modifiers = [\"bold\"] }
\"markup.heading.3\" = { fg = \"doc_heading\", modifiers = [\"bold\"] }
\"markup.heading.4\" = { fg = \"doc_heading\", modifiers = [\"bold\"] }
\"markup.heading.5\" = { fg = \"doc_heading\", modifiers = [\"bold\"] }
\"markup.heading.6\" = { fg = \"doc_heading\", modifiers = [\"bold\"] }

\"markup.list\" = { fg = \"doc_fg\" }
\"markup.list.unnumbered\" = { fg = \"doc_fg\" }
\"markup.list.numbered\" = { fg = \"doc_fg\" }
\"markup.list.checked\" = { fg = \"doc_fg\" }
\"markup.list.unchecked\" = { fg = \"doc_fg\" }

\"markup.bold\" = { modifiers = [\"bold\"] }
\"markup.italic\" = { modifiers = [\"italic\"] }
\"markup.strikethrough\" = { modifiers = [\"crossed_out\"] }

\"markup.link\" = { fg = \"doc_fg\" }
\"markup.link.url\" = { fg = \"link_fg\", underline = { style = \"line\" } }
\"markup.link.label\" = { fg = \"doc_fg\", underline = { style = \"line\" } }
\"markup.link.text\" = { fg = \"text\", modifiers = [\"bold\"] }

\"markup.quote\" = { fg = \"doc_fg\", bg = \"doc_quote_bg\" }
\"markup.raw.inline\" = { fg = \"text\", bg = \"code_bg\" }
\"markup.raw.block\" = { bg = \"code_bg\" }

\"markup.normal.completion\" = { fg = \"text\", bg = \"paper\" }
\"markup.normal.hover\" = { fg = \"text\", bg = \"paper\" }
\"markup.heading.completion\" = { fg = \"text\", bg = \"paper\", modifiers = [\"bold\"] }
\"markup.heading.hover\" = { fg = \"text\", bg = \"paper\", modifiers = [\"bold\"] }
\"markup.raw.inline.completion\" = { fg = \"text\", bg = \"code_bg\" }
\"markup.raw.inline.hover\" = { fg = \"text\", bg = \"code_bg\" }

\"tabstop\" = { fg = \"text\", bg = \"sel_secondary\" }")

;; helix palette name -> semantic token (a vector of pairs to preserve order).
(def ^:private palette
  [["paper" "surface.base"]
   ["panel" "surface.raised"]
   ["line_primary" "selection.match"]
   ["line" "surface.cursorline"]
   ["line_column" "surface.column"]
   ["ruler_bg" "surface.ruler"]
   ["divider" "border.default"]
   ["code_bg" "surface.code"]
   ["text" "text.primary"]
   ["text_soft" "text.secondary"]
   ["comment_fg" "comment.fg"]
   ["comment_bg" "comment.bg"]
   ["doc_fg" "doc.fg"]
   ["doc_quote_bg" "doc.quote"]
   ["doc_heading" "doc.heading"]
   ["link_fg" "accent.link"]
   ["string_fg" "accent.string"]
   ["const_fg" "accent.constant"]
   ["function_fg" "accent.function"]
   ["cursor_primary" "cursor.primary"]
   ["cursor_secondary" "cursor.secondary"]
   ["sel_secondary" "selection.secondary"]
   ["sel_primary" "selection.primary"]
   ["search_soft" "search.soft"]
   ["search_mid" "search.active"]
   ["diag_bg" "surface.raised"]
   ["err_fg" "status.error"]
   ["alert_fg" "alert.fg"]
   ["warn_fg" "status.warning"]
   ["info_fg" "status.info"]
   ["hint_fg" "status.hint"]
   ["diff_add_bg" "diff.add"]
   ["diff_change_bg" "diff.change"]
   ["diff_del_bg" "diff.delete"]
   ["diff_conflict_bg" "diff.conflict"]
   ["popup_bg" "surface.popup"]
   ["popup_header_bg" "surface.popupHeader"]])

(defn render [theme]
  (str
   "# " generated-banner "\n"
   "# Edit the tokens in theme/, then run `bb -m generate`.\n"
   "\n"
   scopes "\n"
   "\n"
   "[palette]\n"
   (str/join "\n" (map (fn [[label tok]] (str label " = \"" (theme tok) "\"")) palette))
   "\n"))
