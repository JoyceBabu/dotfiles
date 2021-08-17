" vim: fdm=marker foldenable sw=4 ts=4 sts=4
" "zo" to open folds, "zc" to close, "zn" to disable, "zi" to toggle

" {{{ Initialization

" Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

" Declare group for autocmd for whole init.vim, and clear it
" Otherwise every autocmd will be added to group each time vimrc sourced!
augroup vimrc
  autocmd!
augroup END

let mapleader = ','

" {{{ Vim Plug Auto Setup

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  silent !mkdir -p ~/.vim/autoload
  silent !ln -fs ~/.local/share/nvim/site/autoload/plug.vim ~/.vim/autoload/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" }}}

" }}}

" {{{ Load Plugins

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

" Syntax
Plug 'StanAngeloff/php.vim'            " Better syntax highlighting for PHP
Plug 'AndrewRadev/splitjoin.vim' , { 'on': ['SplitjoinSplit', 'SplitjoinJoin']}
Plug 'swekaj/php-foldexpr.vim', { 'for' :'php' } " Enable code folding for PHP

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
" Plug 'jreybert/vimagit'
Plug 'shumphrey/fugitive-gitlab.vim'   " for :Gbrowse
Plug 'airblade/vim-gitgutter', { 'on': ['GitGutterEnable', 'GitGutterDisable'] } " Git integration in gutter

" File Management
Plug 'junegunn/fzf', {
      \ 'dir': '~/.fzf',
      \ 'do': './install --all --no-update-rc'
      \}
Plug 'junegunn/fzf.vim'
Plug 'justinmk/vim-dirvish'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'ryanoasis/vim-devicons'
Plug 'wsdjeg/vim-fetch'                " Handle line & col no in filename
Plug 'lambdalisue/suda.vim'            " Write file with sudo
Plug 'editorconfig/editorconfig-vim'   " Support for EditorConfig

" Navigation
Plug 'christoomey/vim-tmux-navigator'

" Autocomplete
Plug 'neoclide/coc.nvim', { 'branch': 'release','do': ':CocInstall coc-diagnostic coc-tsserver coc-json coc-tabnine coc-pairs coc-yaml coc-phpls coc-highlight coc-git coc-snippets' }
" Plug 'SirVer/ultisnips'

" Editing
Plug 'mbbill/undotree'                 " Visualize undo tree
Plug 'michaeljsmith/vim-indent-object' " Text objects for indentation level
Plug 'vim-scripts/argtextobj.vim'

" Debugging
Plug 'vim-vdebug/vdebug'

call plug#end()

" }}}

" {{{ Language Support

" {{{ PHP

" {{{ Coc / Intelephense

highlight! CocCodeLens guifg=#606060 ctermfg=60

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

imap <silent> <c-u>      <plug>(coc-snippets-expand)
inoremap <m-p> call CocActionAsync('showSignatureHelp')<cr>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Show quick documentation
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Remap keys for gotos
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gI <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Remap for rename current symbol
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap for format selected region
xmap <leader>F  <Plug>(coc-format-selected)


" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Apply codeAction to the selected region
xmap <leader>a  <Plug>(coc-codeaction-selected)
" Apply codeAction to the current buffer
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nnoremap <leader>prw :CocSearch <C-R>=expand("<cword>")<CR><CR>

" " Use CTRL-S for selections ranges.
" nmap <silent> <C-s> <Plug>(coc-range-select)
" xmap <silent> <C-s> <Plug>(coc-range-select)

" command! -nargs=+ -complete=file
"       \ SplitIfNotOpen4COC
"       \ call lh#coc#_split_open(<f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

command! -nargs=0 IntelephenseReindex   :call     CocAction('runCommand', 'intelephense.index.workspace')

" Add (Neo)Vim's native statusline support.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

augroup vimrc
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  " Highlight the symbol and its references when holding the cursor.
  autocmd CursorHold * silent call CocActionAsync('highlight')
augroup end

" }}}

" {{{ phpactor

au FileType php nmap ,gd :call phpactor#GotoDefinition()<CR>
au FileType php nmap ,c :call phpactor#ContextMenu()<CR>
au FileType php nmap ,i :call phpactor#OffsetTypeInfo()<CR>

" }}}

" autocmd vimrc BufWritePost *.php silent! call PhpCsFixerFixFile()

" }}}

" }}}

" {{{ Project / Session

" Workspace
let g:workspace_session_directory = $HOME . '/.cache/vim/sessions/'
let g:workspace_persist_undo_history = 1
let g:workspace_undodir='.undodir'
let g:workspace_session_disable_on_args = 1

let g:netrw_liststyle = 3    " Show tree style directory list
" let g:netrw_banner = 0       " Hide directory banner
let g:netrw_winsize = 25     " Width of the netrw split
let g:netrw_preview   = 1
let g:netrw_browse_split = 4 " Open file in previous window
let g:netrw_altv = 1         " Open file in left right split when pressing v
let g:netrw_list_hide = '\.sw[op]$'

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
let g:lens#disabled_filetypes = ['nerdtree', 'fzf', 'netrw']
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
" let g:indentLine_enabled=1
let g:indentLine_color_term = 239
let g:indentLine_leadingSpaceEnabled=1
let g:indentLine_leadingSpaceChar = '.'
" let g:indentLine_char = '︙'
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
" autocmd! User indentLine doautocmd indentLine Syntax

" }}}

" {{{ Windows / Tabs

set splitbelow splitright        " Split windows more intuitively.

" Disable vim->tmux navigation when the Vim pane is zoomed in tmux
let g:tmux_navigator_disable_when_zoomed = 1

" Rebalance windows on vim resize when tmux panes are created/destroyed/resized
autocmd vimrc VimResized * :wincmd =

" zoom a vim pane, <C-w>= to re-balance
nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>

" Zoom / Restore window.
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction

command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <C-m> :ZoomToggle<CR>

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

" }}}

" {{{ Code Navigation

" imap <S-Tab> <plug>(fzf-complete-line)
set nohlsearch ignorecase        " disable highlight searches, incsearch plugin does this
set smartcase                    " Enable case sensitivity if term is mixed case
set nostartofline                " prevent cursor from moving when scrolling
set switchbuf=useopen,usetab     " better behavior for the quickfix window and :sb
set scrolloff=8

" Builtin Pluign. Hit `%` on `if` to jump to `else`.
runtime macros/matchit.vim

" {{{ Code Foldings

set nofoldenable                   " Enable block folding

augroup code_folding
    autocmd!
    " autocmd FileType php setlocal foldmethod=manual
    autocmd FileType php setlocal foldlevel=1
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

" nnoremap <C-p> :GFiles<CR>

" }}}

" {{{ FileType Overrides

autocmd vimrc FileType php setlocal commentstring=//\ %s
autocmd vimrc FileType yaml setlocal shiftwidth=2 softtabstop=2

" }}}

" {{{ Command Line Modes

" Save files as root
cnoremap w!! execute ':w suda://%'

" }}}

" {{{ Custom Mappings

" Execute current line in $SHELL and replace it with the output
noremap Q !!$SHELL<cr>

" Quick edit $MYVIMRC
nnoremap ,ve :vsp $MYVIMRC<cr>
nnoremap ,vr :source $MYVIMRC<cr>

" Bash like keys for the insert/command line mode
inoremap <C-a> <Home>
inoremap <C-b> <Left>
inoremap <C-d> <Delete>
inoremap <C-e> <End>
inoremap <C-f> <Right> asdf
" inoremap <C-h> <Backspace>
" inoremap <C-k> <C-U>
inoremap <C-y> <C-r>+
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
" cnoremap <C-k> <C-o>D

" Indent without killing the selection in vmode
vmap < <gv
vmap > >gv

" Home-row shortcut for escape key
inoremap kj <esc>
inoremap jk <esc>

" Replace selection with last yanked text without modifying unnamed registers
vnoremap <leader>p "_dP
" Delete without modifying unnamed registers
nnoremap <leader>d "_d
vnoremap <leader>d "_d
" Yank to system clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y

nnoremap <leader>bs /<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>
nnoremap <leader>pv :Vex<CR>

" }}}

" {{{ Overrides

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" }}}
