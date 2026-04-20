local M = {}

---@param tbl table
---@return string[]
function M.get_keys(tbl)
  local keys = {}
  for key, _ in pairs(tbl) do
    table.insert(keys, key)
  end
  return keys
end

---@param tbl any[]
---@param element any
---@return boolean
function M.included_in_table(tbl, element)
  for _, item in ipairs(tbl) do
    if item == element then
      return true
    end
  end
  return false
end

--- Ensures a value is a table.
---
--- If given a table it will be returned unmodified.
--- If given a non-table it will be wrapped in a table
---@param value any
---@return any[]
function M.into_table(value)
  if type(value) == "table" then
    return value
  end
  return { value }
end

---@param hunk number[] A hunk descriptor {start_line, count}
---@return fun(): number? Iterator over line numbers in the hunk
function M.hunk_lines(hunk)
  local line = hunk[1] - 1
  return function()
    line = line + 1
    if line < hunk[1] + hunk[2] then
      return line
    end
  end
end

---@param change table The change object containing hunks and selected_lines
---@param hunk table The hunk to check
---@return boolean
function M.all_lines_selected_in_hunk(change, hunk)
  for i in M.hunk_lines(hunk.left) do
    if not change.selected_lines.left[i] then
      return false
    end
  end

  for i in M.hunk_lines(hunk.right) do
    if not change.selected_lines.right[i] then
      return false
    end
  end

  return true
end

---@param change table The change object containing hunks and selected_lines
---@return boolean
function M.all_lines_selected(change)
  for _, hunk in ipairs(change.hunks) do
    if not M.all_lines_selected_in_hunk(change, hunk) then
      return false
    end
  end

  return true
end

---@param change table The change object containing hunks and selected_lines
---@param hunk table The hunk to check
---@return boolean
function M.any_lines_selected_in_hunk(change, hunk)
  for i in M.hunk_lines(hunk.left) do
    if change.selected_lines.left[i] then
      return true
    end
  end

  for i in M.hunk_lines(hunk.right) do
    if change.selected_lines.right[i] then
      return true
    end
  end

  return false
end

---@param change table The change object containing hunks and selected_lines
---@return boolean
function M.any_lines_selected(change)
  for _, hunk in ipairs(change.hunks) do
    if M.any_lines_selected_in_hunk(change, hunk) then
      return true
    end
  end

  return false
end

return M
