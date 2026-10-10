(ns generators.wezterm
  (:require
   [clojure.string :as str]
   [engine :refer [generated-banner]]))

(def ^:private tabs
  [["active_tab"         {:bg "surface.key"       :fg "text.strong"}]
   ["inactive_tab"       {:bg "surface.raised"    :fg "text.muted"}]
   ["inactive_tab_hover" {:bg "surface.cursorline" :fg "text.primary"}]
   ["new_tab"            {:bg "surface.raised"    :fg "text.secondary"}]
   ["new_tab_hover"      {:bg "surface.base"      :fg "status.info"}]])

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

