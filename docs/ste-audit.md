# ASD-STE100 audit of the dotfiles repository

This report records the snapshot before the wording corrections.
The subsequent correction pass updated project prose, messages, token descriptions, and shared preview text.
It also added writing conventions to docs/writing.md and removed the outdated terminal screenshot from the theme guide.
The original findings and line references below remain as the audit record, rather than a description of the corrected files.
The PNG remains an unreferenced historical image. The generated SVG previews are the maintained illustrations.
Technical-term exceptions remain contextual decisions. The correction pass does not establish certified STE compliance.

The repository does not comply with ASD-STE100 Issue 9. Its READMEs are generally concise, but documentation, comments, theme descriptions,
and messages contain confirmed departures from the writing rules and dictionary. The largest concentration is in
`theme/ergo-light.tokens.json`.

This audit covers the working-tree snapshot on October 7, 2026, based on commit `ecfc7e89ea5e3443fede25c660e2ac1e7d7d5b79`. It includes the
existing modifications to `bootstrap/Brewfile`, `packages/wezterm/.wezterm.lua`, and `packages/zsh/.zshrc`, and the untracked Git ignore
file. Findings refer to that snapshot. The audit itself did not change source files.

The audit covers all 78 repository files in the inventory below. It examines prose in documentation, code comments, docstrings, JSON
descriptions, messages, interface labels, and the three preview images. Executable syntax, identifiers, literal commands, lockfile data, and
external product names are not rewritten as ordinary English. Generated theme files were checked through their generators; caches, logs, Git
internals, and private local settings are outside the maintained-source scope.

The findings distinguish confirmed departures from terminology and editorial decisions. This is a repository-wide manual audit, not a
certificate that every remaining word is compliant. Suggested corrections address the identified defect; they are not independently
certified replacement documents.

## Reference and interpretation

The reference is the complete [official ASD-STE100 Issue 9 standard and
dictionary](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf), dated January 15, 2025. The complete PDF was obtained and its
text searched. Rule and dictionary references below refer to that edition.

The main controls are vocabulary and contextual meanings (section 1), noun groups (2), verb grammar (3), sentence construction (4),
procedures (5), descriptions (6), safety instructions (7), punctuation and counting (8), and writing practices (9). Procedures have a
20-word sentence limit; descriptions have a 25-word limit and six-sentence paragraph limit. Counting follows section 8, including its
treatment of parenthetical material, quoted text, identifiers, and hyphenated words. Ordinary multiword technical nouns do not automatically
count as one word. Computer terminology can qualify under rules 1.5 and 1.12. Headings and labels are not automatically defective fragments.
These distinctions are applied throughout this audit. [Source](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf)

## Findings in procedures and documentation

| ID | Location | Finding and rule | Suggested correction |
| --- | --- | --- | --- |
| D01 | [README.md:12](</Users/eserebriakov/source_code/dotfiles/README.md:12>) | “Clone the repository and run the setup script” combines sequential instructions (5.2). | Give cloning, changing directories, and starting the script separate steps, with their commands. |
| D02 | [README.md:39](</Users/eserebriakov/source_code/dotfiles/README.md:39>) | “Correct the error, then run…” and “install it and run setup again” each combine sequential instructions (5.2). | “Correct the error. Run `mise install --locked`.” Give the missing-mise condition and installation as separate steps. |
| D03 | [README.md:151](</Users/eserebriakov/source_code/dotfiles/README.md:151>) | Testing, reviewing, and committing are successive actions in one sentence (5.2). | “Do the tool tests. Review the lockfile. Commit the lockfile.” |
| D04 | [theme/README.md:49](</Users/eserebriakov/source_code/dotfiles/theme/README.md:49>) | Editing the token file and starting the commands are successive instructions (5.2). | “Edit a token file. From the repository root, use these commands:” |
| D05 | [packages/zellij/.config/zellij/README.md:37](</Users/eserebriakov/source_code/dotfiles/packages/zellij/.config/zellij/README.md:37>) | Unlocking and using the default keys are successive instructions in one sentence (5.2). | “Press `Ctrl+g` to enter normal mode. Use the default Zellij keys:” Put the key descriptions in a list. |
| D06 | [README.md:11](</Users/eserebriakov/source_code/dotfiles/README.md:11>), [README.md:163](</Users/eserebriakov/source_code/dotfiles/README.md:163>), README line 45, [theme/README.md:69](</Users/eserebriakov/source_code/dotfiles/theme/README.md:69>) | “before using,” “before committing,” “without installing,” and “before reloading” use action participles (3.5). | “before you use,” “before you commit,” “does not install,” and “before you reload.” Other word choices in these sentences still need the vocabulary corrections below. |
| D07 | [theme/README.md:10](</Users/eserebriakov/source_code/dotfiles/theme/README.md:10>), lines 58, 69 | “switching themes,” “without writing files,” and “reloading tools” describe actions, not names of components (3.5). | “when you change themes,” “The preview does not write files,” and “before you reload the tools.” |
| D08 | [packages/claude/.claude/CLAUDE.md:20](</Users/eserebriakov/source_code/dotfiles/packages/claude/.claude/CLAUDE.md:20>), lines 21–23 and 30 | “When creating,” “Before proposing,” “When viewing,” and “without asking” use action participles (3.5). | Use clauses with an actor: “When you create…”, “Before you propose…”, “When you view…”. For line 30: “Get permission before you add a pip or npm dependency.” |
| D09 | [theme/README.md:9](</Users/eserebriakov/source_code/dotfiles/theme/README.md:9>), [README.md:181](</Users/eserebriakov/source_code/dotfiles/README.md:181>) | The selection “is saved” and “is remembered,” although the writer can identify the program that stores it (3.6). | “The generator stores the selected theme in `theme/.active`.” |
| D11 | [README.md:76](</Users/eserebriakov/source_code/dotfiles/README.md:76>) | “surrounding” is not approved for this meaning; “context” also needs a precise software definition (1.1–1.3). | “The position of `Include` determines which `Host` or `Match` block applies to it.” Preserve the following instruction about global scope. |
| D12 | [packages/claude/.claude/CLAUDE.md:22](</Users/eserebriakov/source_code/dotfiles/packages/claude/.claude/CLAUDE.md:22>), [packages/claude/.claude/CLAUDE.md:11](</Users/eserebriakov/source_code/dotfiles/packages/claude/.claude/CLAUDE.md:11>) | General-purpose “ensure” and “via” are unapproved dictionary entries (1.1). | “make sure that” and “through,” respectively. The command literals stay unchanged. |

The Zellij session-name description at line 24 is 21 words under ordinary counting and is descriptive text. It is not a confirmed length
violation. Similarly, counting the spaces inside `git town diff-parent` as separate ordinary words would exaggerate the length of the Claude
instruction at line 23. Its participle and vocabulary problems remain, but the raw whitespace total alone does not establish a rule 5.1
violation.

## Findings in scripts and editor instructions

| ID | Location | Finding and rule | Suggested correction |
| --- | --- | --- | --- |
| S01 | [bootstrap/install.sh:52](</Users/eserebriakov/source_code/dotfiles/bootstrap/install.sh:52>), lines 59, 117, 121, 134, 173, 177 | Action forms include “overwriting,” “restoring,” “stowing,” “moving,” “reverting,” “resolving,” and “installing” (3.5). | Use clauses such as “Do not overwrite local plugin changes” and “After you correct the error, use `mise install --locked`.” At line 177, state the installation prerequisite before the retry instruction. |
| S02 | [bootstrap/install.sh:28](</Users/eserebriakov/source_code/dotfiles/bootstrap/install.sh:28>), lines 36, 49, 71, 76, 107, 109, 145, 148, 160, 167, 169; [bootstrap/linux.sh:8](</Users/eserebriakov/source_code/dotfiles/bootstrap/linux.sh:8>); [bootstrap/macos.sh:10](</Users/eserebriakov/source_code/dotfiles/bootstrap/macos.sh:10>), lines 29, 36, 40 | Progress messages repeatedly present ongoing actions as “Installing…”, “Restoring…”, “skipping…”, and similar forms (3.5). | Use complete present-tense messages, for example “Setup installs mise.” For genuine status labels, use explicit noun labels such as “mise installation”; do not treat every label as a sentence. |
| S03 | [bootstrap/install.sh:105](</Users/eserebriakov/source_code/dotfiles/bootstrap/install.sh:105>) | The comment instructs installation now and installation of the remaining tools later in one sentence (5.2). | “Install Babashka before Stow creates the links. Install the other tools after Stow creates the links.” |
| S04 | [bootstrap/macos.sh:19](</Users/eserebriakov/source_code/dotfiles/bootstrap/macos.sh:19>) | “when first adding a key” omits the actor and uses an action participle (3.5, 4.2). | “When the script adds a key for the first time, it requests a passphrase.” |
| S05 | [packages/git/.gitconfig:20](</Users/eserebriakov/source_code/dotfiles/packages/git/.gitconfig:20>), [packages/nvim/.config/nvim/lua/colorschemes/baked.lua:4](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/lua/colorschemes/baked.lua:4>) | Editing and regenerating are successive instructions in one sentence (5.2). | “Edit the tokens. From `theme/`, use `bb -m generate`.” |
| S06 | [packages/nvim/.config/nvim/init.lua:1](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/init.lua:1>), [packages/nvim/.config/nvim/lua/plugins/autopairs.lua:7](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/lua/plugins/autopairs.lua:7>), [packages/nvim/.config/nvim/lua/plugins/cmp.lua:85](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/lua/plugins/cmp.lua:85>), [packages/nvim/.config/nvim/lua/plugins/minivim.lua:23](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/lua/plugins/minivim.lua:23>) | “before loading,” “after accepting,” “selecting choice nodes,” and “while recording” are action participles (3.5). | Give the actor and a finite verb, for example “Set the leader keys before you load plugins” and “while you record a macro.” |
| S07 | [packages/nvim/.config/nvim/lua/plugins/lsp.lua:86](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/lua/plugins/lsp.lua:86>), line 216 | These comments combine actions with different triggers, or instructions followed by a different instruction (5.2). | Describe the actual behavior in present tense, or give one command per sentence. For line 86: “Highlight references on `CursorHold`. Clear the highlights when the cursor moves.” |
| S08 | [packages/zsh/.zshrc:18](</Users/eserebriakov/source_code/dotfiles/packages/zsh/.zshrc:18>), lines 71, 224, 225 | “stating,” “when completing,” “containing,” and “from reading” are action participles (3.5). | For example: “The lockfile contains `workspaceFolders`.” “If no lockfile exists, `/dev/null` prevents `grep` from waiting for standard input.” |
| S09 | [packages/zsh/.zshrc:19](</Users/eserebriakov/source_code/dotfiles/packages/zsh/.zshrc:19>), [packages/nvim/.config/nvim/lua/plugins/lsp.lua:18](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/lua/plugins/lsp.lua:18>) | “Set before plugins…” omits what to set. “Initialize it before dependent plugins” omits the second action (4.2). | “Set Vi mode before you load plugins and Starship.” “Initialize Mason before you load plugins that use Mason.” |
| S10 | [packages/zsh/.zshrc:201](</Users/eserebriakov/source_code/dotfiles/packages/zsh/.zshrc:201>) | “could not resolve” has no grammatical subject; “cd there” and “zoxide learns it” use shorthand and personification (4.1, 4.2, 1.3). | “zoxide cannot find '$1'. Use `cd` to open the project directory once. This adds the directory to zoxide.” |
| S11 | [packages/nvim/.config/nvim/lua/colorschemes/baked.lua:276](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/lua/colorschemes/baked.lua:276>), [bootstrap/install.sh:170](</Users/eserebriakov/source_code/dotfiles/bootstrap/install.sh:170>) | “stale render-markdown code block borders” and “GitHub rate limit errors” have dense modifier sequences (2.1–2.2). | “old borders around code blocks in render-markdown”; “errors caused by GitHub rate limits.” Preserve `render-markdown` and GitHub as product names. |
| S12 | [packages/aerospace/.aerospace.toml:93](</Users/eserebriakov/source_code/dotfiles/packages/aerospace/.aerospace.toml:93>), line 132; [packages/nvim/.config/nvim/lua/plugins/lsp.lua:76](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/lua/plugins/lsp.lua:76>) | “Move node to workspace,” “reset layout,” and “some lsp support methods…” omit necessary sentence parts (4.2, 4.5). | “Move the node to a workspace.” “Reset the layout.” Keep `---@param bufnr? integer` intact, but change its description to “Some language servers support methods only for specified files.” |
| S13 | [packages/nvim/.config/nvim/lua/plugins/lsp.lua:8](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/lua/plugins/lsp.lua:8>), [packages/nvim/.config/nvim/init.lua:126](</Users/eserebriakov/source_code/dotfiles/packages/nvim/.config/nvim/init.lua:126>) | The procedural comments use “is found” and “are set up” instead of naming the action and actor (3.6). | “When `vim.uv` occurs in the source, load the luvit types.” “Load the baked colorscheme after Neovim initializes the plugins.” |

Some comments describe an automatic action using an imperative. A descriptive sentence is often the clearer correction. For example, a
keybinding comment can explain what pressing the key does, rather than appear to instruct the maintainer to perform that action while
editing the file.

## Theme descriptions and generators

| ID | Location | Finding and rule | Suggested correction |
| --- | --- | --- | --- |
| T01 | [theme/ergo-light.tokens.json:3](</Users/eserebriakov/source_code/dotfiles/theme/ergo-light.tokens.json:3>) | The introduction combines architecture, interpolation, contrast, chroma, and appearance. Its long sentences and topic changes violate 6.3 and 6.5. It also contains fragments, a semicolon, and nonliteral terms. | Separate the architecture from the color calculations. Give each numerical design constraint its own sentence. Keep the values, units, and comparison backgrounds. |
| T02 | [theme/ergo-light.tokens.json:5](</Users/eserebriakov/source_code/dotfiles/theme/ergo-light.tokens.json:5>) | The primitive description combines multiple chroma ranges, foreground constraints, and exceptions in long sentences (6.3, 6.5). | Use separate paragraphs for steps 50–200, steps 300–700, and the foreground contrast restriction. Explain the transition numerically. |
| T03 | [theme/ergo-light.tokens.json:22](</Users/eserebriakov/source_code/dotfiles/theme/ergo-light.tokens.json:22>), line 50 | The red and amber descriptions contain long causal chains and color metaphors (6.3, 4.1, 1.3). | State the hue range, the reason for the selection, and the comparison separately. Replace “kill the brown cast” with a literal explanation of the intended color appearance. |
| T04 | [theme/ergo-light.tokens.json:120](</Users/eserebriakov/source_code/dotfiles/theme/ergo-light.tokens.json:120>) | The alert description has nine sentences in a single paragraph, long sentences, contractions, and metaphorical explanations (6.6, 6.3, 4.2). | Separate the alert color value, permitted uses, accessibility rationale, and warning comparison. Retain the distinction between marks and diagnostic text. |
| T05 | [theme/ergo-light.tokens.json:125](</Users/eserebriakov/source_code/dotfiles/theme/ergo-light.tokens.json:125>) | The semantic description combines the alias architecture, hue meanings, and color-vision considerations (6.3, 6.5). | Give the alias rule first. Put role-to-color mappings in a list. Explain the lightness and shape distinctions separately. |
| T06 | [theme/ergo-light.tokens.json:190](</Users/eserebriakov/source_code/dotfiles/theme/ergo-light.tokens.json:190>), lines 203, 206, 216 | Long explanations still exceed 25 words after parenthetical groups and identifiers are treated conservatively (6.3). | Split conditions, measurements, and conclusions into separate sentences. See the counted examples below. |
| T07 | [theme/ergo-light.tokens.json:190](</Users/eserebriakov/source_code/dotfiles/theme/ergo-light.tokens.json:190>), lines 205, 216 | Action forms include “shouting,” “mirroring,” “making,” “breaking,” and “passing” (3.5). | Give the actor and a finite verb. For example, replace “without making the whole line loud” with a statement that the emphasis applies only to the changed text. Review each clause, not every word ending in `ing`. |
| T08 | [theme/ergo-light.tokens.json:3](</Users/eserebriakov/source_code/dotfiles/theme/ergo-light.tokens.json:3>), lines 5, 8, 22, 50, 120, 125, 158, 178, 184, 185, 190, 206, 207, 212, 216; [theme/te-calm.tokens.json:3](</Users/eserebriakov/source_code/dotfiles/theme/te-calm.tokens.json:3>), line 305 | “paper,” “ink,” “whisper,” “shouts,” “loud,” “bites apps,” “pops,” “out-reads,” and similar expressions mix names, metaphor, and physical descriptions (1.1–1.3, 4.1). | Define genuine design terms once. Elsewhere name the property: foreground, background, chroma, luminance, contrast ratio, or affected element. Do not invent new numerical claims during the rewrite. |
| T09 | [theme/ergo-light.tokens.json:216](</Users/eserebriakov/source_code/dotfiles/theme/ergo-light.tokens.json:216>) | “The 'white' channels…” combines ordering, contrast, and a conclusion in one sentence of at least 45 conservatively counted words (6.3). | Give the color-15 ordering requirement first. Give the contrast limitation second. Give the selected values and their contrast ratios separately. |
| T10 | [theme/generate.clj:52](</Users/eserebriakov/source_code/dotfiles/theme/generate.clj:52>), lines 53–56, 60; [theme/generate_test.clj:15](</Users/eserebriakov/source_code/dotfiles/theme/generate_test.clj:15>), lines 17, 24, 69, 78, 81–82 | “touches … vocabulary,” “dirties,” “rot,” “heart,” “drifted,” “ship,” and “show up” are compressed metaphors or phrasal constructions (1.3, 4.1, 9.3). | For example: “The preview references more tokens than the tool generators.” “Theme changes do not change these tracked files.” “The generated output differs from this file.” |
| T11 | [theme/engine.clj:42](</Users/eserebriakov/source_code/dotfiles/theme/engine.clj:42>), lines 43–44; [theme/generators/nvim.clj:6](</Users/eserebriakov/source_code/dotfiles/theme/generators/nvim.clj:6>), lines 7–8 | “concrete hex,” “ancestors visited this resolution,” and “requires()s” compress the explanation or turn syntax into prose (4.1, 4.2). | “Follow the token aliases until the value is a hexadecimal color.” “The `seen` vector contains the tokens visited during this call.” “The palette keys must match the keys that the colorscheme reads.” |
| T12 | [theme/generators/preview.clj:73](</Users/eserebriakov/source_code/dotfiles/theme/generators/preview.clj:73>), lines 74, 101–102, 115–116, 133–134, 187–188, 201–202 | Several docstrings are fragments or metaphors: “Locale/ROOT because…”, “One segment rendered…”, “self-portrait,” “degrades” (4.1, 4.2). | Give each function a complete description. For example: “Use `Locale/ROOT` so that coordinates use a period as the decimal separator.” Describe the underline fallback directly. |
| T13 | [theme/generators/zellij.clj:6](</Users/eserebriakov/source_code/dotfiles/theme/generators/zellij.clj:6>), lines 7–14, 36; [theme/generators/delta.clj:8](</Users/eserebriakov/source_code/dotfiles/theme/generators/delta.clj:8>) | The explanations combine spelling departures, a contraction, a semicolon, and terms such as “borrowing” and “live” (1.14, 4.2, 8.1, 1.3). | “Each component has a specified color.” “Do not enable `simplified_ui` with `status-bar`.” “The committed `.gitconfig` contains the delta behavior settings.” |
| T14 | [theme/generators/preview.clj:30](</Users/eserebriakov/source_code/dotfiles/theme/generators/preview.clj:30>), lines 37, 42; both SVG files and the PNG screenshot | Preview prose contains “down to a hex,” “AA on paper,” and “live selection” without clear definitions (1.1–1.3, 4.1). | “Resolve the alias to a hexadecimal color.” “Measure the contrast against the background.” “Selected line.” If AA is important, name the applicable contrast criterion. Update the generator before regenerating the SVGs; replace the screenshot separately. |
| T15 | [theme/generate.clj:55](</Users/eserebriakov/source_code/dotfiles/theme/generate.clj:55>), [theme/generators/zellij.clj:7](</Users/eserebriakov/source_code/dotfiles/theme/generators/zellij.clj:7>) | “switching themes” and “borrowing a palette slot” use action participles (3.5). | “when you change themes”; state that each component uses its own specified color. |

The token descriptions also contain technical claims about contrast, color-vision simulations, and optimization. This language audit does
not validate those calculations. A rewrite must preserve their stated conditions and uncertainty rather than strengthen the claims.

## Counted length examples

These counts collapse parenthetical material to one word, omit standalone punctuation, count a hyphenated form as one word, and
conservatively treat quoted text and identifiers such as “color 15” as one word. The parenthetical text can itself require an additional
sentence check. The examples are not raw source-line lengths.

| Location | Sentence opening | Conservative count | Result |
| --- | --- | --- | --- |
| `theme/ergo-light.tokens.json:216` | “The 'white' channels are a hard light-theme constraint…” | At least 45 | Exceeds 25. |
| `theme/ergo-light.tokens.json:203` | “word-level emphasis inside an added line…” | At least 33 | Exceeds 25 even if treated as a description rather than a sentence fragment. |
| `theme/ergo-light.tokens.json:190` | “The prominence comments get in this theme…” | At least 35 | Exceeds 25. |

The descriptions on lines 3, 5, 22, 50, 120, 125, 190, 203, 206, and 216 need sentence-by-sentence restructuring, rather than line wrapping.
A line-length formatter cannot correct these problems.

## Repeated mechanical findings

The following occurrence lists identify the source locations to change. A line can contain more than one occurrence. Generated copies are
not counted as separate authoring defects.

### Semicolons in prose

Rule 8.1 applies to prose punctuation. Replace each listed semicolon with separate sentences or a suitable list. Do not change shell or Lua
syntax, Clojure comment delimiters, KDL syntax, or the ANSI sample `(2;r;g;b)`.

| File | Lines |
| --- | --- |
| `.gitignore` | 16 |
| `README.md` | 12, 45, 95, 176, 181 |
| `bootstrap/Brewfile` | 1, 4, 7 |
| `bootstrap/install.sh` | 59, 86, 117, 171 |
| `bootstrap/macos.sh` | 38 |
| `packages/git/.gitconfig` | 19 |
| `packages/nvim/.config/nvim/init.lua` | 51 |
| `packages/nvim/.config/nvim/lua/colorschemes/baked.lua` | 123, 214, 252 |
| `packages/nvim/.config/nvim/lua/plugins/claudecode.lua` | 3 |
| `packages/nvim/.config/nvim/lua/plugins/conform.lua` | 29 |
| `packages/nvim/.config/nvim/lua/plugins/lsp.lua` | 70, 86, 190, 216 |
| `packages/wezterm/.wezterm.lua` | 21 |
| `packages/zellij/.config/zellij/config.kdl` | 2, 38, 40 |
| `packages/zellij/.config/zellij/layouts/work.kdl` | 1 |
| `packages/zsh/.zshrc` | 18, 24, 40, 43, 71, 208 |
| `theme/README.md` | 60 |
| `theme/ergo-light.tokens.json` | 3, 5, 8, 50, 64, 120, 125, 154, 167, 173, 180, 184, 185, 189, 190, 202, 204, 216 |
| `theme/generators/delta.clj` | 8 |
| `theme/te-calm.tokens.json` | 372 |

### Contractions

Rule 4.2 applies to these occurrences. Possessives such as “Zellij's” and “repository's” are not contractions.

| File | Lines | Correction |
| --- | --- | --- |
| `packages/zellij/.config/zellij/README.md` | 38 | `won't` → `will not` |
| `packages/zsh/.zshrc` | 176 | `isn't` → `is not` |
| `packages/nvim/.config/nvim/lua/plugins/minivim.lua` | 39 | `doesn't` → `does not` |
| `theme/ergo-light.tokens.json` | 120 | `isn't` → `is not` |
| `theme/generate.clj` | 60 | `don't` → `do not` |
| `theme/generate_test.clj` | 16 | `isn't` → `is not` |
| `theme/generators/zellij.clj` | 13 | `Don't` → `Do not` |

### American spelling

No repository directive authorizes British spelling. Apply rule 1.14 to the following prose, while preserving identifiers and exact names.

| File | Lines |
| --- | --- |
| `packages/lazydocker/Library/Application Support/jesseduffield/lazydocker/config.yml` | 2, 5, 6 |
| `packages/nvim/.config/nvim/lua/colorschemes/baked.lua` | 27, 39, 214 |
| `packages/nvim/.config/nvim/lua/plugins/gitsigns.lua` | 6 |
| `packages/nvim/.config/nvim/lua/plugins/lsp.lua` | 127 |
| `packages/nvim/.config/nvim/lua/plugins/todo-comments.lua` | 6 |
| `theme/README.md` | 6 |
| `theme/ergo-light.tokens.json` | 3, 5, 8, 22, 50, 125, 136, 216 |
| `theme/generators/delta.clj` | 8 |
| `theme/generators/preview.clj` | 136, 201 |
| `theme/generators/zellij.clj` | 7, 8, 36 |
| `theme/te-calm.tokens.json` | 3, 305 |

Use `color`, `colored`, `gray`, `grays`, `centered`, `behavioral`, `equalize`, and `uncolored` as appropriate. Rewrite a phrase if a
spelling change alone leaves an unclear metaphor.

Do not rename the `grey` API key in `octo.lua`, the test identifier `preview-ansi-emits-every-row-colour`, or any external configuration
property solely to make its spelling American. These are code identifiers, not spelling mistakes in explanatory prose.

## Dictionary findings

The entries below were checked against Part 2 of Issue 9. They identify ordinary-language uses that need attention. The occurrence column is
an index, not a count of violations: it also includes labels, other parts of speech, and technical-term exceptions explicitly identified in
the middle column. Changes must preserve the original meaning. For example, replacing “unused tokens” with “new tokens” would be technically
wrong even though the dictionary offers “new” in a different context. Use “tokens that no generator references” for this repository.

`ensure` is on dictionary page 2-1-E7, `via` on 2-1-V2, `run` on 2-1-R17, `generate` on 2-1-G3, and `drift` on 2-1-D18. The last three
require software-context judgment; they are not universal text substitutions. [Dictionary
source](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf)

| Word or family | Correction or contextual decision | Source occurrences |
| --- | --- | --- |
| already | Remove it where redundant; otherwise state the existing condition. | `README.md`: 51; `bootstrap/install.sh`: 33; `bootstrap/macos.sh`: 9, 19, 27; `packages/nvim/.config/nvim/init.lua`: 15; `packages/nvim/.config/nvim/lua/colorschemes/baked.lua`: 270; `packages/zsh/.zshrc`: 191 |
| another | Use “a different” or “one more,” according to the intended meaning. | `README.md`: 150; `bootstrap/install.sh`: 121; `theme/README.md`: 52; `theme/ergo-light.tokens.json`: 190 |
| any | Usually omit it or state the range explicitly. “You can clone the repository into a directory of your choice” also needs a correction for “choice”; prefer a direct statement about the permitted location. | `README.md`: 12, 67; `theme/README.md`: 60; `theme/ergo-light.tokens.json`: 5; `theme/generate.clj`: 53; `theme/generators/preview.clj`: 115 |
| both | Name the two platforms, or use “the two.” Recast the final-position use in the token description. | `README.md`: 30; `bootstrap/install.sh`: 30; `packages/nvim/.config/nvim/lua/colorschemes/baked.lua`: 252; `theme/ergo-light.tokens.json`: 206 |
| choice | Use “selection.” Retain “choice node” only as a defined LuaSnip technical term. | `README.md`: 181; `packages/nvim/.config/nvim/lua/plugins/cmp.lua`: 85; `theme/README.md`: 9; `theme/ergo-light.tokens.json`: 216 |
| complete | Use “full” for the tool list and “completed” for setup status. The verb “complete” is different and is not rejected. | `README.md`: 203; `bootstrap/linux.sh`: 12; `bootstrap/macos.sh`: 43 |
| enough | Use “sufficient,” or state the actual limit. | `theme/ergo-light.tokens.json`: 5, 22 |
| ensure | Use “make sure that.” | `packages/claude/.claude/CLAUDE.md`: 22 |
| entire | Use “full” or “all.” | `packages/claude/.claude/CLAUDE.md`: 23 |
| entirely | Use “fully,” or state the relationship without the adverb. | `theme/ergo-light.tokens.json`: 190 |
| every | Use “each” or “all.” Review compounds and quoted labels separately. | `packages/lazydocker/Library/Application Support/jesseduffield/lazydocker/config.yml`: 5; `packages/nvim/.config/nvim/init.lua`: 51; `theme/README.md`: 29, 62; `theme/engine.clj`: 26; `theme/ergo-light.tokens.json`: 3, 5, 8, 120, 125; `theme/generate_test.clj`: 15, 81; `theme/generators/preview.clj`: 73; `theme/generators/zellij.clj`: 13 |
| exact | For the revision, use “specified.” An equality comparison such as “exact match” needs a technical definition, not an inaccurate substitute. | `bootstrap/install.sh`: 52; `packages/zsh/.zshrc`: 226 |
| exactly | Usually remove it or state the equality. “Accurately” is not an appropriate replacement for every occurrence. | `theme/ergo-light.tokens.json`: 5, 120, 205; `theme/generators/nvim.clj`: 7 |
| except | State the exception in a separate sentence. For example: “Mason installs the configured servers. It does not install Biome.” | `packages/nvim/.config/nvim/lua/plugins/lsp.lua`: 34; `packages/zellij/.config/zellij/README.md`: 31 |
| extra | Use “more” or “additional.” | `theme/ergo-light.tokens.json`: 50; `theme/generators/preview.clj`: 67 |
| faint | Describe the low contrast or give the contrast ratio. Do not substitute “dim” if that changes the color meaning. | `theme/ergo-light.tokens.json`: 204, 205 |
| foreign | For the path warning, say “outside the packages directory.” For the color, specify the hue distinction. | `bootstrap/install.sh`: 145; `theme/ergo-light.tokens.json`: 120 |
| inactive | Technical-term decision for “inactive selection.” Otherwise use “not active.” | `theme/ergo-light.tokens.json`: 179 |
| independent | Technical-term decision for “independent feature branch.” Recast the delay explanation as “This delay does not depend on…” | `packages/claude/.claude/CLAUDE.md`: 21; `packages/nvim/.config/nvim/lua/plugins/which-key.lua`: 6 |
| inside | Use “in” or “into” in ordinary prose. Preserve an exact editor text-object name. | `packages/nvim/.config/nvim/lua/plugins/minivim.lua`: 4; `packages/nvim/.config/nvim/lua/plugins/octo.lua`: 1; `packages/zsh/.zshrc`: 191; `theme/README.md`: 29; `theme/ergo-light.tokens.json`: 178, 203, 205, 207 |
| inspect | Use “examine” for visual examination. | `packages/nvim/.config/nvim/lua/plugins/lsp.lua`: 216; `theme/README.md`: 69 |
| instead | Recast with “as an alternative” or directly state which item the tool uses. Includes “instead of.” | `.gitignore`: 16; `packages/nvim/.config/nvim/lua/plugins/todo-comments.lua`: 6; `packages/wezterm/.wezterm.lua`: 76; `theme/generators/zellij.clj`: 7 |
| just | Use “only” when that is the meaning, or remove the word. | `packages/wezterm/.wezterm.lua`: 21; `theme/ergo-light.tokens.json`: 3, 22, 120, 134, 190 |
| little | State that chroma is low; do not preserve the “leaves little hue” metaphor. | `theme/ergo-light.tokens.json`: 178 |
| main | Use “primary” for an ordinary modifier. Preserve the literal Git branch name `main`. | `README.md`: 91; `packages/claude/.claude/CLAUDE.md`: 15, 21, 24; `packages/nvim/.config/nvim/lua/plugins/lsp.lua`: 14; `packages/nvim/.config/nvim/lua/plugins/treesitter.lua`: 6; `packages/starship/.config/starship.toml`: 15 |
| major | Define which changes require a new screenshot; “major” has no objective threshold here. | `theme/README.md`: 75 |
| never | Use “do not” for prohibitions and “does not” for behavior. Avoid a mechanical substitution in fragments. | `packages/claude/.claude/CLAUDE.md`: 19, 30, 31; `theme/README.md`: 10, 30; `theme/ergo-light.tokens.json`: 64, 92, 125, 154, 158, 173, 190, 216; `theme/generate.clj`: 53, 56; `theme/generators/helix.clj`: 7; `theme/te-calm.tokens.json`: 372 |
| now | State the stage in the procedure, or omit an unnecessary time reference. | `bootstrap/install.sh`: 105; `theme/ergo-light.tokens.json`: 3, 50 |
| omit | For the command argument: “Do not specify a tool name to update all tools…” Preserve the version-range condition. | `README.md`: 150 |
| over | Use “through SSH” for the transport. Preserve the debugger label “Step Over.” | `packages/git/.gitconfig`: 24; `packages/nvim/.config/nvim/lua/plugins/debug.lua`: 52; `theme/README.md`: 69 |
| per | Use “for each,” with appropriate sentence restructuring. | `README.md`: 99, 101; `packages/nvim/.config/nvim/init.lua`: 78; `theme/README.md`: 33, 43; `theme/ergo-light.tokens.json`: 3; `theme/generate.clj`: 55; `theme/generators/zellij.clj`: 6 |
| persistent | Define the display state or explain how long the text remains. Retain only as an established technical modifier where justified. | `theme/ergo-light.tokens.json`: 120, 125 |
| place | For the instruction in README line 77, use “put.” The noun “place” in the alert description is a different part of speech. | `README.md`: 77; `theme/ergo-light.tokens.json`: 120 |
| precisely | Remove it where it only emphasizes the reason. | `theme/ergo-light.tokens.json`: 120 |
| require, required, requires | Use a construction with “necessary” or “must.” Do not alter Lua `require()` or `requires()` syntax. | `README.md`: 29, 45, 93, 166; `bootstrap/Brewfile`: 4, 7; `packages/mise/.config/mise/config.toml`: 2, 3; `packages/nvim/.config/nvim/lua/plugins/debug.lua`: 9; `theme/generators/nvim.clj`: 8 |
| residual | Use “remaining.” | `theme/ergo-light.tokens.json`: 184 |
| routine | Use “usual,” or state which upgrades setup omits. | `README.md`: 166 |
| slightly | Give the actual difference or describe its direction without an unquantified degree. | `theme/ergo-light.tokens.json`: 206 |
| specific | Use “specified” for a user-selected path or pull request. State the actual functions of the emphasis slots. | `packages/zellij/.config/zellij/README.md`: 21; `packages/zsh/.zshrc`: 149, 187; `theme/generators/zellij.clj`: 9 |
| still | Use “continues to,” “stays,” or restructure the sentence. | `theme/ergo-light.tokens.json`: 22, 120, 207 |
| surrounding | Use “adjacent” where accurate; otherwise name the containing block or nearby comments. | `README.md`: 76; `theme/ergo-light.tokens.json`: 191 |
| therefore | Use “thus.” | `theme/ergo-light.tokens.json`: 216 |
| toward | Use “to” or an explicit description of the direction. | `theme/ergo-light.tokens.json`: 3, 5, 50 |
| under | In ordinary prose, use “below” or name the containing block. For simulations, state “in the simulation.” Preserve actual UI labels and code. | `README.md`: 77; `packages/zellij/.config/zellij/config.kdl`: 40; `theme/ergo-light.tokens.json`: 22, 125, 154, 178, 184, 185, 203, 206; `theme/generators/preview.clj`: 73 |
| uniform | Use “equal” or “constant,” according to whether values are compared across hues or across steps. | `theme/ergo-light.tokens.json`: 3 |
| unused | Terminology decision: “unused token” is a plausible computer term. “Tokens that no generator references” gives the precise local meaning. Do not change this to “new tokens.” | `theme/README.md`: 44, 85; `theme/generate.clj`: 54, 61 |
| usage | Rename the documentation heading to “Operation” or “Use the sessions.” `Usage:` in conventional command-line help can remain a help label; it is not ordinary narrative. | `bootstrap/install.sh`: 21; `packages/zellij/.config/zellij/README.md`: 9; `packages/zsh/.zshrc`: 186 |
| via | Use “through.” | `packages/claude/.claude/CLAUDE.md`: 11 |
| visible | Use a clause with “see,” or describe the measured contrast. | `theme/ergo-light.tokens.json`: 131, 204, 205 |
| way | Recast “That way…” as a direct consequence, for example “Thus, the tool configuration does not change…” | `theme/README.md`: 30 |
| whichever | Recast as “for all themes” or “The name does not depend on the active theme.” | `theme/README.md`: 29; `theme/generate.clj`: 55 |
| whole | Use “full,” “all,” or remove it. | `theme/ergo-light.tokens.json`: 50, 120, 125, 205; `theme/generate_test.clj`: 15 |
| within | Use “in,” a stated upper limit, or an explicit range, according to the sentence. | `README.md`: 150; `packages/zsh/.zshrc`: 207; `theme/ergo-light.tokens.json`: 5, 207 |
| would | Rewrite hypothetical behavior as a condition and result. Preserve the condition; do not turn a hypothetical result into an unconditional statement. | `packages/claude/.claude/CLAUDE.md`: 23; `packages/mise/.config/mise/config.toml`: 3; `theme/ergo-light.tokens.json`: 120, 125, 206; `theme/generate.clj`: 44, 53; `theme/generate_test.clj`: 69; `theme/generators/preview.clj`: 73 |
| preserve, preserves | Use “keep” for retaining paths, files, links, or ordering. Keep a specialized technical verb only if the general wording is insufficient. | `README.md`: 51, 54; `bootstrap/install.sh`: 142; `theme/ergo-light.tokens.json`: 216; `theme/generators/helix.clj`: 209 |
| follow, follows | Use “obey” for an instruction pattern, or “use the same colors” for the theme relation. Alias traversal can be a separately defined software operation. | `packages/claude/.claude/CLAUDE.md`: 26; `packages/lazydocker/Library/Application Support/jesseduffield/lazydocker/config.yml`: 2; `theme/README.md`: 37; `theme/engine.clj`: 42 |
| work, works | For behavior, state “operates” or the actual result. Do not change the noun “work,” the `work` layout, or the tab name. | `bootstrap/install.sh`: 86; `packages/claude/.claude/CLAUDE.md`: 5, 20; `packages/zellij/.config/zellij/README.md`: 31; `packages/zellij/.config/zellij/layouts/work.kdl`: 2; `packages/zsh/.zshrc`: 185, 226; `theme/README.md`: 12 |

Additional contextual meaning issues:

| Location | Text | Disposition |
| --- | --- | --- |
| `packages/nvim/.config/nvim/lua/plugins/minivim.lua:39` | “as you move” | This is a temporal conjunction rather than the approved preposition. Use “when you move the cursor.” |
| `theme/ergo-light.tokens.json:178` | “since the low chroma…” | Causal `since` is not the approved temporal meaning. Use “because.” |
| `packages/nvim/.config/nvim/lua/colorschemes/baked.lua:27`, `packages/nvim/.config/nvim/lua/plugins/lsp.lua:127`, numerous theme descriptions | “reads as,” “read without colour,” “read alike” | `READ` concerns obtaining information, not a color's appearance. Describe appearance or distinguishability directly. |
| `theme/generators/preview.clj:42`, `theme/ergo-light.tokens.json:125` | “live selection” | The dictionary's general `LIVE` adjective does not mean active. Prefer “active selection,” unless a documented technical term specifically requires “live selection.” |
| `theme/generators/delta.clj:8`, `packages/ssh/.ssh/config.d/defaults.conf:1`, `theme/ergo-light.tokens.json:5`, line 190 | settings, hosts, or foregrounds “live” in a place | Use “contains,” “uses,” or another literal construction. |
| `packages/zsh/.zshrc:43`, `theme/generate_test.clj:82` | “picks up,” “show up” | Use “includes” and “appear.” These are phrasal meanings, not software operation names (9.3). |
| `bootstrap/install.sh:117`, `packages/zsh/.zshrc:176` | “falls back” | Explain the alternative behavior: “The tools use their default colors” or “If the argument is not a directory, zoxide searches for a directory.” |
| `packages/claude/.claude/CLAUDE.md:11`, line 25 | “clean up,” “cleans up” | Name the operation, such as removing the shipped branch. Do not replace it with a vague verb if multiple operations are intended. |
| `README.md:151`, line 163 | “Test the tools,” “Test the plugin” | The ordinary dictionary treats `test` as a noun. Prefer “Do the tool tests” or state the particular checks. Retain a verb only with a justified computer-process usage. |
| `README.md:83`, `bootstrap/macos.sh:18`, `packages/zsh/.zshrc:159` | “first use,” “automatic use” | Review the ordinary noun `use`; describe the action instead, for example “when a command first uses a key.” |

## Technical terminology and editorial decisions

These items are not counted as confirmed violations merely because they are absent from the general dictionary.

| Term group | Decision |
| --- | --- |
| Git, Stow, mise, Babashka, Neovim, WezTerm, Zellij, Karabiner-Elements, Homebrew, plugin names | Retain exact product names and identifiers. Use consistent capitalization in ordinary prose where it is not part of an executable name. |
| directory, symbolic link, shell, socket, lockfile, commit, branch, stack, buffer, pane, plugin, token, namespace, checksum, alias, keybinding | These have recognized computer meanings. Keep the distinctions; record the intended meanings if adopting STE formally. A glossary is useful, but its absence alone is not a writing-rule violation. |
| clone, commit, rebase, render, install, generate, regenerate, reload, resolve, overwrite, initialize, debug, stage, diff, run | Evaluate these as computer processes under 1.12. Retain precise technical operations. Prefer an approved general expression where it is equally accurate. Do not replace Git operations with aviation-oriented dictionary alternatives. |
| `run` in “run a command,” `generate` in “generate a theme file” | Plausible computer technical verbs. Their lowercase dictionary entries do not, by themselves, make every repository occurrence wrong. Define the operation if retained. |
| “inactive selection,” “independent feature branch,” “unused token,” “normal mode,” “floating pane,” “syntax highlighting” | These can be technical noun phrases. Do not mechanically prohibit every modifier or every `-ing` form. Distinguish an established term from an ordinary narrative clause. |
| `paper`, `ink`, `ramp`, `wash`, `keycap`, `armed`, `resting`, `signal`, `strong-tier`, `whisper tier` | Some can be defined theme-design terms. Their meanings currently overlap with informal descriptions. Select one literal name for each concept, and explain retained specialist terms. `paper` is also a code identifier and must not be renamed by a prose-only correction. |
| ANSI, ASCII, RGB, OKLCH, L*, ΔE, CVD, AA, SGR, LSP, DAP, REPL | Legitimate abbreviations and notation can remain. Explain CVD, AA and the color metrics where their definitions affect the design rationale. Avoid assuming that every reader understands `deut`, `word-emph`, `bg`, `fg`, `sp`, and `ref`. |
| Slurp, Barf, Splice, Yank, hunk, Quickfix, Live Grep | In editor commands and UI labels, these are established names or terms. Preserve correspondence with the tool. In surrounding instructions, explain the operation rather than using an unexplained metaphor. |
| Keybinding labels, section headings, file-type labels, task labels, diagnostic prefixes | Short labels are not automatically sentence fragments. Their grammar must match their function. For example, “Previous buffer,” “Breakpoint condition,” and “Default profile” do not need to become full sentences. |
| `config` versus `configuration`; `dir` versus `directory`; `repo` versus `repository`; `hex` versus `hexadecimal color`; `ref` versus `reference` | Prefer the full expression in prose. Preserve literal identifiers. Notable locations: theme README line 30, engine docstring line 42, generation comment line 44, palette warning line 9, and installation warning line 145. |
| `adapter` versus `generator`; `links` versus `symbolic links`; `colorscheme` versus `theme` | Confirm whether each pair denotes the same concept before standardizing it. `adapters` is a real identifier and remains unchanged. “Link” can also mean a hyperlink, so use “symbolic link” where that distinction matters. |

The common generated banner is primarily file metadata. Its fragment “GENERATED from…” is not treated like a broken procedural sentence. A
clearer optional form is “The theme generator created this file. Do not edit this file manually.” A correction belongs in
`theme/generators/common.clj`, not individually in the generated files.

## Rule coverage and limits

| Area | Audit result |
| --- | --- |
| Section 1 | Confirmed spelling, ordinary vocabulary, and meaning problems. Technical terms were evaluated separately. |
| Section 2 | Dense noun groups identified. Product names and literal commands retained. |
| Section 3 | Action participles and identifiable passive constructions found. Technical `-ing` nouns are not blanket failures. |
| Section 4 | Omitted sentence parts and unclear constructions found. Genuine headings and labels excluded from fragment findings. |
| Section 5 | Multiple sequential instructions found. Command literals were not counted as ordinary strings of words. |
| Section 6 | Long descriptions, topic mixing, and the nine-sentence alert paragraph found. |
| Section 7 | No authored physical-safety procedure or formal hazard warning was identified. Routine CLI errors and theme warning labels are not automatically safety instructions. |
| Section 8 | Prose semicolons found. Code punctuation excluded. Sentence counts account for the applicable exceptions. |
| Section 9 | Phrasal meanings and inconsistent terminology identified. Rewriting requires context, not global substitutions. |

The existing `en_us` spelling configuration in `packages/nvim/.config/nvim/init.lua:86` supports American spelling. The Markdown linter
checks formatting. Neither constitutes an STE compliance check. The comment in `lsp.lua:223` mentions Vale, but the actual Markdown linter
configuration lists only `markdownlint-cli2`, and the mise configuration does not install Vale. No STE ruleset, dictionary integration, or
explicit STE authoring policy was found. This is an adoption gap, not proof of a standards violation by itself.

## Suggested correction order

1. Correct the operational READMEs and Claude instructions: sequential steps, participles, contractions, and ordinary vocabulary.
2. Correct the shared generated text and user-facing warnings at their source.
3. Restructure the theme descriptions, preserving all numbers and technical conditions.
4. Correct the remaining comments and settle the technical terminology.
5. Regenerate affected images and theme files. Check the new text in context against the dictionary.

A small terminology list and an explicit STE writing policy would make future reviews more repeatable. An automated checker can assist, but
is not necessary to start the corrections and cannot resolve every contextual decision.

## File coverage inventory

Every file below was included in the maintained-source inventory. “Reviewed” means the available human-readable content was examined; it is
not a per-file certificate of compliance. “Syntax/data” means the file has no substantive prose to assess. “Labels” means short interface
text was reviewed as labels. Generated images were checked against their source text as well as their visible content.

| File | Coverage |
| --- | --- |
| `.gitignore` | Comments, docstrings, and human-readable strings reviewed where present. |
| `.stow-local-ignore` | Syntax/data inspected; no substantive prose. |
| `README.md` | Full prose, headings, lists, and code-block comments reviewed. |
| `bootstrap/Brewfile` | Comments, docstrings, and human-readable strings reviewed where present. |
| `bootstrap/install.sh` | Comments, docstrings, and human-readable strings reviewed where present. |
| `bootstrap/linux.sh` | Comments, docstrings, and human-readable strings reviewed where present. |
| `bootstrap/macos.sh` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/aerospace/.aerospace.toml` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/ccstatusline/.config/ccstatusline/settings.json` | Syntax/data inspected; no substantive prose. |
| `packages/claude/.claude/CLAUDE.md` | Full prose, headings, lists, and code-block comments reviewed. |
| `packages/claude/.claude/settings.json` | Syntax/data inspected; no substantive prose. |
| `packages/git/.config/git/ignore` | Syntax/data inspected; no substantive prose. |
| `packages/git/.gitconfig` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/helix/.config/helix/config.toml` | Mode abbreviations reviewed as labels; configuration syntax excluded. |
| `packages/helix/.config/helix/languages.toml` | Syntax/data inspected; no substantive prose. |
| `packages/karabiner/.config/karabiner/karabiner.json` | Remapping description and profile label reviewed; retain literal key names. |
| `packages/lazydocker/Library/Application Support/jesseduffield/lazydocker/config.yml` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/markdown/.markdownlint-cli2.jsonc` | Syntax/data inspected; no substantive prose. |
| `packages/mise/.config/mise/config.toml` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/mise/.config/mise/mise.lock` | Syntax/data inspected; no substantive prose. |
| `packages/nvim/.config/nvim/.stylua.toml` | Syntax/data inspected; no substantive prose. |
| `packages/nvim/.config/nvim/init.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lazy-lock.json` | Syntax/data inspected; no substantive prose. |
| `packages/nvim/.config/nvim/lua/colorschemes/baked.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/autolist.lua` | Labels reviewed where present; remaining content is executable configuration. |
| `packages/nvim/.config/nvim/lua/plugins/autopairs.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/claudecode.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/cmp.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/colorscheme.lua` | Labels reviewed where present; remaining content is executable configuration. |
| `packages/nvim/.config/nvim/lua/plugins/conform.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/conjure.lua` | Labels reviewed where present; remaining content is executable configuration. |
| `packages/nvim/.config/nvim/lua/plugins/debug.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/diffview.lua` | Labels reviewed where present; remaining content is executable configuration. |
| `packages/nvim/.config/nvim/lua/plugins/flash.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/fugitive.lua` | Labels reviewed where present; remaining content is executable configuration. |
| `packages/nvim/.config/nvim/lua/plugins/git-blame.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/gitsigns.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/init.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/lint.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/lsp.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/minivim.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/neogit.lua` | Labels reviewed where present; remaining content is executable configuration. |
| `packages/nvim/.config/nvim/lua/plugins/octo.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/oil.lua` | Labels reviewed where present; remaining content is executable configuration. |
| `packages/nvim/.config/nvim/lua/plugins/paredit.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/render-markdown.lua` | Labels reviewed where present; remaining content is executable configuration. |
| `packages/nvim/.config/nvim/lua/plugins/telescope.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/todo-comments.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/treesitter.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/nvim/.config/nvim/lua/plugins/trouble.lua` | Labels reviewed where present; remaining content is executable configuration. |
| `packages/nvim/.config/nvim/lua/plugins/ts-autotag.lua` | Labels reviewed where present; remaining content is executable configuration. |
| `packages/nvim/.config/nvim/lua/plugins/which-key.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/ssh/.ssh/config.d/defaults.conf` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/starship/.config/starship.toml` | Comment and compact prompt labels reviewed; format strings preserved. |
| `packages/wezterm/.wezterm.lua` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/zellij/.config/zellij/README.md` | Full prose, headings, lists, and code-block comments reviewed. |
| `packages/zellij/.config/zellij/config.kdl` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/zellij/.config/zellij/layouts/work.kdl` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/zsh/.zprofile` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/zsh/.zshenv` | Comments, docstrings, and human-readable strings reviewed where present. |
| `packages/zsh/.zshrc` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/README.md` | Full prose, headings, lists, and code-block comments reviewed. |
| `theme/bb.edn` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/engine.clj` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/ergo-light.tokens.json` | All description fields reviewed; token identifiers and numeric values excluded. |
| `theme/generate.clj` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/generate_test.clj` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/generators/common.clj` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/generators/delta.clj` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/generators/helix.clj` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/generators/nvim.clj` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/generators/preview.clj` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/generators/wezterm.clj` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/generators/zellij.clj` | Comments, docstrings, and human-readable strings reviewed where present. |
| `theme/preview-ergo-light.svg` | Generated illustration text and banner reviewed; T14 and shared-banner decision. |
| `theme/preview-te-calm.svg` | Generated illustration text and banner reviewed; T14 and shared-banner decision. |
| `theme/preview-terminal.png` | Visible screenshot text reviewed; T14. Old command shown is a documentation-maintenance issue outside STE grammar. |
| `theme/te-calm.tokens.json` | All description fields reviewed; token identifiers and numeric values excluded. |
