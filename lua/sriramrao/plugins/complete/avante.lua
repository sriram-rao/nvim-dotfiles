return {
  'yetone/avante.nvim',
  -- ⚠️ must add this setting! ! !
  build = vim.fn.has 'win32' ~= 0
      and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
    or 'make',
  event = 'VeryLazy',
  version = false, -- Never set this value to "*"! Never!
  opts = {
    -- add any opts here
    instructions_file = 'avante.md',
    behaviour = {
      enable_fastapply = true,
      auto_apply_diff_after_generation = false,
    },
    provider = 'openai',
    providers = {
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = 'claude-sonnet-4-20250514',
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          max_tokens = 32768,
        },
      },
      openai = {
        endpoint = 'https://api.openai.com/v1',
        model = 'gpt-5',
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 1,
          reasoning_effort = 'low',
        },
      },
      morph = {
        model = 'morph-v3-large',
      },
      ollama = {
        endpoint = 'http://localhost:11434',
        model = 'gemma3:4b',
      },
    },
    -- Split-based UI: separators are styled via colorscheme config
  },
  -- No Avante-only separator handling; global separators module manages all panes
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
    'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
    'stevearc/dressing.nvim', -- for input provider dressing
    'folke/snacks.nvim', -- for input provider snacks
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
}
