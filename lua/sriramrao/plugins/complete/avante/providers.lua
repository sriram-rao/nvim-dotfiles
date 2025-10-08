return {
  claude = {
    endpoint = 'https://api.anthropic.com',
    model = 'claude-sonnet-4-5',
    model_names = {
      'claude-sonnet-4-5',
      'claude-sonnet-4-20250514',
      'claude-3-7-sonnet-20250219',
      'claude-3-5-sonnet-20241022',
    },
    timeout = 30000,
    extra_request_body = {
      max_tokens = 32768,
    },
  },
  openai = {
    endpoint = 'https://api.openai.com/v1',
    model = 'gpt-5-mini',
    model_names = {
      'gpt-5',
      'gpt-5-mini',
      'gpt-5-nano',
      'gpt-4.1',
      'o4-mini',
      'gpt-4o',
    },
    timeout = 30000,
    extra_request_body = {
      service_tier = 'flex',
      temperature = 1,
      reasoning_effort = 'medium',
    },
  },
  morph = {
    endpoint = 'https://api.morph.so/v1',
    model = 'morph-v3-large',
    model_names = {
      'morph-v3-large',
      'morph-v3-small',
    },
    api_key_name = 'MORPH_API_KEY',
    timeout = 30000,
  },
  google = {
    endpoint = 'https://generativelanguage.googleapis.com/v1beta/models',
    model = 'gemini-2.5-flash',
    model_names = {
      'gemini-2.5-flash',
      'gemini-2.5-pro',
      'gemini-2.5-flash-lite-latest',
    },
  },
  ollama = {
    endpoint = 'http://localhost:11434',
    model = 'deepseek-coder:6.7b',
    timeout = 30000,
    model_names = {
      'codegemma:2b',
      'codegemma:7b',
      'deepseek-coder:1.3b',
      'deepseek-coder:6.7b',
      'gemma3:1b',
      'gemma3:4b',
      'qwen2.5-coder:1.5b',
      'qwen2.5-coder:7b',
      'starcoder2:3b',
      'starcoder2:7b',
    },
    extra_request_body = {
      options = {
        temperature = 0.75,
        num_ctx = 4096,
        num_predict = 512,  -- Keep responses short
      },
    },
  },
  tabby = {
    endpoint = 'http://localhost:8080/v1beta',
    model = 'deepseek-coder:6.7b',
    timeout = 30000,
  },
}
