(ns generators.preview
  (:require
   [engine :refer [generated-banner hex->rgb]]
   [clojure.string :as str]))

(defn preview-rows [theme]
  (let [ink (theme "text.primary")
        muted (theme "text.muted")
        paper (theme "surface.base")
        comment-fg (theme "comment.fg")
        comment-bg (theme "comment.bg")
        todo (theme "comment.high")
        function (theme "accent.function")
        string (theme "accent.string")
        constant (theme "accent.constant")
        link (theme "accent.link")
        selection (theme "selection.primary")
        search (theme "search.soft")
        search-active (theme "search.active")
        alert (theme "alert.fg")
        error (theme "status.error")
        diff-delete (theme "diff.delete")
        diff-delete-text (theme "diff.deleteText")
        diff-add (theme "diff.add")
        diff-add-text (theme "diff.addText")
        diff-change (theme "diff.change")
        diff-change-text (theme "diff.changeText")]
    {:paper paper
     :rows [{:gutter "1" :gcol muted :band comment-bg
             :segments [{:text "// Resolve an alias to a hexadecimal color." :fg comment-fg}]}
            {:gutter "2" :gcol muted
             :segments [{:text "const paper = " :fg ink} {:text "theme" :fg function}
                        {:text "(" :fg ink} {:text "'surface.base'" :fg string} {:text ")" :fg ink}]}
            {:gutter "3" :gcol muted
             :segments [{:text "const CEIL = " :fg ink} {:text "0.035" :fg constant}]}
            {:gutter "4" :gcol muted :band todo
             :segments [{:text "// TODO: measure contrast against the background" :fg comment-fg}]}
            {:gutter "5" :gcol muted
             :segments [{:text "see " :fg ink}
                        {:text "https://oklch.com" :fg link :underline true}]}
            {:gutter "6" :gcol muted :band selection
             :segments [{:text "  selected line — active selection" :fg ink}]}
            {:gutter "7" :gcol muted
             :segments [{:text "grep " :fg ink} {:text "match" :fg ink :hl search}
                        {:text " and " :fg ink} {:text "current" :fg ink :hl search-active}]}
            {:gutter "⊗" :gcol alert
             :segments [{:text "foo()" :fg ink :curl alert} {:text "   " :fg ink}
                        {:text "■ " :fg alert} {:text "undefined name 'foo'" :fg error}]}
            {:gutter "-" :gcol muted :band diff-delete :gap true
             :segments [{:text "  const c = " :fg ink}
                        {:text "0.061" :fg ink :hl diff-delete-text}]}
            {:gutter "+" :gcol muted :band diff-add
             :segments [{:text "  const c = " :fg ink}
                        {:text "0.035" :fg ink :hl diff-add-text}]}
            {:gutter "~" :gcol muted :band diff-change
             :segments [{:text "  modified " :fg ink} {:text "word" :fg ink :hl diff-change-text}
                        {:text " here" :fg ink}]}]}))

;; --- SVG layout, in px ---
(def ^:private font-size 19)
(def ^:private line-height 34)
(def ^:private char-width 11.4)          ; monospace advance ≈ 0.6·em, so columns align
(def ^:private svg-width 780)
(def ^:private code-x 104)               ; left edge where code segments start
(def ^:private gutter-x 80)              ; right edge the gutter number is anchored to
(def ^:private padding-top 18)
(def ^:private diff-gap 20)              ; Additional space before the diff block.
(def ^:private padding-bottom 18)
(def ^:private mono
  "ui-monospace, SFMono-Regular, Menlo, Consolas, 'DejaVu Sans Mono', monospace")

(defn- format-coord
  "Format a coordinate with one decimal place.
  Locale/ROOT keeps the decimal separator as a period for all system locales.
  A comma decimal separator produces invalid coordinates."
  [x]
  (String/format java.util.Locale/ROOT "%.1f" (into-array Object [(double x)])))

(defn- el [tag attrs & children]
  (str "<" tag
       (str/join (map (fn [[k v]] (str " " k "=\"" v "\"")) (partition 2 attrs)))
       (if (seq children)
         (str ">" (str/join children) "</" tag ">")
         "/>")))

(defn- esc [s]
  (-> s
      (str/replace "&" "&amp;")
      (str/replace "<" "&lt;")
      (str/replace ">" "&gt;")))

(defn- text-el
  ([x y s color] (text-el x y s color "start"))
  ([x y s color anchor]
   (el "text" ["x" (format-coord x) "y" (format-coord y)
              "text-anchor" anchor
              "font-family" mono "font-size" font-size
              "fill" color "xml:space" "preserve"]
       (esc s))))

(defn- undercurl
  "Make the curved underline for an error mark.
  Convert the {:d :cx :up} points to one SVG path."
  [x y w color]
  (let [{:keys [d]} (reduce (fn [{:keys [d cx up]} _]
                              (let [nx (+ cx 4)
                                    cy (if up (- y 2) (+ y 2))]
                                {:d  (str d " Q" (format-coord (+ cx 2)) "," (format-coord cy) " " (format-coord nx) "," (format-coord y))
                                 :cx nx
                                 :up (not up)}))
                            {:d (str "M" (format-coord x) "," (format-coord y)) :cx x :up true}
                            (range (max 1 (int (/ w 4)))))]
    (el "path" ["d" d "fill" "none" "stroke" color "stroke-width" "1.3"])))

(defn- segment-elements
  "Render a segment at `column`.
  Include its text, highlight background, and underline when present."
  [baseline y column {:keys [text underline] foreground :fg, highlight :hl, curl-color :curl}]
  (let [x             (+ code-x (* column char-width))
        segment-width (* (count text) char-width)]
    (cond-> []
      highlight (conj (el "rect" ["x" (format-coord (- x 2)) "y" (format-coord (+ y 5))
                                  "width" (format-coord (+ segment-width 4))
                                  "height" (- line-height 10)
                                  "rx" "3" "fill" highlight]))
      true      (conj (text-el x baseline text foreground))
      underline (conj (el "line" ["x1" (format-coord x) "y1" (format-coord (+ baseline 3))
                                  "x2" (format-coord (+ x segment-width))
                                  "y2" (format-coord (+ baseline 3))
                                  "stroke" foreground "stroke-width" "1.4"]))
      curl-color (conj (undercurl x (+ baseline 4) segment-width curl-color)))))

(defn- draw-row
  "Render a row at baseline-top `y`.
  Include the background, gutter number, and segments at their character columns."
  [y {:keys [gutter band segments] gutter-color :gcol}]
  (let [baseline (+ y 23)                                   ; Center the text in the line box.
        columns  (reductions + 0 (map (comp count :text) segments))]
    (into (cond-> []
            band (conj (el "rect" ["x" "0" "y" (format-coord y) "width" svg-width
                                   "height" line-height "fill" band]))
            true (conj (text-el gutter-x baseline gutter gutter-color "end")))
          (mapcat #(segment-elements baseline y %1 %2) columns segments))))

(defn generate-preview [theme]
  (let [{:keys [paper rows]} (preview-rows theme)
        [final-y body] (reduce (fn [[y elements] row]
                                 (let [y (if (:gap row) (+ y diff-gap) y)]
                                   [(+ y line-height) (into elements (draw-row y row))]))
                               [padding-top []] rows)
        h (+ final-y padding-bottom)]
    (str "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
         "<!-- " generated-banner " -->\n"
         "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" svg-width "\" height=\"" h
         "\" viewBox=\"0 0 " svg-width " " h "\">\n"
         "<rect width=\"" svg-width "\" height=\"" h "\" fill=\"" paper "\"/>\n"
         (str/join "\n" body)
         "\n</svg>\n")))

(def ^:private gutter-width 2)
(def ^:private separator "  ")

(defn- rgb [hex layer]
  (str/join ";" (into [layer 2] (hex->rgb hex))))

(defn- run [text {:keys [fg bg underline curl]}]
  (let [codes (cond-> []
                bg (conj (rgb bg 48))
                fg (conj (rgb fg 38))
                underline (conj "4")
                curl (into ["4:3" (rgb curl 58)]))]
    (str (when (seq codes) (str "\u001b[" (str/join ";" codes) "m"))
         text
         "\u001b[0m")))

(defn- line-width [rows]
  (+ gutter-width (count separator)
     (apply max (map (fn [row] (reduce + (map (comp count :text)
                                              (:segments row))))
                     rows))))

(defn- render-line
  "Render a terminal row with its gutter, separator, and segments.
  Add spaces to extend the background to the full width."
  [width {:keys [gutter band segments] gutter-color :gcol}]
  (let [consumed (+ gutter-width (count separator)
                    (reduce + (map (comp count :text) segments)))]
    (str (run (format "%2s" gutter) {:fg gutter-color :bg band})
         (run separator {:bg band})
         (str/join (map (fn [{:keys [text underline] foreground :fg, highlight :hl, curl-color :curl}]
                          (run text {:fg foreground :bg (or highlight band)
                                     :underline underline :curl curl-color}))
                        segments))
         (run (apply str (repeat (- width consumed) \space)) {:bg band}))))

(defn preview-ansi
  "Render the generate-preview sample with 24-bit ANSI colors.
  SGR codes 4:3 and 58 control the curved underline.
  Terminals without this support show a straight underline."
  [theme]
  (let [{:keys [paper rows]} (preview-rows theme)
        width (line-width rows)
        lines (mapcat (fn [row]
                        (cond-> []
                          (:gap row) (conj (run (apply str (repeat width \space)) {:bg paper}))
                          true       (conj (render-line width row))))
                      rows)]
    (str (str/join "\n" lines) "\n")))
