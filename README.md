# nvim

Personal Neovim configuration with AI-assisted development.

## Structure

Configuration is organized by plugin usage patterns. All external plugins are configured in `lua/sriramrao/plugins/`:

- `complete/` - Completion and AI tools
- `edit/` - Text editing enhancements
- `lang/` - Language-specific tools
- `move/` - Navigation and movement
- `visual/` - UI components
- `session/` - Session management
- `util/` - Utility plugins
- `local/` - Local/custom plugins

## AI Features

### AI Assistants

#### CodeCompanion (Active)
Primary AI assistant with chat and inline editing capabilities:
- Multiple provider support (Anthropic API, OpenAI, Ollama, Claude Code CLI, Gemini CLI)
- Runtime provider/model switching with pickers (`<leader>ap`, `<leader>am`)
- VectorCode integration for semantic code search (RAG)
- MCPhub for MCP server integration
- Auto-add buffer to context (toggle with `<leader>at`)
- Keymaps: `<C-a>` actions, `<leader>aa` toggle chat, `<leader>an` new chat, `<leader>ae` inline edit

#### Avante (Disabled)
AI-powered chat interface for code generation and refactoring with:
- Multiple provider support (local via Ollama, CLI tools, paid APIs)
- Project-aware RAG for contextual understanding
- Provider and model switchers for easy configuration changes
- Agentic mode for complex multi-step tasks
- Config preserved in `complete/avante.lua` (`enabled = false`)
- Can be re-enabled alongside or instead of CodeCompanion

### AI Completion

#### cmp-tabby (Active)
Tabby AI completions integrated into nvim-cmp menu for consistent completion UX.
- Server: http://localhost:8080
- Appears alongside LSP, snippets, and buffer completions
- Standard cmp navigation: `<Tab>` accept, `<C-j>`/`<C-k>` navigate

#### vim-tabby (Disabled)
Ghost text inline completion (Copilot-style).
- Shows grayed-out suggestions inline while typing
- Keymaps: `<C-y>` accept, `<C-\>` trigger/dismiss
- Config preserved in `complete/tabby.lua` (`enabled = false`)
- Can be re-enabled if ghost text style preferred over cmp menu

#### Copilot (Disabled)
GitHub Copilot integration.
- Commented out in nvim-cmp sources
- Can be re-enabled in `complete/nvim-cmp.lua` by uncommenting `{ name = 'copilot' }`

### Supporting Tools

#### VectorCode + ChromaDB (Active)
Semantic code search using vector embeddings for contextual code understanding.
- ChromaDB server: http://localhost:8000 (Docker)
- Integrated with CodeCompanion as RAG tool

## UI/Visual

### Statusline

#### Heirline (Active)
Highly customizable statusline with:
- Mode indicator with colors
- Git status (branch, changes)
- Aerial (code context breadcrumbs)
- CodeCompanion provider/model/context display
- VectorCode job status
- Diagnostics count
- Single global statusline across splits

#### Lualine (Disabled)
Blazing fast and easy to configure statusline.
- Config preserved in `visual/lualine.lua` (`enabled = false`)
- Can be re-enabled instead of Heirline

### Window Titles

#### Incline (Active)
Floating filename labels for split windows with filetype-specific colors.

## Other Plugins

### Completion Sources

#### copilot.lua (Disabled)
GitHub Copilot base plugin.
- Config preserved in `complete/copilot.lua` (`enabled = false`)

#### copilot-cmp (Disabled)
nvim-cmp source for Copilot.
- Config preserved in `complete/copilot-cmp.lua` (`enabled = false`)