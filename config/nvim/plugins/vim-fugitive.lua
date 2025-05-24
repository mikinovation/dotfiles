local vimFugitive = {}

function vimFugitive.config()
	return {
		"tpope/vim-fugitive",
		commit = "4a745ea72fa93bb15dd077109afbb3d1809383f2",
		config = function()
			-- Basic Git operations
			vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Git [S]tatus" })
			vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git [C]ommit" })
			vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git [P]ush" })
			vim.keymap.set("n", "<leader>gpl", ":Git pull<CR>", { desc = "Git Pu[L]l" })
			vim.keymap.set("n", "<leader>gf", ":Git fetch --all<CR>", { desc = "Git [F]etch All" })
			vim.keymap.set("n", "<leader>gl", ":Git log<CR>", { desc = "Git [L]og" })
			vim.keymap.set("n", "<leader>glo", ":Git log --oneline<CR>", { desc = "Git [L]og [O]neline" })
			vim.keymap.set("n", "<leader>glg", ":Git log --graph<CR>", { desc = "Git [L]og [G]raph" })

			-- Blame operations
			vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Git [B]lame" })
			vim.keymap.set("n", "<leader>gbs", ":Git blame --show-stats<CR>", { desc = "Git [B]lame with [S]tats" })

			-- Diff operations
			vim.keymap.set("n", "<leader>gd", ":Gdiffsplit<CR>", { desc = "Git [D]iff Split" })
			vim.keymap.set("n", "<leader>gdh", ":Gdiffsplit HEAD<CR>", { desc = "Git [D]iff with [H]EAD" })
			vim.keymap.set("n", "<leader>gdt", ":Gdiffsplit --staged<CR>", { desc = "Git [D]iff S[T]aged" })

			-- Merge operations
			vim.keymap.set("n", "<leader>gm", ":Git mergetool<CR>", { desc = "Git [M]ergetool" })
			vim.keymap.set("n", "<leader>gmc", ":Git merge --continue<CR>", { desc = "Git [M]erge [C]ontinue" })
			vim.keymap.set("n", "<leader>gma", ":Git merge --abort<CR>", { desc = "Git [M]erge [A]bort" })

			-- Stash operations
			vim.keymap.set("n", "<leader>gss", ":Git stash<CR>", { desc = "Git [S]tash [S]ave" })
			vim.keymap.set("n", "<leader>gsp", ":Git stash pop<CR>", { desc = "Git [S]tash [P]op" })
			vim.keymap.set("n", "<leader>gsl", ":Git stash list<CR>", { desc = "Git [S]tash [L]ist" })
			vim.keymap.set("n", "<leader>gsa", ":Git stash apply<CR>", { desc = "Git [S]tash [A]pply" })

			-- Branch operations
			vim.keymap.set("n", "<leader>gbr", ":Git branch<CR>", { desc = "Git [BR]anch List" })
			vim.keymap.set("n", "<leader>gbl", ":Git branch -vv<CR>", { desc = "Git [B]ranch [L]ist Verbose" })
			vim.keymap.set("n", "<leader>gbn", ":Git checkout -b ", { desc = "Git [B]ranch [N]ew" })
			vim.keymap.set("n", "<leader>gbs", ":Git switch ", { desc = "Git [B]ranch [S]witch" })

			-- Rebase operations
			vim.keymap.set("n", "<leader>grb", ":Git rebase ", { desc = "Git [R]e[B]ase" })
			vim.keymap.set("n", "<leader>gri", ":Git rebase -i HEAD~", { desc = "Git [R]ebase [I]nteractive" })
			vim.keymap.set("n", "<leader>grc", ":Git rebase --continue<CR>", { desc = "Git [R]ebase [C]ontinue" })
			vim.keymap.set("n", "<leader>gra", ":Git rebase --abort<CR>", { desc = "Git [R]ebase [A]bort" })

			-- Reset operations
			vim.keymap.set("n", "<leader>grs", ":Git reset<CR>", { desc = "Git [R]e[S]et" })
			vim.keymap.set("n", "<leader>grh", ":Git reset --hard<CR>", { desc = "Git [R]eset [H]ard" })
			vim.keymap.set("n", "<leader>grhh", ":Git reset --hard HEAD~", { desc = "Git [R]eset [H]ard HEAD~" })

			-- File operations
			vim.keymap.set("n", "<leader>ga", ":Git add %<CR>", { desc = "Git [A]dd Current File" })
			vim.keymap.set("n", "<leader>gaa", ":Git add .<CR>", { desc = "Git [A]dd [A]ll" })
			vim.keymap.set("n", "<leader>grm", ":Git rm %<CR>", { desc = "Git [R]e[M]ove Current File" })

			-- Conflict resolution
			vim.keymap.set("n", "<leader>gco", ":Git checkout --ours %<CR>", { desc = "Git [C]heckout [O]urs" })
			vim.keymap.set("n", "<leader>gct", ":Git checkout --theirs %<CR>", { desc = "Git [C]heckout [T]heirs" })

			-- GitHub integration (requires fugitive + rhubarb)
			vim.keymap.set("n", "<leader>gbw", ":GBrowse<CR>", { desc = "Git [B]ro[W]se on GitHub" })
			vim.keymap.set("v", "<leader>gbw", ":GBrowse<CR>", { desc = "Git [B]ro[W]se Selection on GitHub" })

			-- PR preparation (push to remote and setup tracking)
			vim.keymap.set("n", "<leader>gpr", ":Git push -u origin HEAD<CR>", { desc = "Git Push and setup for [PR]" })

			-- File history viewing
			vim.keymap.set("n", "<leader>gfh", ":0Gclog<CR>", { desc = "Git [F]ile [H]istory" })

			-- Git grep for project-wide searching
			vim.keymap.set("n", "<leader>gg", ":Git grep ", { desc = "Git [G]rep" })

			-- Selective staging/unstaging with patch mode
			vim.keymap.set("n", "<leader>gap", ":Git add -p<CR>", { desc = "Git [A]dd [P]atch" })
			vim.keymap.set("n", "<leader>grsp", ":Git reset -p<CR>", { desc = "Git [R]e[S]et [P]atch" })

			-- Git blame line
			vim.keymap.set("n", "<leader>gbl", ":Git blame<CR>", { desc = "Git [B]lame [L]ine" })

			-- Git show for viewing commits
			vim.keymap.set("n", "<leader>gsh", ":Git show HEAD<CR>", { desc = "Git [SH]ow HEAD" })

			-- Additional useful Git commands
			vim.keymap.set("n", "<leader>gcl", ":Git clean -fd<CR>", { desc = "Git [CL]ean (-fd)" })
			vim.keymap.set("n", "<leader>gtg", ":Git tag<CR>", { desc = "Git [T]a[G]s" })
			vim.keymap.set("n", "<leader>grl", ":Git reflog<CR>", { desc = "Git [R]ef[L]og" })
		end,
	}
end

return vimFugitive
