-- RAG LLM options
local llm_options = {
  openai = {
    provider = 'openai',
    endpoint = 'https://api.openai.com/v1',
    api_key = 'OPENAI_API_KEY',
    model = 'gpt-4o-mini',
    extra = nil,
  },
  openrouter_gemini = {
    provider = 'openrouter',
    endpoint = 'https://openrouter.ai/api/v1',
    api_key = 'OPENROUTER_API_KEY',
    model = 'google/gemini-2.0-flash-exp',
    extra = nil,
  },
  openrouter_deepseek = {
    provider = 'openrouter',
    endpoint = 'https://openrouter.ai/api/v1',
    api_key = 'OPENROUTER_API_KEY',
    model = 'deepseek/deepseek-chat',
    extra = nil,
  },
  openrouter_claude = {
    provider = 'openrouter',
    endpoint = 'https://openrouter.ai/api/v1',
    api_key = 'OPENROUTER_API_KEY',
    model = 'anthropic/claude-3.5-sonnet',
    extra = nil,
  },
  ollama = {
    provider = 'ollama',
    endpoint = 'http://localhost:11434',
    api_key = '',
    model = 'llama3.1:8b',
    extra = nil,
  },
}

-- Embedding options
local embed_options = {
  ollama = {
    provider = 'ollama',
    endpoint = 'http://localhost:11434',
    api_key = '',
    model = 'mxbai-embed-large',
    extra = {
      embed_batch_size = 10,
    },
  },
  openai = {
    provider = 'openai',
    endpoint = 'https://api.openai.com/v1',
    api_key = 'OPENAI_API_KEY',
    model = 'text-embedding-3-small',
    extra = nil,
  },
}

return {
  enabled = true,
  runner = 'nix',
  host_mount = vim.fn.expand '~/Code',
  llm = llm_options.openrouter_gemini,  -- Change this to switch LLM
  embed = embed_options.ollama,  -- Change this to switch embeddings
}
