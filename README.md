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

### Avante
AI-powered chat interface for code generation and refactoring with:
- Multiple provider support (local via Ollama, CLI tools, paid APIs)
- Project-aware RAG for contextual understanding
- Provider and model switchers for easy configuration changes
- Agentic mode for complex multi-step tasks

### Autocomplete
Inline code suggestions with ghost text previews powered by Tabby, using local models for privacy.