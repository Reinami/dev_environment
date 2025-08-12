local M = {}

-- map colorscheme -> plugin "name" from the specs above
local THEME_PLUGINS = {
  tokyonight = "tokyonight.nvim",
  kanagawa   = "kanagawa.nvim",
  vscode = "vscode_modern.nvim",
  monokai = "monokai.nvim",
}

-- accepts "tokyonight" or { args = "tokyonight" }
function M.SetTheme(opts)
  local name = type(opts) == "string" and opts
    or (type(opts) == "table" and opts.args)
  if not name then error("Invalid argument passed to SetTheme") end

  local plugin = THEME_PLUGINS[name]
  if plugin then
    require("lazy").load({ plugins = { plugin } })  -- ensure spec loaded
  end

  vim.cmd.colorscheme(name)

  -- safety: keep transparency consistent
  pcall(vim.api.nvim_set_hl, 0, "Normal",      { bg = "none" })
  pcall(vim.api.nvim_set_hl, 0, "NormalFloat", { bg = "none" })
end

vim.api.nvim_create_user_command("SetTheme", function(o)
  M.SetTheme(o.args)
end, {
  nargs = 1,
  complete = function() return vim.tbl_keys(THEME_PLUGINS) end,
})

return M

