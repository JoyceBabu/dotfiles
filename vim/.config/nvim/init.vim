" vim: fdm=marker foldenable sw=4 ts=4 sts=4
" "zo" to open folds, "zc" to close, "zn" to disable, "zi" to toggle

" Declare group for autocmd for whole init.vim, and clear it
" Otherwise every autocmd will be added to group each time vimrc sourced!
augroup vimrc
  autocmd!
augroup END

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
Plug 'mhartington/oceanic-next'        " Dark Theme
Plug 'TaDaa/vimade'                    " Fade vim window on focus lose

Plug 'tpope/vim-surround'              " Surround plugin
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'            " Better code commenting
Plug 'tpope/vim-sensible'              " Sensible defaults for vim
Plug 'wincent/terminus'
Plug 'suy/vim-context-commentstring'   " Context aware commentstring in mixed code
Plug 'editorconfig/editorconfig-vim'   " Support for EditorConfig
Plug 'AndrewRadev/splitjoin.vim' , { 'on': ['SplitjoinSplit', 'SplitjoinJoin']}

" Syntax
Plug 'StanAngeloff/php.vim'            " Better syntax highlighting for PHP

Plug 'haya14busa/incsearch.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'jeffkreeftmeijer/vim-numbertoggle' " use absolute line no in insert mode
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline'         " Airline status bar
Plug 'camspiers/lens.vim'              " Auto expand active window
Plug 'thaerkh/vim-workspace'           " Workspace

" Search & Replace
Plug 'osyo-manga/vim-over'             " Realtime replace preview :OverCommandLine
Plug 'tpope/vim-abolish'               " Case aware substitution, autocorrection
                                       " case coercison

" Git Integration
Plug 'tpope/vim-fugitive'
Plug 'jreybert/vimagit'
Plug 'shumphrey/fugitive-gitlab.vim'   " for :Gbrowse
Plug 'airblade/vim-gitgutter', { 'on': ['GitGutterEnable', 'GitGutterDisable'] } " Git integration in gutter

" File Management
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'ryanoasis/vim-devicons'
Plug 'wsdjeg/vim-fetch'                " Handle line & col no in filename
Plug 'lambdalisue/suda.vim'            " Write file with sudo

" Navigation
Plug 'christoomey/vim-tmux-navigator'

" Autocomplete
Plug 'neoclide/coc.nvim', { 'branch': 'release','do': ':CocInstall coc-tsserver coc-json coc-java coc-tabnine coc-pairs coc-yaml coc-phpls coc-highlightcoc-git coc-rls' }

" Debugging
Plug 'vim-vdebug/vdebug'

call plug#end()

" {{{ Autocompletion powered by coc.vim

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

function! s:handle_cr()
    if pumvisible()
        " if completion window is visible, accept selection
        return coc#_select_confirm()
    elseif index(['{}', '[]', '()'], getline(".")[col(".")-2:col(".")-1]) >= 0
        " if we are inside empty matching brackets, inset newline and indent
        return "\<cr>\<esc>\O"
    else
        " Break undo level and insert <CR>
        return "\<C-g>\u\<cr>"
    endif
endfunction

inoremap <expr> <S-Tab> pumvisible() ? '<C-p>' : '<S-Tab>'
inoremap <silent> <expr> <cr> <SID>handle_cr()

" Remap keys for gotos
nnoremap <silent> [g <Plug>(coc-diagnostic-prev)
nnoremap <silent> ]g <Plug>(coc-diagnostic-next)
nnoremap <silent> gd <Plug>(coc-definition)
" nnoremap <silent> gy <Plug>(coc-type-definition)
" nnoremap <silent> gi <Plug>(coc-implementation)
" nnoremap <silent> gr <Plug>(coc-references)
" Remap for rename current word
nnoremap <leader>rn <Plug>(coc-rename)

" Create mappings for function text object, requires document symbols feature of languageserver.
xnoremap if <Plug>(coc-funcobj-i)
xnoremap af <Plug>(coc-funcobj-a)
onoremap if <Plug>(coc-funcobj-i)
onoremap af <Plug>(coc-funcobj-a)

" Remap for format selected region
xnoremap <leader>F  <Plug>(coc-format-selected)
nnoremap <leader>F  <Plug>(coc-format-selected)
inoremap <C-;> <esc>

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
let g:workspace_session_disable_on_args = 1


" {{{ Basic Settings

syntax on                        " Enable colour syntax highlighting
filetype indent on               " Enable loading of plugin files
filetype plugin on               " Enable loading of indent files

" }}}

" {{{ User Interface

set number relativenumber        " Enable display of relative line number
set signcolumn=yes               " Always show sign colum to prevent resize
set colorcolumn=81               " Show a vertical line after 80 chars
set cursorline                   " Highlight current line
" set showmatch                  " highlight matching [{()}]
" set matchtime=0
set hidden
set cmdheight=2
set shortmess+=c
set history=1000                 " Keep 1000 lines of command line history
set lazyredraw                   " Avoid unnecessary UI redraw
set foldenable                   " Enable block folding
set mouse=a                      " Enable mouse interaction in all modes

set termguicolors
if has('mac') && $COLORTERM == '' && !has('gui_vimr') && !has('gui_running')
  set t_Co=256
  set notermguicolors
endif

let g:vimade = {}
let g:vimade.usecursorhold=1
let g:vimade.fadelevel = 0.8
let g:lens#width_resize_max = 80
let g:lens#disabled_filetypes = ['nerdtree', 'fzf']
" let g:vimade.enablesigns = 1

set conceallevel=1

" {{{ Git Integration

let g:fugitive_gitlab_domains = ['https://git.ennexa.org']

" }}}

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

set splitbelow splitright        " Split windows more intuitively.

" }}}

" }}}

" {{{ Editing

set backspace=indent,eol,start
set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab                    " Indent with space
set autoindent                   " Remember indentation from last line
set encoding=utf8                " The encoding displayed.
set fileencoding=utf8            " The encoding written to file.
" set spell
" set spelllang=en

" Home-row shortcut for escape key
inoremap kj <esc>

" {{{ Undo History
set updatetime=300

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
set nohlsearch ignorecase        " disable highlight searches, incsearch plugin does this
set smartcase                    " Enable case sensitivity if term is mixed case
set nostartofline                " prevent cursor from moving when scrolling
set switchbuf=useopen,usetab     " better behavior for the quickfix window and :sb

" Builtin Pluign. Hit `%` on `if` to jump to `else`.
runtime macros/matchit.vim

" {{{ Code Foldings
"
augroup code_folding
    autocmd!
    autocmd FileType php setlocal foldmethod=manual
    autocmd FileType javascript setlocal foldmethod=syntax
    autocmd FileType javascript.jsx setlocal foldmethod=syntax
    autocmd FileType typescript setlocal foldmethod=syntax
    autocmd FileType typescript.tsx setlocal foldmethod=syntax
    autocmd FileType json setlocal foldmethod=syntax
    autocmd FileType html setlocal foldmethod=manual
    autocmd FileType scss setlocal foldmethod=indent
    autocmd FileType css setlocal foldmethod=indent
augroup END

" }}}

" }}}

" {{{ Debugging

let g:vdebug_options = {'ide_key': 'xdebug'}
let g:vdebug_options = {'break_on_open': 0}
let g:vdebug_options = {'server': '127.0.0.1'}
let g:vdebug_options = {'port': '10000'}

" }}}

" {{{ File Management

" Search down into subfolders. Provide tab-completion for all file related tasks
set path+=**

set wildmenu                     " visual autocomplete for command menu

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

" {{{ FileType Overrides

autocmd vimrc FileType php setlocal commentstring=//\ %s
autocmd vimrc FileType yaml setlocal shiftwidth=2 softtabstop=2

" }}}

" {{{ Custom Mappings

let mapleader = ','
" Execute current line in $SHELL and replace it with the output
noremap Q !!$SHELL<cr>
" Quick edit $MYVIMRC
nnoremap ,ve :vsp $MYVIMRC<cr>
nnoremap ,vr :source $MYVIMRC<cr>
" Save files as root
cnoremap w!! execute ':w suda://%'

" }}}

if filereadable("~/.vimrc.local")
  source ~/.vimrc.local
endif
