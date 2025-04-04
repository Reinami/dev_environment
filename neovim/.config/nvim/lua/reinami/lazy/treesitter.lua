return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- Automatically run `:TSUpdate` after installation
    config = function()
        require("nvim-treesitter.configs").setup({
            -- A list of parser names, or "all"
            ensure_installed = {
                "json",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "go",
                "javascript",
                "typescript",
                "rust",
                "java",
                "css",
                "python",
            },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            auto_install = true,

            highlight = {
                enable = true, -- Enable highlighting
                additional_vim_regex_highlighting = false, -- Disable Vim's regex highlighting
            },
        })
    end,
}
