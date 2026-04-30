-- Copied from: https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/utils/lualine.lua
local function getLuaLineTheme()
  local M = require("catppuccin.palettes").get_palette("mocha")
  local O = require("catppuccin").options
  local bg = O.transparent_background and "NONE" or M.mantle

  local catppuccin = {}

  -- local y = { bg = C.maroon, fg = C.base }
  -- local z = { bg = C.flamingo, fg = C.mantle }

  local y = { bg = M.surface0, fg = M.blue }
  local z = { bg = M.blue, fg = M.mantle }

  catppuccin.normal = {
    a = { bg = M.blue, fg = M.mantle, gui = "bold" },
    b = { bg = M.surface0, fg = M.blue },
    c = { bg = bg, fg = M.text },

    x = { bg = bg, fg = M.overlay0 },
    y = y,
    z = z,
  }

  catppuccin.insert = {
    a = { bg = M.maroon, fg = M.base, gui = "bold" },

    y = y,
    z = z,
  }

  catppuccin.terminal = {
    a = { bg = M.green, fg = M.base, gui = "bold" },
    -- b = { bg = C.surface0, fg = C.green },
    y = y,
    z = z,
  }

  catppuccin.command = {
    a = { bg = M.peach, fg = M.base, gui = "bold" },
    -- b = { bg = C.surface0, fg = C.peach },

    y = y,
    z = z,
  }

  catppuccin.visual = {
    a = { bg = M.mauve, fg = M.base, gui = "bold" },
    -- b = { bg = C.surface0, fg = C.mauve },

    y = y,
    z = z,
  }

  catppuccin.replace = {
    a = { bg = M.red, fg = M.base, gui = "bold" },
    -- b = { bg = C.surface0, fg = C.red },

    y = y,
    z = z,
  }

  catppuccin.inactive = {
    a = { bg = bg, fg = M.blue },
    b = { bg = bg, fg = M.surface1, gui = "bold" },
    c = { bg = bg, fg = M.overlay0 },
  }

  return catppuccin, M
end

local function harpoon2()
  local harpoon = require("harpoon")

  local items = harpoon:list().items

  local current_file = vim.api.nvim_buf_get_name(0)

  local numbers = { "󰲠", "󰲢", "󰲤", "󰲦" }

  --- @type string[]
  local status = {}
  for i, item in ipairs(items) do
    local is_active = vim.endswith(current_file, item.value)

    if is_active then
      table.insert(status, numbers[i])
    else
      table.insert(status, string.format("%%#Whitespace#%s%%*", numbers[i]))
    end
  end

  if #status < 4 then
    -- Fill the rest with empty indicators
    for _ = #status + 1, 4 do
      table.insert(status, string.format("%%#Whitespace#%s%%*", ""))
    end
  end

  return table.concat(status, " ")
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
  opts = function()
    local theme, palette = getLuaLineTheme()
    return {
      options = {
        theme = theme,
        globalstatus = true,
        component_separators = "",
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {
            -- "neo-tree",
            -- "undotree",
          },
        },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            icon = {
              "",
              align = "left",
            },
            separator = { left = "", right = "" },
          },
        },
        lualine_b = {
          {
            "filetype",
            separator = "",
            icon_only = true,
            colored = false,
            padding = { left = 2, right = 0 },
          },
          {
            "filename",
            symbols = { modified = "", readonly = " 󰌾" },
            padding = { left = 0, right = 1 },
            -- separator = { left = '', right = ''},
            fmt = function(str)
              local ft = vim.bo.filetype
              local is_readonly = vim.bo.modifiable == false or vim.bo.readonly == true
              local is_really_modified = vim.bo.modified and vim.bo.buftype == ""

              if ft:match("^snacks_picker") then
                if ft == "snacks_picker_list" then
                  return "Snacks Explorer"
                elseif ft == "snacks_picker_input" then
                  return "Snacks Picker"
                elseif ft == "snacks_picker_preview" then
                  return "Snacks Preview"
                else
                  return "Snacks Picker"
                end
              end

              if ft == "snacks_terminal" then
                return "Snacks Terminal"
              end

              -- If the filetype is one of the passthrough types, return it first letter capitalized
              local passthrough = {
                "lazy",
                "mason",
                "harpoon",
                "checkhealth",
                "snacks_dashboard",
                "snacks_scratch",
              }

              if vim.tbl_contains(passthrough, ft) then
                local res = ft:gsub("^%l", string.upper)
                res = res:gsub("^Snacks_", "Snacks ")
                if is_readonly then
                  res = res .. " 󰌾"
                end
                if is_really_modified then
                  res = res .. " "
                end
                return res
              end

              return str
            end,
          },
        },
        lualine_c = {
          {
            harpoon2,
            icon = {
              "󰀱",
              color = { fg = palette.flamingo },
              align = "left",
            },
          },
          {
            "diagnostics",
          },
        },
        lualine_x = {
          {
            "branch",
            icon = "",
            fmt = function(str)
              str = str:gsub("CU%-(.-)_", "CU-")
              if #str > 20 then
                str = str:sub(1, 9) .. "..." .. str:sub(-8)
              end
              return str
            end,
          },
          {
            "diff",
            padding = { left = 0, right = 1 },
          },
          "encoding",
        },
        lualine_y = {
          {
            "lsp_status",
            symbols = {
              separator = " | ",
              done = "",
              spinner = {},
            },
          },
        },
        lualine_z = {
          {
            "progress",
            icon = " ",
            padding = {
              left = 1,
              right = 0.75,
            },
          },
          {
            "location",
            separator = { right = "" },
          },
        },
      },
    }
  end,
}
