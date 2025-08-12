return {
  "folke/tokyonight.nvim",
  name = "tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
        style = "moon",
        transparent = true, -- Enable transparent background
        styles = {
            sidebars = "transparent",
            floats = "transparent",
  },
  on_highlights = function(hl, c)
      hl.LineNr              = { fg = "#FFFFFF", bold = true, bg = "none" }
      hl.NvimTreeLineNr      = { fg = "#FFFFFF", bold = true, bg = "none" }
      hl.LineNrAbove         = { fg = "#51B3EC", bold = true, bg = "none" }
      hl.NvimTreeLineNrAbove = { fg = "#51B3EC", bold = true, bg = "none" }
      hl.LineNrBelow         = { fg = "#FB508F", bold = true, bg = "none" }
      hl.NvimTreeLineNrBelow = { fg = "#FB508F", bold = true, bg = "none" }
      hl.CursorLineNr        = { fg = "#FFFFFF", bold = true, bg = "none" }
  end,
  },
  config = function(_, opts)
    require("tokyonight").setup(opts)
  end,
}
