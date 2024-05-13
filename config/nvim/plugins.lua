require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'windwp/nvim-ts-autotag'
  use { 'junegunn/fzf', build = './install --all', merged = '0' }
  use { 'yuki-yano/fzf-preview.vim', rev = 'release/rpc' }
  use { 'nvim-treesitter/nvim-treesitter', do = 'TSUpdate' }
  use { 'github/copilot.vim', rev = 'release' }
  use { 'neoclide/coc.nvim', rev = 'release' }
  use { 'tpope/vim-dadbod' }
  use { 'kristijanhusak/vim-dadbod-ui' }
  use { 'lewis6991/gitsigns.nvim' }
  use { 'nvim-tree/nvim-web-devicons' }
  use { 'romgrk/barbar.nvim' }
  use { 'mikinovation/nvim-gitui' }
)
