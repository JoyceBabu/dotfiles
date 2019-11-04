if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  silent !mkdir -p ~/.vim/autoload
  silent !ln -fs ~/.local/share/nvim/site/autoload/plug.vim ~/.vim/autoload/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

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

" Navigation
Plug 'christoomey/vim-tmux-navigator'

" Autocomplete
Plug 'neoclide/coc.nvim', { 'branch': 'release','do': ':CocInstall coc-tsserver coc-json coc-java coc-tabnine coc-pairs coc-yaml coc-phpls coc-highlightcoc-git coc-rls' }

call plug#end()

" coc.vim
" use <c-space>for trigger completion
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <Tab> pumvisible() ? '<C-n>' : '<Tab>'
inoremap <expr> <S-Tab> pumvisible() ? '<C-p>' : '<S-Tab>'
" inoremap <expr> <cr> pumvisible() ? '\<C-y>' : '\<C-g>u\<CR>'
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : '<C-g>u<CR>'
" Close preview when completion is done
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Workspace
let g:workspace_session_directory = $HOME . '/.cache/vim/sessions/'
let g:workspace_undodir='.undodir'
" CloseHiddenBuffers

let g:fugitive_gitlab_domains = ['https://git.ennexa.org']
let g:golden_ratio_autocommand = 0

"call <plug>fzf#run({'sink': 'tabedit'})
let g:indentLine_faster     = 1
let g:indentLine_setConceal = 0
set conceallevel=1
let g:indentLine_conceallevel=2

" let g:indentLine_char = 'c'

" IndentLine Settings
let g:indentLine_enabled=0
let g:indentLine_color_term = 239
let g:indentLine_char = '︙'
let g:indentLine_leadingSpaceEnabled=1
let g:indentLine_leadingSpaceChar = '.'
" autocmd! User indentLine doautocmd indentLine Syntax

if has('persistent_undo')
  let target_path = expand('~/.cache/vim/vim-persisted-undo/')

  if !isdirectory(target_path)
    call system('mkdir -p ' . target_path)
  endif

  let &undodir = target_path
  set undofile
endif

set termguicolors
if has('mac') && $COLORTERM == '' && !has('gui_vimr') && !has('gui_running')
  set t_Co=256
  set notermguicolors
endif

" OceanicNext Theme
let g:airline_theme='oceanicnext'
let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1

colorscheme OceanicNext

" color dracula

autocmd FileType php setlocal commentstring=//\ %s

set nocompatible
" Always show sign column. Prevent gutter from resizing on lint error
set signcolumn=yes

" Enable mouse mode in all modes
set mouse=a

set hidden
set cmdheight=2
set updatetime=300
set shortmess+=c

set number
set relativenumber
set nohlsearch ignorecase smartcase  " do not highlight searches, incsearch plugin does this
set backspace=indent,eol,start
set shiftwidth=4
set tabstop=4
set expandtab autoindent smartindent
set splitbelow splitright
set nostartofline " prevent cursor from moving when scrolling
set encoding=utf-8  " The encoding displayed.
set fileencoding=utf-8  " The encoding written to file.
set colorcolumn=81
set history=100
set cursorline

syntax on
filetype indent plugin on

" imap <S-Tab> <plug>(fzf-complete-line)
" Quick navigation
nnoremap J 20j
nnoremap K 20k
" Execute current line in $SHELL and replace it with the output
noremap Q !!$SHELL<cr>
" Handle indentation when pressing enter from withing curly braces
inoremap <expr> <cr> getline(".")[col(".")-2:col(".")-1]=="{}" ? "<cr><esc>O" : "<cr>"
" Quick edit $MYVIMRC
nmap <silent> ,ev :vsp $MYVIMRC<cr>

" NERDTree Toggle
let NERDTreeHijackNetrw = 0
let g:NERDTreeUpdateOnCursorHold = 0
let g:NERDTreeUpdateOnWrite  = 0
let NERDTreeShowHidden = 1
let NERDTreeIgnore = ['\.DS_Store', '\~$', '\.swp']

noremap <silent> <Leader>n :NERDTreeToggle<CR> <C-w>=
noremap <silent> <Leader>f :NERDTreeFind<CR> <C-w>=

nnoremap <c-p> :call fzf#run({'sink': 'tabedit'})<cr>

if filereadable("~/.vimrc.local")
  source ~/.vimrc.local
endif
