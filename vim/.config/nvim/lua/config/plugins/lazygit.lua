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

local map = function(keys, func)
  vim.keymap.set('n', keys, func, { silent = true, noremap = true })
end

-- LazyGit
vim.g.lazygit_use_custom_config_file_path = 1
vim.g.lazygit_config_file_path = {
  vim.env.HOME .. '/.config/lazygit/config.yml',
  vim.env.HOME .. '/.config/lazygit/config.nvim.yml',
}
vim.g.lazygit_floating_window_scaling_factor = 1

map('<leader>lg', ':LazyGit<cr>')
map('<leader>lgf', ':LazyGitCurrentFile<cr>')
