set encoding=utf-8
scriptencoding utf-8

let $CACHE = expand('~/.cache')

if !isdirectory($CACHE)
  call mkdir($CACHE, 'p')
endif

if &runtimepath !~# '/dein.vim'
  let s:dir = fnamemodify('dein.vim', ':p')
  if(!isdirectory(s:dir))
    let s:dir = $CACHE . '/dein/repos/github.com/Shougo/dein.vim'    
    if !isdirectory(s:dir)
      execute '!git clone https://github.com/Shougo/dein.vim' s:dir
    endif
  endif
  execute 'set runtimepath^='
    \ . substitute(fnamemodify(s:dir, ':p'), '[/\\]$', '', '')
  

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

" カラースキームの復元
" TODO: legacyモードなので新しいschemeに変更したい
colorscheme vim

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
set clipboard=unnamedplus
" 検索した文字をハイライトする
set hlsearch
" バックアップファイルを作らない
set nobackup
set nowritebackup
set noswapfile

" leaderをスペースへ設定
let mapleader = "\<Space>"

function! s:RenameFile(new_name)
  let l:current_file_dir = expand('%:p:h')
  let l:new_file_path = l:current_file_dir . '/' . a:new_name
  execute ':saveas ' . l:new_file_path
  call delete(expand('#'))
endfunction

:nmap <Leader>rf :call <SID>RenameFile(input('New file name: '))<CR>

" file explorerを開く
:nmap <Leader>e <Cmd>CocCommand explorer<CR>
" 補完を利用できるようにする
:inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" インサートモード

" jjでノーマルモードに戻る
inoremap <silent> jj <ESC>

" ターミナルモード

" :Tコマンドで Terminalを開くと現在のウィンドウの下部に別ウィンドウで表示されるようにする
command! -nargs=* T split | wincmd j | resize 20 | terminal <args>
" ターミナルを閉じてノーマルモードに戻る
:tnoremap <ESC> <C-\><C-n>
" ターミナルモードを開いたら自動でインサートモードにする
autocmd TermOpen * startinsert

let g:coc_global_extensions = [
  \ 'coc-explorer', 
  \ 'coc-fzf-preview', 
  \ 'coc-copilot',
  \ 'coc-docker',
  \ 'coc-git',
  \ 'coc-json',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-java',
  \ 'coc-rust-analyzer',
  \ '@yaegassy/coc-volar',
  \ '@yaegassy/coc-volar-tools',
  \ ]

" coc mappings

" 定義元へジャンプ
nmap <silent> gd <Plug>(coc-definition)
" 参照元の閲覧
nmap <silent> gr <Plug>(coc-references)
" リネーム
nmap <silent> <Leader>rn <Plug>(coc-rename)
" ホバー
nmap <silent> K <Plug>(coc-hover)

" coc-fzf-preview

nmap <Leader>f [fzf-p]
xmap <Leader>f [fzf-p]

nnoremap <silent> [fzf-p]p     :<C-u>CocCommand fzf-preview.FromResources project_mru git<CR>
nnoremap <silent> [fzf-p]gs    :<C-u>CocCommand fzf-preview.GitStatus<CR>
nnoremap <silent> [fzf-p]ga    :<C-u>CocCommand fzf-preview.GitActions<CR>
nnoremap <silent> [fzf-p]b     :<C-u>CocCommand fzf-preview.Buffers<CR>
nnoremap <silent> [fzf-p]B     :<C-u>CocCommand fzf-preview.AllBuffers<CR>
nnoremap <silent> [fzf-p]o     :<C-u>CocCommand fzf-preview.FromResources buffer project_mru<CR>
nnoremap <silent> [fzf-p]<C-o> :<C-u>CocCommand fzf-preview.Jumps<CR>
nnoremap <silent> [fzf-p]g;    :<C-u>CocCommand fzf-preview.Changes<CR>
nnoremap <silent> [fzf-p]/     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
nnoremap <silent> [fzf-p]*     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
nnoremap          [fzf-p]gr    :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
xnoremap          [fzf-p]gr    "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
nnoremap <silent> [fzf-p]t     :<C-u>CocCommand fzf-preview.BufferTags<CR>
nnoremap <silent> [fzf-p]q     :<C-u>CocCommand fzf-preview.QuickFix<CR>
nnoremap <silent> [fzf-p]l     :<C-u>CocCommand fzf-preview.LocationList<CR>

" nvim-treesitter

lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"typescript", "javascript", "vue", "html", "css", "json", "yaml", "bash", "lua"},
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
}

require'nvim-gitui'.setup {}
EOF

" CopilotChat

lua << EOF
require'CopilotChat'.setup {
  debug = true,
}
EOF

nmap <Leader>cc [copilot-chat]
xmap <Leader>cc [copilot-chat]

nnoremap <silent> [copilot-chat]t     :<C-u>CopilotChatToggle<CR>
nnoremap <silent> [copilot-chat]r     :<C-u>CopilotChatReview<CR>
nnoremap <silent> [copilot-chat]o     :<C-u>CopilotChatOptimize<CR>
nnoremap <silent> [copilot-chat]f     :<C-u>CopilotChatFix<CR>
nnoremap <silent> [copilot-chat]fd    :<C-u>CopilotChatFixDiagnostic<CR>

" coc-git

nmap [g <Plug>(coc-git-prevchunk)
nmap ]g <Plug>(coc-git-nextchunk)
nmap [c <Plug>(coc-git-prevconflict)
nmap ]c <Plug>(coc-git-nextconflict)
nmap gs <Plug>(coc-git-chunkinfo)
nmap gc <Plug>(coc-git-commit)
omap ig <Plug>(coc-git-chunk-inner)
xmap ig <Plug>(coc-git-chunk-inner)
omap ag <Plug>(coc-git-chunk-outer)
xmap ag <Plug>(coc-git-chunk-outer)

" barbar.nvim

" 次へ・前へ

nmap <silent> tb <Cmd>BufferPrevious<CR>
nmap <silent> tn <Cmd>BufferNext<CR>

" バッファの削除
nnoremap <silent> tc <Cmd>BufferClose<CR>
