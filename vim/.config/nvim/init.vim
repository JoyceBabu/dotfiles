" vim: filetype=vim fdm=marker foldenable sw=4 ts=4 sts=4
" "zo" to open folds, "zc" to close, "zn" to disable, "zi" to toggle

" {{{ Initialization

" Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

source ~/.config/nvim/basic.vim

" Declare group for autocmd for whole init.vim, and clear it
" Otherwise every autocmd will be added to group each time vimrc sourced!
augroup vimrc
  autocmd!
augroup END

" }}}

" {{{ Vim Plug Auto Setup

" if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
"   silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
"     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"   silent !mkdir -p ~/.vim/autoload
"   silent !ln -fs ~/.local/share/nvim/site/autoload/plug.vim ~/.vim/autoload/plug.vim
"   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
" endif
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" }}}

" {{{ Load Plugins

call plug#begin('~/.local/share/nvim/plugged')

if has('nvim')
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-neorg/neorg'
  Plug 'nvim-telescope/telescope.nvim'
endif

" Theme
Plug 'mhartington/oceanic-next'        " Dark Theme
Plug 'gruvbox-community/gruvbox', {'as': 'grubox'} " Gruvbox Theme
Plug 'dracula/vim', {'as': 'dracula'}  " Dracula Theme
Plug 'jeffkreeftmeijer/vim-dim', { 'branch': '1.x' }
Plug 'doums/darcula'
" Plug 'TaDaa/vimade'                    " Fade vim window on focus lose

Plug 'tpope/vim-surround'              " Surround plugin
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'            " Better code commenting
Plug 'tpope/vim-sensible'              " Sensible defaults for vim
Plug 'wincent/terminus'
Plug 'suy/vim-context-commentstring'   " Context aware commentstring in mixed code

" Syntax
Plug 'StanAngeloff/php.vim'            " Better syntax highlighting for PHP
Plug 'ollykel/v-vim'				   " Syntax support for vlang
" Plug 'stephpy/vim-php-cs-fixer'        " PHP CS Fixer
Plug 'AndrewRadev/splitjoin.vim' , { 'on': ['SplitjoinSplit', 'SplitjoinJoin']}
" Plug 'rayburgemeestre/phpfolding.vim'
Plug 'swekaj/php-foldexpr.vim', { 'for' :'php' } " Enable code folding for PHP
Plug 'phpactor/phpactor', {'for': 'php', 'tag': '*', 'do': 'composer install --no-dev -o'}

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
Plug 'junegunn/gv.vim'
" Plug 'jreybert/vimagit'
Plug 'shumphrey/fugitive-gitlab.vim'   " for :Gbrowse
Plug 'airblade/vim-gitgutter', { 'on': ['GitGutterEnable', 'GitGutterDisable'] } " Git integration in gutter

" File Management
Plug 'junegunn/fzf', {
      \ 'dir': '~/.fzf',
      \ 'do': './install --all --no-update-rc'
      \}
Plug 'junegunn/fzf.vim'
Plug 'jesseleite/vim-agriculture'      " Allow passing flags in :Ag
Plug 'justinmk/vim-dirvish'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'ryanoasis/vim-devicons'
Plug 'wsdjeg/vim-fetch'                " Handle line & col no in filename
Plug 'lambdalisue/suda.vim'            " Write file with sudo
Plug 'editorconfig/editorconfig-vim'   " Support for EditorConfig

" Navigation
Plug 'christoomey/vim-tmux-navigator'
Plug 'mg979/vim-visual-multi', {'branch': 'master'} " Multi cursor support

" Autocomplete
Plug 'neoclide/coc.nvim', { 'branch': 'release','do': ':CocInstall coc-diagnostic coc-tsserver coc-json coc-tabnine coc-pairs coc-yaml coc-phpactor coc-highlight coc-git coc-snippets' }
" Plug 'SirVer/ultisnips'
Plug 'github/copilot.vim'

" Editing
Plug 'mbbill/undotree'                 " Visualize undo tree
Plug 'michaeljsmith/vim-indent-object' " Text objects for indentation level
Plug 'vim-scripts/argtextobj.vim'

" Debugging
Plug 'vim-vdebug/vdebug'

call plug#end()

" }}}

" {{{ Configure Plugins

if has('nvim')
  lua require('neorg-cfg')
  lua require('treesitter-cfg')
endif

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

function! s:handle_cr()
    if pumvisible()
        " if completion window is visible, accept selection
        return coc#_select_confirm()
    elseif index(['{}', '[]', '()'], getline(".")[col(".")-2:col(".")-1]) >= 0
        " if we are inside empty matching brackets, inset newline and indent
        return "\<cr>\<esc>\O"
    else
        " Break undo level and insert <CR>
        return "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
    endif
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr> <S-Tab> pumvisible() ? '<C-p>' : '<S-Tab>'
inoremap <silent><expr> <cr> <SID>handle_cr()

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

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

  if has("nvim")
    autocmd FileType fzf tunmap <buffer> <Esc>
  endif
augroup end

" }}}

" {{{ phpactor

augroup vimrc
  au FileType php nmap ,gd :call phpactor#GotoDefinition()<CR>
  au FileType php nmap ,c :call phpactor#ContextMenu()<CR>
  au FileType php nmap ,i :call phpactor#OffsetTypeInfo()<CR>
augroup end

" }}}

" autocmd vimrc BufWritePost *.php silent! call PhpCsFixerFixFile()

" }}}

" {{{ vlang

let g:v_autofmt_bufwritepre = 1        " Auto format on save

" }}}

" }}}

" {{{ Project / Session

" {{{ Workspace

let g:workspace_session_directory = $HOME . '/.cache/vim/sessions/'
let g:workspace_persist_undo_history = 1
let g:workspace_undodir='.undodir'
let g:workspace_session_disable_on_args = 1

" }}}

" {{{ Undo History

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

" {{{ User Interface

let g:vimade = {}
let g:vimade.usecursorhold=1
let g:vimade.fadelevel = 0.8
let g:lens#width_resize_max = 80
let g:lens#disabled_filetypes = ['nerdtree', 'fzf', 'netrw']
" let g:vimade.enablesigns = 1

" {{{ Git Integration

let g:fugitive_gitlab_domains = ['https://git.ennexa.org']

" }}}

" {{{ Theme

" OceanicNext Theme
let g:airline_theme='gruvbox'
let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1

set background=dark
colorscheme gruvbox
" colorscheme darcula
" colorscheme dim

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

" Disable vim->tmux navigation when the Vim pane is zoomed in tmux
let g:tmux_navigator_disable_when_zoomed = 1

nnoremap <silent> gz :ZoomToggle<CR>

" }}}

" }}}

" {{{ Debugging

let g:vdebug_options = {'ide_key': 'xdebug'}
let g:vdebug_options = {'break_on_open': 0}
let g:vdebug_options = {'server': '127.0.0.1'}
let g:vdebug_options = {'port': '10000'}

" }}}

" {{{ File Management

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

" {{{ Command Line Modes

" Save files as root
cnoremap w!! execute ':w suda://%'

" }}}

" {{{ Custom Mappings

" Execute current line in $SHELL and replace it with the output
noremap Q !!$SHELL<cr>

" {{{ Vim Visual Multi

let g:VM_theme = 'iceblue'
let g:VM_highlight_matches = 'underline'

let g:VM_maps = {}
let g:VM_maps["Undo"]            = 'u'
let g:VM_maps["Redo"]            = '<C-r>'
let g:VM_maps["Add Cursor Down"] = '<M-j>'   " new cursor down
let g:VM_maps["Add Cursor Up"]   = '<M-k>'   " new cursor up
let g:VM_maps["Toggle Mappings"] = '<CR>'    " toggle VM buffer mappings
let g:VM_maps["Exit"]            = '<C-c>'   " quit VM
let g:VM_maps['Select All']      = '<M-n>'
let g:VM_maps['Visual All']      = '<M-n>'
" let g:VM_maps["Select l"] = '<S-Right>'
" let g:VM_maps["Select h"] = '<S-Left>'

let g:VM_mouse_mappings = 1    " Equivalent to following mappings
" nmap   <C-LeftMouse>       <Plug>(VM-Mouse-Cursor)
" nmap   <C-RightMouse>      <Plug>(VM-Mouse-Word)
" nmap   <M-C-RightMouse>    <Plug>(VM-Mouse-Column)

" }}}

" Home-row shortcut for escape key
" cnoremap kj <esc>
" inoremap kj <esc>
" vnoremap kj <esc>

nnoremap <leader>ps :GFiles<CR>

" }}}

" {{{ Overrides

if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

" }}}

