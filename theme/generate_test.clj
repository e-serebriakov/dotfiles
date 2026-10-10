(ns generate-test
  (:require
   [babashka.fs :as fs]
   [clojure.string :as str]
   [clojure.test :refer [deftest is testing]]
   [engine :as e]
   [generate :as g]
   [generators.preview :as preview]))

(defn- theme
  ([] (theme (e/active-theme)))
  ([theme-name] (e/->theme (g/load-theme theme-name))))

(deftest repo-contract-holds
  (doseq [theme-name (e/theme-names)]
    (testing theme-name
      (let [{:keys [missing unused]} (g/check (g/load-theme theme-name) g/adapters)]
        (is (empty?  missing))
        (is (empty?  unused))))))

(deftest unknown-theme-is-fatal
  (is (thrown-with-msg? clojure.lang.ExceptionInfo #"unknown theme 'nope'"
                        (g/load-theme "nope"))))

(deftest missing-tokens-are-caught
  (let [tokens {"semantic" {"surface" {"base" {"$value" "#fff"}}}}
        adapters [{:render (fn [theme] (str (theme "surface.base") (theme "surface.nope")))}]
        {:keys [missing]} (g/check tokens adapters)]
    (is (contains? missing "surface.nope"))))

(deftest unused-tokens-are-caught
  (let [tokens {"semantic" {"surface" {"base" {"$value" "#fff"} "unused" {"$value" "#000"}}}}
        adapters [{:render (fn [theme] (theme "surface.base"))}]
        {:keys [unused]} (g/check tokens adapters)]
    (is (contains? unused "surface.unused"))))

(deftest chained-alias-resolved
  (let [theme (e/->theme
               {"primitive" {"gray" {"50" {"$value" "#fafafa"}}}
                "semantic" {"surface" {"raised" {"$value" "{primitive.gray.50}"}
                                       "base" {"$value" "{semantic.surface.raised}"}}}})]
    (is (= "#fafafa" (theme "surface.raised")))
    (is (= "#fafafa" (theme "surface.base")))))

(deftest cycle-is-fatal
  (let [theme (e/->theme {"semantic" {"a" {"$value" "{semantic.b}"}
                                      "b" {"$value" "{semantic.a}"}}})]
    (is (thrown-with-msg? clojure.lang.ExceptionInfo #"alias cycle"
                          (theme "a")))))

(deftest unknown-token-is-fatal
  (let [theme (e/->theme {"semantic" {"a" {"$value" "{semantic.nope}"}}})]
    (is (thrown-with-msg? clojure.lang.ExceptionInfo #"unknown token"
                          (theme "a")))))

;; Git tracks the generated README images.
;; Compare them with the generator output to prevent outdated images on GitHub.
(deftest preview-matches-disk
  (doseq [theme-name (e/theme-names)]
    (testing theme-name
      (let [content (preview/generate-preview (theme theme-name))
            path    (e/preview-path theme-name)]
        (is (fs/exists? path)
            (str (fs/file-name path) " is missing. Run `bb -m generate`."))
        (is (= (slurp (str path)) content)
            (str (fs/file-name path) " differs from the generated output. Run `bb -m generate`."))
        (is (str/includes? content e/generated-banner))))))

;; The ANSI and SVG previews use the same rows. Each hexadecimal color
;; in a row must appear in a truecolor sequence (2;r;g;b).
(deftest preview-ansi-emits-every-row-colour
  (let [t     (theme)
        ansi  (preview/preview-ansi t)
        rows  (:rows (preview/preview-rows t))
        hexes (->> rows
                   (mapcat (fn [{:keys [band segments] gcol :gcol}]
                             (into [gcol band]
                                   (mapcat (fn [{fg :fg hl :hl}] [fg hl]) segments))))
                   (remove nil?)
                   set)]
    (is (str/starts-with? ansi "\u001b[") "expected an opening SGR escape")
    (is (seq hexes))
    (doseq [hex hexes]
      (let [triple (str/join ";" (into [2] (e/hex->rgb hex)))]
        (is (str/includes? ansi triple) (str hex " missing from ANSI preview"))))))
