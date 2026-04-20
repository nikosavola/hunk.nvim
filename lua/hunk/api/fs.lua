local M = {}

local uv = vim.loop

--- Recursively scan a directory and return all files as a map.
---@param dir string Absolute path to directory
---@return table<string, table> files Map of relative path to file descriptor
function M.scan_dir(dir)
  dir = (dir:gsub("/+$", ""))
  local out = {}

  local function relative_path(full)
    return full:sub(#dir + 2)
  end

  local function walk(path)
    local fd = uv.fs_scandir(path)
    if not fd then
      return
    end

    while true do
      local name, ftype = uv.fs_scandir_next(fd)
      if not name then
        break
      end

      local full = path .. "/" .. name

      if ftype == "directory" then
        walk(full)
      elseif ftype == "file" then
        local file_path = relative_path(full)
        out[file_path] = { path = file_path }
      elseif ftype == "link" then
        local file_path = relative_path(full)
        out[file_path] = {
          path = file_path,
          symlink = uv.fs_readlink(full),
        }
      end
    end
  end

  walk(dir)

  return out
end

--- Read a file's full content as a string.
---@param file_path string Absolute path to file
---@return string? content File content, or nil if file cannot be opened
function M.read_file(file_path)
  local file = io.open(file_path, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  return content
end

--- Read a file as an array of lines.
---@param file_path string Absolute path to file
---@return string[] lines
function M.read_file_as_lines(file_path)
  local content = vim.split(M.read_file(file_path) or "", "\n")
  if content[#content] == "" then
    table.remove(content, #content)
  end
  return content
end

--- Create parent directories for the given file path.
---@param file_path string Absolute path to file
function M.make_parents(file_path)
  local parent_dir = file_path:match("(.*/)")
  vim.fn.mkdir(parent_dir, "p")
end

--- Move a file from src to dst.
---@param src string Source path
---@param dst string Destination path
function M.move_file(src, dst)
  M.make_parents(dst)
  vim.fn.system({ "mv", src, dst })
end

--- Remove a file.
---@param file string Path to file
function M.rm_file(file)
  vim.fn.system({ "rm", file })
end

--- Write an array of lines to a file.
---@param file_path string Absolute path to file
---@param content string[] Lines to write
function M.write_file(file_path, content)
  M.make_parents(file_path)

  local file = io.open(file_path, "w")
  if not file then
    return
  end

  for _, line in ipairs(content) do
    file:write(line .. "\n")
  end

  file:close()
end

return M
