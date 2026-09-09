(ns engine
  (:require
   [clojure.string :as str]
   [babashka.fs :as fs]))

(def root (-> *file* fs/absolutize fs/parent fs/parent))

(defn write-if-changed [path content]
  (if (and (fs/exists? path) (= (slurp path) content))
    (println "unchanged" (str (fs/relativize root path)))
    (do
      (fs/create-dirs (fs/parent path))
      (spit path content)
      (println "wrote" (str (fs/relativize root path))))))

(def tokens-path (fs/file root "theme" "ergo-light.tokens.json"))
(def preview-path (fs/file root "theme" "preview.svg"))

(defn- get-token [tokens path]
  (get-in tokens (conj (str/split path #"\.") "$value")))

(def ^:private alias-re #"^\{(.+)\}$")

(defn- resolve-token
  "Follow {alias} chains from `path` down to a concrete hex. `seen` is the
  ordered vector of ancestors visited this resolution — membership is the cycle
  check, order builds the error message."
  ([tokens path] (resolve-token tokens path []))
  ([tokens path seen]
   (when (some #{path} seen)
     (throw (ex-info (str "token alias cycle: " (str/join " -> " (conj seen path)))
                     {:type :theme-error})))
   (let [raw (get-token tokens path)]
     (when (nil? raw)
       (throw (ex-info (str "unknown token: " path) {:type :theme-error})))
     (if-let [[_ target] (re-matches alias-re raw)]
       (resolve-token tokens target (conj seen path))
       raw))))

(defn ->theme [tokens]
  (fn [path]
    (resolve-token tokens (str "semantic." path))))

(defn references [render]
  (let [seen  (atom #{})
        probe (fn [path] (swap! seen conj path) "#000000")]
    (render probe)
    @seen))

(defn- leaf-paths [node prefix]
  (if (contains? node "$value")
    [prefix]
    (mapcat (fn [[k v]]
              (when-not (str/starts-with? k "$")
                (leaf-paths v (if (empty? prefix)
                                k
                                (str prefix "." k)))))
            node)))

(defn defined-tokens [tokens]
  (->> (leaf-paths tokens "")
       (filter #(str/starts-with? % "semantic."))
       (map #(subs % (count "semantic.")))
       set))
