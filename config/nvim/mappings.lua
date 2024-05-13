local mappings = {
  -- leaderをスペースに設定
  ["n"] = { "<Space>", "<Nop>" },
  -- file explorerを開く
  ["n"] = { "<leader>e", "CocCommand explorer" },
  -- 補完を利用できるようにする
  ["i"] = { "<CR>", "coc#pum#visible() ? coc#pum#confirm() : \"<CR>\"" },
  -- インサートモードに戻る
  ["i"] = { "jj", "<ESC>" }
}

for mode, maps in pairs(mappings) do
  for key, map in pairs(maps) do
    vim.api.nvim_set_keymap(mode, key, map, { noremap = true, silent = true })
  end
end
