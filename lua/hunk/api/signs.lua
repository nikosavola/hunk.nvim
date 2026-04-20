local config = require("hunk.config")

local M = {
  signs = {
    selected = {
      name = "HunkLineSelected",
      hl = "HunkSignSelected",
    },
    deselected = {
      name = "HunkLineDeselected",
      hl = "HunkSignDeselected",
    },
    partially_selected = {
      name = "HunkLinePartiallySelected",
      hl = "HunkSignPartiallySelected",
    },
  },
}

--- Clear all hunk signs from a buffer.
---@param buf number Buffer handle
function M.clear_signs(buf)
  vim.fn.sign_unplace("Hunk", {
    buffer = buf,
  })
end

--- Place a sign at a specific line in a buffer.
---@param buf number Buffer handle
---@param sign table Sign descriptor with .name field
---@param linenr number Line number (1-indexed)
function M.place_sign(buf, sign, linenr)
  vim.fn.sign_place(0, "Hunk", sign.name, buf, {
    lnum = linenr,
    priority = 100,
  })
end

--- Define the sign symbols used by hunk.nvim.
function M.define_signs()
  vim.fn.sign_define({
    {
      name = M.signs.selected.name,
      text = config.icons.selected,
      texthl = M.signs.selected.hl,
    },
    {
      name = M.signs.deselected.name,
      text = config.icons.deselected,
      texthl = M.signs.deselected.hl,
    },
    {
      name = M.signs.partially_selected.name,
      text = config.icons.partially_selected,
      texthl = M.signs.partially_selected.hl,
    },
  })
end

return M
