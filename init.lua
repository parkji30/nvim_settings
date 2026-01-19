-- 1. Bootstrap lazy.nvim (the plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. Set leader key (do this BEFORE loading plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 3. Basic Neovim settings
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.ignorecase = true      -- Case insensitive search
vim.opt.smartcase = true       -- Unless uppercase is used
vim.opt.termguicolors = true   -- True color support
vim.opt.signcolumn = "yes"     -- Always show sign column
vim.opt.updatetime = 250       -- Faster completion
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- Indentation
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.shiftwidth = 4         -- Indent by 4 spaces
vim.opt.tabstop = 4            -- Tab = 4 spaces
vim.opt.smartindent = true     -- Auto-indent new lines

-- Better experience
vim.opt.scrolloff = 8          -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8      -- Keep 8 columns left/right of cursor
vim.opt.wrap = false           -- Don't wrap lines
vim.opt.cursorline = true      -- Highlight current line
vim.opt.undofile = true        -- Persistent undo (survives closing)
vim.opt.mouse = "a"            -- Enable mouse in all modes
vim.opt.showmode = false       -- Hide mode (lualine shows it)
vim.opt.inccommand = "split"   -- Live preview for :s/find/replace
vim.opt.splitright = true      -- Vertical splits open right
vim.opt.splitbelow = true      -- Horizontal splits open below
vim.opt.timeoutlen = 300       -- Faster which-key popup

-- 4. Load plugins with lazy.nvim
require("lazy").setup({
  -- Telescope: Fuzzy finder for files, grep, buffers, and more
  {
    "nvim-telescope/telescope.nvim",
    -- Using main branch for Neovim 0.11+ compatibility
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Optional but recommended: native fzf for better performance
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          -- Default configuration
          file_ignore_patterns = { "node_modules", ".git/" },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,  -- Show hidden files
          },
        },
      })

      -- Load fzf extension for better performance (if available)
      pcall(telescope.load_extension, "fzf")

      -- Keymaps for Telescope
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep (search text)" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
      vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Commands" })
      vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search in buffer" })

      -- Quick access shortcuts
      vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files (Ctrl+P)" })
    end,
  },

  -- File explorer sidebar
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 35 },
        filters = { dotfiles = false },
      })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    end,
  },

  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight" },
      })
    end,
  },

  -- Which-key: Shows available keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },

  -- LSP Configuration
  "neovim/nvim-lspconfig",

  -- Autocompletion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",

  -- Signature help (shows function params as you type)
  "ray-x/lsp_signature.nvim",

  -- Treesitter: Installs parsers (highlighting is built-in on Neovim 0.11+)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "python", "lua", "bash", "json", "yaml", "markdown" },
        auto_install = true,
      })
    end,
  },

  -- Claude Code integration
  {
    "coder/claudecode.nvim",
    config = function()
      require("claudecode").setup({
        terminal = {
          split_side = "right",
          split_width_percentage = 0.4,
        },
      })

      vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude Code' })
      vim.keymap.set('n', '<leader>cs', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send to Claude' })
      vim.keymap.set('v', '<leader>cs', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send selection to Claude' })
    end,
  },

  -- Git conflict resolution
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = function()
      require("git-conflict").setup({
        default_mappings = true,
        disable_diagnostics = false,
        highlights = {
          incoming = "DiffAdd",
          current = "DiffText",
        },
      })
    end,
  },
})

-- 5. Helper to find local .venv python (works with uv, poetry, etc.)
local function get_python_path()
  local cwd = vim.fn.getcwd()
  local venv_path = cwd .. '/.venv/bin/python'
  if vim.fn.executable(venv_path) == 1 then
    return venv_path
  end
  venv_path = cwd .. '/venv/bin/python'
  if vim.fn.executable(venv_path) == 1 then
    return venv_path
  end
  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

-- 6. Diagnostic Configuration
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
  update_in_insert = true,
  severity_sort = true,
  float = { border = "rounded", source = "always" },
})

-- 7. Python LSP Configuration (Pyright + Ruff)
vim.lsp.config.pyright = {
  settings = {
    python = {
      pythonPath = get_python_path(),
      analysis = {
        typeCheckingMode = "standard",
        diagnosticSeverityOverrides = {
          reportUnknownMemberType = "none",
          reportUnknownArgumentType = "none",
          reportUnknownVariableType = "none",
          reportUnknownParameterType = "none",
          reportUnknownLambdaType = "none",
          reportMissingTypeStubs = "none",
        },
      },
    },
    pyright = {
      disableOrganizeImports = true,
    },
  },
}

vim.lsp.config.ruff = {}
vim.lsp.enable({ 'pyright', 'ruff' })

-- 8. Autocompletion Setup
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
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
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

-- 9. LSP Keybindings (on attach)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }

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

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', 'rf', function()
      vim.lsp.buf.format({
        async = false,
        filter = function(client)
          return client.name == "ruff"
        end,
      })
      vim.notify("Ruff format applied", vim.log.levels.INFO)
    end, opts)
  end,
})

-- Diagnostic navigation
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })

-- Format Python on save
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

-- 10. Quick Python Runner
vim.keymap.set('n', '<leader>r', function()
  vim.cmd('write')
  local python = get_python_path()
  vim.cmd('split | terminal ' .. python .. ' %')
end, { desc = 'Run Python file' })

vim.keymap.set('n', '<leader>R', function()
  vim.cmd('write')
  local python = get_python_path()
  vim.cmd('vsplit | terminal ' .. python .. ' %')
end, { desc = 'Run Python file (vertical)' })

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
