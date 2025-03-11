" vim: filetype=vim fdm=marker foldenable sw=4 ts=4 sts=4
" "zo" to open fold, "zc" to close, "za" to toggle, "zi" to toggle folding

"  Initialization

" Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

source ~/.config/nvim/basic.vim

set termguicolors
if has('mac') && $COLORTERM == '' && !has('gui_vimr') && !has('gui_running')
  set t_Co=256
  set notermguicolors
endif

" Declare group for autocmd for whole init.vim, and clear it
" Otherwise every autocmd will be added to group each time vimrc sourced!
augroup vimrc
  autocmd!
augroup END

"  Vim Plug Auto Setup

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  silent !mkdir -p ~/.vim/autoload
  silent !ln -fs ~/.local/share/nvim/site/autoload/plug.vim ~/.vim/autoload/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

"  Load Plugins

call plug#begin('~/.local/share/nvim/plugged')

if has('nvim')
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-neorg/neorg'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-ui-select.nvim'
  Plug 'olimorris/onedarkpro.nvim'
  " Required by hardtime.nvim
  Plug 'MunifTanjim/nui.nvim'
  Plug 'm4xshen/hardtime.nvim'

  " Plug 'ldelossa/nvim-ide'
  " LSP Support
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'jose-elias-alvarez/null-ls.nvim'
  Plug 'jay-babu/mason-null-ls.nvim'

  " Autocompletion
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'saadparwaiz1/cmp_luasnip'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-nvim-lua'

  " Useful status updates for LSP
  Plug 'j-hui/fidget.nvim'

  " Additional lua configuration, makes nvim stuff amazing
  Plug 'folke/neodev.nvim'

  " Snippets
  Plug 'L3MON4D3/LuaSnip'
  Plug 'rafamadriz/friendly-snippets'

  Plug 'VonHeikemen/lsp-zero.nvim', { 'branch': 'v1.x' }
else
  Plug 'joshdick/onedark.vim'
endif

" Theme
" Plug 'gruvbox-community/gruvbox', {'as': 'gruvbox'} " Gruvbox Theme
" Plug 'jeffkreeftmeijer/vim-dim', { 'branch': '1.x' }
" Plug 'TaDaa/vimade'                    " Fade vim window on focus lose

Plug 'tpope/vim-surround'              " Surround plugin
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'            " Better code commenting
Plug 'tpope/vim-sensible'              " Sensible defaults for vim

" Syntax
Plug 'StanAngeloff/php.vim', {'for': 'php'} " Better syntax highlighting for PHP
Plug 'ollykel/v-vim', { 'for': 'vlang' } " Syntax support for vlang
Plug 'AndrewRadev/splitjoin.vim' , { 'on': ['SplitjoinSplit', 'SplitjoinJoin']}

Plug 'machakann/vim-highlightedyank'
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline'         " Airline status bar
" Plug 'camspiers/lens.vim'              " Auto expand active window
Plug 'thaerkh/vim-workspace'           " Workspace

" Search & Replace
Plug 'tpope/vim-abolish'               " Case aware substitution, autocorrection
                                       " case coercison

" Git Integration
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
" Plug 'jreybert/vimagit'
Plug 'shumphrey/fugitive-gitlab.vim'   " for :Gbrowse
Plug 'airblade/vim-gitgutter', { 'on': ['GitGutterEnable', 'GitGutterDisable'] } " Git integration in gutter
Plug 'kdheepak/lazygit.nvim'

" File Management
Plug 'junegunn/fzf', {
      \ 'dir': '~/.fzf',
      \ 'do': './install --all --no-update-rc'
      \}
Plug 'junegunn/fzf.vim'
Plug 'jesseleite/vim-agriculture'      " Allow passing flags in :Ag
Plug 'justinmk/vim-dirvish'
Plug 'ryanoasis/vim-devicons'
" Plug 'wsdjeg/vim-fetch'                " Handle line & col no in filename
Plug 'editorconfig/editorconfig-vim'   " Support for EditorConfig

" Navigation
Plug 'christoomey/vim-tmux-navigator'
Plug 'mg979/vim-visual-multi', {'branch': 'master'} " Multi cursor support

" Editing
Plug 'mbbill/undotree'                 " Visualize undo tree
Plug 'vim-scripts/argtextobj.vim'

" Debugging
" Plug 'vim-vdebug/vdebug'

call plug#end()

"

"  Configure Plugins

if has('nvim')
  lua require('treesitter-cfg')
endif

"
"  Language Support

"  vlang

let g:v_autofmt_bufwritepre = 1        " Auto format on save

"

"

"  Project / Session

"  Workspace

let g:workspace_session_directory = $HOME . '/.cache/vim/sessions/'
let g:workspace_persist_undo_history = 1
let g:workspace_undodir='.undodir'
let g:workspace_session_disable_on_args = 1

"

"  Undo History

if has('persistent_undo')
  let target_path = expand('~/.cache/vim/vim-persisted-undo/')

  if !isdirectory(target_path)
    call system('mkdir -p ' . target_path)
  endif

  let &undodir = target_path
  set undofile
  set noswapfile
  set nobackup
endif

"

"

"  User Interface

let g:vimade = {}
let g:vimade.usecursorhold=1
let g:vimade.fadelevel = 0.8
let g:lens#width_resize_max = 80
let g:lens#disabled_filetypes = ['nerdtree', 'fzf', 'netrw']
" let g:vimade.enablesigns = 1

"  Git Integration

let g:fugitive_gitlab_domains = ['https://git.ennexa.org']

" LazyGit
let g:lazygit_use_custom_config_file_path = 1
let g:lazygit_config_file_path = [
  \$HOME . '/.config/lazygit/config.yml',
  \$HOME . '/.config/lazygit/config.nvim.yml',
\]
let g:lazygit_floating_window_scaling_factor = 1
nnoremap <silent> <leader>lg :LazyGit<CR>

"  Theme

" let g:airline_theme='gruvbox'

set background=dark
colorscheme onedark
highlight Comment cterm=italic gui=italic

"

"  IndentLine Settings

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

"

"  Windows / Tabs

" Disable vim->tmux navigation when the Vim pane is zoomed in tmux
let g:tmux_navigator_disable_when_zoomed = 1

nnoremap <silent> gz :ZoomToggle<CR>

"

"

"  Debugging

" let g:vdebug_options = {'ide_key': 'xdebug'}
" let g:vdebug_options = {'break_on_open': 0}
" let g:vdebug_options = {'server': '127.0.0.1'}
" let g:vdebug_options = {'port': '10000'}

"

"  File Management

" nnoremap <C-p> :GFiles<CR>

nnoremap <leader>ps :GFiles<CR>

" Find files using Telescope command-line sugar.
nnoremap <leader>fa <cmd>Telescope find_files<cr>
nnoremap <leader>ff <cmd>Telescope git_files<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fo <cmd>Telescope oldfiles<cr>
nnoremap <leader>sf <cmd>Telescope live_grep<cr>
nnoremap <leader>sh <cmd>Telescope help_tags<cr>

"
"  Command Line Modes
"

"  Custom Mappings


" Execute current line in $SHELL and replace it with the output
noremap Q !!$SHELL<cr>

"  Vim Visual Multi

let g:VM_theme = 'iceblue'
let g:VM_highlight_matches = 'underline'

let g:VM_maps = {}
let g:VM_maps["Undo"]            = 'u'
let g:VM_maps["Redo"]            = '<C-r>'
let g:VM_maps["Add Cursor Down"] = '<M-j>'   " new cursor down
let g:VM_maps["Add Cursor Up"]   = '<M-k>'   " new cursor up
let g:VM_maps["Toggle Mappings"] = '<CR>'    " toggle VM buffer mappings
" let g:VM_maps["Exit"]            = '<C-c>'   " quit VM
let g:VM_maps['Select All']      = '<M-n>'
let g:VM_maps['Visual All']      = '<M-n>'
" let g:VM_maps["Select l"] = '<S-Right>'
" let g:VM_maps["Select h"] = '<S-Left>'

let g:VM_mouse_mappings = 1    " Equivalent to following mappings
" nmap   <C-LeftMouse>       <Plug>(VM-Mouse-Cursor)
" nmap   <C-RightMouse>      <Plug>(VM-Mouse-Word)
" nmap   <M-C-RightMouse>    <Plug>(VM-Mouse-Column)

"

" Home-row shortcut for escape key
" cnoremap kj <esc>
" inoremap kj <esc>
" vnoremap kj <esc>

"  Overrides

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

"

