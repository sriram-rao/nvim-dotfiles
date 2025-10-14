return {
  'yetone/avante.nvim',
  enabled = false,
  build = 'make',
  event = 'VeryLazy',
  version = false,
  opts = {
    instructions_file = 'AGENTS.md',
    behaviour = {
      enable_fastapply = true,
      auto_apply_diff_after_generation = true,
      minimize_diff = true,
      auto_save_before_apply = true,
      enable_inline_diff = true,
    },
    provider = 'openai',
    mode = 'agentic',
    providers = require 'sriramrao.plugins.complete.avante.providers',
    web_search_engine = {
      provider = 'google',
      proxy = nil,
    },
    acp_providers = require 'sriramrao.plugins.complete.avante.acp_providers',
    rag_service = require 'sriramrao.plugins.complete.avante.rag',
    --   local ok, hub = pcall(require('mcphub').get_hub_instance)
    --   if not ok then return '' end
    --
    --   local prompt = hub and hub:get_active_servers_prompt() or ''
    --   -- Replace newlines with spaces to avoid nvim_buf_set_lines error
    --   return prompt:gsub('\n', ' ')
    -- end,
    -- custom_tools = function()
    --   local ok, mcp_tool = pcall(function()
    --     return require('mcphub.extensions.avante').mcp_tool()
    --   end)
    --   if not ok then return {} end
    --   return { mcp_tool }
    -- end,
    disabled_tools = {
      'view',
      'add_file_to_context',
      'list_files',
      'search_files',
      'read_file',
      'create_file',
      'rename_file',
      'delete_file',
      'create_dir',
      'rename_dir',
      'delete_dir',
      'bash',
      'add_todos',
      'update_todo_status',
    },
    windows = {
      edit = { border = 'rounded' },
      ask = { border = 'rounded' },
      sidebar_header = { enabled = true, align = 'center', rounded = true },
    },
  },
  config = function(_, opts)
    local avante = require 'avante'
    avante.setup(opts)

    local setup = require 'sriramrao.plugins.complete.avante.setup'
    setup.setup_rag_resource()
    setup.setup_rag_debug()
    setup.setup_provider_switcher()
    setup.setup_rag_controls()

    -- Auto-start RAG service on nvim startup (safe for concurrent instances)
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        local rag_service = require 'avante.rag_service'
        if opts.rag_service and opts.rag_service.enabled then
          rag_service.launch_rag_service(function()
            vim.notify('[Avante RAG] Service started', vim.log.levels.INFO)
          end)
        end
      end,
    })

  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'echasnovski/mini.pick',
    'nvim-telescope/telescope.nvim',
    'hrsh7th/nvim-cmp',
    'ibhagwan/fzf-lua',
    'stevearc/dressing.nvim',
    'folke/snacks.nvim',
    'nvim-tree/nvim-web-devicons',
    'zbirenbaum/copilot.lua',
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
    {
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
        },
      },
    },
  },
}
