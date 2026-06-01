return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      -- Disallowed Copilot attachment patterns (basename, case-insensitive).
      local secret_name_patterns = {
        "^%.env$",
        "^%.env%.",
        "secret",
        "credential",
        "%.pem$",
        "%.key$",
        "id_rsa",
        "id_ed25519",
      }

      -- Private note patterns (full path, case-insensitive).
      local private_note_patterns = {
        -- "%.private%.md$",
      }

      local function matches_any(text, patterns)
        for _, pattern in ipairs(patterns) do
          if text:match(pattern) then
            return true
          end
        end
        return false
      end

      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
        -- Exclude secret-heavy filetypes.
        filetypes = {
          dotenv = false,
        },
        -- Reject secret and private buffers, preserving default checks.
        should_attach = function(bufnr, bufname)
          if not vim.bo[bufnr].buflisted or vim.bo[bufnr].buftype ~= "" then
            return false
          end

          local path = bufname:lower()
          local basename = path:match("[^/]+$") or path

          if matches_any(basename, secret_name_patterns) then
            return false
          end

          if matches_any(path, private_note_patterns) then
            return false
          end

          return true
        end,
      })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      "saghen/blink.lib",
      {
        "L3MON4D3/LuaSnip",
        -- build = "make install_jsregexp",
        build = "make install_jsregexp && codesign --force --sign - "
          .. vim.fn.stdpath("data")
          .. "/lazy/LuaSnip/deps/luasnip-jsregexp.so",
        version = "v2.*",
        opts = {
          history = true,
          delete_check_events = "TextChanged",
        },
      },
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
      "giuxtaposition/blink-cmp-copilot",
    },
    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "none",
        ["<C-e>"] = { "hide" },
        ["<C-y>"] = { "select_and_accept" },
        ["<C-j>"] = { "select_next" },
        ["<C-k>"] = { "select_prev" },
        ["<C-d>"] = { "scroll_documentation_down" },
        ["<C-u>"] = { "scroll_documentation_up" },
        ["<Tab>"] = { "select_and_accept", "fallback" },
      },
      snippets = {
        preset = "luasnip",
      },
      signature = {
        enabled = true,
      },
      completion = {
        menu = {
          winblend = 0,
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
            components = {
              kind_icon = {
                text = function(ctx)
                  if ctx.kind == "Copilot" then
                    return ""
                  end
                  return require("lspkind").presets.codicons[ctx.kind] or ""
                end,
              },
            },
          },
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 100,
        },
        ghost_text = {
          enabled = false,
        },
      },
      sources = {
        default = function()
          local success, node = pcall(vim.treesitter.get_node)

          local string_node_types = {
            "string",
            "string_content",
            "character",
            "string_literal",
          }

          if success and node and vim.tbl_contains(string_node_types, node:type()) then
            return { "buffer", "snippets" }
          end

          return { "copilot", "lazydev", "lsp", "path", "snippets", "buffer" }
        end,
        providers = {
          lazydev = {
            name = "[LZDV]",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          lsp = {
            name = "[LSP]",
            fallbacks = {},
            score_offset = 1,
          },
          buffer = {
            name = "[BUF]",
            max_items = 20,
          },
          path = {
            name = "[PATH]",
            opts = {
              trailing_slash = false,
              show_hidden_files_by_default = true,
            },
          },
          snippets = {
            name = "[SNP]",
          },
          copilot = {
            name = "",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.kind_name = "Copilot"
              end
              return items
            end,
          },
        },
      },
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<C-j>"] = { "select_next", "show" },
          ["<C-k>"] = { "select_prev", "show" },
          ["<Tab>"] = { "show", "accept" },
        },
        sources = function()
          local t = vim.fn.getcmdtype()
          if t == "/" or t == "?" then
            return { "buffer" }
          end

          if t == ":" then
            return { "cmdline", "path" }
          end
          return {}
        end,
        completion = {
          list = {
            selection = {
              auto_insert = false,
            },
          },
          menu = {
            auto_show = true,
          },
          ghost_text = {
            enabled = true,
          },
        },
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
        sorts = {
          function(a, b)
            local a_is_copilot = a.source_id == "copilot"
            local b_is_copilot = b.source_id == "copilot"
            if a_is_copilot ~= b_is_copilot then
              return a_is_copilot
            end
          end,
          "exact",
          "score",
          function(a, b)
            local _, a_under = a.label:find("^_+")
            local _, b_under = b.label:find("^_+")
            a_under = a_under or 0
            b_under = b_under or 0
            if a_under ~= b_under then
              return a_under < b_under
            end
          end,
          "sort_text",
          "label",
        },
      },
    },
    opts_extend = { "sources.default" },
    config = function(_, opts)
      local ls = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        ls.jump(1)
      end, { silent = true })

      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        ls.jump(-1)
      end, { silent = true })

      require("blink.cmp").setup(opts)
    end,
  },
}
