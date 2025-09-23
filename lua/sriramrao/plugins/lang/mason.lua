return {
  'williamboman/mason-lspconfig.nvim',
  dependencies = {
    {
      'williamboman/mason.nvim',
      config = true,
    },
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    -- here until they work with mason
    vim.lsp.config('jdtls', {})
    vim.lsp.config('gopls', {
      settings = {
        gopls = {
          format = {
            tabWidth = 4,
            useTabs = false,
          },
        },
      },
    })

    vim.lsp.config('sourcekit', {
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
    })

    local venv_python = vim.fn.getcwd() .. '/venv/bin/python'
    vim.lsp.config('basedpyright', {
      settings = {
        python = {
          pythonPath = vim.fn.filereadable(venv_python) == 1 and venv_python
            or 'python3',
        },
      },
    })

    vim.lsp.config('ruff', {
      capabilities = {
        general = {
          positionEncodings = { 'utf-16' },
        },
      },
    })

    vim.lsp.enable { 'basedpyright', 'gopls', 'jdtls', 'sourcekit' }
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
        'tailwindcss',
        'ruff',
        'markdown_oxide',

        'jsonls',
        'clangd',
        'cmake',
        'elixirls',
        'jdtls',
      },
    }

    mason_tool_installer.setup {
      ensure_installed = {
        'prettier', -- prettier formatter
        -- 'stylua', -- lua formatter
        -- 'rustfmt', -- rust formatter
        'clang-format',
        -- 'goimports',
        'shfmt', -- shell formatter
        'google-java-format',
        'ruff',
        'eslint_d',
      },
    }
  end,
}
