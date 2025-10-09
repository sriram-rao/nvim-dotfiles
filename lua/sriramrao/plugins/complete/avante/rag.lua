return {
  enabled = true,
  runner = 'nix',
  host_mount = vim.fn.expand '~/Code',
  llm = { -- Configuration for the Language Model (LLM) used by the RAG service
    provider = 'openai', -- The LLM provider
    endpoint = 'https://api.openai.com/v1', -- OpenAI API endpoint
    api_key = 'OPENAI_API_KEY', -- Environment variable name for API key
    model = 'gpt-4o-mini', -- The LLM model name
    extra = nil, -- Extra configuration options for the LLM (optional)
  },

  embed = { -- Configuration for the Embedding Model used by the RAG service
    provider = 'openai', -- The Embedding provider
    endpoint = 'https://api.openai.com/v1', -- OpenAI API endpoint
    api_key = 'OPENAI_API_KEY', -- Environment variable name for API key
    model = 'text-embedding-3-medium', -- The Embedding model name
    extra = { -- Extra configuration options for the Embedding model (optional)
      embed_batch_size = 10,
    },
  },
}
