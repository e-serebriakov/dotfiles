"""Preview generators — the theme's self-portrait, in two renderings.

Deliberately NOT registered in ADAPTERS: the previews reference far more of the
vocabulary than any one tool, so folding them into the tokens<->adapter contract
would mask genuinely-unused (rotting) tokens. gen_preview -> the committed SVG
(engine.PREVIEW, for GitHub); preview_ansi -> truecolor for the terminal
(`generate.py --preview`). Both render from _preview_rows so they can't drift.
"""

from theme.engine import GENERATED_BANNER


def _preview_rows(sem):
    """The theme's self-portrait as tool-agnostic rows — the single source both
    preview renderers consume.

    One code-mock that tours the semantic layer: comment band, TODO marker,
    function/string/constant, link, a live selection, search match-vs-current,
    the loud error MARK (undercurl + sign) over a muted message, and
    add/change/delete diff word-emphasis. Uses ONLY semantic tokens via sem(),
    so it re-tunes from Layer 1 like every adapter.

    Returns (ink, paper, alert, rows). Each row is
    (gutter, gutter_color, band_or_None, segs, gap_before); each segment is
    (text, fg, opts) where opts may set a word-band 'hl', an 'underline', or the
    error 'curl' (always drawn in `alert`)."""
    ink, muted = sem("text.primary"), sem("text.muted")
    paper = sem("surface.base")
    cmt_fg, cmt_bg, todo = sem("comment.fg"), sem("comment.bg"), sem("comment.high")
    fn, string = sem("accent.function"), sem("accent.string")
    const, link = sem("accent.constant"), sem("accent.link")
    sel = sem("selection.primary")
    search, current = sem("search.soft"), sem("search.active")
    alert, err = sem("alert.fg"), sem("status.error")
    d_del, d_del_w = sem("diff.delete"), sem("diff.deleteText")
    d_add, d_add_w = sem("diff.add"), sem("diff.addText")
    d_chg, d_chg_w = sem("diff.change"), sem("diff.changeText")

    rows = [
        ("1", muted, cmt_bg, [("// resolve an alias down to a hex", cmt_fg, {})], False),
        ("2", muted, None, [("const paper = ", ink, {}), ("theme", fn, {}), ("(", ink, {}),
                            ("'surface.base'", string, {}), (")", ink, {})], False),
        ("3", muted, None, [("const CEIL = ", ink, {}), ("0.035", const, {})], False),
        ("4", muted, todo, [("// TODO: verify AA on paper", cmt_fg, {})], False),
        ("5", muted, None, [("see ", ink, {}),
                            ("https://oklch.com", link, {"underline": True})], False),
        ("6", muted, sel, [("  selected line — a live selection", ink, {})], False),
        ("7", muted, None, [("grep ", ink, {}), ("match", ink, {"hl": search}),
                            (" and ", ink, {}), ("current", ink, {"hl": current})], False),
        ("⊗", alert, None, [("foo()", ink, {"curl": True}), ("   ", ink, {}),
                            ("■ ", alert, {}), ("undefined name 'foo'", err, {})], False),
        ("-", muted, d_del, [("  const c = ", ink, {}),
                             ("0.061", ink, {"hl": d_del_w})], True),  # gap before diff
        ("+", muted, d_add, [("  const c = ", ink, {}),
                             ("0.035", ink, {"hl": d_add_w})], False),
        ("~", muted, d_chg, [("  modified ", ink, {}), ("word", ink, {"hl": d_chg_w}),
                             (" here", ink, {})], False),
    ]
    return ink, paper, alert, rows


def gen_preview(sem):
    """Render _preview_rows() as an SVG (inline attributes only, no CSS/<style>)
    so GitHub renders it in the README."""
    ink, paper, alert, rows = _preview_rows(sem)

    FS, LH, CW = 19, 34, 11.4  # monospace: char advance ≈ 0.6·em, so columns align
    W, code_x, num_r = 780, 104, 80
    PAD_TOP, GAP, PAD_BOT = 18, 20, 18
    MONO = "ui-monospace, SFMono-Regular, Menlo, Consolas, 'DejaVu Sans Mono', monospace"

    def esc(s):
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

    def text_el(x, y, s, color, anchor="start"):
        return (
            f'<text x="{x:.1f}" y="{y:.1f}" text-anchor="{anchor}" '
            f'font-family="{MONO}" font-size="{FS}" fill="{color}" '
            f'xml:space="preserve">{esc(s)}</text>'
        )

    def curl(x, y, w, color):  # a wavy undercurl — the error MARK's shape cue
        d, cx, up = f"M{x:.1f},{y:.1f}", x, True
        for _ in range(max(1, int(w / 4))):
            nx, cy = cx + 4, (y - 2 if up else y + 2)
            d += f" Q{cx + 2:.1f},{cy:.1f} {nx:.1f},{y:.1f}"
            cx, up = nx, not up
        return f'<path d="{d}" fill="none" stroke="{color}" stroke-width="1.3"/>'

    body = []

    def draw(y, gutter, gutter_color, band, segs):
        if band:
            body.append(f'<rect x="0" y="{y:.1f}" width="{W}" height="{LH}" fill="{band}"/>')
        bl = y + 23  # text baseline, vertically centred in the line box
        body.append(text_el(num_r, bl, gutter, gutter_color, anchor="end"))
        col = 0
        for text, color, opts in segs:
            x, w = code_x + col * CW, len(text) * CW
            if opts.get("hl"):  # word-level highlight band (search / diff-emph)
                body.append(
                    f'<rect x="{x - 2:.1f}" y="{y + 5:.1f}" width="{w + 4:.1f}" '
                    f'height="{LH - 10}" rx="3" fill="{opts["hl"]}"/>'
                )
            body.append(text_el(x, bl, text, color))
            if opts.get("underline"):
                body.append(
                    f'<line x1="{x:.1f}" y1="{bl + 3:.1f}" x2="{x + w:.1f}" '
                    f'y2="{bl + 3:.1f}" stroke="{color}" stroke-width="1.4"/>'
                )
            if opts.get("curl"):
                body.append(curl(x, bl + 4, w, alert))
            col += len(text)

    y = PAD_TOP
    for gutter, gcol, band, segs, gap_before in rows:
        if gap_before:
            y += GAP
        draw(y, gutter, gcol, band, segs)
        y += LH
    h = y + PAD_BOT

    head = (
        f'<?xml version="1.0" encoding="UTF-8"?>\n'
        f"<!-- {GENERATED_BANNER} -->\n"
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{h}" '
        f'viewBox="0 0 {W} {h}">\n'
        f'<rect width="{W}" height="{h}" fill="{paper}"/>\n'
    )
    return head + "\n".join(body) + "\n</svg>\n"


def preview_ansi(sem):
    """The same self-portrait as gen_preview(), rendered with 24-bit-colour ANSI
    escapes for the terminal (`generate.py --preview`). Full-line bands and
    word-highlights are real background runs; the error undercurl uses the
    4:3 / 58 SGR (WezTerm, kitty) and degrades to a plain underline on terminals
    that lack it."""
    ink, paper, alert, rows = _preview_rows(sem)
    GUT, SEP = 2, "  "  # gutter width + separator, mirroring the SVG's number rail
    width = GUT + len(SEP) + max(sum(len(t) for t, _, _ in r[3]) for r in rows)

    def rgb(hexs, layer):  # '#RRGGBB' -> a 38/48 truecolor SGR parameter
        h = hexs.lstrip("#")
        return f"{layer};2;{int(h[0:2], 16)};{int(h[2:4], 16)};{int(h[4:6], 16)}"

    def run(text, fg=None, bg=None, opts=None):
        opts = opts or {}
        codes = []
        if bg:
            codes.append(rgb(bg, 48))
        if fg:
            codes.append(rgb(fg, 38))
        if opts.get("underline"):
            codes.append("4")
        if opts.get("curl"):
            codes += ["4:3", rgb(alert, 58)]  # curl style + its own colour
        sgr = ("\x1b[" + ";".join(codes) + "m") if codes else ""
        return sgr + text + "\x1b[0m"

    out = []
    for gutter, gcol, band, segs, gap_before in rows:
        if gap_before:
            out.append(run(" " * width, bg=paper))
        cells = GUT + len(SEP)
        line = run(f"{gutter:>{GUT}}", fg=gcol, bg=band) + run(SEP, bg=band)
        for text, fg, opts in segs:
            line += run(text, fg=fg, bg=opts.get("hl") or band, opts=opts)
            cells += len(text)
        line += run(" " * (width - cells), bg=band)  # extend the band to full width
        out.append(line)
    return "\n".join(out) + "\n"
