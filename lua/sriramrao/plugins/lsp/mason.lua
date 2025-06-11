return {
  'williamboman/mason.nvim',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    -- here until they work with mason
    -- require("lspconfig").gopls.setup({})
    local lspconfig = require 'lspconfig'
    lspconfig.java_language_server.setup {}
    lspconfig.gopls.setup {
      settings = {
        gopls = {
          format = {
            tabWidth = 4,
            useTabs = false,
          },
        },
      },
    }

    -- import mason
    local mason = require 'mason'

    -- import mason-lspconfig
    local mason_lspconfig = require 'mason-lspconfig'

    local mason_tool_installer = require 'mason-tool-installer'

    -- enable mason and configure icons
    mason.setup {
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
    }

    mason_lspconfig.setup {
      ensure_installed = {
        'html',
        'cssls',
        'svelte',
        'lua_ls',
        'emmet_ls',
        'basedpyright',
        'markdown_oxide',
        'rust_analyzer',
        'jsonls',
        'clangd',
        'cmake',
      },
    }

    mason_tool_installer.setup {
      ensure_installed = {
        'prettier', -- prettier formatter
        'stylua', -- lua formatter
        'rustfmt', -- rust formatter
        'clang-format',
        'goimports',
        'shfmt', -- shell formatter
        'google-java-format',
        'ruff',
        'eslint_d',
      },
    }

    if lspconfig.basedpyright then
      lspconfig.basedpyright.setup {
        on_attach = function(client)
          client:stop()
        end,
      }
    end
  end,
}
