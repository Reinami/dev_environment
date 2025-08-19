-- lua/reinami/lazy/mason_core.lua
return {
  {
    "williamboman/mason.nvim",
    lazy = false,            -- load at startup
    priority = 900,          -- before LSPs
    config = function()
      require("mason").setup()

      -- ensure these are installed up front
      local mr = require("mason-registry")
      local want = { "jdtls", "java-debug-adapter", "java-test" }
      for _, name in ipairs(want) do
        local ok, pkg = pcall(mr.get_package, name)
        if ok and not pkg:is_installed() then
          pkg:install()
        end
      end
    end,
  },
}

