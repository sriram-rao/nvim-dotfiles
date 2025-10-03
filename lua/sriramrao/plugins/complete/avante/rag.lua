return {
  enabled = true,
  runner = 'docker',
  host_mount = vim.fn.expand '~/Code',
  llm = {
    provider = 'openai',
    endpoint = 'https://api.openai.com/v1',
    api_key = 'OPENAI_API_KEY',
    model = 'gpt-4o-mini',
  },
  embed = {
    provider = 'openai',
    endpoint = 'https://api.openai.com/v1',
    api_key = 'OPENAI_API_KEY',
    model = 'text-embedding-3-small',
  },
  docker_extra_args = table.concat({
    '--memory=2g',
    '--memory-swap=2g',
    '--cpus=2',
    '-e DATA_DIR=/data',
    '-e IGNORE_GLOBS="target/**,**/target/**,**/node_modules/**,**/.git/**,**/dist/**,**/build/**,**/.venv/**,**/venv/**,**/.next/**,**/.svelte-kit/**,**/.turbo/**,**/*.png,**/*.jpg,**/*.pdf,**/*.zip,**/*.mp4,**/*.bin"',
    '-e INCLUDE_GLOBS="**/*.py,**/*.ts,**/*.tsx,**/*.js,**/*.lua,**/*.go,**/*.rs,**/*.md,**/*.json,**/*.toml,**/*.yml,**/*.yaml"',
    '-e TOP_K=10',
    '-e CHUNK_SIZE=700',
    '-e CHUNK_OVERLAP=80',
    '-e OPENAI_API_KEY=' .. (os.getenv 'OPENAI_API_KEY' or ''),
  }, ' '),
}
