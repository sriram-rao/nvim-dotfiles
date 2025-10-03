return {
  'yetone/avante.nvim',
  build = 'make',
  event = 'VeryLazy',
  version = false,
  opts = {
    instructions_file = 'AGENTS.md',
    behaviour = {
      enable_fastapply = true,
      auto_apply_diff_after_generation = false,
      minimize_diff = true,
      auto_save_before_apply = true,
    },
    provider = 'claude-code',
    mode = 'agentic',
    providers = require 'sriramrao.plugins.complete.avante.providers',
    web_search_engine = {
      provider = 'google',
      proxy = nil,
    },
    acp_providers = require 'sriramrao.plugins.complete.avante.acp_providers',
    rag_service = require 'sriramrao.plugins.complete.avante.rag',
    system_prompt = function()
      local hub = require('mcphub').get_hub_instance()
      local prompts = {}

      local hub_prompt = hub and hub:get_active_servers_prompt() or ''
      if hub_prompt ~= '' then table.insert(prompts, hub_prompt) end

      table.insert(
        prompts,
        [[Use `rag_search` whenever the task hinges on the current project's files, history, or other locally indexed context. Prefer RAG before broader web or filesystem tools in those situations, and fall back to other tools only when RAG returns no useful sources or the task clearly needs info outside the repo.]]
      )

      return table.concat(prompts, '\n\n')
    end,
    custom_tools = function()
      return {
        require('mcphub.extensions.avante').mcp_tool(),
      }
    end,
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