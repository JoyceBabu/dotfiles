local lsp = require('lsp-zero')
local fidget = require("fidget")

lsp.preset("recommended")

lsp.ensure_installed({
  'bashls',
  'cssls',
  'eslint',
  'html',
  'jsonls',
  'sumneko_lua',
  'tsserver',
  'yamlls',
  'phpactor',
  -- 'rust_analyzer',
})

-- Fix Undefined global 'vim'
lsp.configure('sumneko_lua', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})

fidget.setup()

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

-- disable completion with tab
-- this helps with copilot setup
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings,
  -- sources = {
  --   { name = 'path' },
  --   { name = 'vim_lsp', keyword_length = 3 },
  --   { name = 'buffer', keyword_length = 3 },
  -- }
})

lsp.set_preferences({
    suggest_lsp_servers = true,
    sign_icons = {
        -- error = " ",
        -- warn = " ",
        -- hint = " ",
        -- info = " "
    }
})

lsp.on_attach(function(client, bufnr)
  if client.name == "eslint" then
      vim.cmd.LspStop('eslint')
      return
  end

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, remap = false, desc = desc })
  end

  nmap("gd", vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  -- nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap("<leader>ws", vim.lsp.buf.workspace_symbol, '[W]orkspace [S]ymbols')
  nmap("K", vim.lsp.buf.hover, 'Hover Documentation')
  -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

  -- Diagnostic keymaps
  nmap("[d", vim.diagnostic.goto_next, 'Prev [d]iagnostic message')
  nmap("]d", vim.diagnostic.goto_prev, 'Next [d]iagnostic message')
  nmap('<leader>e', vim.diagnostic.open_float, 'Show [E]rrors')
  nmap('<leader>q', vim.diagnostic.setloclist, '[Q]uickfix')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end)

lsp.setup()

local null_ls = require('null-ls')
local null_opts = lsp.build_options('null-ls', {})
local mason_null_ls = require("mason-null-ls")
local diagnostics = null_ls.builtins.diagnostics;

null_ls.setup({
  on_attach = null_opts.on_attach,
  debug = true,
  sources = {
    -- diagnostics.psalm,
    diagnostics.phpstan,
    -- diagnostics.phpcsfixer,
  }
})

mason_null_ls.setup({
  ensure_installed = nil,
  automatic_installation = true,
  automatic_setup = true,
})
mason_null_ls.setup_handlers({})

vim.diagnostic.config({
    virtual_text = true, -- Set this to false to disable inline diagnostic message
    -- signs = true,
    -- update_in_insert = false,
    -- underline = true,
    -- severity_sort = true,
    -- float = true,
})
