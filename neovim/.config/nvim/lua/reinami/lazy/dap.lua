-- lua/reinami/lazy/java_dap.lua
return {
  -- Core DAP + attach configs + keymaps
  {
    "mfussenegger/nvim-dap",
    ft = { "java" },
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "williamboman/mason.nvim",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local ok, dap = pcall(require, "dap")
      if not ok then return end

      -- Keep anything jdtls adds (main-class launch configs)
      dap.configurations.java = dap.configurations.java or {}

      -- Attach targets (JDWP)
      table.insert(dap.configurations.java, {
        type = "java",
        request = "attach",
        name = "Attach to Java (5005)",
        hostName = "127.0.0.1",
        port = 5005,
      })
      table.insert(dap.configurations.java, {
        type = "java",
        request = "attach",
        name = "Attach (prompt)",
        hostName = "127.0.0.1",
        port = function()
          return tonumber(vim.fn.input("Debug port: ", "5005"))
        end,
      })

      -- Bridge jdtls <-> dap (Hot Code Replace + main-class configs)
      local ok_j, jdtls = pcall(require, "jdtls")
      if ok_j then
        jdtls.setup_dap({ hotcodereplace = "auto" })
        pcall(function() require("jdtls.dap").setup_dap_main_class_configs() end)
      end

      -- Keymaps (VSCode-ish)
      local map, opts = vim.keymap.set, { noremap = true, silent = true }
      map("n", "<F5>",    function() dap.continue() end,          opts)
      map("n", "<F9>",    function() dap.toggle_breakpoint() end, opts)
      map("n", "<F10>",   function() dap.step_over() end,         opts)
      map("n", "<F11>",   function() dap.step_into() end,         opts)
      map("n", "<S-F11>", function() dap.step_out() end,          opts)

      -- Optional: nice breakpoint sign
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
    end,
  },

  -- DAP UI (optional)
  {
    "rcarriga/nvim-dap-ui",
    ft = { "java" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"]      = function() dapui.close() end
    end,
  },

  -- Inline virtual text (optional)
  {
    "theHamsta/nvim-dap-virtual-text",
    ft = { "java" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = true,
  },
}

