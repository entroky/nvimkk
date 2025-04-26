return {
	"phijor/forester.nvim",
    	branch = "completion-enhancements",
	requires = {
		{ "nvim-telescope/telescope.nvim" },
		{ "nvim-treesitter/nvim-treesitter" },
		{ "nvim-lua/plenary.nvim" },
		{
			"echasnovski/mini.pairs",
			config = function()
				require("mini.pairs").setup()
			end,
			version = "*",
		},
	},
	-- -- maybe could be even lazier with these, but not working, because `forester` filetype is not registered yet
	-- ft = "tree",
	-- ft = "forester",
	"nvim-treesitter/nvim-treesitter",
	config = function()
	local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            parser_config.forester = {
                install_info = {
                    url = "~/tree-sitter-forester",
                    files = { "src/parser.c" },
                    branch = "main",
                    generate_requires_npm = false,
                    requires_generate_from_grammar = false,
                },
                filetype = "tree",
            }

            require("nvim-treesitter.configs").setup({
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },

                ensure_installed = { "forester" },
            })
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.tree", -- Change this to match your desired file type or file pattern
			callback = function()
				if vim.bo.filetype == "forester" then -- Change "markdown" to your target filetype
					local save_cursor = vim.api.nvim_win_get_cursor(0) -- Save cursor position

					-- Get the whole buffer content
					local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
					local text = table.concat(lines, "\n")

					-- Perform substitutions:
					-- Single-line replacements (if contained on one line)
					text = text:gsub("%$%$(.-)%$%$", "##{ %1 }") -- $$ x $$ -> ##{ x }
					text = text:gsub("%$(.-)%$", "#{ %1 }") -- $ x $ -> #{ x }

					-- Multi-line replacements (if spanning multiple lines)
					text = text:gsub("%$%$\n(.-)\n%$%$", "##{\n%1\n}") -- $$ x (newline) $$ -> ##{ x }
					text = text:gsub("%$\n(.-)\n%$", "#{\n%1\n}") -- $ x (newline) $ -> #{ x }

					-- Update buffer content
					vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(text, "\n"))

					-- Restore cursor position
					vim.api.nvim_win_set_cursor(0, save_cursor)
				end
			end,
		})
	end,
	keys = {
		{ "<localleader>n", "<cmd>Forester new<cr>", desc = "Forester - New" },
		{ "<localleader>b", "<cmd>Forester browse<cr>", desc = "Forester - Browse" },
		{ "<localleader>l", "<cmd>Forester link_new<cr>", desc = "Forester - Link New" },
		{ "<C-t>", "<cmd>Forester transclude_new<cr>", desc = "Forester - Transclude New" },
		{
			"<localleader>d",
			"<cmd>Forester transclude_template def<cr>",
			desc = "Forester - Transclude New Definition",
		},
		{ "<localleader>l", "<cmd>Forester transclude_template lemma<cr>", desc = "Forester - Transclude New Lemma" },
		{ "<localleader>t", "<cmd>Forester transclude_template thm<cr>", desc = "Forester - Transclude New Theorem" },
		{
			"<localleader>p",
			"<cmd>Forester transclude_template prop<cr>",
			desc = "Forester - Transclude New Proposition",
		},
		{
			"<localleader>T",
			"<cmd>Forester transclude_template_search<cr>",
			desc = "Forester - Transclude template new",
		},
	},
}
