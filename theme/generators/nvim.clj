(ns generators.nvim
  (:require
   [clojure.string :as str]
   [generators.common :refer [generated-banner]]))

;; A vector of [palette-key semantic-token] pairs — a VECTOR (not a map) so the
;; output line order is exactly this order. Palette keys must match the ones the
;; colorscheme requires()s.
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
   ["text_muted" "text.muted"]
   ["text_strong" "text.strong"]
   ["comment_fg" "comment.fg"]
   ["comment_bg" "comment.bg"]
   ["comment_high_bg" "comment.high"]
   ["doc_fg" "doc.fg"]
   ["doc_bg" "doc.bg"]
   ["doc_quote_bg" "doc.quote"]
   ["doc_heading" "doc.heading"]
   ["link_fg" "accent.link"]
   ["string_fg" "accent.string"]
   ["const_fg" "accent.constant"]
   ["function_fg" "accent.function"]
   ["match_bg" "selection.match"]
   ["cursor_primary" "cursor.primary"]
   ["cursor_secondary" "cursor.secondary"]
   ["sel_secondary" "selection.secondary"]
   ["sel_primary" "selection.primary"]
   ["search_soft" "search.soft"]
   ["search_mid" "search.active"]
   ["err_fg" "status.error"]
   ["alert_fg" "alert.fg"]
   ["signal_mark" "signal.mark"]
   ["warn_fg" "status.warning"]
   ["info_fg" "status.info"]
   ["hint_fg" "status.hint"]
   ["diff_add_bg" "diff.add"]
   ["diff_change_bg" "diff.change"]
   ["diff_del_bg" "diff.delete"]
   ["diff_change_text_bg" "diff.changeText"]
   ["diff_conflict_bg" "diff.conflict"]
   ["popup_bg" "surface.popup"]
   ["popup_header_bg" "surface.popupHeader"]
   ["key_bg" "surface.key"]])

(defn render [theme]
  (str
   "-- " generated-banner "\n"
   "return {\n"
   (str/join "\n"
             (map (fn [[key token]] (str "  " key " = '" (theme token) "',")) palette))
   "\n}\n"))
