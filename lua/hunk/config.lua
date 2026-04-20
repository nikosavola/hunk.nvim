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
    on_tree_mount = function(_context) end,
    on_diff_mount = function(_context) end,
  },
}

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
