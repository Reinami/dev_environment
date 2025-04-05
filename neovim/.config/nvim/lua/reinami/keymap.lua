vim.g.mapleader = " "

-- sets file as executable
vim.keymap.set("n", "<leader>exec", "<cmd>!chmod +x %<CR>", { silent = true })

-- opens up error for lsp
vim.keymap.set("n", "<M-e>", vim.diagnostic.open_float)

-- jumps to definition using lsp
vim.keymap.set("n", "<C-Space>", vim.lsp.buf.definition, { noremap = true, silent = true })

-- binds dd to delete without copying text
vim.keymap.set("n", "dd", '"_dd', { noremap = true, silent = true })

-- binds ctrl + alt + down to copy line down

local function copy_line_below()
    local current_line = vim.api.nvim_get_current_line()
    vim.api.nvim_command("normal! o" .. current_line)
    vim.api.nvim_command('normal! =="')
end

local function copy_line_below_insert()
    vim.api.nvim_command("stopinsert")
    copy_line_below()
    vim.api.nvim_command("startinsert")
end

local function copy_selection_below()
    local lines, end_line = get_visual_selection_lines()
    -- insert lines after selection
    vim.api.nvim_buf_set_lines(0, end_line, end_line, false, lines)
end

local function smart_copy_down()
    local mode = vim.api.nvim_get_mode().mode
    if mode:match("v") or mode:match("V") then
        copy_selection_below()
    else
        copy_line_below()
    end
end

local function smart_copy_down_insert()
    vim.api.nvim_command("stopinsert")
    smart_copy_down()
    vim.api.nvim_command("startinsert")
end

vim.keymap.set("n", "<C-M-Down>", smart_copy_down, { noremap = true, silent = true })
vim.keymap.set("i", "<C-M-Down>", smart_copy_down_insert, { noremap = true, silent = true })
vim.keymap.set("v", "<C-M-Down>", smart_copy_down, { noremap = true, silent = true })

-- binds ctrl + down to add new empty line below

local function new_empty_line_below()
    vim.api.nvim_command("stopinsert")
    vim.api.nvim_command("normal! o")
    vim.api.nvim_command("startinsert")
end

vim.keymap.set("n", "<C-Down>", new_empty_line_below, { noremap = true, silent = true })

-- binds ctrl + c to copy
vim.keymap.set("v", "<C-c>", '"+y')
vim.keymap.set("n", "<C-c>", '"+yy')

-- binds ctrl + v to paste
vim.keymap.set("n", "<C-v>", '"+p')
vim.keymap.set("i", "<C-v>", '<C-r>+')
vim.keymap.set("v", "<C-v>", '"+p')

