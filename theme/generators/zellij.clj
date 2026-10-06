(ns generators.zellij
  (:require
   [clojure.string :as str]
   [generators.common :refer [generated-banner]]))

;; Zellij's component theme spec (0.42+): one block per UI part, so each bar
;; element gets an explicit colour instead of borrowing a palette slot.
;; The selected ribbon is an ink block; nothing else is filled.
;; Some emphasis slots have specific jobs in the built-in plugins:
;;   ribbon_unselected 0 = status-bar key letter, 1 = compact-bar alternate tab fill, 3 = bell
;;   text_unselected   2 = compact-bar NORMAL (armed), 3 = compact-bar LOCKED (resting, so muted)
;;   text_selected     0 = compact-bar indicator fill
;; Don't enable simplified_ui with status-bar: it draws every other hint label
;; in ribbon_unselected.base on a ribbon_unselected.base fill (zellij 0.44).
(def ^:private components
  [["text_unselected"     {:base "text.primary"   :background "surface.base"       :emphasis ["text.strong" "status.info" "signal.mark" "text.muted"]}]
   ["text_selected"       {:base "text.strong"    :background "surface.cursorline" :emphasis ["surface.cursorline" "status.info" "status.success" "signal.mark"]}]
   ["ribbon_selected"     {:base "surface.base"   :background "text.strong"        :emphasis ["surface.base" "surface.base" "surface.base" "surface.base"]}]
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
  "Zellij component themes take colours as decimal R G B triplets."
  [hex]
  (str/join " " (map #(Integer/parseInt (subs hex % (+ % 2)) 16) [1 3 5])))

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
