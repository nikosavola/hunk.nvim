---@class hunk.KeysGlobal
---@field quit string|string[] Keybinding(s) to quit (exit with non-zero code)
---@field accept string|string[] Keybinding(s) to accept the current selection
---@field focus_tree string|string[] Keybinding(s) to focus the file tree

---@class hunk.KeysTree
---@field expand_node string|string[] Keybinding(s) to expand a tree node
---@field collapse_node string|string[] Keybinding(s) to collapse a tree node
---@field open_file string|string[] Keybinding(s) to open file under cursor
---@field toggle_file string|string[] Keybinding(s) to toggle all hunks in file

---@class hunk.KeysDiff
---@field toggle_hunk string|string[] Keybinding(s) to toggle entire hunk under cursor
---@field toggle_line string|string[] Keybinding(s) to toggle line under cursor
---@field toggle_line_pair string|string[] Keybinding(s) to toggle line pair on both sides
---@field prev_hunk string|string[] Keybinding(s) to jump to previous hunk
---@field next_hunk string|string[] Keybinding(s) to jump to next hunk
---@field toggle_focus string|string[] Keybinding(s) to toggle focus between left/right

---@class hunk.Keys
---@field global hunk.KeysGlobal
---@field tree hunk.KeysTree
---@field diff hunk.KeysDiff

---@class hunk.UiTree
---@field mode "nested"|"flat" Tree display mode
---@field width number Width of the file tree panel

---@class hunk.Ui
---@field tree hunk.UiTree
---@field layout "vertical"|"horizontal" Diff split layout direction
---@field confirm_before_quit boolean Show a confirmation before quitting

---@class hunk.Icons
---@field enable_file_icons boolean Whether to show file type icons
---@field selected string Icon for selected items
---@field deselected string Icon for deselected items
---@field partially_selected string Icon for partially selected items
---@field folder_open string Icon for open folders
---@field folder_closed string Icon for closed folders
---@field expanded string Icon for expanded tree nodes
---@field collapsed string Icon for collapsed tree nodes

---@class hunk.Hooks
---@field on_tree_mount fun(context: { buf: number, tree: NuiTree, opts: table }) Called after tree buffer is mounted
---@field on_diff_mount fun(context: { buf: number, win: number }) Called after diff buffer is mounted

---@class hunk.Config
---@field keys hunk.Keys
---@field ui hunk.Ui
---@field icons hunk.Icons
---@field hooks hunk.Hooks

---@type hunk.Config
local M = {
  keys = {
    global = {
      quit = { "q" },
      accept = { "<leader><Cr>" },
      focus_tree = { "<leader>e" },
    },

    tree = {
      expand_node = { "l", "<Right>" },
      collapse_node = { "h", "<Left>" },

      open_file = { "<Cr>" },

      toggle_file = { "a" },
    },

    diff = {
      toggle_hunk = { "A" },
      toggle_line = { "a" },
      -- This is like toggle_line but it will also toggle the line on the other
      -- 'side' of the diff.
      toggle_line_pair = { "s" },

      prev_hunk = { "[h" },
      next_hunk = { "]h" },

      -- Jump between the left and right diff view
      toggle_focus = { "<Tab>" },
    },
  },

  ui = {
    tree = {
      -- Mode can either be `nested` or `flat`
      mode = "nested",
      width = 35,
    },
    --- Can be either `vertical` or `horizontal`
    layout = "vertical",
    --- Show a confirmation before quitting
    confirm_before_quit = false,
  },

  icons = {
    enable_file_icons = true,

    selected = "󰡖",
    deselected = "",
    partially_selected = "󰛲",

    folder_open = "",
    folder_closed = "",

    expanded = "",
    collapsed = "",
  },

  hooks = {
    ---@param _context { buf: number, tree: NuiTree, opts: table }
    on_tree_mount = function(_context) end,
    ---@param _context { buf: number, win: number }
    on_diff_mount = function(_context) end,
  },
}

--- Validate user-supplied configuration options.
---@param opts table User configuration table
---@return boolean ok Whether validation passed
---@return string? err Error message if validation failed
local function validate_config(opts)
  if opts.ui then
    if opts.ui.layout then
      if opts.ui.layout ~= "vertical" and opts.ui.layout ~= "horizontal" then
        return false, "config.ui.layout must be 'vertical' or 'horizontal', got: " .. tostring(opts.ui.layout)
      end
    end
    if opts.ui.tree then
      if opts.ui.tree.mode then
        if opts.ui.tree.mode ~= "nested" and opts.ui.tree.mode ~= "flat" then
          return false, "config.ui.tree.mode must be 'nested' or 'flat', got: " .. tostring(opts.ui.tree.mode)
        end
      end
      if opts.ui.tree.width then
        if type(opts.ui.tree.width) ~= "number" or opts.ui.tree.width < 1 then
          return false, "config.ui.tree.width must be a positive number, got: " .. tostring(opts.ui.tree.width)
        end
      end
    end
  end
  if opts.hooks then
    if opts.hooks.on_tree_mount and type(opts.hooks.on_tree_mount) ~= "function" then
      return false, "config.hooks.on_tree_mount must be a function"
    end
    if opts.hooks.on_diff_mount and type(opts.hooks.on_diff_mount) ~= "function" then
      return false, "config.hooks.on_diff_mount must be a function"
    end
  end
  return true
end

--- Merge user config into defaults.
---@param new_config table User-provided configuration overrides
function M.update_config(new_config)
  local ok, err = validate_config(new_config)
  if not ok then
    vim.notify("[hunk.nvim] Invalid configuration: " .. err, vim.log.levels.ERROR)
    return
  end

  local config = vim.tbl_deep_extend("force", M, new_config)
  for key, value in pairs(config) do
    M[key] = value
  end
end

return M
