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
    },
    -- Split-based UI: separators are styled via colorscheme config
  },
  init = function()
    -- Ensure the Avante split shows visible separators
    local grp = vim.api.nvim_create_augroup('AvanteBorders', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = grp,
      pattern = { 'Avante', 'avante' },
      callback = function()
        local win = 0
        local val = vim.wo[win].winhighlight or ''
        -- Remove any mapping that could hide separators
        val = val:gsub('WinSeparator:[^,]*,?', '')
        val = val:gsub('VertSplit:[^,]*,?', '')
        if #val > 0 then val = val:gsub('^,+', ''):gsub(',+$', '') end
        if #val > 0 then val = val .. ',' end
        -- Ensure default groups are used so theme/global color applies
        vim.wo[win].winhighlight = val .. 'WinSeparator:WinSeparator,VertSplit:VertSplit'
        -- Ensure Avante window uses thin separator char
        local f = vim.wo[win].fillchars or ''
        if not f:match('vert:') then
          f = (#f > 0 and (f .. ',') or f) .. 'vert:┊'
        else
          f = f:gsub('vert:[^,]*', 'vert:┊')
        end
        vim.wo[win].fillchars = f
      end,
    })
  end,
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
