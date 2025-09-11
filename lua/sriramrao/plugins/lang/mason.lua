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

    lspconfig.sourcekit.setup {
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
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
        'tailwindcss',
        'ruff',
        'markdown_oxide',
        -- 'rust_analyzer',
        'jsonls',
        'clangd',
        'cmake',
        'elixirls',
      },
    }

    mason_tool_installer.setup {
      ensure_installed = {
        'prettier', -- prettier formatter
        'stylua', -- lua formatter
        -- 'rustfmt', -- rust formatter
        'clang-format',
        -- 'goimports',
        'shfmt', -- shell formatter
        'google-java-format',
        'ruff',
        'eslint_d',
      },
    }
    local venv_python = vim.fn.getcwd() .. '/venv/bin/python'
    if lspconfig.basedpyright then
      lspconfig.basedpyright.setup {
        on_attach = function(client) client:stop() end,
        settings = {
          python = {
            pythonPath = vim.fn.filereadable(venv_python) == 1 and venv_python
              or 'python3',
          },
        },
      }
    end
  end,
}
