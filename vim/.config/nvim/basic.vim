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

let mapleader = ' '
let maplocallseader = ' '

set updatetime=250

if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif

if has('autocmd')
  filetype on                    " Enable filetype detection
  filetype plugin on             " Enable loading of filetype plugins
  filetype indent on             " Enable loading of indent files
endif

" }}}

" {{{ User Interface

set number relativenumber        " Enable display of relative line number
set colorcolumn=81               " Show a vertical line after 80 chars
set cursorline                   " Highlight current line
set showcmd
" set showmatch                  " highlight matching [{()}]
" set matchtime=0
set hidden
set cmdheight=2
set shortmess=filnxtToOF
set history=10000                " Keep 10000 lines of command line history
set lazyredraw                   " Avoid unnecessary UI redraw
set mouse=a                      " Enable mouse interaction in all modes
set belloff=all
set conceallevel=1
set cdpath=,.,~/src,~/

if has("nvim-0.5.0") || has("patch-8.1.1564")
  set signcolumn=number          " Merge signcolumn and number column into one
else
  set signcolumn=yes             " Always show sign colum to prevent resize
endif

" Disable a legacy behavior that can break plugin maps.
if has('langmap') && exists('+langremap') && &langremap
  set nolangremap
endif

set nojoinspaces
set background=dark
set laststatus=2
set ruler

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

augroup vimrc_basic
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup end

" }}}

" {{{ Windows / Tabs

"set splitbelow splitright        " Split windows more intuitively.

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
set smarttab
set nrformats-=octal             " Increment 007 to 008, not 010
" set spell
" set spelllang=en
" set complete-=i                " Scan current & included files for completion
"set clipboard=unnamed,unnamedplus
"set clipboard=unnamed
set complete=.,w,b,u,t
set diffopt=internal,filler

if exists(":DiffOrig") != 2
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_
        \ | diffthis | wincmd p | diffthis
endif

" Correctly highlight $() and other modern affordances in filetype=sh.
if !exists('g:is_posix') && !exists('g:is_bash') && !exists('g:is_kornshell') && !exists('g:is_dash')
  let g:is_posix = 1
endif

" }}}

" {{{ Code Navigation

" imap <S-Tab> <plug>(fzf-complete-line)
set incsearch
set nohlsearch ignorecase        " disable highlight searches, incsearch plugin does this
set smartcase                    " Enable case sensitivity if term is mixed case
set nostartofline                " prevent cursor from moving when scrolling
set switchbuf=useopen,usetab     " better behavior for the quickfix window and :sb
set scrolloff=8
set sidescroll=1                 " Scroll horizontally when wordwrap is disabled
set sidescrolloff=5              " and cursor is 5 chars away from the edge
set display+=lastline
set autoread                     " Auto reload file on external change
set tabpagemax=50
set viminfo^=!

if v:version > 703
  set formatoptions+=j " Delete comment character when joining commented lines
endif

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

" Saving options in session and view files causes more problems than it
" solves, so disable it.
set sessionoptions-=options
set viewoptions-=options

function! NetrwMapping()
    " noremap <buffer> <C-l> <C-W>l
    " noremap <buffer> <C-h> <C-W>h

    let g:netrw_liststyle = 3    " Directory tree view. Cycle with i
    " let g:netrw_banner = 0     " Hide directory banner
    " let g:netrw_winsize = 50     " Width of the netrw split
    let g:netrw_preview   = 1
    " let g:netrw_browse_split = 4 " Open file in previous window
    let g:netrw_sort_sequence = '[\/]$,*'
    let g:netrw_altv = 1         " Open file in left right split when pressing v

    let g:netrw_list_hide= '.*.swp$,
            \ *.pyc$,
            \ *.log$,
            \ *.o$,
            \ *.xmi$,
            \ *.sw[op]$,
            \ *.bak$,
            \ *.pyc$,
            \ *.class$,
            \ *.jar$,
            \ *.war$,
            \ *__pycache__*'
endfunction

autocmd vimrc_basic FileType netrw call NetrwMapping()
" Press ? for quick help in netrw window
autocmd vimrc_basic FileType netrw nnoremap ? :help netrw-quickmap<CR>

" }}}

" {{{ FileType Overrides

autocmd vimrc_basic FileType php setlocal commentstring=//\ %s
autocmd vimrc_basic FileType yaml setlocal shiftwidth=2 softtabstop=2

" }}}

" {{{ Custom Mappings

" Browse in separate window. Requires g:netrw_browse_split = 4
" Also need to experiment with g:netrw_chgwin to use both :Exp and :Lex
" nnoremap <leader>9 :Lex \| vertical resize 35<cr>
nnoremap <leader>9 :execute exists("w:netrw_rexlocal")?":Rexplore":":Explore"<cr>

" Experimental Mappings
nnoremap <leader>/ :nohlsearch<CR>

" Quick edit $MYVIMRC
nnoremap <leader>ve :vsp $MYVIMRC<cr>
nnoremap <leader>vr :source $MYVIMRC<cr>

" Bash like keys for the insert/command line mode
" https://github.com/tpope/vim-rsi/blob/master/plugin/rsi.vim
inoremap <C-a> <Home>
inoremap <C-x><C-a> <C-a>
inoremap <C-b> <Left>
inoremap <C-d> <Delete>
" inoremap <C-e> <End>
inoremap <expr> <C-E> col('.')>strlen(getline('.'))<bar><bar>pumvisible()?"\<Lt>C-E>":"\<Lt>End>"
inoremap <C-f> <Right>
" inoremap <C-h> <Backspace>
" inoremap <C-k> <C-U>
inoremap <C-y> <C-r>+
cnoremap <C-a> <Home>
cnoremap   <C-x><C-a> <C-a>
cnoremap <C-e> <End>
" Add an undo point before deleting, to prevent accidental data loss
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

" cnoremap <C-k> <C-o>D

" Indent without killing the selection in vmode
vmap < <gv
vmap > >gv
" Select last pasted text
nnoremap <expr> gvp '`[' . strpart(getregtype(), 0, 1) . '`]'
" Reselect last pasted text
nnoremap gp `[v`]

noremap H ^
noremap L $

" Retain cursor position when joining lines
noremap J mzJ`z
" Center cursor
noremap <C-d> <C-d>zz
noremap <C-u> <C-u>zz
" Center cursor and open folds
noremap n nzzzv
noremap N Nzzzv

" Replace selection with last yanked text without modifying unnamed registers
vnoremap <leader>p "_dP
" Delete without modifying unnamed registers
nnoremap <leader>d "_d
vnoremap <leader>d "_d
" Yank to system clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y

nnoremap <leader>bs /<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>
nnoremap <leader>pv :Lex<CR>

cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
" cnoremap $$ <C-R>=fnameescape(expand('%'))<cr>
map <leader>E :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" Search/Replace word under cursor
nnoremap <leader>h :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

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

if !has('ide')
  " If not IdeaVim

  let s:save_cpo = &cpo
  set cpo&vim

  function! s:OscYankPut(text)
    let length = strlen(a:text)
	let limit = 10000
    if length > limit
      echohl WarningMsg
      echo '[OscYank] Selection has length ' . length . ', limit is ' . limit
      echohl None
      return
    endif

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

  " Yank selected content with OSC.
  function! s:OscYank() range
    let tmp = @@            " Backup register.
    silent normal gvy       " Yank current selected line.
    let text = @@           " Put current register's content to 'text'
    let @@ = tmp            " Restore original register.
    call s:OscYankPut(text) " Put text with OSC52
  endfunction

  function s:ToggleClipboard() abort
    augroup Yank
      autocmd!

      if execute('autocmd TextYankPost') !~# 's:OscYankPut'
        autocmd TextYankPost * if v:event.operator ==# 'y' && v:event.regname ==# '+' | call s:OscYankPut(getreg(v:register)) | endif
        echo '[OscYank] clipboardy copy enabled'
      else
        echo '[OscYank] clipboardy copy disabled'
      endif
    augroup END
  endfunction

  command! -range OscYank call s:OscYank()
  command ToggleClipboard call s:ToggleClipboard()

  if $JB_ENV_DIR != ""
    call s:ToggleClipboard()
  endif

  let &cpo = s:save_cpo
  unlet s:save_cpo

endif

" }}}

" }}}

" {{ Neovim Compatibility
" https://github.com/mikeslattery/nvim-defaults.vim/blob/main/plugin/.vimrc

if exists('g:loaded_nvim_defaults')
  finish
endif

let g:loaded_nvim_defaults = 1

if has('nvim')
  function! Stdpath(id)
    return stdpath(a:id)
  endfunction

  command! MapQ :
  finish
endif

if &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=50
endif

let &keywordprg=":Man"
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
set listchars=tab:>\ ,trail:-,nbsp:+
set maxcombine=6
set scroll=13
set tags=./tags;,tags
set notitle
set titleold=

set ttyfast

let &viminfo='!,'.&viminfo
let &wildoptions="pum,tagfile"
let g:vimsyn_embed='l'

" These don't always necessarily exist in Neovim,
" but are convenient to have for Stdpath()

if ! exists('$NVIM_APPNAME')
    let $NVIM_APPNAME = 'nvim'
endif

if ! exists('$XDG_CACHE_HOME')
  if has('win32')
    let $XDG_CACHE_HOME=$TEMP
  else
    let $XDG_CACHE_HOME=$HOME . '/.cache'
  endif
endif

if ! exists('$XDG_CONFIG_HOME')
  if has('win32')
    let $XDG_CONFIG_HOME=$LOCALAPPDATA
  else
    let $XDG_CONFIG_HOME=$HOME . '/.config'
  endif
endif

if ! exists('$XDG_DATA_HOME')
  if has('win32')
    let $XDG_DATA_HOME=$LOCALAPPDATA
  else
    let $XDG_DATA_HOME=$HOME . '/.local/share'
  endif
endif

" Similar to nvim's stdpath(id)
" Unfortunately, user functions can't use lowercase
function! Stdpath(id)
  if a:id == 'data'
    if has('win32')
      return $XDG_DATA_HOME . '/' . $NVIM_APPNAME . '-data'
    else
      return $XDG_DATA_HOME . '/' . $NVIM_APPNAME
    endif
  elseif a:id == 'data_dirs'
    return []
  elseif a:id == 'config'
    return $XDG_CONFIG_HOME . '/' . $NVIM_APPNAME
  elseif a:id == 'config_dirs'
    return []
  elseif a:id == 'cache'
    return $XDG_CACHE_HOME . '/' . $NVIM_APPNAME
  else
    throw '"' . a:id . '" is not a valid stdpath'
  endif
endfunction

let s:datadir   = Stdpath('data')
let s:configdir = Stdpath('config')

" backupdir isn't set exactly like Neovim, because it's odd.
let &backupdir = s:datadir . '/backup//'
let &viewdir   = s:datadir . '/view//'
if ! executable('nvim')
  let &directory = s:datadir . '/swap//'
  let &undodir   = s:datadir . '/undo//'
else
  " Vim/Neovim have different file formats
  let &directory = s:datadir . '/vimswap//'
  let &undodir   = s:datadir . '/vimundo//'
endif

let s:shadadir   = s:datadir  . '/shada'
let &viminfofile.= s:shadadir . '/viminfo'

" Neovim creates directories if they don't exist
function! s:MakeDirs()
  for dir in [&backupdir, &directory, &undodir, &viewdir, s:shadadir]
    call mkdir(dir, "p")
  endfor
endfunction
autocmd VimEnter * call s:MakeDirs()

" Add user config dirs to search paths
function! s:fixpath(path)
  let l:pathprefix  = s:configdir . ',' . s:datadir . '/site,'
  let l:pathpostfix = ',' . s:datadir . '/site/after,' . s:configdir . '/after'
  let l:fullpath = l:pathprefix . a:path . l:pathpostfix
  " Remove .vim
  return substitute(l:fullpath, ','.$HOME.'\/\.vim\(/after\)\?', '', 'g')
endfunction

let &packpath     = s:fixpath(&packpath)
let &runtimepath  = s:fixpath(&runtimepath)

" Implement Q
let g:qreg='@'
function! RecordOrStop()
  if reg_recording() == ''
    echo 'Enter register to record to: '
    let g:qreg=getcharstr()
    if g:qreg != "\e"
      execute 'normal! q'.g:qreg
    endif
  else
    normal! q
    call setreg(g:qreg, substitute(getreg(g:qreg), "q$", "", ""))
  endif
endfunction

" :MapQ will activate the Q mapping
command! MapQ noremap q <cmd>call RecordOrStop()<cr>
noremap Q <cmd>execute 'normal! @'.g:qreg<cr>

" Builtin Pluign. Hit `%` on `if` to jump to `else`.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime macros/matchit.vim
endif
if exists(":Man") != 2
  runtime! ftplugin/man.vim      " Enable the :Man command
endif

" If this is the .vimrc, not a plugin, then load init.vim
if $MYVIMRC == expand('<sfile>:p')
  let $MYVIMRC = s:configdir . '/init.vim'
  source $MYVIMRC
endif
