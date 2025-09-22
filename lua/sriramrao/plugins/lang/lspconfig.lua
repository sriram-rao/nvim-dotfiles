return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    { 'antosha417/nvim-lsp-file-operations', config = true },
    { 'folke/neodev.nvim', opts = {} },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = vim.lsp.config

    -- import mason_lspconfig plugin
    local mason_lspconfig = require 'mason-lspconfig'

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require 'cmp_nvim_lsp'

    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true, noremap = true }
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        -- set the rust specific keybinds
        if client.name == 'rust_analyzer' then
          opts.desc = 'Hover actions for Rust'
          keymap.set(
            'n',
            '<leader>rh',
            function() vim.cmd.RustLsp 'codeAction' end,
            opts
          )

          opts.desc = 'Run with cargo'
          keymap.set(
            'n',
            '<leader>rc',
            function() vim.cmd.RustLsp 'runnables' end,
            opts
          )

          opts.desc = 'Show in docs.rs'
          keymap.set(
            'n',
            '<leader>rd',
            function() vim.cmd.RustLsp 'openDocs' end,
            opts
          )
        end

        -- set default keybinds
        opts.desc = 'Show LSP references'
        keymap.set('n', ',u', '<cmd>Telescope lsp_references<CR>', opts) -- show definition, references

        opts.desc = 'Go to declaration'
        keymap.set('n', ',D', vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = 'Show LSP definitions'
        keymap.set('n', ',a', '<cmd>Telescope lsp_definitions<CR>', opts) -- show lsp definitions

        opts.desc = 'Show LSP implementations'
        keymap.set('n', ',i', '<cmd>Telescope lsp_implementations<CR>', opts) -- show lsp implementations

        opts.desc = 'Show LSP type definitions'
        keymap.set('n', ',t', '<cmd>Telescope lsp_type_definitions<CR>', opts) -- show lsp type definitions

        opts.desc = 'Go to definition'
        keymap.set('n', 'gd', vim.lsp.buf.definition, opts) -- show lsp type definitions

        opts.desc = 'Go back'
        keymap.set('n', 'gb', '<C-o>', opts)

        opts.desc = 'Go forward'
        keymap.set('n', 'gF', '<C-O>', opts)

        opts.desc = 'Show documentation for what is under cursor'
        keymap.set('n', ',s', vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = 'Show buffer diagnostics'
        keymap.set('n', ',D', '<cmd>Telescope diagnostics bufnr=0<CR>', opts) -- show  diagnostics for file

        opts.desc = 'Show line diagnostics'
        keymap.set('n', ',d', vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = 'Go to previous diagnostic'
        keymap.set('n', ',p', vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = 'Go to next diagnostic'
        keymap.set('n', ',n', vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs =
      { Error = ' ', Warn = ' ', Hint = '󰠠 ', Info = ' ' }
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end

    -- Modern way to set diagnostic signs (replaces the deprecated sign_define above)
    vim.diagnostic.config {
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚',
          [vim.diagnostic.severity.WARN] = '󰀪',
          [vim.diagnostic.severity.HINT] = '󰌶',
          [vim.diagnostic.severity.INFO] = '󰋽',
        },
      },
    }

    mason_lspconfig.setup {
      handlers = {
        -- default handler for installed servers
        function(server_name)
          -- if server_name ~= 'rust_analyzer' then
          -- let rustaceanvim handle everything rust-related
          lspconfig[server_name].setup {
            capabilities = capabilities,
          }
          -- end
        end,
        ['svelte'] = function()
          -- configure svelte server
          lspconfig['svelte'].setup {
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              vim.api.nvim_create_autocmd('BufWritePost', {
                pattern = { '*.js', '*.ts', '*.svelte' },
                callback = function(ctx)
                  -- Here use ctx.match instead of ctx.file
                  client.notify('$/onDidChangeTsOrJsFile', { uri = ctx.match })
                end,
              })
            end,
          }
        end,
        ['graphql'] = function()
          -- configure graphql language server
          lspconfig['graphql'].setup {
            capabilities = capabilities,
            filetypes = {
              'graphql',
              'gql',
              'svelte',
              'typescriptreact',
              'javascriptreact',
            },
          }
        end,
        ['lua_ls'] = function()
          -- configure lua server (with special settings)
          lspconfig['lua_ls'].setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                -- make the language server recognize "vim" global
                diagnostics = {
                  globals = { 'vim' },
                },
                completion = {
                  callSnippet = 'Replace',
                },
              },
            },
          }
        end,
      },
    }
  end,
}
