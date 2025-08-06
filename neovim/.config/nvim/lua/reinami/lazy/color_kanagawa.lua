return {
    "rebelot/kanagawa.nvim",
    config = function()
        require("kanagawa").setup({
            transparent = true, -- Enable transparent background
            overrides = function(colors)
                local palette = colors.palette
                return {
                    -- Ensure Normal and NormalFloat retain transparency
                    Normal = { bg = "none" },
                    NormalFloat = { bg = "none" },
                }
            end,
        })
    end,
}
