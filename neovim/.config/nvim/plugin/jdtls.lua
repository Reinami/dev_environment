local java_cmds = vim.api.nvim_create_augroup('java_cmds', { clear = true })
local cache_vars = {}

local root_files = {
    '.git',
    'mvnw',
    'gradlew',
    'pom.xml',
    'build.gradle',
}

-- TODO: later
local features = {
    codelens = false,
    debugger = false,
}

local function get_jdtls_paths()
  if cache_vars.paths then
    return cache_vars.paths
  end

  local path = {}
  path.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'

  -- Try mason-registry, but fall back to standard install dir
  local jdtls_install
  local ok_mr, mr = pcall(require, 'mason-registry')
  if ok_mr and mr.has_package and mr.has_package('jdtls') then
    local pkg = mr.get_package('jdtls')
    if pkg and pkg.get_install_path then
      jdtls_install = pkg:get_install_path()
    end
  end
  if not jdtls_install then
    -- Fallback to Mason's default path
    local fallback = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
    if vim.loop.fs_stat(fallback) then
      jdtls_install = fallback
    else
      vim.notify('[jdtls] Mason package "jdtls" not found. Run :Mason and install jdtls.', vim.log.levels.ERROR)
      return {}
    end
  end

  -- lombok (optional)
  path.java_agent = jdtls_install .. '/lombok.jar'
  if not vim.loop.fs_stat(path.java_agent) then
    -- ok if missing; comment out -javaagent usage later if needed
    path.java_agent = nil
  end

  -- launcher jar (pick one)
  local matches = vim.split(
    vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
    '\n',
    { trimempty = true }
  )
  path.launcher_jar = matches[1]
  if not path.launcher_jar or path.launcher_jar == '' then
    vim.notify('[jdtls] Equinox launcher jar not found under ' .. jdtls_install, vim.log.levels.ERROR)
    return {}
  end

  -- platform config
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
    return {}
  end

  -- bundles (guard each)
  path.bundles = {}
  if ok_mr and mr.has_package and mr.has_package('java-test') then
    local p = mr.get_package('java-test'); p = p and p.get_install_path and p:get_install_path()
    if p then
      local jars = vim.split(vim.fn.glob(p .. '/extension/server/*.jar'), '\n', { trimempty = true })
      if #jars > 0 then vim.list_extend(path.bundles, jars) end
    end
  end
  if ok_mr and mr.has_package and mr.has_package('java-debug-adapter') then
    local p = mr.get_package('java-debug-adapter'); p = p and p.get_install_path and p:get_install_path()
    if p then
      local jars = vim.split(vim.fn.glob(p .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'), '\n', { trimempty = true })
      if #jars > 0 then vim.list_extend(path.bundles, jars) end
    end
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
        callback = function()
            pcall(vim.lsp.codelens.refresh)
        end,
    })
end

local function enable_debugger(bufnr)
    require('jdtls').setup_dap({hotcodereplace = 'auto'})
    require('jdtls.dap').setup_dap_main_class_configs()

    local opts = {buffer = bufnr}
    vim.keymap.set('n', '<leader>df', "<cmd>lua require('jdtls').test_class()<cr>", opts)
    vim.keymap.set('n', '<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<cr>", opts)
end

local function jdtls_on_attach(client, bufnr)
    if features.debugger then
        enable_debugger(bufnr)
    end

    if features.codelens then
        enable_codelens(bufnr)
    end

    local opts = {buffer = bufnr}
    vim.keymap.set('n', '<A-o>', "<cmd>lua require('jdtls').organize_imports()<cr>", opts)
    vim.keymap.set('n', 'crv', "<cmd>lua require('jdtls').extract_variable()<cr>", opts)
    vim.keymap.set('x', 'crv', "<esc><cmd>lua require('jdtls').extract_variable(true)<cr>", opts)
    vim.keymap.set('n', 'crc', "<cmd>lua require('jdtls').extract_constant()<cr>", opts)
    vim.keymap.set('x', 'crc', "<esc><cmd>lua require('jdtls').extract_constant(true)<cr>", opts)
    vim.keymap.set('x', 'crm', "<esc><Cmd>lua require('jdtls').extract_method(true)<cr>", opts)
end

local function jdtls_setup(event)
    local jdtls = require('jdtls')

    local path = get_jdtls_paths()
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
      -- java sucks
      java_exec,

      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-javaagent:' .. path.java_agent,
      '-Xms1g',
      '--add-modules=ALL-SYSTEM,java.compiler,jdk.compiler',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',

      -- java really sucks
      '-jar',
      path.launcher_jar,

      -- java reall really sucks
      '-configuration',
      path.platform_config,

      -- java can suck it
      '-data',
      data_dir,
    }
  local lsp_settings = {
    java = {
      -- jdt = {
      --   ls = {
      --     vmargs = "-XX:+UseParallelGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx1G -Xms100m"
      --   }
      -- },
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = 'interactive',
        runtimes = path.runtimes,
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      -- inlayHints = {
      --   parameterNames = {
      --     enabled = 'all' -- literals, all, none
      --   }
      -- },
      format = {
        enabled = true,
        -- settings = {
        --   profile = 'asdf'
        -- },
      }
    },
    signatureHelp = {
      enabled = true,
    },
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
    contentProvider = {
      preferred = 'fernflower',
    },
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      }
    },
    codeGeneration = {
      toString = {
        template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
      },
      useBlocks = true,
    },
  }

  -- This starts a new client & server,
  -- or attaches to an existing client & server depending on the `root_dir`.
  jdtls.start_or_attach({
    cmd = cmd,
    settings = lsp_settings,
    on_attach = jdtls_on_attach,
    capabilities = cache_vars.capabilities,
    root_dir = jdtls.setup.find_root(root_files),
    flags = {
      allow_incremental_sync = true,
    },
    init_options = {
      bundles = path.bundles,
    },
  })
end

vim.api.nvim_create_autocmd('FileType', {
  group = java_cmds,
  pattern = {'java'},
  desc = 'Setup jdtls',
  callback = jdtls_setup,
})
