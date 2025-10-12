return {
  'saghen/blink.cmp',
  enabled = true,
  event = 'InsertEnter',
  dependencies = {
    'rafamadriz/friendly-snippets',
  },
  version = 'v0.*',
  opts = {
    keymap = {
      preset = 'default',
      ['<C-k>'] = { 'select_prev', 'fallback' },
      ['<C-j>'] = { 'select_next', 'fallback' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-n>'] = { 'show', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<Esc>'] = { 'hide', 'fallback' },
    },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },

    sources = {
      default = { 'tabby', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        tabby = {
          name = 'tabby',
          module = 'sriramrao.plugins.local.blink-tabby-source',
          async = true,
          timeout_ms = 2000,
          opts = {
            max_items = 3,
          },
        },
      },
    },

    completion = {
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        border = 'rounded',
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = 'rounded',
        },
      },
    },

    signature = {
      enabled = true,
      window = {
        border = 'rounded',
      },
    },
  },
  opts_extend = { "sources.default" },
}
