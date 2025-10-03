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
      temperature = 1,
      reasoning_effort = 'low',
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
}
