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

-- 4. Load plugins with lazy.nvim
require("lazy").setup({
  -- Telescope: Fuzzy finder for files, grep, buffers, and more
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
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
})
