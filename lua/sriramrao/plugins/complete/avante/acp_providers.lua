return {
  ['gemini-cli'] = {
    command = 'gemini',
    args = { '--experimental-acp' },
    env = {
      NODE_NO_WARNINGS = '1',
      GEMINI_API_KEY = os.getenv 'GEMINI_API_KEY',
    },
  },
  ['claude-code'] = {
    command = 'env',
    args = {
      '-u',
      'ANTHROPIC_API_KEY',
      'npx',
      '--yes',
      '@zed-industries/claude-code-acp',
    },
    env = {
      NODE_NO_WARNINGS = '1',
    },
  },

  ['codex'] = {
    command = 'npx --yes @zed-industries/codex-acp',
    args = { '--no-stream' },
    env = {
      NODE_NO_WARNINGS = '1',
    },
  },
}
