-- Global split separators: ensure visible lines between all panes
-- - Sets global fillchars (without overriding if already set)
-- - Removes per-window mappings that hide WinSeparator/VertSplit
-- - Reapplies on new windows and colorscheme changes

local M = {}

local function ensure_fillchars()
  local fc = vim.opt.fillchars:get() or {}
  local need = {}
  if not fc.eob or fc.eob == '' then need.eob = ' ' end
  if not fc.fold or fc.fold == '' then need.fold = ' ' end
  if not fc.vert or fc.vert == '' then need.vert = '│' end
  if not fc.horiz or fc.horiz == '' then need.horiz = '─' end
  if not fc.horizup or fc.horizup == '' then need.horizup = '┴' end
  if not fc.horizdown or fc.horizdown == '' then need.horizdown = '┬' end
  if not fc.vertleft or fc.vertleft == '' then need.vertleft = '┤' end
  if not fc.vertright or fc.vertright == '' then need.vertright = '├' end
  if not fc.verthoriz or fc.verthoriz == '' then need.verthoriz = '┼' end
  if next(need) then vim.opt.fillchars:append(need) end
end

local function normalize_winhighlight(win)
  win = win or 0
  local val = vim.wo[win].winhighlight or ''
  if val == '' then
    -- map explicitly so themes apply to all windows consistently
    vim.wo[win].winhighlight = 'WinSeparator:WinSeparator,VertSplit:VertSplit'
    return
  end
  -- remove any mapping that hides or overrides these groups
  val = val:gsub('WinSeparator:[^,]*,?', '')
  val = val:gsub('VertSplit:[^,]*,?', '')
  val = val:gsub('^,+', ''):gsub(',+$', '')
  if #val > 0 then val = val .. ',' end
  vim.wo[win].winhighlight = val
    .. 'WinSeparator:WinSeparator,VertSplit:VertSplit'
end

local function apply_all()
  ensure_fillchars()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    normalize_winhighlight(win)
  end
end

function M.setup()
  -- Apply immediately and once the event loop runs (after other init tweaks)
  apply_all()
  vim.schedule(apply_all)
  local grp =
    vim.api.nvim_create_augroup('GlobalSplitSeparators', { clear = true })
  vim.api.nvim_create_autocmd(
    { 'VimEnter', 'UIEnter', 'WinNew', 'WinEnter', 'BufWinEnter', 'TabEnter' },
    {
      group = grp,
      callback = function(args) apply_all() end,
    }
  )
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = grp,
    callback = function()
      -- re-assert mappings after theme reloads
      apply_all()
      vim.schedule(apply_all)
    end,
  })
end

M.setup()

return M
