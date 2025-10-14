-- lua/sriramrao/plugins/visual/heirline.lua
return {
  'rebelot/heirline.nvim',
  event = 'VeryLazy',
  config = function()
    vim.o.laststatus = 3 -- single, global statusline
    -- optional if you use Noice:
    vim.o.cmdheight = 0
    local h = require 'heirline'

    local cond = require 'heirline.conditions'
    local u = require 'heirline.utils'
    local SL = '#627E97' -- tasteful gray-blue from colorscheme fg_gutter
    local NL = u.get_highlight('Normal').bg
    local BoxBG = '#143652' -- bg_highlight from colorscheme - more visible
    local Space = { provider = '  ', hl = { bg = NL } }

    RightSlantEnd = {
      provider = '',
      hl = function() return { fg = NL, bg = SL } end, -- transition out of section: normal bg on section color
    }
    RightSlantStart = {
      provider = '',
      hl = function() return { fg = SL, bg = NL } end, -- transition into section: section color on normal bg
    }

    local Mode = {
      static = {
        modes = {
          n = { name = 'NORMAL', color = '#65D1FF' },
          i = { name = 'INSERT', color = '#3EFFDC' },
          v = { name = 'VISUAL', color = '#FF61EF' },
          V = { name = 'V-LINE', color = '#FF61EF' },
          ['\22'] = { name = 'V-BLOCK', color = '#FF61EF' },
          c = { name = 'COMMAND', color = '#FFDA7B' },
          R = { name = 'REPLACE', color = '#FF4A4A' },
          t = { name = 'TERMINAL', color = '#3EFFDC' },
        },
      },
      provider = function(self)
        local mode = vim.fn.mode(1):sub(1, 1)
        local m = self.modes[mode] or { name = mode:upper() }
        return '  ' .. m.name .. '  '
      end,
      hl = function(self)
        local mode = vim.fn.mode(1):sub(1, 1)
        local m = self.modes[mode] or { color = '#627E97' }
        return { fg = '#011628', bg = m.color, bold = true }
      end,
      update = { 'ModeChanged', 'BufEnter' },
    }
    local Align = { provider = '%=' }
    local Ruler = {
      provider = '  %l:%c %p%%  ',
      hl = { bg = BoxBG, fg = '#CBE0F0' },
    }

    local Git = {
      condition = cond.is_git_repo,
      provider = function()
        local g = vim.b.gitsigns_status_dict
        if not g or not g.head then return '' end
        local t = { '  ' .. g.head }
        if (g.added or 0) > 0 then t[#t + 1] = '+' .. g.added end
        if (g.changed or 0) > 0 then t[#t + 1] = '~' .. g.changed end
        if (g.removed or 0) > 0 then t[#t + 1] = '-' .. g.removed end
        return table.concat(t, ' ') .. '  '
      end,
      hl = { bg = BoxBG, fg = '#B4D0E9' },
    }

    local Diag = {
      update = { 'DiagnosticChanged', 'LspAttach', 'LspDetach' },
      condition = function() return #vim.diagnostic.get(0) > 0 end,
      provider = function()
        local s = vim.diagnostic.severity
        local function n(x) return #vim.diagnostic.get(0, { severity = x }) end
        local e, w, i, h = n(s.ERROR), n(s.WARN), n(s.INFO), n(s.HINT)
        local t = {}
        if e > 0 then t[#t + 1] = 'E' .. e end
        if w > 0 then t[#t + 1] = 'W' .. w end
        if i > 0 then t[#t + 1] = 'I' .. i end
        if h > 0 then t[#t + 1] = 'H' .. h end
        return table.concat(t, ' ')
      end,
    }

    local Aerial = {
      condition = function()
        local ok, aerial = pcall(require, 'aerial')
        if not ok then return false end
        local symbols = aerial.get_location(true)
        return not aerial.is_open() and symbols and #symbols > 0
      end,
      provider = function()
        local ok, aerial = pcall(require, 'aerial')
        if not ok then return '' end
        local symbols = aerial.get_location(true)
        if not symbols or #symbols == 0 then return '' end

        local parts = {}
        for _, symbol in ipairs(symbols) do
          local icon = symbol.icon and (symbol.icon .. ' ') or ''
          table.insert(parts, icon .. symbol.name)
        end

        return '  ' .. table.concat(parts, ' > ') .. '  '
      end,
      hl = { bg = BoxBG, fg = '#B4D0E9' },
      update = { 'CursorMoved', 'BufEnter' },
    }

    local CodeCompanionProvider = {
      condition = function() return vim.bo.filetype == 'codecompanion' end,
      {
        provider = function()
          local ok, config = pcall(require, 'codecompanion.config')
          if not ok or not config then return '  codecompanion  ' end

          local adapter = config.strategies.chat.adapter or 'unknown'
          local model = ''

          -- Get model from adapter config (new API: adapters.http)
          if
            config.adapters
            and config.adapters.http
            and config.adapters.http[adapter]
          then
            local adapter_fn = config.adapters.http[adapter]
            if type(adapter_fn) == 'function' then
              local adapter_obj = adapter_fn()
              if
                adapter_obj
                and adapter_obj.schema
                and adapter_obj.schema.model
              then
                model = adapter_obj.schema.model.default or ''
              end
            end
          end

          if model ~= '' then
            return '  ' .. adapter .. ' (' .. model .. ')  '
          else
            return '  ' .. adapter .. '  '
          end
        end,
        hl = { bg = BoxBG, fg = '#CBE0F0' },
        update = { 'FileType', 'BufEnter' },
      },
      Space,
    }

    local IsCodeCompanion = function()
      return package.loaded.codecompanion -- and vim.bo.filetype == 'codecompanion'
    end

    local CodeCompanionCurrentContext = {
      static = {
        enabled = true,
      },
      condition = function(self)
        return IsCodeCompanion()
          and _G.codecompanion_current_context ~= nil
          and type(_G.codecompanion_current_context) == 'number'
          and vim.api.nvim_buf_is_valid(_G.codecompanion_current_context)
          and self.enabled
      end,
      {
        provider = function()
          local bufname = vim.fn.fnamemodify(
            vim.api.nvim_buf_get_name(_G.codecompanion_current_context),
            ':t'
          )

          -- Check if there are multiple contexts
          local context_count = 0
          if
            _G.codecompanion_contexts
            and type(_G.codecompanion_contexts) == 'table'
          then
            for _ in pairs(_G.codecompanion_contexts) do
              context_count = context_count + 1
            end
          end

          local suffix = ''
          if context_count > 1 then suffix = ' +' .. (context_count - 1) end

          return ' ' .. bufname .. suffix .. ' '
        end,
        hl = { fg = '#B4D0E9', bg = BoxBG },
        update = {
          'User',
          pattern = { 'CodeCompanionRequest*', 'CodeCompanionContextChanged' },
          callback = vim.schedule_wrap(function(self, args)
            if args.match == 'CodeCompanionRequestStarted' then
              self.enabled = false
            elseif args.match == 'CodeCompanionRequestFinished' then
              self.enabled = true
            end
            vim.cmd 'redrawstatus'
          end),
        },
      },
      Space,
    }

    local CodeCompanionStats = {
      condition = function(self) return IsCodeCompanion() end,
      static = {
        chat_values = {},
      },
      init = function(self)
        local bufnr = vim.api.nvim_get_current_buf()
        self.chat_values = (
          _G.codecompanion_chat_metadata
          and _G.codecompanion_chat_metadata[bufnr]
        ) or {}
      end,
      -- Combined ribbon
      {
        condition = function(self)
          return (self.chat_values.tokens and self.chat_values.tokens >= 0)
            or (self.chat_values.cycles and self.chat_values.cycles >= 0)
        end,
        {
          provider = function(self)
            local parts = {}
            if self.chat_values.tokens and self.chat_values.tokens >= 0 then
              table.insert(parts, '   ' .. self.chat_values.tokens)
            end
            if self.chat_values.cycles and self.chat_values.cycles >= 0 then
              table.insert(parts, '  ' .. self.chat_values.cycles)
            end
            return '  ' .. table.concat(parts, ' ') .. '  '
          end,
          hl = { fg = '#CBE0F0', bg = BoxBG },
          update = {
            'User',
            pattern = {
              'CodeCompanionChatOpened',
              'CodeCompanionRequestFinished',
            },
            callback = vim.schedule_wrap(function() vim.cmd 'redrawstatus' end),
          },
        },
        Space,
      },
    }

    -- VectorCode integration
    local VectorCode = nil
    local ok, vectorcode = pcall(require, 'vectorcode.integrations')
    if ok then
      VectorCode = {
        vectorcode.heirline {
          show_job_count = true,
          component_opts = {
            hl = { bg = BoxBG, fg = '#CBE0F0' },
            update = { 'User', 'BufEnter' },
          },
          Space,
        },
      }
    end

    h.setup {
      statusline = {
        Space,
        Mode,
        Space,
        { Git, Space },
        Aerial,
        Align,
        VectorCode,
        CodeCompanionProvider,
        CodeCompanionCurrentContext,
        CodeCompanionStats,
        { Ruler, Space },
      },
    }
  end,
}
