(ns generators.zellij
  (:require
   [clojure.string :as str]
   [engine :refer [generated-banner hex->rgb]]))

;; Zellij component themes (0.42+) use one block for each interface part.
;; Each bar element has a specified color rather than a shared palette slot.
;; The selected ribbon uses the gray surface.key background with dark text.
;; The built-in plugins assign these functions to emphasis slots:
;;   ribbon_unselected 0 = status-bar key letter, 1 = compact-bar alternate tab fill, 3 = bell
;;   text_unselected   2 = compact-bar NORMAL (active), 3 = compact-bar LOCKED (less emphasis)
;;   text_selected     0 = compact-bar indicator fill
;; Do not enable simplified_ui with status-bar. In Zellij 0.44, alternate hint labels
;; use ribbon_unselected.base for the foreground and background, which hides the text.
(def ^:private components
  [["text_unselected"     {:base "text.primary"   :background "surface.base"       :emphasis ["text.strong" "status.info" "signal.mark" "text.muted"]}]
   ["text_selected"       {:base "text.strong"    :background "surface.cursorline" :emphasis ["surface.cursorline" "status.info" "status.success" "signal.mark"]}]
   ["ribbon_selected"     {:base "text.strong"    :background "surface.key"        :emphasis ["text.strong" "text.strong" "text.strong" "text.strong"]}]
   ["ribbon_unselected"   {:base "text.secondary" :background "surface.raised"     :emphasis ["text.strong" "surface.cursorline" "text.strong" "signal.mark"]}]
   ["table_title"         {:base "text.strong"    :background "surface.base"       :emphasis ["text.strong" "status.info" "status.success" "signal.mark"]}]
   ["table_cell_selected" {:base "text.strong"    :background "surface.cursorline" :emphasis ["text.strong" "status.info" "status.success" "signal.mark"]}]
   ["table_cell_unselected" {:base "text.primary" :background "surface.base"       :emphasis ["text.strong" "status.info" "status.success" "signal.mark"]}]
   ["list_selected"       {:base "text.strong"    :background "surface.cursorline" :emphasis ["text.strong" "status.info" "status.success" "signal.mark"]}]
   ["list_unselected"     {:base "text.primary"   :background "surface.base"       :emphasis ["text.strong" "status.info" "status.success" "signal.mark"]}]
   ["frame_selected"      {:base "text.strong"    :background "surface.base"       :emphasis ["text.strong" "text.strong" "text.strong" "text.strong"]}]
   ["frame_unselected"    {:base "border.default" :background "surface.base"       :emphasis ["text.muted" "text.muted" "text.muted" "text.muted"]}]
   ["frame_highlight"     {:base "signal.mark"    :background "surface.base"       :emphasis ["signal.mark" "signal.mark" "signal.mark" "signal.mark"]}]
   ["exit_code_success"   {:base "status.success" :background "surface.base"       :emphasis ["status.success" "status.success" "status.success" "status.success"]}]
   ["exit_code_error"     {:base "status.error"   :background "surface.base"       :emphasis ["status.error" "status.error" "status.error" "status.error"]}]])

(def ^:private players
  ["accent.string" "accent.constant" "accent.function" "status.info" "status.warning"
   "terminal.ansi.magenta" "terminal.ansi.cyan" "status.success" "status.error" "text.secondary"])

(defn- rgb
  "Convert the color to a decimal R G B triplet for Zellij component themes."
  [hex]
  (str/join " " (hex->rgb hex)))

(defn- block [theme [name {:keys [base background emphasis]}]]
  (str "        " name " {\n"
       "            base " (rgb (theme base)) "\n"
       "            background " (rgb (theme background)) "\n"
       (str/join (map-indexed (fn [i e] (str "            emphasis_" i " " (rgb (theme e)) "\n")) emphasis))
       "        }\n"))

(defn render [theme]
  (str
   "// " generated-banner "\n"
   "themes {\n"
   "    baked {\n"
   (str/join (map #(block theme %) components))
   "        multiplayer_user_colors {\n"
   (str/join (map-indexed (fn [i p] (str "            player_" (inc i) " " (rgb (theme p)) "\n")) players))
   "        }\n"
   "    }\n"
   "}\n"))
