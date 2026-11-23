(ns generate
  (:require
   [babashka.fs :as fs]
   [cheshire.core :as json]
   [clojure.set :as set]
   [clojure.string :as str]
   [engine :as e]
   [generators.helix :as helix]
   [generators.nvim :as nvim]
   [generators.preview :as preview]
   [generators.rex :as rex]))

(def adapters
  ;; Each tool gets a light and a dark file. %s in :output is "light" or "dark".
  ;; :render receives the theme and the tool's theme name, baked-light or baked-dark.
  [{:render (fn [theme _] (nvim/render theme)) :output "packages/nvim/.config/nvim/lua/colorschemes/baked_%s.lua"}
   ;; follow-appearance.sh links baked.toml to the variant that matches the system.
   {:render (fn [theme _] (helix/render theme)) :output "packages/helix/.config/helix/themes/baked-%s.toml"}
   {:render (fn [theme _] (rex/render theme)) :output "packages/rex/.config/rex/themes/baked-%s"}])

;; The tools pick the file that matches the system light/dark mode.
(def appearance-themes {"light" "te-calm" "dark" "te-dark"})

(defn check [tokens adapters]
  (let [defined (e/defined-tokens tokens)
        referenced (apply set/union (map #(e/references (:render %)) adapters))]
    {:missing (set/difference referenced defined)
     :unused (set/difference defined referenced)}))

(defn load-theme [theme-name]
  (let [path (e/tokens-path theme-name)]
    (when-not (fs/exists? path)
      (throw (ex-info (str "unknown theme '" theme-name "' — available: "
                           (str/join ", " (e/theme-names)))
                      {:type :theme-error})))
    (json/parse-string (slurp (str path)))))

(defn -main [& args]
  (let [chosen (second (drop-while #(not= "--theme" %) args))]
    (if (some #{"--preview"} args)                    ; Show a theme. Do not write files.
      (do (print (preview/preview-ansi (e/->theme (load-theme (or chosen (appearance-themes "light"))))))
          (flush))
      (do
        ;; Check both themes before writing, so a broken theme does not leave a half-updated pair.
        (doseq [theme-name (vals appearance-themes)
                :let [{:keys [missing unused]} (check (load-theme theme-name) adapters)]]
          (when (seq missing)                         ; Stop before generation if a token reference has no definition.
            (throw (ex-info (str "theme generation stopped — undefined tokens in " theme-name ": "
                                 (str/join ", " (sort missing)))
                            {:type :theme-error})))
          (when (seq unused)                          ; Report tokens that no generator references. They do not prevent generation.
            (println "warning: no generator references these semantic tokens in" theme-name ":"
                     (str/join ", " (sort unused)))))
        (doseq [[mode theme-name] appearance-themes
                :let [tokens (load-theme theme-name)]]
          (println (str mode ": " theme-name))
          (doseq [{:keys [render output]} adapters]
            (e/write-if-changed (fs/file e/root (format output mode))
                                (render (e/->theme tokens) (str "baked-" mode)))))
        ;; Keep the preview separate from the tool generators. It references more tokens
        ;; than the tools. Its references can hide tokens that no tool generator uses.
        ;; Generate a README image for each theme.
        (doseq [n (e/theme-names)]
          (e/write-if-changed (e/preview-path n)
                              (preview/generate-preview (e/->theme (load-theme n)))))))))
