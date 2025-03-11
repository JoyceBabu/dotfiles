function EditLineFromLazygit(file_path, line)
  local path = vim.fn.expand("%:p")
  if path == file_path then
    vim.cmd(tostring(line))
  else
    vim.cmd("e " .. file_path)
    vim.cmd(tostring(line))
  end
end

function EditFromLazygit(file_path)
  local path = vim.fn.expand("%:p")
  if path == file_path then
    return
  else
    vim.cmd("e " .. file_path)
  end
end
