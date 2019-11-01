if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

" Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'mhartington/oceanic-next'
Plug 'tpope/vim-surround'
" Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'
Plug 'haya14busa/incsearch.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'tpope/vim-commentary' " Comment code
Plug 'jeffkreeftmeijer/vim-numbertoggle' "Toggle relative / absolute number based on context
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline' " Airline status bar
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'roman/golden-ratio', { 'on': 'GoldenRatioResize' }
Plug 'tpope/vim-fugitive' " Git Integration
Plug 'jreybert/vimagit'
Plug 'shumphrey/fugitive-gitlab.vim' " for :Gbrowse
Plug 'airblade/vim-gitgutter', { 'on': ['GitGutterEnable', 'GitGutterDisable'] } " Git integration in gutter
Plug 'tpope/vim-repeat'
Plug 'thaerkh/vim-workspace'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'Shougo/neco-syntax'
Plug 'thalesmello/webcomplete.vim'

Plug 'neoclide/coc.nvim', { 'branch': 'release','do': ':CocInstall coc-tsserver coc-json coc-java coc-tabnine coc-pairs coc-yaml coc-phpls coc-highlightcoc-git coc-rls' }
" Plug 'prabirshrestha/vim-lsp'
" Plug 'prabirshrestha/async.vim'
" Plug 'lighttiger2505/deoplete-vim-lsp'
" autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif


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

" Deoplete
set completeopt-=preview
let g:deoplete#enable_at_startup = 0
if !exists('g:deoplete#omni#input_patterns')
  let g:deoplete#omni#input_patterns = {}
endif

let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
let g:deoplete#ignore_sources.php = get(g:deoplete#ignore_sources, 'php', ['omni', 'around', 'member'])
call deoplete#custom#option('max_list', 10)

" inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" source $HOME/.config/nvim/config/lsp.vimrc

let g:fugitive_gitlab_domains = ['https://git.ennexa.org']
let g:golden_ratio_autocommand = 0

"Shortcut window switches, w+h/j/k/l
" nmap Wk <c-w><up>
" nmap Wh <c-w><left>
" nmap Wl <c-w><right>
" nmap Wj <c-w><down>
" nmap W} :GoldenRatioResize<CR>

"call <plug>fzf#run({'sink': 'tabedit'})
let g:indentLine_faster     = 1
let g:indentLine_setConceal = 0
set conceallevel=1
let g:indentLine_conceallevel=2

let g:indentLine_color_term = 239
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

if (has("termguicolors"))
  set termguicolors
endif

" OceanicNext Theme
let g:airline_theme='oceanicnext'
let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1
colorscheme OceanicNext

" color dracula

autocmd FileType php setlocal commentstring=//\ %s

" Prevent gutter from resizing on lint error
set signcolumn=yes

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

syntax on
filetype indent plugin on

imap <S-Tab> <plug>(fzf-complete-line)
nnoremap J 20j
nnoremap K 20k

" NERDTree Toggle
let NERDTreeHijackNetrw = 0
let g:NERDTreeUpdateOnCursorHold = 0
let g:NERDTreeUpdateOnWrite  = 0
let NERDTreeShowHidden = 1
let NERDTreeIgnore = ['\.DS_Store', '\~$', '\.swp']

noremap <silent> <Leader>n :NERDTreeToggle<CR> <C-w>=
noremap <silent> <Leader>f :NERDTreeFind<CR> <C-w>=

nnoremap <c-p> :call fzf#run({'sink': 'tabedit'})<cr>

