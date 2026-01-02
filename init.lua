-- 1. Bootstrap lazy.nvim (the plugin manager)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end

vim.opt.rtp:prepend(lazypath)



-- 2. Plugin Setup

require("lazy").setup({
  "neovim/nvim-lspconfig", -- Provides LSP server configurations
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- Autocompletion
  "hrsh7th/nvim-cmp",         -- Completion engine
  "hrsh7th/cmp-nvim-lsp",     -- LSP source for nvim-cmp
  "hrsh7th/cmp-buffer",       -- Buffer words source
  "L3MON4D3/LuaSnip",         -- Snippet engine (required by cmp)
  "saadparwaiz1/cmp_luasnip", -- Snippet completions

  -- Signature help (shows function params as you type)
  "ray-x/lsp_signature.nvim",
})



-- 3. UI and General Settings

vim.cmd.colorscheme "catppuccin-mocha"

vim.opt.termguicolors = true -- Enable true color support
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 250 -- Snappier interface (for hover delays)



-- 4. Unified Diagnostic Configuration (Combined Block)

vim.diagnostic.config({
  underline = true,
  virtual_text = { spacing = 4, prefix = '●' },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN]  = "▲",
      [vim.diagnostic.severity.HINT]  = "⚑",
      [vim.diagnostic.severity.INFO]  = "»",
    },
  },
  update_in_insert = true, -- Keep underlines visible while typing
  severity_sort = true,
  float = { border = "rounded", source = "always" },
})



-- 5. Python LSP Configuration (Pyright + Ruff)

-- Helper to find the local .venv python (works with uv, poetry, etc.)
local function get_python_path()
  local cwd = vim.fn.getcwd()
  -- Check for .venv in current directory (uv, python -m venv)
  local venv_path = cwd .. '/.venv/bin/python'
  if vim.fn.executable(venv_path) == 1 then
    return venv_path
  end
  -- Check for venv in current directory
  venv_path = cwd .. '/venv/bin/python'
  if vim.fn.executable(venv_path) == 1 then
    return venv_path
  end
  -- Fallback to system python
  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

-- Pyright setup using new vim.lsp.config API (Neovim 0.11+)
vim.lsp.config.pyright = {
  settings = {
    python = {
      pythonPath = get_python_path(),
    },
    pyright = {
      disableOrganizeImports = true, -- Let Ruff handle imports
    },
    python = {
      analysis = {
        typeCheckingMode = "standard", -- Keep full type checking
        diagnosticSeverityOverrides = {
          -- Only suppress "Unknown" type errors (from untyped libraries)
          reportUnknownMemberType = "none",
          reportUnknownArgumentType = "none",
          reportUnknownVariableType = "none",
          reportUnknownParameterType = "none",
          reportUnknownLambdaType = "none",
          reportMissingTypeStubs = "none",
          -- Keep all other type errors visible!
        },
      },
    },
  },
}

-- Ruff setup (linting + formatting)
vim.lsp.config.ruff = {}

-- Enable the LSP servers
vim.lsp.enable({ 'pyright', 'ruff' })



-- 6. Autocompletion Setup

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    -- Tab to select next item or expand snippet
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),

    -- Shift-Tab to select previous item
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  }),
})



-- 7. Keybindings

-- LSP keybindings (set up on LSP attach)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }

    -- Setup lsp_signature for this buffer
    require('lsp_signature').on_attach({
      bind = true,
      handler_opts = { border = "rounded" },
      hint_enable = true,
      hint_prefix = "🔹 ",
      floating_window = true,
      floating_window_above_cur_line = true,
      hi_parameter = "LspSignatureActiveParameter",
      max_height = 12,
      max_width = 80,
      wrap = true,
      doc_lines = 10,
      toggle_key = '<C-s>',
      select_signature_key = '<C-n>',
    }, ev.buf)

    -- Go to definition
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

    -- Hover documentation
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

    -- Rename symbol
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

    -- Code actions
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

    -- Manual signature help trigger
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)

    -- Format with Ruff
    vim.keymap.set('n', 'rf', function()
      vim.lsp.buf.format({
        async = true,
        filter = function(client)
          return client.name == "ruff"
        end,
      })
    end, opts)
  end,
})

-- Diagnostic navigation (global, not buffer-specific)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })

-- Format Python files on save with Ruff
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.py',
  callback = function()
    vim.lsp.buf.format({
      async = false,
      filter = function(client)
        return client.name == "ruff"
      end,
    })
  end,
})



-- 8. Quick Python Runner (uses venv if available)

-- Press <leader>r to run current Python file in a horizontal split terminal
vim.keymap.set('n', '<leader>r', function()
  vim.cmd('write')  -- Save first
  local python = get_python_path()
  vim.cmd('split | terminal ' .. python .. ' %')
end, { desc = 'Run Python file' })

-- Press <leader>R to run in a vertical split instead
vim.keymap.set('n', '<leader>R', function()
  vim.cmd('write')
  local python = get_python_path()
  vim.cmd('vsplit | terminal ' .. python .. ' %')
end, { desc = 'Run Python file (vertical)' })

-- Quick escape from terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
