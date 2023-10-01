" Ward off unexpected things that your distro might have made, as
" well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Set Dein base path (required)
let s:dein_base = '/home/ubuntu/.cache/dein'

" Set Dein source path (required)
let s:dein_src = '/home/ubuntu/.cache/dein/repos/github.com/Shougo/dein.vim'

" Set Dein runtime path (required)
execute 'set runtimepath+=' . s:dein_src

" Call Dein initialization (required)
call dein#begin(s:dein_base)

call dein#add(s:dein_src)

" Your plugins go here:
call dein#add('Shougo/neosnippet.vim')
call dein#add('Shougo/neosnippet-snippets')
call dein#add('neoclide/coc.nvim', {'rev': 'release'})

" Finish Dein initialization (required)
call dein#end()

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
if has('filetype')
  filetype indent plugin on
endif

" Enable syntax highlighting
if has('syntax')
  syntax on
endif

" Uncomment if you want to install not-installed plugins on startup.
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
