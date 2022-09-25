" vim: fdm=marker foldenable sw=4 ts=4 sts=4
" "zo" to open folds, "zc" to close, "zn" to disable, "zi" to toggle

" {{{ Initialization

" Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

" Declare group for autocmd for whole init.vim, and clear it
" Otherwise every autocmd will be added to group each time vimrc sourced!
augroup vimrc_basic
  autocmd!
augroup END

" }}}

" {{{ Basic Settings

let mapleader = ','
" let maplocallseader = ','

set updatetime=300

syntax on                        " Enable colour syntax highlighting
filetype indent on               " Enable loading of plugin files
filetype plugin on               " Enable loading of indent files

" }}}

" {{{ User Interface

set number relativenumber        " Enable display of relative line number
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
set conceallevel=1

set termguicolors
if has('mac') && $COLORTERM == '' && !has('gui_vimr') && !has('gui_running')
  set t_Co=256
  set notermguicolors
endif

if has("nvim-0.5.0") || has("patch-8.1.1564")
  set signcolumn=number          " Merge signcolumn and number column into one
else
  set signcolumn=yes             " Always show sign colum to prevent resize
endif

set background=dark

" {{{ Word Wrap

" Indents word-wrapped lines as much as the parent line
set breakindent
" Ensures word-wrap does not split words
set formatoptions=l
set lbr
if has('multi_byte') && &encoding ==# 'utf-8'
  set showbreak=↪\ \ \
else
  " Some vim versions does not support multi-byte
  set showbreak=...\ \ \
endif

" }}}

" {{{ Windows / Tabs

set splitbelow splitright        " Split windows more intuitively.

" Rebalance windows on vim resize when tmux panes are created/destroyed/resized
autocmd vimrc_basic VimResized * :wincmd =

" zoom a vim pane, <C-w>= to re-balance
nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>

augroup vimrc_basic
  if has("nvim")
    " Disable line number in builtin terminal
    autocmd TermOpen * setlocal nonumber norelativenumber
    " Escape from terminal
    autocmd TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
  endif
augroup end

" {{{ Tmux/Vim seamless window navigation

function! TmuxMove(direction)
  let wnr = winnr()
  silent! execute 'wincmd ' . a:direction
  " If the winnr is still the same after we moved, it is the last pane
  if wnr == winnr()
    call system('tmux select-pane -' . tr(a:direction, 'phjkl', 'lLDUR'))
  end
endfunction

nnoremap <silent> <C-h> :call TmuxMove('h')<cr>
nnoremap <silent> <C-j> :call TmuxMove('j')<cr>
nnoremap <silent> <C-k> :call TmuxMove('k')<cr>
nnoremap <silent> <C-l> :call TmuxMove('l')<cr>

" }}}

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

let g:netrw_liststyle = 3    " Show tree style directory list
" let g:netrw_banner = 0       " Hide directory banner
let g:netrw_winsize = 25     " Width of the netrw split
let g:netrw_preview   = 1
let g:netrw_browse_split = 4 " Open file in previous window
let g:netrw_altv = 1         " Open file in left right split when pressing v
let g:netrw_list_hide = '\.sw[op]$'

" }}}

" {{{ FileType Overrides

autocmd vimrc_basic FileType php setlocal commentstring=//\ %s
autocmd vimrc_basic FileType yaml setlocal shiftwidth=2 softtabstop=2

" }}}

" {{{ Custom Mappings

" Quick edit $MYVIMRC
nnoremap ,ve :vsp $MYVIMRC<cr>
nnoremap ,vr :source $MYVIMRC<cr>

" Bash like keys for the insert/command line mode
inoremap <C-a> <Home>
inoremap <C-b> <Left>
inoremap <C-d> <Delete>
inoremap <C-e> <End>
inoremap <C-f> <Right>
" inoremap <C-h> <Backspace>
" inoremap <C-k> <C-U>
inoremap <C-y> <C-r>+
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
" cnoremap <C-k> <C-o>D

" Indent without killing the selection in vmode
vmap < <gv
vmap > >gv

noremap H ^
noremap L $

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

cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
" cnoremap $$ <C-R>=fnameescape(expand('%'))<cr>
map <leader>E :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Apply a macro line by line on the selected range in visual block mode
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

" }}}

" {{{ Custom Commands

" {{{ Pipe - Pipe the selected range to an extenal command and
" display the output in a new buffer

if !has('ide')
  " eg `:Pipe sort | uniq -c`
  command! -range -nargs=+ Pipe call Pipe(<q-args>, <line1>, <line2>)
endif

function! Pipe(cmd, line1, line2) abort
  let lines = getline(a:line1, a:line2)
  let res = systemlist(a:cmd, lines)
  if empty(res)
    echomsg 'Empty output'
    return
  endif
  new
  call setline(1, res)
endfunction

" }}}

" {{{ ZoomToggle - Zoom / Restore window.

command! ZoomToggle call s:ZoomToggle()

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

" }}}

" {{{ Copy to Local Clipboard Using OSC52
" https://github.com/greymd/oscyank.vim

let s:save_cpo = &cpo
set cpo&vim

function! s:OscyankPut(text)
  let encodedText=""
  " `tty` works in vim, `tty < /proc/$$PID/fd/0` is required for neovim per
  " https://github.com/neovim/neovim/issues/8450#issuecomment-407063983)
  let tty = exists('g:tty') ? shellescape(g:tty) : system('(tty || tty </proc/$PPID/fd/0 || echo /dev/tty) 2>/dev/null | grep /dev/')
  if $TMUX != ""
    let encodedText=substitute(a:text, '\', '\\', "g")
  else
    let encodedText=substitute(a:text, '\', '\\\\', "g")
  endif
  let encodedText=substitute(encodedText, "\'", "'\\\\''", "g")
  let executeCmd="echo -n '".encodedText."' | base64 | tr -d '\\n'"
  let encodedText=system(executeCmd)
  if $TMUX != ""
    " tmux
    let executeCmd='echo -en "\033Ptmux;\033\033]52;;'.encodedText.'\033\033\\\\\033\\"'
  elseif $TERM == "screen"
    " screen
    let executeCmd='echo -en "\033P\033]52;;'.encodedText.'\007\033\\"'
  else
    let executeCmd='echo -en "\033]52;;'.encodedText.'\033\\"'
  endif
  call system(executeCmd . ' > ' . tty)
  redraw!
endfunction

" Yank register's content with OSC.
function! s:OscyankRegister()
  let text = @"           " Put current register's content to 'text'
  call s:OscyankPut(text) " Put text with OSC52
endfunction

" Yank selected content with OSC.
function! s:Oscyank() range
  let tmp = @@            " Backup register.
  silent normal gvy       " Yank current selected line.
  let text = @@           " Put current register's content to 'text'
  let @@ = tmp            " Restore original register.
  call s:OscyankPut(text) " Put text with OSC52
endfunction

function s:ToggleClipboard() abort
  if execute('autocmd TextYankPost') =~# 's:OscyankRegister'
    augroup Yank
      autocmd!
    augroup END
    echo 'OSC52 clipboardy copy disabled'
  else
    augroup Yank
      autocmd!
      autocmd TextYankPost * if v:event.operator ==# 'y' | call s:OscyankRegister() | endif
    augroup END
    echo 'OSC52 clipboardy copy enabled'
  endif
endfunction

command! -range Oscyank call s:Oscyank()
command! OscyankRegister call s:OscyankRegister()
command ToggleClipboard call s:ToggleClipboard()

let &cpo = s:save_cpo
unlet s:save_cpo

" }}}

" }}}
