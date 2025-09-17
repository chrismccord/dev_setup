-- ~/.config/nvim/init.lua 
-- NEOVIM CONFIGURATION
--
-- new machine setup:
-- 
-- 1. Create the config directory:
--    mkdir -p ~/.config/nvim
--
-- 2. Save this file as ~/.config/nvim/init.lua:
--    nvim ~/.config/nvim/init.lua
--
-- 3. Install required system packages:
--    sudo apt install xclip        # For clipboard support
--    sudo apt install ripgrep fd-find  # For better file finding (optional)
--
-- 4. Open Neovim and plugins will auto-install:
--    nvim
--    (Wait for the lazy.nvim popup to finish installing plugins)
--
-- 5. Restart Neovim and you're ready to go!
--
-- KEY MAPPINGS:
-- ,t         - Fuzzy find symbols in current file
-- ,p         - Fuzzy find files in project
-- gh/gl/gk/gj - Navigate between splits (left/right/up/down)
-- Ctrl-j/k   - Jump 5 lines down/up (or navigate in fuzzy finder)
-- cc         - Clear line and enter insert mode at indent
-- gcc        - Comment/uncomment current line
-- gc         - Comment/uncomment selection (visual mode)
-- Esc        - Exit fuzzy finder
-- gd         - Go to definition
-- gr         - Find references
-- K          - Show hover documentation
-- ,e         - Show diagnostics
-- ,rn        - Rename symbol

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key (must be before lazy setup)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Plugin setup
require("lazy").setup({
{
  'mg979/vim-visual-multi',
  branch = 'master',
  init = function()
    vim.g.VM_maps = {
      ['Find Under'] = '<C-n>',
      ['Find Subword Under'] = '<C-n>',
    }
  end
},
  -- File tree sidebar
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = false,
        window = {
          position = "left",
          width = 30,
          mappings = {
            ["<space>"] = "none",
            ["<cr>"] = "open",
            ["o"] = "open",
            ["s"] = "open_split",
            ["v"] = "open_vsplit",
            ["C"] = "close_node",
            ["z"] = "close_all_nodes",
            ["Z"] = "expand_all_nodes",
            ["R"] = "refresh",
            ["a"] = "add",
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy",
            ["m"] = "move",
            ["q"] = "close_window",
          }
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = {
            enabled = true,
          },
        },
      })
      
      -- Keymap to toggle file tree
      vim.keymap.set('n', '<leader>n', ':Neotree toggle<CR>', { desc = 'Toggle file tree' })
      vim.keymap.set('n', '<leader>N', ':Neotree reveal<CR>', { desc = 'Reveal current file in tree' })
    end
  },
  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          -- Use ctrl-j/k for navigation in telescope
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<Esc>"] = "close",
            },
          },
          -- Enable cache for maintaining search state
          cache_picker = {
            num_pickers = 20,
            limit_entries = 1000,
          },
        },
        -- ADD THIS EXTENSIONS SECTION:
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              -- You can add more options here if needed
            })
          }
        }
      })
      -- ADD THIS LINE TO LOAD THE EXTENSION:
      require("telescope").load_extension("ui-select")
    end
  },

  {
    'nvim-telescope/telescope-ui-select.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    -- No config needed here since we configured it in the main telescope setup
  },
  -- Better syntax highlighting and symbol navigation
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        -- Common languages - auto-install when opening files
        ensure_installed = { 
          "lua", "vim", "vimdoc", "query", "regex", "markdown", "markdown_inline",
          "javascript", "typescript", "tsx", "json", "html", "css", "scss",
          "python", "rust", "go", "c", "cpp", "java", "kotlin",
          "bash", "dockerfile", "yaml", "toml", "sql",
          "ruby", "php", "elixir", "erlang",
          "graphql", "prisma", "terraform", "hcl"
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },
  
  -- Mason for LSP management
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end
  },
  -- LSP Configuration (simplified without mason-lspconfig)
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/nvim-cmp',         -- Autocompletion
      'hrsh7th/cmp-nvim-lsp',     -- LSP completion source
      'L3MON4D3/LuaSnip',          -- Snippet engine
    },
    config = function()
      -- Setup autocompletion
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
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })
      
      -- Setup LSP servers
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- Function to setup common on_attach
      local on_attach = function(client, bufnr)
        -- LSP Keybindings (removed the omnifunc line that was causing the error)
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
        
        -- Notify that LSP attached
        vim.notify("LSP attached: " .. client.name, vim.log.levels.INFO)
      end
      
      -- Add Mason bin to PATH
      vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
      
      -- Setup servers - simplified approach
      local servers = {
        'ts_ls', 'pyright', 'lua_ls', 'rust_analyzer', 'gopls'
      }
      
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
          on_attach = on_attach,
        })
      end
      
      -- Special configs
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      })
      
      -- Elixir LSP with explicit command path
      lspconfig.elixirls.setup({
        cmd = { vim.fn.stdpath("data") .. "/mason/bin/elixir-ls" },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          elixirLS = {
            dialyzerEnabled = false,
            fetchDeps = false,
            suggestSpecs = false,
            mixEnv = "dev",
          }
        }
      })
    end
  },
  -- GitHub dark theme
  {
    'projekt0n/github-nvim-theme',
    config = function()
      require('github-theme').setup({})
      vim.cmd('colorscheme github_dark_dimmed')
    end
  },
  
  -- Comment plugin
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  },
  
  -- Show LSP progress
  {
    'j-hui/fidget.nvim',
    opts = {},
  },
  
  -- Better UI for diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
})

-- Basic settings
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = false -- No relative line numbers
vim.opt.clipboard = "unnamedplus" -- Use system clipboard for yank/delete
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.shiftwidth = 2        -- Size of indent
vim.opt.tabstop = 2           -- Size of tab
vim.opt.smartindent = true    -- Smart autoindenting

-- Fuzzy finder keymaps
vim.keymap.set('n', '<leader>t', ':Telescope treesitter<CR>', { desc = 'Find symbols in current file' })
vim.keymap.set('n', '<leader>p', ':Telescope find_files<CR>', { desc = 'Find files in project' })
-- Complete VSCode-like palette experience
vim.keymap.set('n', '<leader><leader>', ':Telescope commands<CR>', { desc = 'Command palette' })
vim.keymap.set('n', '<leader>:', ':Telescope command_history<CR>', { desc = 'Command history' })
vim.keymap.set('n', '<leader><leader>', ':Telescope<CR>', { desc = 'Telescope main menu' })
vim.keymap.set('n', '<leader>c', ':Telescope commands<CR>', { desc = 'Commands' })
vim.keymap.set('n', '<leader>h', ':Telescope help_tags<CR>', { desc = 'Help' })
vim.keymap.set('n', '<leader>k', ':Telescope keymaps<CR>', { desc = 'Keymaps' })
vim.keymap.set('n', '<leader>f', ':Telescope find_files<CR>', { desc = 'Find files' })
-- Live grep with dedicated cache (ONLY resumes live_grep)
local live_grep_cache = { default_text = "" }

local function live_grep_with_cache(visual_selection)
  local telescope = require('telescope.builtin')
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  -- Use visual selection if provided, otherwise use cached text
  local search_text = visual_selection or live_grep_cache.default_text
  
  telescope.live_grep({
    default_text = search_text,
    attach_mappings = function(prompt_bufnr, map)
      -- Override the close action to save state
      map('i', '<Esc>', function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        live_grep_cache.default_text = picker:_get_prompt()
        actions.close(prompt_bufnr)
      end)
      
      -- Override enter to save state before selecting
      map('i', '<CR>', function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        live_grep_cache.default_text = picker:_get_prompt()
        actions.select_default(prompt_bufnr)
      end)
      
      return true
    end,
  })
end

-- Normal mode: resume previous search
vim.keymap.set('n', '<leader>g', function()
  live_grep_with_cache()
end, { desc = 'Live grep (persistent cache)' })

-- Visual mode: search selected text
vim.keymap.set('v', '<leader>g', function()
  -- Get the selected text
  vim.cmd('noau normal! "vy"')
  local selected_text = vim.fn.getreg('v')
  -- Escape special regex characters
  selected_text = vim.fn.escape(selected_text, [[\/]])
  live_grep_with_cache(selected_text)
end, { desc = 'Live grep selected text' })
vim.keymap.set('n', '<leader>b', ':Telescope buffers<CR>', { desc = 'Buffers' })
vim.keymap.set('n', '<leader>r', ':Telescope oldfiles<CR>', { desc = 'Recent files' })
vim.keymap.set('n', '<leader>s', ':Telescope lsp_document_symbols<CR>', { desc = 'Document symbols' })
vim.keymap.set('n', '<leader>d', ':Telescope diagnostics<CR>', { desc = 'Diagnostics' })
-- Or create a custom "context menu" for the symbol under cursor
vim.keymap.set('n', 'gm', function()
  -- Show all available LSP actions for current position
  vim.ui.select({
    'Go to Definition',
    'Go to Type Definition', 
    'Go to Implementation',
    'Find References',
    'Show Hover',
    'Rename',
    'Code Actions',
  }, {
    prompt = 'Select action:',
  }, function(choice)
    if choice == 'Go to Definition' then
      vim.lsp.buf.definition()
    elseif choice == 'Go to Type Definition' then
      vim.lsp.buf.type_definition()
    elseif choice == 'Go to Implementation' then
      vim.lsp.buf.implementation()
    elseif choice == 'Find References' then
      vim.lsp.buf.references()
    elseif choice == 'Show Hover' then
      vim.lsp.buf.hover()
    elseif choice == 'Rename' then
      vim.lsp.buf.rename()
    elseif choice == 'Code Actions' then
      vim.lsp.buf.code_action()
    end
  end)
end, { desc = 'Symbol menu' })

-- Navigation between splits using g + hjkl
vim.keymap.set('n', 'gh', '<C-w>h', { desc = 'Go to left split' })
vim.keymap.set('n', 'gl', '<C-w>l', { desc = 'Go to right split' })
vim.keymap.set('n', 'gj', '<C-w>j', { desc = 'Go to split below' })
vim.keymap.set('n', 'gk', '<C-w>k', { desc = 'Go to split above' })

-- Jump 5 lines with Ctrl-j/k in normal mode
vim.keymap.set('n', '<C-j>', '5j', { desc = 'Jump 5 lines down' })
vim.keymap.set('n', '<C-k>', '5k', { desc = 'Jump 5 lines up' })

-- cc to clear line and enter insert mode at indent
vim.keymap.set('n', 'cc', 'S', { desc = 'Clear line and insert at indent' })

-- Smart buffer close function
local function close_buffer()
  local buffers = vim.fn.getbufinfo({buflisted = 1})
  if #buffers > 1 then
    vim.cmd('bd')
  else
    -- If only one buffer, create a new empty buffer first
    vim.cmd('enew')
    vim.cmd('bd #')
  end
end

-- Add keymap for closing buffers
vim.keymap.set('n', '<leader>w', close_buffer, { desc = 'Close current buffer' })

-- Additional useful settings
vim.opt.ignorecase = true     -- Case insensitive search
vim.opt.smartcase = true      -- Unless uppercase is used
vim.opt.termguicolors = true  -- True color support
vim.opt.cursorline = true     -- Highlight current line
vim.opt.signcolumn = "yes"    -- Always show sign column
vim.opt.scrolloff = 8         -- Keep 8 lines visible when scrolling
vim.opt.updatetime = 250      -- Faster completion
vim.opt.completeopt = 'menu,menuone,noselect' -- Better completion experience
vim.opt.autoread = true       -- reload files from disk when they change

-- Auto-refresh files when they change on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})

-- Notify when file changes
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

-- status line
vim.opt.statusline = " %f %h%m%r%=%-14.(%l,%c%V%) %P"
vim.cmd([[
  hi StatusLine guibg=#2d333b guifg=#768390 gui=NONE cterm=NONE
  hi StatusLineNC guibg=#22272e guifg=#545d68 gui=NONE cterm=NONE
]])
-- Diagnostic signs
local signs = { Error = "✘", Warn = "▲", Hint = "⚡", Info = "ℹ" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
