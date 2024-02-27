-- Set mpace as leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local lazy = require('lazy')

lazy.setup({
    -- Plugins
    'tpope/vim-fugitive',
    'mfussenegger/nvim-dap',
    {
        'ojroques/nvim-osc52',
        config = function()
            require('osc52').setup {
                max_length = 0,           -- Maximum length of selection (0 for no limit)
                silent = false,           -- Disable message on successful copy
                trim = false,             -- Trim surrounding whitespaces before copy
                tmux_passthrough = true, -- Use tmux passthrough (requires tmux: set -g allow-passthrough on)
            }
        end
    },
    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', opts = {} },

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim',
        },
    },
    {'preservim/nerdtree', cmd = 'NERDTreeToggle'},
    {'kyazdani42/nvim-web-devicons', opt = true},
    -- Detect tabstop and shiftwidth automatically
    {'tpope/vim-sleuth'},
    {
        'navarasu/onedark.nvim',
        lazy = false,
        priority = 1000,
        opts = {},
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons'
        },
        config = function()
            require('lualine').setup()
        end,
    },
    {'fatih/vim-go', ft = 'go'},
    {'nvim-lua/plenary.nvim', opt = true},
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        requires = {'nvim-lua/plenary.nvim'},
        cmd = 'Telescope'
    },
    {
        'nvim-treesitter/nvim-treesitter-context',
        config = function()
            require'treesitter-context'.setup{
                enable = true,  -- Enable this plugin (Can be enabled/disabled later via commands)
                throttle = true, -- Throttles plugin updates (which may improve performance)
            }
        end
    },
    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        build = ':TSUpdate',
    },
    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets',
        },
        config = function()
            require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
        end
    },
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        requires = {'nvim-lua/plenary.nvim'}
    },
    {
        'numToStr/Comment.nvim',
        opts = {
            -- add any options here
        },
        lazy = false,
    }
    -- Add other plugins here
})

-- Basic settings
-- vim.o.nocompatible = true
vim.cmd('filetype off')
vim.cmd('syntax on')
vim.o.history = 1000
vim.o.t_Co = 256
vim.o.mouse = 'a'
vim.wo.number = true
vim.wo.relativenumber = true
-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.autoread = true

-- Colorscheme
require('onedark').setup {
    style = 'cool'
}
require('onedark').load()

vim.keymap.set('n', '<C-e>', ':NERDTreeToggle<CR>', {})
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<cr>', {noremap = true})
vim.keymap.set('n', '<leader>fs', ':Telescope grep_string<cr>', {noremap = true})
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<cr>', {noremap = true})
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<cr>', {noremap = true})
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<cr>', {noremap = true})
vim.keymap.set('n', '<C-d>', '<C-d>zz', {noremap = true})
vim.keymap.set('n', '<C-u>', '<C-u>zz', {noremap = true})
vim.keymap.set('x', '<leader>p', "\"_dP", {noremap = true})

-- some terminal remaps
vim.keymap.set('n', '<leader>T', ':term<cr>', {noremap = true})
vim.keymap.set('n', '<leader>t', function()
  local term_bufs = {}

  -- Build the "hashmap" 
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
    if buftype == 'terminal' then
      term_bufs[buf] = true
    end
  end

  local cur_buf = vim.api.nvim_get_current_buf()

  if term_bufs[cur_buf] == nil or next(term_bufs, cur_buf) == nil then
      local next_buf = next(term_bufs, nil)
      if next_buf then
          -- Cycle to next terminal
          vim.api.nvim_set_current_buf(next_buf)
          return
      else
          -- No terminals yet
          vim.cmd('term')
          return
      end
  end

  -- Otherwise cycle to next terminal
  local next_term = next(term_bufs, cur_buf)
  vim.api.nvim_set_current_buf(next_term)

end, { noremap = true, silent = true })

vim.keymap.set('t', '<esc>', '<c-\\><c-n>', {noremap = true})
vim.keymap.set('t', '<c-w>h', '<c-\\><c-n><c-w>h', {noremap = true})
vim.keymap.set('t', '<c-w>j', '<c-\\><c-n><c-w>j', {noremap = true})
vim.keymap.set('t', '<c-w>k', '<c-\\><c-n><c-w>k', {noremap = true})
vim.keymap.set('t', '<c-w>l', '<c-\\><c-n><c-w>l', {noremap = true})
vim.keymap.set('t', '<c-w><c-w>', '<c-\\><c-n><c-w><c-w>', {noremap = true})

-- for copying
vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr = true})
vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
vim.keymap.set('v', '<leader>c', require('osc52').copy_visual)

local dap = require("dap")
dap.configurations.go = {
  {
    type = 'go';
    name = 'Debug';
    request = 'launch';
    showLog = false;
    program = "${file}";
    dlvToolPath = vim.fn.exepath('dlv')  -- Adjust to where delve is installed
  },
}

-- Yes, we're just executing a bunch of Vimscript, but this is the officially
-- endorsed method; see https://github.com/L3MON4D3/LuaSnip#keymaps
vim.cmd[[
    " Use Tab to expand and jump through snippets
    imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
    smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'

    " Use Shift-Tab to jump backwards through snippets
    imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
    smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
]]

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
    clangd = {},
    gopls = {},
    golangci_lint_ls = {},
    ruff_lsp = {},
    pylsp = {
        pylsp = {
            plugins = {
                pycodestyle = { enabled = false },
                mccabe = { enabled = false },
                pyflakes = { enabled = false },
            }
        }
    },
    docker_compose_language_service = {},
    -- pyright = {},
    -- rust_analyzer = {},
    -- tsserver = {},
    -- html = { filetypes = { 'html', 'twig', 'hbs'} },

    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
        },
    },
}

local lspconfig = require 'lspconfig'
local configs = require 'lspconfig/configs'

if not configs.golangcilsp then
 	configs.golangcilsp = {
		default_config = {
			cmd = {'golangci-lint-langserver'},
			root_dir = lspconfig.util.root_pattern('.git', 'go.mod'),
			init_options = {
					command = { "golangci-lint", "run", "--out-format", "json", "--issues-exit-code=1" };
			}
		};
	}
end
lspconfig.golangci_lint_ls.setup {
	filetypes = {'go','gomod'}
}

lspconfig.clangd.setup {
    on_attach = function (client, bufnr)
        client.server_capabilities.signatureHelpProvider = false
        on_attach(client, bufnr)
    end,
    capabilities = configs.capabilities,
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
        }
    end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    completion = {
        completeopt = 'menu,menuone,noinsert',
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'path' },
    },
}

-- harpoon
local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
vim.keymap.set("n", "<C-s>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
