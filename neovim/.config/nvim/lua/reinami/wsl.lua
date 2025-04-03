local function is_wsl()
    return vim.fn.has("wsl") == 1 or vim.fn.system("uname -r"):lower():match("wsl")
end
  
if is_wsl() then
    vim.g.clipboard = {
        name = "win32yank-wsl",
        copy = {
          ["+"] = "win32yank.exe -i --crlf",
          ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
          ["+"] = "win32yank.exe -o --lf",
          ["*"] = "win32yank.exe -o --lf",
        },
        cache_enabled = 0,
    }
    
    vim.api.nvim_create_autocmd("TextYankPost", {
        pattern = "*",
        callback = function()
            -- Use pcall to safely execute the substitution
            pcall(vim.cmd, [[%s/\r//g]])
        end,
    })
    
    vim.api.nvim_create_autocmd("TextChangedI", {
        pattern = "*",
        callback = function()
            -- Safe execution with pcall to suppress errors
            pcall(vim.cmd, [[%s/\r//g]])
        end,
    })
end