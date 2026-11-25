import type { Register } from 'claude-code'

// A closed mermaid block. A block still streaming has no closing fence, so it draws as code until it closes.
const BLOCK = /```mermaid[^\n]*\n([\s\S]*?)\n```/g

// The drawing of each diagram by width and source, or null when mermaid-ascii failed on it.
// A reply draws again on each streamed chunk, so the cache runs mermaid-ascii once per diagram.
const drawings = new Map<string, string | null>()

export const register: Register = on => {
  // The model and the transcript keep the mermaid source. Only the drawn row changes.
  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) => {
    const { text } = e.props
    if (!text.includes('```mermaid')) return next(e)

    // The reply is indented under its bullet.
    const width = e.viewport ? String(e.viewport.columns - 4) : 'auto'
    const draw = async (source: string) => {
      const key = `${width}\n${source}`
      if (!drawings.has(key)) {
        const ran = await $.process
          .run(['mermaid-ascii', '-p', '0', '-y', '2', '--max-width', width, '-f', '-'], { stdin: source, timeoutMs: 5000 })
          .catch(() => undefined)
        drawings.set(key, ran?.exitCode === 0 && ran.stdout.trim() ? ran.stdout.trimEnd() : null)
      }
      return drawings.get(key)
    }

    const sources = [...text.matchAll(BLOCK)].map(match => match[1] ?? '')
    const drawn = await Promise.all(sources.map(draw))
    let index = 0
    // A diagram that mermaid-ascii cannot draw keeps its source, so the error is visible.
    const replaced = text.replace(BLOCK, block => {
      const drawing = drawn[index++]
      return drawing ? '```text\n' + drawing + '\n```' : block
    })
    return next({ ...e, props: { ...e.props, text: replaced } })
  })
}
