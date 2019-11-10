" vim: fdm=marker foldenable sw=4 ts=4 sts=4
" "zo" to open folds, "zc" to close, "zn" to disable, "zi" to toggle

" {{{ Vim Plug Auto Setup

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  silent !mkdir -p ~/.vim/autoload
  silent !ln -fs ~/.local/share/nvim/site/autoload/plug.vim ~/.vim/autoload/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" }}}

call plug#begin('~/.local/share/nvim/plugged')

" Theme
Plug 'mhartington/oceanic-next'
" Plug 'dracula/vim', { 'as': 'dracula' }

Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary' " Comment code
Plug 'editorconfig/editorconfig-vim'
" Plug 'terryma/vim-multiple-cursors'

Plug 'haya14busa/incsearch.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'jeffkreeftmeijer/vim-numbertoggle' "Toggle relative / absolute number based on context
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline' " Airline status bar
Plug 'roman/golden-ratio', { 'on': 'GoldenRatioResize' }
Plug 'thaerkh/vim-workspace'

" Git Integration
Plug 'tpope/vim-fugitive'
Plug 'jreybert/vimagit'
Plug 'shumphrey/fugitive-gitlab.vim' " for :Gbrowse
Plug 'airblade/vim-gitgutter', { 'on': ['GitGutterEnable', 'GitGutterDisable'] } " Git integration in gutter

" File Management
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'ryanoasis/vim-devicons'

" Navigation
Plug 'christoomey/vim-tmux-navigator'

" Autocomplete
Plug 'neoclide/coc.nvim', { 'branch': 'release','do': ':CocInstall coc-tsserver coc-json coc-java coc-tabnine coc-pairs coc-yaml coc-phpls coc-highlightcoc-git coc-rls' }

call plug#end()

" {{{ Autocompletion powered by coc.vim

" use <c-space>for trigger completion
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <Tab> pumvisible() ? '<C-n>' : '<Tab>'
inoremap <expr> <S-Tab> pumvisible() ? '<C-p>' : '<S-Tab>'
" inoremap <expr> <cr> pumvisible() ? '\<C-y>' : '\<C-g>u\<CR>'
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : '<C-g>u<CR>'

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

command! -nargs=+ -complete=file
      \ SplitIfNotOpen4COC
      \ call lh#coc#_split_open(<f-args>)

" Use K to show documentation in preview window
nnoremap <silent> gk :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Close preview when completion is done
" autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" }}}

" Workspace
let g:workspace_session_directory = $HOME . '/.cache/vim/sessions/'
let g:workspace_persist_undo_history = 1
let g:workspace_undodir='.undodir'

let g:fugitive_gitlab_domains = ['https://git.ennexa.org']

"call <plug>fzf#run({'sink': 'tabedit'})

autocmd FileType php setlocal commentstring=//\ %s
syntax on
filetype indent plugin on

" {{{ Basic Settings

set nocompatible

" }}}

" {{{ User Interface

set number relativenumber " Enable display of relative line number
set signcolumn=yes " Always show sign colum. This prevents resizing when linting is enabled.
set colorcolumn=81 " Show a vertical line after 80 chars
set cursorline " Highlight current line

set hidden
set cmdheight=2
set shortmess+=c
set history=100

set mouse=a " Enable mouse interaction in all modes

set termguicolors
if has('mac') && $COLORTERM == '' && !has('gui_vimr') && !has('gui_running')
  set t_Co=256
  set notermguicolors
endif

" {{{ Theme

" OceanicNext Theme
let g:airline_theme='oceanicnext'
let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1

" color dracula
colorscheme OceanicNext

" }}}

" {{{ Word Wrap

" Indents word-wrapped lines as much as the parent line
set breakindent
" Ensures word-wrap does not split words
set formatoptions=l
set lbr
set showbreak=↪\ \ \

" }}}

set conceallevel=1

" {{{ IndentLine Settings

let g:indentLine_faster     = 1
let g:indentLine_setConceal = 0
let g:indentLine_conceallevel=2
" let g:indentLine_char = 'c'
let g:indentLine_enabled=0
let g:indentLine_color_term = 239
let g:indentLine_char = '︙'
let g:indentLine_leadingSpaceEnabled=1
let g:indentLine_leadingSpaceChar = '.'
" autocmd! User indentLine doautocmd indentLine Syntax

" }}}

" {{{ Windows / Tabs

let g:golden_ratio_autocommand = 0
set splitbelow splitright

" }}}

" }}}

" {{{ Editing

set backspace=indent,eol,start
set shiftwidth=4
set tabstop=4
set expandtab autoindent smartindent
set encoding=utf-8  " The encoding displayed.
set fileencoding=utf-8  " The encoding written to file.

" {{{ Undo History
set updatetime=300
" Handle indentation when pressing enter from withing curly braces
inoremap <expr> <cr> getline(".")[col(".")-2:col(".")-1]=="{}" ? "<cr><esc>O" : "<cr>"

if has('persistent_undo')
  let target_path = expand('~/.cache/vim/vim-persisted-undo/')

  if !isdirectory(target_path)
    call system('mkdir -p ' . target_path)
  endif

  let &undodir = target_path
  set undofile
endif
" }}}

" }}}

" {{{ Code Navigation

" imap <S-Tab> <plug>(fzf-complete-line)
set nohlsearch ignorecase smartcase  " do not highlight searches, incsearch plugin does this
set nostartofline " prevent cursor from moving when scrolling

" Quick navigation
nnoremap J 20j
nnoremap K 20k

" }}}

" {{{ File Management

" Search down into subfolders. Provide tab-completion for all file related tasks
set path+=**

" Display all matching files when doing tab-completion.
set wildmenu

set wildignore+=**/vendor/**
set wildignore+=**/composer/**
set wildignore+=**/node_modules/**
set wildignore+=**/bower_components/**
set wildignore+=**/test/**
set wildignore+=**/.git/**
set wildignore+=**/.data/**
set wildignore+=**/update-db/**
set wildignore+=**/__dist/**
set wildignore+=**/db/**

" NERDTree Toggle
let NERDTreeHijackNetrw = 0
let g:NERDTreeUpdateOnCursorHold = 0
let g:NERDTreeUpdateOnWrite  = 0
let NERDTreeShowHidden = 1
let NERDTreeIgnore = ['\.DS_Store', '\~$', '\.swp']

noremap <silent> <Leader>n :NERDTreeToggle<CR> <C-w>=
noremap <silent> <Leader>f :NERDTreeFind<CR> <C-w>=

nnoremap <c-p> :call fzf#run({'sink': 'tabedit'})<cr>

" }}}

" Execute current line in $SHELL and replace it with the output
noremap Q !!$SHELL<cr>
" Quick edit $MYVIMRC
nnoremap ,ve :vsp $MYVIMRC<cr>
nnoremap ,vr :source $MYVIMRC<cr>

if filereadable("~/.vimrc.local")
  source ~/.vimrc.local
endif
