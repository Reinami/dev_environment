return {
  "tanvirtin/monokai.nvim",
  name = "monokai.nvim",
  lazy = false,
  priority = 1000,
  config = function()
      local grp = vim.api.nvim_create_augroup("MonokaiCustomHL", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
          group = grp,
          pattern = "monokai*",
          callback = function ()
              vim.api.nvim_set_hl(0, "LineNr",              { fg = "#FFFFFF", bold = true, bg = "none" })
              vim.api.nvim_set_hl(0, "NvimTreeLineNr",      { fg = "#FFFFFF", bold = true, bg = "none" })
              vim.api.nvim_set_hl(0, "LineNrAbove",         { fg = "#51B3EC", bold = true, bg = "none" })
              vim.api.nvim_set_hl(0, "NvimTreeLineNrAbove", { fg = "#51B3EC", bold = true, bg = "none" })
              vim.api.nvim_set_hl(0, "LineNrBelow",         { fg = "#FB508F", bold = true, bg = "none" })
              vim.api.nvim_set_hl(0, "NvimTreeLineNrBelow", { fg = "#FB508F", bold = true, bg = "none" })
              vim.api.nvim_set_hl(0, "CursorLineNr",        { fg = "#FFFFFF", bold = true, bg = "none" })
              vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
              vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
          end,
      })
  end,
}

