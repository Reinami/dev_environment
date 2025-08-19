-- lua/reinami/lazy/java_all.lua
return {
  ---------------------------------------------------------------------------
  -- 1) Mason core (install Java bits BEFORE jdtls starts)
  ---------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 900,
    config = function()
      require("mason").setup()

      -- Ensure these are installed up front so jdtls can load debug bundles
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

  ---------------------------------------------------------------------------
  -- 2) jdtls (LSP) – configured here instead of plugin/ to keep it all-in-one
  ---------------------------------------------------------------------------
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      local java_cmds = vim.api.nvim_create_augroup('java_cmds', { clear = true })
      local cache_vars = {}

      local root_files = {
        '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle',
      }

      local features = { codelens = false, debugger = true }

      local function get_jdtls_paths()
        if cache_vars.paths then return cache_vars.paths end
        local path = {}
        path.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'

        local jdtls_install
        local ok_mr, mr = pcall(require, 'mason-registry')
        if ok_mr and mr.has_package and mr.has_package('jdtls') then
          local pkg = mr.get_package('jdtls')
          if pkg and pkg.get_install_path then jdtls_install = pkg:get_install_path() end
        end
        if not jdtls_install then
          local fallback = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
          if vim.loop.fs_stat(fallback) then
            jdtls_install = fallback
          else
            vim.notify('[jdtls] Mason package "jdtls" not found.', vim.log.levels.ERROR)
            cache_vars.paths = {}
            return {}
          end
        end

        -- Optional Lombok agent
        path.java_agent = jdtls_install .. '/lombok.jar'
        if not vim.loop.fs_stat(path.java_agent) then path.java_agent = nil end

        -- Launcher jar
        local matches = vim.split(
          vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
          '\n', { trimempty = true }
        )
        path.launcher_jar = matches[1]
        if not path.launcher_jar or path.launcher_jar == '' then
          vim.notify('[jdtls] Equinox launcher jar not found: ' .. jdtls_install, vim.log.levels.ERROR)
          cache_vars.paths = {}
          return {}
        end

        -- Platform config
        local sys = vim.loop.os_uname().sysname
        if sys == 'Darwin' then
          path.platform_config = jdtls_install .. '/config_mac'
        elseif sys == 'Windows_NT' then
          path.platform_config = jdtls_install .. '/config_win'
        else
          path.platform_config = jdtls_install .. '/config_linux'
        end
        if not vim.loop.fs_stat(path.platform_config) then
          vim.notify('[jdtls] Platform config not found: ' .. path.platform_config, vim.log.levels.ERROR)
          cache_vars.paths = {}
          return {}
        end

        -- Bundles (java-test optional, java-debug-adapter required for debugging)
        path.bundles = {}
        local function add_debug_jar(base)
          local jars = vim.split(
            vim.fn.glob(base .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'),
            '\n', { trimempty = true }
          )
          if #jars > 0 then vim.list_extend(path.bundles, jars) end
        end

        if ok_mr and mr.has_package and mr.has_package('java-test') then
          local p = mr.get_package('java-test'); p = p and p.get_install_path and p:get_install_path()
          if p then
            local jars = vim.split(vim.fn.glob(p .. '/extension/server/*.jar'), '\n', { trimempty = true })
            if #jars > 0 then vim.list_extend(path.bundles, jars) end
          end
        end

        if ok_mr and mr.has_package and mr.has_package('java-debug-adapter') then
          local p = mr.get_package('java-debug-adapter'); p = p and p.get_install_path and p:get_install_path()
          if p then add_debug_jar(p) end
        end
        if #path.bundles == 0 then
          add_debug_jar(vim.fn.stdpath('data') .. '/mason/packages/java-debug-adapter')
        end
        if #path.bundles == 0 then
          vim.notify("[jdtls] No debug bundles found (java-debug-adapter).", vim.log.levels.WARN)
        end

        path.runtimes = {}
        cache_vars.paths = path
        return path
      end

      local function enable_codelens(bufnr)
        pcall(vim.lsp.codelens.refresh)
        vim.api.nvim_create_autocmd('BufWritePost', {
          buffer = bufnr,
          group = java_cmds,
          desc = 'refresh codelens',
          callback = function() pcall(vim.lsp.codelens.refresh) end,
        })
      end

      local function enable_debugger(bufnr)
        require('jdtls').setup_dap({ hotcodereplace = 'auto' })
        pcall(function() require('jdtls.dap').setup_dap_main_class_configs() end)
        local opts = { buffer = bufnr }
        vim.keymap.set('n', '<leader>df', function() require('jdtls').test_class() end, opts)
        vim.keymap.set('n', '<leader>dn', function() require('jdtls').test_nearest_method() end, opts)
      end

      local function jdtls_on_attach(_, bufnr)
        if features.debugger then enable_debugger(bufnr) end
        if features.codelens then enable_codelens(bufnr) end

        local opts = { buffer = bufnr }
        vim.keymap.set('n', '<A-o>', function() require('jdtls').organize_imports() end, opts)
        vim.keymap.set('n', 'crv',  function() require('jdtls').extract_variable() end, opts)
        vim.keymap.set('x', 'crv',  function() require('jdtls').extract_variable(true) end, opts)
        vim.keymap.set('n', 'crc',  function() require('jdtls').extract_constant() end, opts)
        vim.keymap.set('x', 'crc',  function() require('jdtls').extract_constant(true) end, opts)
        vim.keymap.set('x', 'crm',  function() require('jdtls').extract_method(true) end, opts)
      end

      local function jdtls_setup()
        local ok, jdtls = pcall(require, 'jdtls')
        if not ok then
          vim.notify('[jdtls] nvim-jdtls not found', vim.log.levels.ERROR)
          return
        end

        local path = get_jdtls_paths()
        if not path or not path.launcher_jar then return end

        local data_dir = path.data_dir .. '/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

        if cache_vars.capabilities == nil then
          jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
          local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
          cache_vars.capabilities = vim.tbl_deep_extend(
            'force',
            vim.lsp.protocol.make_client_capabilities(),
            (ok_cmp and cmp_lsp.default_capabilities()) or {}
          )
        end

        local java_exec = os.getenv("JAVA_HOME")
            and (os.getenv("JAVA_HOME") .. "/bin/java")
            or "java"

        local cmd = {
          java_exec,
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          '-Xms1g',
          '--add-modules=ALL-SYSTEM,java.compiler,jdk.compiler',
          '--add-opens','java.base/java.util=ALL-UNNAMED',
          '--add-opens','java.base/java.lang=ALL-UNNAMED',
        }
        if path.java_agent then
          table.insert(cmd, 6, '-javaagent:' .. path.java_agent)
        end
        vim.list_extend(cmd, {
          '-jar', path.launcher_jar,
          '-configuration', path.platform_config,
          '-data', data_dir,
        })

        local lsp_settings = {
          java = {
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = 'interactive', runtimes = path.runtimes },
            maven = { downloadSources = true },
            implementationsCodeLens = { enabled = true },
            referencesCodeLens = { enabled = true },
            format = { enabled = true },
          },
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              'org.hamcrest.MatcherAssert.assertThat',
              'org.hamcrest.Matchers.*',
              'org.hamcrest.CoreMatchers.*',
              'org.junit.jupiter.api.Assertions.*',
              'java.util.Objects.requireNonNull',
              'java.util.Objects.requireNonNullElse',
              'org.mockito.Mockito.*',
            },
          },
          contentProvider = { preferred = 'fernflower' },
          extendedClientCapabilities = jdtls.extendedClientCapabilities,
          sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
          codeGeneration = {
            toString = { template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}' },
            useBlocks = true,
          },
        }

        jdtls.start_or_attach({
          cmd = cmd,
          settings = lsp_settings,
          on_attach = jdtls_on_attach,
          capabilities = cache_vars.capabilities,
          root_dir = require('jdtls.setup').find_root(root_files),
          flags = { allow_incremental_sync = true },
          init_options = { bundles = path.bundles },
        })
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = java_cmds,
        pattern = { 'java' },
        desc = 'Setup jdtls',
        callback = jdtls_setup,
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 3) DAP (attach configs + keymaps) + UI + virtual text
  ---------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
    ft = { "java" },
    dependencies = { "mfussenegger/nvim-jdtls", "nvim-neotest/nvim-nio" },
    config = function()
      local ok, dap = pcall(require, "dap")
      if not ok then return end

      dap.configurations.java = dap.configurations.java or {}

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
        port = function() return tonumber(vim.fn.input("Debug port: ", "5005")) end,
      })

      -- Keymaps
      local map, opts = vim.keymap.set, { noremap = true, silent = true }
      map("n", "<F5>",    function() dap.continue() end,          opts)
      map("n", "<F9>",    function() dap.toggle_breakpoint() end, opts)
      map("n", "<F10>",   function() dap.step_over() end,         opts)
      map("n", "<F11>",   function() dap.step_into() end,         opts)
      map("n", "<S-F11>", function() dap.step_out() end,          opts)

      -- Optional: breakpoint sign
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    ft = { "java" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui"]      = function() dapui.close() end
    end,
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    ft = { "java" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = true,
  },
}

