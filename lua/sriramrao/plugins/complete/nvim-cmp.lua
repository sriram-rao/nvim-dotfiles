return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    'hrsh7th/cmp-buffer', -- source for text in buffer
    'hrsh7th/cmp-path', -- source for file system paths
    {
      'L3MON4D3/LuaSnip',
      -- follow latest release.
      version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      -- install jsregexp (optional!).
      build = 'make install_jsregexp',
    },
    'saadparwaiz1/cmp_luasnip', -- for autocompletion
    'rafamadriz/friendly-snippets', -- useful snippets
    'onsails/lspkind.nvim', -- vs-code like pictograms
    {
      'sriram-rao/cmp-tabby.nvim',
      dependencies = { 'TabbyML/vim-tabby' },
      config = true,
    },
  },
  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    local lspkind = require 'lspkind'
    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require('luasnip.loaders.from_vscode').lazy_load()

    -- Setup Tabby source
    require('cmp-tabby').setup()

    cmp.setup {
      completion = {
        completeopt = 'menu,menuone,preview,noselect',
        keyword_length = 0, -- Trigger completion even with 0 characters typed
      },
      window = {
        completion = cmp.config.window.bordered({
          border = 'rounded',
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
        }),
        documentation = cmp.config.window.bordered({
          border = 'rounded',
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
        }),
      },
      sources = {
        per_filetype = {
          codecompanion = { 'codecompanion' },
        },
      },
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args) luasnip.lsp_expand(args.body) end,
      },
      mapping = cmp.mapping.preset.insert {
        ['<C-k>'] = cmp.mapping.select_prev_item(), -- previous suggestion
        ['<C-j>'] = cmp.mapping.select_next_item(), -- next suggestion
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-n>'] = cmp.mapping.complete(), -- show completion suggestions
        ['<C-t>'] = cmp.mapping.complete({
          config = {
            sources = {
              { name = 'cmp_tabby' }
            }
          }
        }), -- show only Tabby AI suggestions
        ['<Esc>'] = cmp.mapping.abort(), -- close completion window
        ['<CR>'] = cmp.mapping.confirm { select = false },
        ['<Tab>'] = cmp.mapping.confirm { select = true }, -- Accept completion with Tab
      },
      -- sources for autocompletion
      sources = cmp.config.sources {
        { name = 'cmp_tabby', priority = 1000, group_index = 1 }, -- Tabby AI completions (top priority)
        -- { name = 'copilot' }, -- Copilot (disabled in favor of Tabby)
        { name = 'nvim_lsp', group_index = 2 },
        { name = 'luasnip', group_index = 2 }, -- snippets
        { name = 'buffer', group_index = 3 }, -- text within current buffer
        { name = 'path', group_index = 3 }, -- file system paths
      },

      -- Sorting to prioritize Tabby
      sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },

      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        format = function(entry, vim_item)
          -- Use lspkind for all sources first
          vim_item = lspkind.cmp_format {
            maxwidth = 50,
            ellipsis_char = '...',
            symbol_map = { Tabby = '' },
          }(entry, vim_item)

          -- Then customize Tabby menu and force snippet icon
          if entry.source.name == 'cmp_tabby' then
            vim_item.kind = ' Snippet' -- Force snippet icon with proper formatting
            vim_item.menu = '🐈 Tabby'
          end
          return vim_item
        end,
      },
    }
  end,
}
