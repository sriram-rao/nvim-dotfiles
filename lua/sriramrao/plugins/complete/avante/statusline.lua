local M = {}

function M.provider()
  local config = require 'avante.config'
  local provider = config.acp_provider or config.provider or 'n/a'
  local provider_config = (config.providers and config.providers[provider])
    or { model = '' }

  local rag_status = ''
  local ok, rag_service = pcall(require, 'avante.rag_service')
  if ok and config.rag_service and config.rag_service.enabled then
    rag_status = rag_service.is_ready() and '● ' or '○ '
  end

  return rag_status
    .. '\u{f09d1} '
    .. (
      provider_config.display_name or (provider .. ' ' .. provider_config.model)
    )
end

return M
