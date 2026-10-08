# Writing conventions

Use [ASD-STE100 Issue 9](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf) as the reference for project prose.
Apply these conventions to documentation, comments, descriptions, and messages:

- Use American spelling, complete sentences, and active voice.
- Give each sequential instruction its own sentence.
- Limit procedural sentences to 20 words and descriptive sentences to 25 words, with the counting rules in section 8.
- Keep one topic in each paragraph, with no more than six sentences.
- Use periods or lists in place of semicolons. Write contractions in full.
- Describe actions with finite verbs. Keep established technical nouns such as “syntax highlighting.”
- Keep commands, identifiers, product names, and interface labels accurate.
- Check ordinary words against the STE dictionary for their meaning and part of speech.

Use the following terms consistently:

| Term | Meaning in this project |
| --- | --- |
| Directory, repository, configuration | Use these full forms in prose. Keep `dir`, `repo`, and `config` in identifiers. |
| Symbolic link | A filesystem link created by Stow. Use “link” alone only when its meaning is clear. |
| Theme | The color definitions for a tool. “Colorscheme” can remain in Neovim names and identifiers. |
| Primitive color | A value in a color scale. |
| Semantic token | A named role that refers to a primitive color or a different semantic token. |
| Generator | Code that converts semantic tokens to tool configuration files. Keep the `adapters` identifier in code. |
| Background and foreground | The surface color and the text or mark color. Keep `paper` and `ink` in identifiers. |

Retain precise computer operations such as clone, commit, rebase, render, generate, and reload in their technical meanings.
Use established editor terms in interface labels, including Slurp, Barf, Yank, and Quickfix.
Explain these terms in instructions when the operation is unclear.

Markdown lint and spelling checks assist review. They do not establish STE compliance.
