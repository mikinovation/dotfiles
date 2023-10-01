if &compatible
  set nocompatible
endif

let $CACHE = expand('~/.cache')
if !($CACHE->isdirectory())
  call mkdir($CACHE, 'p')
endif
if &runtimepath !~# '/dein.vim'
  let s:dir = 'dein.vim'->fnamemodify(':p')
  if !(s:dir->isdirectory())
    let s:dir = $CACHE .. '/dein/repos/github.com/Shougo/dein.vim'    
    if !(s:dir->isdirectory())
      execute '!git clone https://github.com/Shougo/dein.vim' s:dir
    endif
  endif
  execute 'set runtimepath^='
    \ .. s:dir->fnamemodify(':p')->substitute('[/\\]$', '', '')
  

  if dein#load_state(s:dir)
    " Call Dein initialization (required)
    call dein#begin(s:dir)

    let s:toml_dir = expand('~/.config/nvim')

    call dein#load_toml(s:toml_dir . '/dein.toml', {'lazy': 0})
    call dein#load_toml(s:toml_dir . '/lazy.toml', {'lazy': 1})

    call dein#end()
  endif
endif

if has('filetype')
  filetype indent plugin on
endif

if has('syntax')
  syntax on
endif

if dein#check_install()
 call dein#install()
endif

" 文字コード
set encoding=utf-8
" 行番号を表示
set number
" タブ文字の代わりにスペースを使う
set expandtab
" 改行時に自動でインデント
set autoindent
" 自動インデント時に入力する空白の数
set shiftwidth=2
" タブの空白の数
set tabstop=2
" yankした文字列をクリップボードにコピー
set clipboard=unnamed
" 検索した文字をハイライトする
set hls

:nmap <space>e <Cmd>CocCommand explorer<CR>
:inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
