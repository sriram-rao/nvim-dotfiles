# nvim

Personal Neovim configuration with AI-assisted development via Avante.nvim.

## Structure

Configuration is organized by plugin usage patterns:

- `lua/sriramrao/plugins/complete/` - Completion and AI tools (Avante, Copilot, nvim-cmp)
- `lua/sriramrao/plugins/edit/` - Text editing enhancements (surround, comment, autopairs, substitute, lazygit)
- `lua/sriramrao/plugins/lang/` - Language-specific tools (LSP, treesitter, conform, lint, DAP, rustacean)
- `lua/sriramrao/plugins/move/` - Navigation and movement (telescope, nvim-tree, aerial, hop)
- `lua/sriramrao/plugins/visual/` - UI components (lualine, bufferline, colorscheme, gitsigns, trouble, which-key)
- `lua/sriramrao/plugins/session/` - Session management
- `lua/sriramrao/plugins/util/` - Utility plugins
- `lua/sriramrao/plugins/local/` - Local/custom plugins

## Avante Setup

Avante is configured with:

- **Claude Code** as the default provider (via local CLI)
- **RAG service** for project-aware context retrieval
- **MCP tools** for extended functionality
- **Web search** integration via Google
- **Agentic mode** for complex multi-step tasks

Provider switching: Use `:lua require('sriramrao.plugins.complete.avante.setup').switch_provider()` to change AI providers on the fly.

