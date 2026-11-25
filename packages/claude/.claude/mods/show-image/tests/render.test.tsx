import { expect, test } from 'claude-code/testing'

// The signature and the start of the IHDR chunk of a PNG 200 px wide and 100 px tall.
const png = new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 200, 0, 0, 0, 100])
const jpeg = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, ...new Array(20).fill(0)])

for (const [name, bytes, isDrawn] of [
  ['draws a PNG that Claude reads', png, true],
  ['keeps the row of a renamed JPEG', jpeg, false],
  ['keeps the row of a truncated PNG', png.slice(0, 12), false],
] as const) {
  test(name, async ($, on) => {
    let reads = 0
    // Stands for the file system: every path is the test file, last modified at 1.
    on('fs.stat', () => ({ value: { kind: 'file', size: bytes.length, mtimeMs: 1, isLink: false } }))
    on('fs.read', () => {
      reads++
      return { value: { base64: bytes.toBase64() } }
    })
    // Stands for the engine's own drawing of the row.
    on('ui.render', { component: 'ToolUse' }, ($, e) => {
      const { Text } = $.ui.resolve(e)
      return <Text>usual row</Text>
    })

    const ui = await $.ui.mount({
      plugin: 'show-image',
      surface: 'terminal',
      component: 'ToolUse',
      props: {
        tool_use_id: name,
        tool: 'Read',
        input: { file_path: `/tmp/${name}.png` },
        isRunning: false,
        isErrored: false,
        isInterrupted: false,
      },
    })
    await ui.redraw()

    const image = await ui.find({ type: 'Image' })
    expect(image?.props.columns).toBe(isDrawn ? 20 : undefined)
    expect(image?.props.rows).toBe(isDrawn ? 5 : undefined)
    expect((await ui.find({ type: 'Text', text: 'usual row' })) !== undefined).toBe(!isDrawn)
    // The second drawing takes the size from the cache.
    expect(reads).toBe(1)
  })
}
