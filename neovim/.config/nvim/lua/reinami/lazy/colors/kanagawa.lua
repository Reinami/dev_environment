return {
    "rebelot/kanagawa.nvim",
    name = "kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        transparent = true, -- Enable transparent background
        overrides = function(colors)
            return {
                -- Ensure Normal and NormalFloat retain transparency
                Normal = { bg = "none" },
                NormalFloat = { bg = "none" },
                LineNrAbove = { fg = "#51B3EC", bold = true, bg = "none" },
                NvimTreeLineNrAbove = { fg = "#51B3EC", bold = true, bg = "none" },
                LineNr = { fg = "#FFFFFF", bold = true, bg = "none" },
                NvimTreeLineNr = { fg = "#FFFFFF", bold = true, bg = "none" },
                LineNrBelow = { fg = "#FB508F", bold = true, bg = "none" },
                NvimTreeLineNrBelow = { fg = "#FB508F", bold = true, bg = "none" },
                CursorLineNr = { fg = "#FFFFFF", bold = true, bg = "none"},
            }
        end,
    },
    config = function(_, opts)
        require("kanagawa").setup(opts)
    end,
}
