
" 行番号を表示
set number
" カーソルの位置表示
set ruler
" カーソルのハイライト
set cursorline
" 改行時に自動でインデント
set autoindent
" タブ文字の代わりにスペースを使う
set expandtab
" タブを何文字の空白にするか
set tabstop=2
" 自動インデント時に入力する空白の数
set shiftwidth=2
" yankした文字列をクリップボードにコピー
set clipboard=unnamed
" 検索した文字をハイライト
set hls
" コマンドモードの補完
set wildmenu
" スワップファイルを出力しないようにする
set noswapfile


" インサートモードを抜けて保存
inoremap <silent> jj <ESC>:<C-u>w<CR>:

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
    call dein#begin(s:dir)

    let g:dein_dir = expand('~/.config/nvim')

    " 起動時に読み込むプラグイン群のtoml
    call dein#load_toml(g:dein_dir . '/dein.toml', {'lazy': 0})

    " 利用時に読み込むプラグインのtoml
    call dein#load_toml(g:dein_dir . '/lazy.toml', {'lazy': 1})

    call dein#end()
    call dein#save_state()
  endif
endif

filetype plugin indent on

if dein#check_install()
  call dein#install()
endif
