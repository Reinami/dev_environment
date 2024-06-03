function ColorTheme(color)
	color = color or "kanagawa"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

function SetDefaultColor()
    ColorTheme()
end

vim.api.nvim_create_autocmd("VimEnter", { callback = SetDefaultColor })

