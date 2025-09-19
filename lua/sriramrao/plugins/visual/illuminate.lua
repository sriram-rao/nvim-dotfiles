return {
  'RRethy/vim-illuminate',
  config = function()
    require('illuminate').configure {
      providers = {
        'lsp',
        'treesitter',
        'regex',
      },
    }
    local format = { underline = true, sp = '#7fbfff', bold = true }
    local set = vim.api.nvim_set_hl
    set(0, 'IlluminatedWordText', format)
    set(0, 'IlluminatedWordRead', format)
    set(
      0,
      'IlluminatedWordWrite',
      { bold = true, reverse = true, nocombine = true }
    )
  end,
}
