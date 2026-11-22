(ns generators.rex
  (:require
   [clojure.string :as str]
   [engine :refer [generated-banner]]))

;; Rex imports Ghostty theme files: Settings > Theme > Import, or `rex do client.theme.import path=...`.
(def ^:private ansi
  (concat (map #(str "terminal.ansi." %) ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"])
          (map #(str "terminal.bright." %) ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"])))

(defn render [theme]
  (str
   "# " generated-banner "\n"
   "background = " (theme "surface.base") "\n"
   "foreground = " (theme "text.primary") "\n"
   "cursor-color = " (theme "cursor.primary") "\n"
   "cursor-text = " (theme "surface.base") "\n"
   "selection-background = " (theme "selection.primary") "\n"
   "selection-foreground = " (theme "text.primary") "\n"
   (str/join (map-indexed (fn [i token] (str "palette = " i "=" (theme token) "\n")) ansi))))
