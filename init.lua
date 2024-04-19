vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.wo.number = true
-- Required for plugins

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

require("lazy").setup({
	{
		'neovim/nvim-lspconfig'
	}, -- gd lsp
	{
		'akinsho/bufferline.nvim',
		version = "*",
		dependencies = 'nvim-tree/nvim-web-devicons'
	}, -- tab list
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		}
	}, -- popup with keybinds
	{
		'stevearc/stickybuf.nvim',
		opts = {},
	}, -- stickybuf fixes opening stuff in the wrong buffer
	{
		'stevearc/aerial.nvim',
		opts = {},
		-- Optional dependencies
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons"
		},
	}, -- lets you browse all declared functions in a side pane
	{
		'nvim-tree/nvim-tree.lua',
	},
	{
		"lukas-reineke/indent-blankline.nvim", 
		main = "ibl", 
		opts = {}, 
	}, -- indent highlighting
	{
		'HiPhish/rainbow-delimiters.nvim',
	}, -- colors delimiters based on scope
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 
			'nvim-tree/nvim-web-devicons'
		},
	}, -- luwualine ;3
	{
		'mvllow/modes.nvim',
		tag = 'v0.2.0',
		config = function()
			require('modes').setup()
		end
	}, -- changes line color based on mode
	{
		'rcarriga/nvim-notify'
	}, -- currently does nothing TODO coc.nvim integration maybe
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		}
	}, -- TODO this builds on notify and is enough reason to keep it installed remember to configure and change comments
	{
		'akinsho/toggleterm.nvim',
		version = "*",
		config =  function()
--			local highlights = require('rose-pine.plugins.toggleterm')
--			require('toggleterm').setup({ highlights = highlights })
		end
	}, -- TODO toggleable terminals look into uwu :3
	{
		'sudormrfbin/cheatsheet.nvim',

		dependencies = {
			{'nvim-telescope/telescope.nvim'},
			{'nvim-lua/popup.nvim'},
			{'nvim-lua/plenary.nvim'},
		},
	},
	{
		'nvim-orgmode/orgmode',
		dependencies = {
			{ 'nvim-treesitter/nvim-treesitter', lazy = true },
		},
		event = 'VeryLazy',
		config = function()
			-- Load treesitter grammar for org
			require('orgmode').setup_ts_grammar()
			-- Setup treesitter
			require('nvim-treesitter.configs').setup({
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { 'org' },
				},
				ensure_installed = { 'org' },
			})
		end,
	},
	{
		'Bekaboo/dropbar.nvim',
		-- optional, but required for fuzzy finder support
		dependencies = {
			'nvim-telescope/telescope-fzf-native.nvim'
		}
	},
	{ 
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-vsnip",
			"hrsh7th/vim-vsnip",
		},
	},
})

local lspconfig = require('lspconfig')

lspconfig.bashls.setup{
	cmd = { "bash-language-server", "start" },
	filestypes = { 'sh' },
	--root_dir = util.find_git_ancestor,
	single_file_support = true,
	settings = {
		bashIde = {
			globPattern = "*@(.sh|.inc|.bash|.command)"
		}
	}
}

require'lspconfig'.lua_ls.setup{}

local cmp = require('cmp')

cmp.setup({
	snippet = {
	-- REQUIRED - you must specify a snippet engine
		expand = function(args)
        		vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        		vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' }, -- For vsnip users.
	}, {
		{ name = 'buffer' },
	})
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
	--	{ name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
	--}, {
		{ name = 'buffer' },
    	})
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	}),
	matching = { disallow_symbol_nonprefix_matching = false }
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig')['clangd'].setup {
	capabilities = capabilities
}

require('lspconfig')['pyright'].setup {
	capabilities = capabilities
}

require('lspconfig')['bashls'].setup {
	capabilities = capabilities
}

require('lspconfig')['lua_ls'].setup {
	capabilities = capabilities
}

vim.ui.select = require('dropbar.utils.menu').select
-- Dropbar thingie 

require("stickybuf").setup()

vim.opt.termguicolors = true -- needed for bufferline

local bufferline = require('bufferline')

bufferline.setup({
	options = {
		style_preset = bufferline.style_preset.default,
		tab_size = 18,
		max_name_length = 32,
		truncate_names = false,
		themable = false,
		numbers = "buffer_id",
		show_tab_indicators = true,
		indicator = {
			icon = '$',
			style = 'icon',
		},
		separator_style = "slant",
		offsets = {
                	{
                		filetype = "NvimTree",
                		text = "File Explorer",
                		text_align = "left",
                		separator = true,
                	},
			{
				filetype = "neo-tree",
				text = "File Explorer",
				text_align = "left",
				seperator = false,
			},
        	},
		diagnostics = "nvim_lsp",  --TODO check if working!
		-- TODO groups!
		-- TODO keybind mappings
	},
})

require("aerial").setup({
	backends = { "lsp", "treesitter", "markdown", "man" },
	layout = {
		max_width = {40, 0.2},
		width = nil,
		min_width = {10, 0.1},
	},
	resize_to_content = true,
	filter_kind = false,
	show_guides = true,
	nerd_font = "auto",
	-- optionally use on_attach to set keymaps when aerial has attached to a buffer
	on_attach = function(bufnr)
	-- Jump forwards/backwards with '{' and '}'
	vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
	vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
	end,
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")

require("nvim-tree").setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
	diagnostics = {
        	enable = true,
        	show_on_dirs = false,
        	show_on_open_dirs = true,
        	debounce_delay = 50,
        	severity = {
        		min = vim.diagnostic.severity.HINT,
        		max = vim.diagnostic.severity.ERROR,
        	},
        	icons = {
        		hint = "",
        		info = "",
        		warning = "",
        		error = "",
        	},
	},
	modified = {
        	enable = true,
        	show_on_dirs = true,
        	show_on_open_dirs = true,
	},
})

vim.keymap.set("n", "|", "<cmd>NvimTreeToggle<CR>")

require("ibl").setup{
	scope = { enabled = false },
}

require('lualine').setup {
	options = {
		icons_enabled = true,
		theme = 'catppuccin',
		component_separators = {
			left = '',
			right = ''
		},
		section_separators = {
			left = '',
			right = ''
		},
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {'NvimTree'},
		always_divide_middle = true,
		globalstatus = true,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		}
	},
	sections = {
		lualine_a = {'mode'},
		lualine_b = {'branch', 'diff', 'diagnostics'},
		lualine_c = {'filename'},
		lualine_x = {'encoding', 'fileformat', 'filetype'},
		lualine_y = {'progress'},
		lualine_z = {'location'}
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {'filename'},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
	--TODO configure!!
}

vim.notify = require("notify")

require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = false, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})

require("toggleterm").setup({
  -- size can be a number or function which is passed the current terminal
  function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = [[<c-\>]],
  --on_create = fun(t: Terminal), -- function to run when the terminal is first created
  --on_open = fun(t: Terminal), -- function to run when the terminal opens
  --on_close = fun(t: Terminal), -- function to run when the terminal closes
  --on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
  --on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
 -- on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
  hide_numbers = true, -- hide the number column in toggleterm buffers
  autochdir = false, -- when neovim changes it current directory the terminal will change it's own when next it's opened
  shade_terminals = true,
  insert_mappings = true, -- whether or not the open mapping applies in insert mode
  terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
  persist_size = true,
  persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
  direction = 'horizontal',
  close_on_exit = false, -- close the terminal window when the process exits
   -- Change the default shell. Can be a string or a function returning a string
  shell = vim.o.shell,
  auto_scroll = true, -- automatically scroll to the bottom on terminal output
	winbar = {
		enabled = false,
		name_formatter = function(term) --  term: Terminal
			return term.name
		end
	},
})

require('orgmode').setup({
	org_agenda_files = '~/orgfiles/**/*',
	org_default_notes_file = '~/orgfiles/refile.org',
	org_capture_templates = {
		n = {
			description = "Note",
			template = "*\tNOTE\t%^{title}\t:note:%^{tag}:\n#\t%<%A, the %d/%m/%Y %X>\n%^{content}\n\n%a %?",
			target = "~/notes/index.org",
		}
	},
})

-- Set colorscheme after options
vim.cmd('colorscheme catppuccin')

vim.opt.fillchars = { eob = ' ' }
--Hide EOB
