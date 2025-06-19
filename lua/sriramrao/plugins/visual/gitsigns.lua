return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map('n', ']g', gs.next_hunk, 'Next Hunk')
      map('n', '[g', gs.prev_hunk, 'Prev Hunk')

      -- Actions
      map('n', '<leader>gS', gs.stage_buffer, 'Stage buffer')
      map('n', '<leader>gR', gs.reset_buffer, 'Reset buffer')

      map('n', '<leader>gu', gs.undo_stage_hunk, 'Undo stage hunk')
      map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')

      map('n', '<leader>gd', gs.diffthis, 'Diff of unstaged changes')
      map(
        'n',
        '<leader>gD',
        function() gs.diffthis '~' end,
        'Diff of staged v HEAD'
      )

      -- Text object
      map(
        { 'o', 'x' },
        'ig',
        ':<C-U>Gitsigns select_hunk<CR>',
        'Gitsigns select hunk'
      )
    end,
  },
}
