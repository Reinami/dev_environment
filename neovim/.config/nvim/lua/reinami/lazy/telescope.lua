return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }, -- Telescope requires plenary.nvim
    config = function()
        local builtin = require("telescope.builtin")

        -- Key mappings
        vim.keymap.set("n", "<C-l>", builtin.find_files, {})
        vim.keymap.set("n", "<C-g>", builtin.git_files, {})
        vim.keymap.set("n", "<C-s>", builtin.live_grep, {})
        vim.keymap.set("n", "<C-f>", builtin.current_buffer_fuzzy_find, {})
    end,
}
