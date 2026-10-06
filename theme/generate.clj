(ns generate
  (:require
   [babashka.fs :as fs]
   [cheshire.core :as json]
   [clojure.set :as set]
   [clojure.string :as str]
   [engine :as e]
   [generators.delta :as delta]
   [generators.helix :as helix]
   [generators.nvim :as nvim]
   [generators.preview :as preview]
   [generators.wezterm :as wezterm]
   [generators.zellij :as zellij]))

(def adapters
  [{:render delta/render :output "packages/git/.config/delta/baked.gitconfig"}
   {:render zellij/render :output "packages/zellij/.config/zellij/themes/baked.kdl"}
   {:render nvim/render :output "packages/nvim/.config/nvim/lua/colorschemes/baked_palette.lua"}
   {:render wezterm/render :output "packages/wezterm/.config/wezterm/colors/baked.toml"}
   {:render helix/render :output "packages/helix/.config/helix/themes/baked.toml"}])

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
  (let [chosen     (second (drop-while #(not= "--theme" %) args))
        theme-name (or chosen (e/active-theme))
        tokens     (load-theme theme-name)
        theme      (e/->theme tokens)]
    (if (some #{"--preview"} args)                    ; print the theme, write nothing
      (do (print (preview/preview-ansi theme)) (flush))
      (let [{:keys [missing unused]} (check tokens adapters)]
        (when (seq missing)                           ; dangling ref would crash generation — stop first
          (throw (ex-info (str "contract broken — undefined tokens: "
                               (str/join ", " (sort missing)))
                          {:type :theme-error})))
        (println "theme:" theme-name)
        (doseq [{:keys [render output]} adapters]
          (e/write-if-changed (fs/file e/root output) (render theme)))
        (when chosen (spit (str e/active-path) (str chosen "\n")))
        ;; Deliberately not an adapter: the preview touches far more of the
        ;; vocabulary than any tool, so the contract check would never see an
        ;; unused token again.
        ;; One README image per theme, whichever is active, so switching themes
        ;; never dirties these tracked files.
        (doseq [n (e/theme-names)]
          (e/write-if-changed (e/preview-path n)
                              (preview/generate-preview (e/->theme (load-theme n)))))
        (when (seq unused)                            ; rot, not breakage — warn, don't fail
          (println "warning: unused semantic tokens:" (str/join ", " (sort unused))))))))
