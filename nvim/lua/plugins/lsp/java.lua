return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local ok_jdtls, jdtls = pcall(require, "jdtls")

      if not ok_jdtls then
        vim.notify("nvim-jdtls is not available", vim.log.levels.ERROR, {
          title = "Java LSP",
          icon = "",
        })
        return
      end

      local project_markers = {
        "pom.xml",
        "build.gradle",
        "build.gradle.kts",
        "settings.gradle",
        "settings.gradle.kts",
      }

      local mason = vim.fn.stdpath("data") .. "/mason"
      local jdtls_path = mason .. "/packages/jdtls"

      local platform_config
      if vim.fn.has("mac") == 1 then
        platform_config = jdtls_path .. "/config_mac"
      elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        platform_config = jdtls_path .. "/config_win"
      else
        platform_config = jdtls_path .. "/config_linux"
      end

      local function find_root(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)
        if path == "" then
          return vim.fn.getcwd(), false
        end

        local file_dir = vim.fs.dirname(path)
        local matches = vim.fs.find(project_markers, { path = file_dir, upward = true })
        if #matches > 0 then
          return vim.fs.dirname(matches[1]), true
        end

        -- Unmanaged folders (no Maven/Gradle marker) should still anchor to the
        -- file directory instead of Neovim's cwd.
        return file_dir, false
      end

      local function safe_project_name(path)
        local name = vim.fs.basename(path)
        if name == "" then
          name = "default"
        end
        return (name:gsub("[^%w%-_]", "_"))
      end

      local function workspace_dir(root_dir)
        local base = vim.fn.stdpath("data") .. "/java-workspaces"
        local dir = base .. "/" .. safe_project_name(root_dir)
        vim.fn.mkdir(dir, "p")
        return dir
      end

      local function lombok_agent_args()
        local candidates = {
          jdtls_path .. "/lombok.jar",
          mason .. "/share/jdtls/lombok.jar",
        }

        for _, jar in ipairs(candidates) do
          if vim.fn.filereadable(jar) == 1 then
            return {
              "-javaagent:" .. jar,
              "-Xbootclasspath/a:" .. jar,
            }
          end
        end

        return {}
      end

      local function load_java_overrides(root_dir)
        local project_config = root_dir .. "/.nvim.lua"
        if vim.fn.filereadable(project_config) ~= 1 then
          return {}
        end

        local ok, config = pcall(dofile, project_config)
        if not ok then
          vim.notify("Failed to load Java overrides from " .. project_config, vim.log.levels.WARN, {
            title = "Java LSP",
            icon = "",
          })
          return {}
        end

        if type(config) ~= "table" then
          return {}
        end

        if type(config.java) == "table" then
          return config.java
        end

        if type(config.jdtls) == "table" then
          return config.jdtls
        end

        return config
      end

      local function build_cmd(root_dir)
        local launchers = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", true, true)
        local launcher = launchers[1]

        if not launcher or launcher == "" then
          return nil
        end

        if vim.fn.isdirectory(platform_config) ~= 1 then
          return nil
        end

        local cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=false",
          "-Dlog.level=ERROR",
          "-Xms1g",
        }

        vim.list_extend(cmd, lombok_agent_args())

        vim.list_extend(cmd, {
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",
          "-jar",
          launcher,
          "-configuration",
          platform_config,
          "-data",
          workspace_dir(root_dir),
        })

        return cmd
      end

      local function attach(bufnr)
        local root_dir, is_managed_project = find_root(bufnr)
        local cmd = build_cmd(root_dir)

        if not cmd then
          vim.notify("jdtls launcher/config not found. Install jdtls via Mason.", vim.log.levels.WARN, {
            title = "Java LSP",
            icon = "",
          })
          return
        end

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local has_blink, blink = pcall(require, "blink.cmp")
        if has_blink then
          capabilities = blink.get_lsp_capabilities(capabilities)
        end

        local settings = {
          java = {
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = "interactive" },
            maven = { downloadSources = true },
            references = { includeDecompiledSources = true },
            inlayHints = { parameterNames = { enabled = "all" } },
            format = { enabled = true },
          },
        }

        if not is_managed_project then
          settings.java.project = {
            sourcePaths = { "." },
          }
        end

        local config = {
          cmd = cmd,
          root_dir = root_dir,
          capabilities = capabilities,
          settings = settings,
          init_options = {
            bundles = {},
          },
        }

        config = vim.tbl_deep_extend("force", config, load_java_overrides(root_dir))
        jdtls.start_or_attach(config)
      end

      local group = vim.api.nvim_create_augroup("UserJavaJdtls", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "java",
        callback = function(event)
          attach(event.buf)
        end,
      })

      if vim.bo.filetype == "java" then
        attach(vim.api.nvim_get_current_buf())
      end
    end,
  },
}
