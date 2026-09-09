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
  [{:render delta/render :output "packages/git/.config/delta/ergo-light.gitconfig"}
   {:render zellij/render :output "packages/zellij/.config/zellij/themes/ergo-light.kdl"}
   {:render nvim/render :output "packages/nvim/.config/nvim/lua/colorschemes/ergo_light_palette.lua"}
   {:render wezterm/render :output "packages/wezterm/.config/wezterm/colors/ergo_light.toml"}
   {:render helix/render :output "packages/helix/.config/helix/themes/ergo_light.toml"}])

(defn check [tokens adapters]
  (let [defined (e/defined-tokens tokens)
        referenced (apply set/union (map #(e/references (:render %)) adapters))]
    {:missing (set/difference referenced defined)
     :unused (set/difference defined referenced)}))

(defn -main [& args]
  (let [tokens (json/parse-string (slurp (str e/tokens-path)))
        theme  (e/->theme tokens)]
    (if (some #{"--preview"} args)                    ; print the theme, write nothing
      (do (print (preview/preview-ansi theme)) (flush))
      (let [{:keys [missing unused]} (check tokens adapters)]
        (when (seq missing)                           ; dangling ref would crash generation — stop first
          (throw (ex-info (str "contract broken — undefined tokens: "
                               (str/join ", " (sort missing)))
                          {:type :theme-error})))
        (doseq [{:keys [render output]} adapters]
          (e/write-if-changed (fs/file e/root output) (render theme)))
        ;; Deliberately not an adapter: the preview touches far more of the
        ;; vocabulary than any tool, so the contract check would never see an
        ;; unused token again.
        (e/write-if-changed e/preview-path (preview/generate-preview theme))
        (when (seq unused)                            ; rot, not breakage — warn, don't fail
          (println "warning: unused semantic tokens:" (str/join ", " (sort unused))))))))
