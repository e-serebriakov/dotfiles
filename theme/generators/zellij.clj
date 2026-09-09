(ns generators.zellij
  (:require
   [generators.common :refer [generated-banner]]))

(defn render [theme]
  (str
   "// " generated-banner "\n"
   "themes {\n"
   "    ergo-light {\n"
   "        fg      \"" (theme "text.primary") "\"\n"
   "        bg      \"" (theme "surface.base") "\"\n"
   "        black   \"" (theme "surface.tile") "\"\n"
   "        red     \"" (theme "status.error") "\"\n"
   "        green   \"" (theme "accent.string") "\"\n"
   "        yellow  \"" (theme "status.warning") "\"\n"
   "        blue    \"" (theme "status.info") "\"\n"
   "        magenta \"" (theme "terminal.ansi.magenta") "\"\n"
   "        cyan    \"" (theme "terminal.ansi.cyan") "\"\n"
   "        white   \"" (theme "text.secondary") "\"\n"
   "        orange  \"" (theme "accent.warm") "\"\n"
   "    }\n"
   "}\n"))


