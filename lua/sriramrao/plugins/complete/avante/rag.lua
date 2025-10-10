return {
  enabled = true,
  runner = 'nix',
  host_mount = vim.fn.expand '~/Code',
  llm = {
    provider = 'openai',
    endpoint = 'https://api.openai.com/v1',
    api_key = 'OPENAI_API_KEY',
    model = 'gpt-4o-mini',
    extra = nil,
  },
  embed = {
    provider = 'ollama',
    endpoint = 'http://localhost:11434',
    api_key = '',
    model = 'mxbai-embed-large',
    extra = {
      embed_batch_size = 10,
    },
  },
}
