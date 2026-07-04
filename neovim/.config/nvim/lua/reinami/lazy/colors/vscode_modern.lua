return {
  "gmr458/vscode_modern_theme.nvim",
  name = "vscode_modern.nvim",
  lazy = false,       -- only load when SetTheme requests it
  priority = 1000,   -- so highlights get applied first
  opts = {
    cursorline = true,
    transparent_background = true,
    nvim_tree_darker = true,
  },
  config = function(_, opts)
    require("vscode_modern").setup(opts)

    vim.api.nvim_set_hl(0, "LineNr",              { fg = "#FFFFFF", bold = true, bg = "none" })
    vim.api.nvim_set_hl(0, "NvimTreeLineNr",      { fg = "#FFFFFF", bold = true, bg = "none" })
    vim.api.nvim_set_hl(0, "LineNrAbove",         { fg = "#51B3EC", bold = true, bg = "none" })
    vim.api.nvim_set_hl(0, "NvimTreeLineNrAbove", { fg = "#51B3EC", bold = true, bg = "none" })
    vim.api.nvim_set_hl(0, "LineNrBelow",         { fg = "#FB508F", bold = true, bg = "none" })
    vim.api.nvim_set_hl(0, "NvimTreeLineNrBelow", { fg = "#FB508F", bold = true, bg = "none" })
    vim.api.nvim_set_hl(0, "CursorLineNr",        { fg = "#FFFFFF", bold = true, bg = "none" })
  end,
}

