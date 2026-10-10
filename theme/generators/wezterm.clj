(ns generators.wezterm
  (:require
   [clojure.string :as str]
   [engine :refer [generated-banner]]))

(def ^:private tabs
  [["active_tab"         {:bg "surface.current"   :fg "text.accent"}]
   ["inactive_tab"       {:bg "surface.raised"    :fg "text.secondary"}]
   ["inactive_tab_hover" {:bg "surface.highlight" :fg "text.primary"}]
   ["new_tab"            {:bg "surface.raised"    :fg "text.secondary"}]
   ["new_tab_hover"      {:bg "surface.base"      :fg "text.accent"}]])

(defn- tab [theme {:keys [bg fg]}]
  (str "bg_color = \"" (theme bg) "\"\n"      ; Resolve the token paths here.
       "fg_color = \"" (theme fg) "\"\n"
       "intensity = \"Normal\"\n"
       "italic = false\n"
       "underline = \"None\"\n"
       "strikethrough = false"))

(def ^:private ansi-names
  ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"])

(def ^:private ansi   (mapv #(str "terminal.ansi." %) ansi-names))
(def ^:private bright (mapv #(str "terminal.bright." %) ansi-names))

(defn- color-array [label colors]
  (str label " = [\n"
       (str/join "\n"
                 (map (fn [row]
                        (str "  " (str/join ", " (map #(str "\"" % "\"") row)) ","))
                      (partition 4 colors)))    ; 8 colors -> two rows of 4
       "\n]"))

(defn render [theme]
  (str
   "# " generated-banner "\n"
   "[metadata]" "\n"
   "name = \"baked\"" "\n"
   "wezterm_version = \"*\"" "\n\n"

   "[colors]" "\n"
   "foreground = \"" (theme "text.primary") "\"\n"
   "background = \"" (theme "surface.base") "\"\n\n"

   "cursor_bg = \"" (theme "cursor.primary") "\"\n"
   "cursor_fg = \"" (theme "surface.base") "\"\n"
   "cursor_border = \"" (theme "cursor.primary") "\"\n\n"

   "selection_bg = \"" (theme "selection.primary") "\"\n"
   "selection_fg = \"" (theme "text.primary") "\"\n\n"

   ;; Copy mode and quick select use the search colors, as in the editors.
   "copy_mode_active_highlight_bg = { Color = \"" (theme "search.current") "\" }\n"
   "copy_mode_active_highlight_fg = { Color = \"" (theme "text.strong") "\" }\n"
   "copy_mode_inactive_highlight_bg = { Color = \"" (theme "search.match") "\" }\n"
   "copy_mode_inactive_highlight_fg = { Color = \"" (theme "text.primary") "\" }\n"
   "quick_select_label_bg = { Color = \"" (theme "search.current") "\" }\n"
   "quick_select_label_fg = { Color = \"" (theme "text.strong") "\" }\n"
   "quick_select_match_bg = { Color = \"" (theme "search.match") "\" }\n"
   "quick_select_match_fg = { Color = \"" (theme "text.primary") "\" }\n\n"

   "scrollbar_thumb = \"" (theme "border.default") "\"\n"
   "split = \"" (theme "border.default") "\"\n\n"

   (color-array "ansi"    (map theme ansi)) "\n"
   (color-array "brights" (map theme bright)) "\n\n"

   "[colors.tab_bar]" "\n"
   "background = \"" (theme "surface.raised") "\"\n"
   "inactive_tab_edge = \"" (theme "border.default") "\"\n\n"

   (str/join "\n\n"
             (map (fn [[section spec]]
                    (str "[colors.tab_bar." section "]\n" (tab theme spec)))
                  tabs))
   "\n"))

