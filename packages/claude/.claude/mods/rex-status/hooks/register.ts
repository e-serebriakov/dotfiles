import type { EngineInterface, Register } from 'claude-code'

// Replaces the settings hooks that ran status.sh. They started a shell after every tool call.
// This mod runs the script only when the state changes.
let last: string | undefined

// status.sh writes to the terminal of its parent process. $.process.run starts it as a child of Claude Code.
async function report($: EngineInterface, ...state: string[]) {
  const key = state.join(' ')
  if (key === last) return
  last = key
  const home = await $.env.get('HOME')
  await $.process.run(['sh', `${home}/.config/rex/status.sh`, ...state], { timeoutMs: 5000 }).catch(() => undefined)
}

export const register: Register = on => {
  on('classic.UserPromptSubmit', async ($, e, next) => (await report($, 'working'), next(e)))
  // After a permission prompt is answered, the tool runs, so the state goes back to working.
  on('classic.PostToolUse', async ($, e, next) => (await report($, 'working'), next(e)))
  on('classic.Notification', async ($, e, next) => {
    if (e.notification_type === 'permission_prompt') await report($, 'blocked', 'permission')
    return next(e)
  })
  on('classic.Stop', async ($, e, next) => (await report($, 'done'), next(e)))
  on('classic.SessionEnd', async ($, e, next) => (await report($, 'clear'), next(e)))
}
