-- Minimal UI settings for tmux popup note-taking
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.signcolumn = "no"
vim.diagnostic.enable(false, { bufnr = 0 })
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = "nc"
vim.opt_local.foldenable = false
vim.opt_local.spell = true
vim.opt_local.textwidth = 80

vim.schedule(function()
  local ok, lualine = pcall(require, 'lualine')
  if ok then
    lualine.hide()
  end
  vim.opt.laststatus = 0
end)
