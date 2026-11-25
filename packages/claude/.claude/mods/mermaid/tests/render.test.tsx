import { expect, test } from 'claude-code/testing'

const reply = (diagram: string) => `Before.\n\n\`\`\`mermaid\n${diagram}\n\`\`\`\n\nAfter.`

for (const [name, diagram, isDrawn] of [
  ['draws a closed block', 'graph LR\nA-->B', true],
  ['keeps a block mermaid-ascii fails on', 'not a diagram', false],
] as const) {
  test(name, async ($, on) => {
    let drawnText = ''
    // Stands for mermaid-ascii: draws a graph, exits 1 on anything else, as the real one does.
    on('process.run', ($, e) => {
      const isGraph = e.init?.stdin?.startsWith('graph') === true
      return {
        value: {
          exitCode: isGraph ? 0 : 1,
          stdout: isGraph ? '┌─┐     ┌─┐\n│A├────►│B│\n└─┘     └─┘ \n' : '',
          stderr: '',
          isStdoutTruncated: false,
          isStderrTruncated: false,
        },
      }
    })
    // Stands for the engine's own drawing of the message, and records the text it gets.
    on('ui.render', { component: 'AssistantMessage' }, ($, e) => {
      drawnText = e.props.text
      const { Text } = $.ui.resolve(e)
      return <Text>{e.props.text}</Text>
    })

    await $.ui.mount({
      plugin: 'mermaid',
      surface: 'terminal',
      component: 'AssistantMessage',
      props: { text: reply(diagram), isFirstOfReply: true },
    })

    expect(drawnText.includes('```mermaid')).toBe(!isDrawn)
    expect(drawnText.includes('┌')).toBe(isDrawn)
    expect(drawnText.startsWith('Before.') && drawnText.endsWith('After.')).toBe(true)
  })
}
