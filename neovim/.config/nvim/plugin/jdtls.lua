-- plugin/jdtls.lua
local java_cmds = vim.api.nvim_create_augroup('java_cmds', { clear = true })
local cache_vars = {}

local root_files = {
  '.git',
  'mvnw',
  'gradlew',
  'pom.xml',
  'build.gradle',
}

-- Feature toggles
local features = {
  codelens = false,
  debugger = true,
}

local function get_jdtls_paths()
  if cache_vars.paths then
    return cache_vars.paths
  end

  local path = {}
  path.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'

  -- Try mason-registry, but fall back to stdpath('data')
  local jdtls_install
  local ok_mr, mr = pcall(require, 'mason-registry')
  if ok_mr and mr.has_package and mr.has_package('jdtls') then
    local pkg = mr.get_package('jdtls')
    if pkg and pkg.get_install_path then
      jdtls_install = pkg:get_install_path()
    end
  end
  if not jdtls_install then
    local fallback = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
    if vim.loop.fs_stat(fallback) then
      jdtls_install = fallback
    else
      vim.notify('[jdtls] Mason package "jdtls" not found. Open :Mason to install it.', vim.log.levels.ERROR)
      cache_vars.paths = {} -- avoid recomputing
      return {}
    end
  end

  -- lombok (optional)
  path.java_agent = jdtls_install .. '/lombok.jar'
  if not vim.loop.fs_stat(path.java_agent) then
    path.java_agent = nil
  end

  -- launcher jar
  local matches = vim.split(
    vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
    '\n',
    { trimempty = true }
  )
  path.launcher_jar = matches[1]
  if not path.launcher_jar or path.launcher_jar == '' then
    vim.notify('[jdtls] Equinox launcher jar not found under ' .. jdtls_install, vim.log.levels.ERROR)
    cache_vars.paths = {}
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
    cache_vars.paths = {}
    return {}
  end

  -- bundles
  path.bundles = {}

  -- java-test (optional)
  if ok_mr and mr.has_package and mr.has_package('java-test') then
    local p = mr.get_package('java-test'); p = p and p.get_install_path and p:get_install_path()
    if p then
      local jars = vim.split(vim.fn.glob(p .. '/extension/server/*.jar'), '\n', { trimempty = true })
      if #jars > 0 then vim.list_extend(path.bundles, jars) end
    end
  end

  -- java-debug-adapter (required for debug) + fallback to stdpath if registry missing
  local function add_debug_jar(base)
    local jars = vim.split(
      vim.fn.glob(base .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'),
      '\n',
      { trimempty = true }
    )
    if #jars > 0 then vim.list_extend(path.bundles, jars) end
  end

  if ok_mr and mr.has_package and mr.has_package('java-debug-adapter') then
    local p = mr.get_package('java-debug-adapter'); p = p and p.get_install_path and p:get_install_path()
    if p then add_debug_jar(p) end
  end

  if #path.bundles == 0 then
    add_debug_jar(vim.fn.stdpath('data') .. '/mason/packages/java-debug-adapter')
  end

  if #path.bundles == 0 then
    vim.notify("[jdtls] No debug bundles found (java-debug-adapter). They will install automatically; reopen this Java file afterwards.", vim.log.levels.WARN)
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
  if features.debugger then
    enable_debugger(bufnr)
  end
  if features.codelens then
    enable_codelens(bufnr)
  end

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
  if not path or not path.launcher_jar then
    return -- errors already notified above
  end

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

  -- Build command (with optional lombok)
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
    table.insert(cmd, 6, '-javaagent:' .. path.java_agent) -- insert near the top flags
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
    root_dir = jdtls.setup.find_root(root_files),
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

