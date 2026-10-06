(ns generators.delta
  (:require
   [generators.common :refer [generated-banner]]))

(defn render [theme]
  (str
   "; " generated-banner "\n"
   "; Color styles only; behavioural delta settings live in the committed .gitconfig.\n"
   "[delta]\n"
   "    syntax-theme = ansi\n"
   "    plus-style = \"syntax " (theme "diff.add") "\"\n"
   "    plus-emph-style = \"syntax " (theme "diff.addText") "\"\n"
   "    minus-style = \"syntax " (theme "diff.delete") "\"\n"
   "    minus-emph-style = \"syntax " (theme "diff.deleteText") "\"\n"
   "    hunk-header-style = \"" (theme "text.secondary") "\"\n"
   "    hunk-header-decoration-style = \"" (theme "border.default") " box\"\n"
   "    file-style = \"" (theme "text.primary") "\"\n"
   "    file-decoration-style = \"" (theme "border.default") " box\"\n"
   "    line-numbers-minus-style = \"" (theme "status.error") "\"\n"
   "    line-numbers-plus-style = \"" (theme "status.success") "\"\n"
   "    line-numbers-zero-style = \"" (theme "text.muted") "\"\n"))


