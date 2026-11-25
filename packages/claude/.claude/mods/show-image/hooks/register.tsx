import type { Register } from 'claude-code'

const TOOL = 'mcp__show-image__show_image'
const PNG_MAGIC = 'iVBORw0KGgo' // base64 of the PNG signature

// The width and height are big-endian at bytes 16 and 20 of the IHDR chunk.
const sizeOf = (bytes: Uint8Array) => {
  const view = new DataView(bytes.buffer, bytes.byteOffset)
  return { width: view.getUint32(16), height: view.getUint32(20) }
}

// The path of a PNG that a Read call opens, or undefined.
const pngReadOf = (tool: string, input: unknown) => {
  const path = (input as { file_path?: string }).file_path
  return tool === 'Read' && path?.toLowerCase().endsWith('.png') ? path : undefined
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.tool.register({
      name: 'show_image',
      description:
        'Show a PNG file to the user, drawn inline in the conversation. ' +
        'Use it when the user asks to see an image, or a chart or screenshot explains more than text. ' +
        'Convert other formats to PNG first, for example with `sips -s format png in.jpg --out out.png`.',
      inputSchema: {
        type: 'object',
        properties: { path: { type: 'string', description: 'Absolute path of the PNG file' } },
        required: ['path'],
      },
    })
    return next(e)
  })

  on('tool.call', { tool: TOOL }, async ($, e) => {
    const path = String(e.path)
    // The terminal reads the file itself, and it needs an absolute path.
    if (!path.startsWith('/')) return { deny: `${path} is not an absolute path.` }
    const file = await $.fs.read(path, { as: 'bytes' }).catch(() => undefined)
    if (!file) return { deny: `Cannot read ${path}. It must exist and be at most 4 MiB.` }
    if (!file.base64.startsWith(PNG_MAGIC)) return { deny: `${path} is not a PNG file.` }
    return { result: `Shown ${path} to the user.` }
  })

  // A run of reads folds into one line, such as "Read 3 files". Unfold it when it holds a PNG, so its row draws.
  on('ui.render', { component: 'ToolGroup' }, ($, e, next) =>
    e.props.calls.some(call => pngReadOf(call.tool, call.input))
      ? next({ ...e, props: { ...e.props, isExpanded: true } })
      : next(e),
  )

  // The show_image row, and the row of a PNG that Claude reads, so the user sees what Claude sees.
  on('ui.render', { component: 'ToolUse' }, async ($, e, next) => {
    const isShown = e.props.tool === TOOL
    const path = isShown ? (e.props.input as { path: string }).path : pngReadOf(e.props.tool, e.props.input)
    // Only the terminal has Image. Other surfaces draw the usual tool row.
    if (!path || e.surface !== 'terminal' || e.props.isErrored || e.props.isRunning) return next(e)

    const file = await $.fs.read(path, { as: 'bytes' }).catch(() => undefined)
    const stat = await $.fs.stat(path).catch(() => undefined)
    if (!file || !stat) return next(e)
    const { width, height } = sizeOf(Uint8Array.fromBase64(file.base64))

    // ponytail: assumes cells about 10 px wide and twice as tall. Not upscaled past that.
    const columns = Math.max(1, Math.min((e.viewport?.columns ?? 80) - 4, 100, Math.ceil(width / 10)))
    const rows = Math.max(1, Math.min(40, Math.round((columns * height) / width / 2)))

    const { Box, Text, Image } = $.ui.resolve(e)
    return (
      <Box flexDirection="column">
        <Text dimColor>{isShown ? 'Image' : 'Read'}: {path}</Text>
        {/* The terminal reads the file. The modification time makes it read the file again after Claude rewrites it. */}
        <Image
          source={{ file: path, format: 'png', generation: Math.floor(stat.mtimeMs) }}
          columns={columns}
          rows={rows}
          alt={`Image ${path}`}
        />
      </Box>
    )
  })
}
