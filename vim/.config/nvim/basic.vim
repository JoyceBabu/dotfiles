" vim: fdm=marker foldenable sw=4 ts=4 sts=4
" "zo" to open folds, "zc" to close, "zn" to disable, "zi" to toggle

" {{{ Initialization

set nocompatible

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

if has('nvim')
  " Highlight yanked text
  autocmd vimrc_basic TextYankPost * silent! lua vim.highlight.on_yank()
endif

" Disable a legacy behavior that can break plugin maps.
if has('langmap') && exists('+langremap') && &langremap
  set nolangremap
endif

set nojoinspaces
set laststatus=2
set ruler

" {{{ Default theme

function! SetupColors()
  if ($TERM =~ '256color' || &term =~ '256color') && has('termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
  endif
endfunction

autocmd vimrc_basic VimEnter * call SetupColors()
call SetupColors()

set background=dark
if &background == "dark"
    highlight ColorColumn guibg=darkgrey ctermbg=235
else
    highlight ColorColumn guibg=lightgrey ctermbg=252
endif

if ($TERM =~ '256' || &t_Co >= 256) || has("gui_running")
    " Main text and background
    hi Normal ctermbg=17 ctermfg=15 cterm=NONE guibg=#1e1e2e guifg=#f8f8f8 gui=NONE
    hi NonText ctermfg=8 guifg=#585b70

    " Syntax groups
    hi Comment ctermfg=8 guifg=#585b70
    hi Constant ctermfg=19 guifg=#0099e6
    hi String ctermfg=11 guifg=#f5e0dc
    hi Identifier ctermfg=215 guifg=#f99058
    hi Function ctermfg=215 guifg=#7aa2f7
    hi Statement ctermfg=122 guifg=#00ccff
    hi Keyword ctermfg=122 guifg=#00ccff
    hi Operator ctermfg=206 guifg=#f77fbe
    hi PreProc ctermfg=206 guifg=#f77fbe
    hi Include ctermfg=200 guifg=#f5c2e7
    hi Type ctermfg=122 guifg=#00ccff
    hi Special ctermfg=200 guifg=#f5c2e7
    hi Error ctermfg=88 guifg=#790914
    hi Todo ctermfg=88 guifg=#790914

    " UI elements
    hi LineNr ctermfg=25 guifg=#77AAFF
    hi CursorLine ctermbg=8 ctermfg=122 guibg=#292e42
    hi CursorLineNr ctermbg=8 ctermfg=122 guibg=#292e42 guifg=#ff9e64
    hi Search ctermbg=215 ctermfg=17 guibg=#f99058 guifg=#1e1e2e
    hi IncSearch ctermbg=206 ctermfg=8 guibg=#f77fbe guifg=#585b70
    hi Visual ctermbg=8 ctermfg=122 guibg=#585b70 guifg=#00ccff
    hi MatchParen ctermfg=215 guifg=#f99058
    hi StatusLine ctermbg=19 ctermfg=17 guibg=#0099e6 guifg=#1e1e2e
    hi StatusLineNC ctermbg=25 ctermfg=17 guibg=#77AAFF guifg=#1e1e2e
    hi VertSplit ctermfg=206 guifg=#f77fbe
    hi Pmenu ctermfg=25 guifg=#77AAFF
    hi PmenuSel ctermbg=25 ctermfg=17 guibg=#77AAFF guifg=#1e1e2e
    hi Folded ctermfg=19 guifg=#7aa2f7 guibg=#3b4261

    " Diff highlighting
    hi DiffAdd ctermfg=15 guifg=#f8f8f8
    hi DiffChange ctermfg=11 guifg=#f5e0dc
    hi DiffDelete ctermfg=88 guifg=#701c1c
    hi DiffText ctermfg=215 guifg=#f99058

elseif &t_Co == 8 || $TERM !~# '^linux' || &t_Co == 16
    set t_Co=16

    " Main text and background
    hi Normal ctermbg=black ctermfg=white cterm=NONE
    hi NonText ctermbg=black ctermfg=darkgray cterm=NONE

    " Syntax groups
    hi Comment ctermbg=black ctermfg=darkgray cterm=NONE
    hi Constant ctermbg=black ctermfg=lightblue cterm=NONE
    hi String ctermbg=black ctermfg=yellow cterm=NONE
    hi Identifier ctermbg=black ctermfg=orange cterm=NONE
    hi Function ctermbg=black ctermfg=orange cterm=NONE
    hi Statement ctermbg=black ctermfg=cyan cterm=NONE
    hi Keyword ctermbg=black ctermfg=cyan cterm=NONE
    hi Operator ctermbg=black ctermfg=rose cterm=NONE
    hi PreProc ctermbg=black ctermfg=rose cterm=NONE
    hi Include ctermbg=black ctermfg=pink cterm=NONE
    hi Type ctermbg=black ctermfg=cyan cterm=NONE
    hi Special ctermbg=black ctermfg=pink cterm=NONE
    hi Error ctermbg=black ctermfg=darkred cterm=NONE
    hi Todo ctermbg=black ctermfg=darkred cterm=NONE

    " UI elements
    hi LineNr ctermbg=black ctermfg=blue cterm=NONE
    hi CursorLine ctermbg=darkgray ctermfg=cyan cterm=NONE
    hi CursorLineNr ctermbg=darkgray ctermfg=cyan cterm=NONE
    hi Search ctermbg=orange ctermfg=black cterm=NONE
    hi IncSearch ctermbg=rose ctermfg=darkgray cterm=NONE
    hi Visual ctermbg=darkgray ctermfg=cyan cterm=NONE
    hi MatchParen ctermbg=black ctermfg=orange cterm=NONE
    hi StatusLine ctermbg=lightblue ctermfg=black cterm=NONE
    hi StatusLineNC ctermbg=blue ctermfg=black cterm=NONE
    hi VertSplit ctermbg=black ctermfg=rose cterm=NONE
    hi Pmenu ctermbg=black ctermfg=blue cterm=NONE
    hi PmenuSel ctermbg=blue ctermfg=black cterm=NONE

    " Diff highlighting
    hi DiffAdd ctermbg=black ctermfg=white cterm=NONE
    hi DiffChange ctermbg=black ctermfg=yellow cterm=NONE
    hi DiffDelete ctermbg=black ctermfg=red cterm=NONE
    hi DiffText ctermbg=black ctermfg=orange cterm=NONE
endif

" Common links
hi link Number Constant
hi link Boolean Constant
hi link Float Number
hi link Conditional Statement
hi link Repeat Statement
hi link Label Statement
hi link Exception Statement
hi link Define PreProc
hi link Macro PreProc
hi link PreCondit PreProc
hi link StorageClass Type
hi link Structure Type
hi link Typedef Type
hi link Tag Special
hi link SpecialChar Special
hi link Delimiter Special
hi link SpecialComment Special
hi link Debug Special
hi link StatusLineTerm StatusLine
hi link StatusLineTermNC StatusLineNC

" }}}

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

" {{{ Buffers / Windows / Tabs

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
  autocmd FileType qf nnoremap <buffer> q :ccl<CR>
  autocmd FileType qf nnoremap <buffer> p <CR>zz<C-w>p
  autocmd FileType qf nmap <buffer> J jp
  autocmd FileType qf nmap <buffer> K kp
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
inoremap <silent> <C-j> :call TmuxMove('j')<cr>
inoremap <silent> <C-l> :call TmuxMove('l')<cr>

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
set timeoutlen=500
" set spell
" set spelllang=en
" set complete-=i                " Scan current & included files for completion
"set clipboard=unnamed,unnamedplus
"set clipboard=unnamed
set complete=.,w,b,u,t
if has("nvim")
  set diffopt=internal,filler
endif

if exists(":DiffOrig") != 2
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_
        \ | diffthis | wincmd p | diffthis
endif

" Correctly highlight $() and other modern affordances in filetype=sh.
if !exists('g:is_posix') && !exists('g:is_bash') && !exists('g:is_kornshell') && !exists('g:is_dash')
  let g:is_posix = 1
endif

" Abbreviations

" We have to use <c-o>i since <Left> is disabled
:autocmd FileType php
  \ :iabbrev <buffer> <?php= <?php<cr><cr>declare(strict_types=1);<cr><cr>namespace ;<c-o>i
autocmd Filetype gitcommit setlocal spell textwidth=72

" {{{ Text Objects

" {{{ Indentation

function! IndentObj(skipblank, header, footer) abort
  let line = nextnonblank('.')
  let level = indent(line)
  let start = line | let end = line
  while start > 1 && !(getline(start - 1) =~ '\S' ? indent(start - 1) < level : !a:skipblank)
    let start -= 1
  endwhile

  let start = a:header ? prevnonblank(start - 1) : nextnonblank(start)
  while end < line('$') && !(getline(end + 1) =~ '\S' ? indent(end + 1) < level : !a:skipblank)
    let end += 1
  endwhile

  let end = a:footer ? nextnonblank(end + 1) : prevnonblank(end)
  " union of the current visual region and the block/paragraph containing the cursor
  if mode() =~# "[vV\<C-v>]"
    let start = min([start, line("'<")])
    let end = max([end, line("'>")])
    exe "normal! \<Esc>"
  endif

  if end - start > winheight(0) | exe "normal! m'" | endif
  exe start | exe 'normal! V' | exe end
endfunction

xnoremap <silent> ii :<C-U>exe 'normal! gv'\|call IndentObj(0,0,0)<CR>
onoremap <silent> ii :<C-u>call IndentObj(0,0,0)<CR>
xnoremap <silent> ai :<C-U>exe 'normal! gv'\|call IndentObj(0,1,1)<CR>
onoremap <silent> ai :<C-u>call IndentObj(0,1,1)<CR>

xnoremap <silent> iI :<C-U>exe 'normal! gv'\|call IndentObj(1,0,0)<CR>
onoremap <silent> iI :<C-u>call IndentObj(1,0,0)<CR>
xnoremap <silent> aI :<C-U>exe 'normal! gv'\|call IndentObj(1,1,1)<CR>
onoremap <silent> aI :<C-u>call IndentObj(1,1,1)<CR>

" }}}

" }}}

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

" Use :grep search_term to search recursively. Use :copen to view results.
" Search project files only when using :grep within a git repo
if trim(system('git rev-parse --is-inside-work-tree')) =~? '^true$'
    set grepprg=git\ --no-pager\ grep\ -n\ --column\ $*
else
    set grepprg=grep\ -nRI\ $*\ /dev/null
endif

if v:version > 703
  set formatoptions+=j " Delete comment character when joining commented lines
endif

augroup vimrc_basic
  autocmd BufLeave *.css,*.scss  normal! mC
  autocmd BufLeave *.js,*.ts     normal! mJ
  autocmd BufLeave *.php         normal! mP
  autocmd BufLeave *.sh          normal! mS
augroup END


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
set path=.,**

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

" {{{ Mapping: Vim Config

function! DropOrNewTab(filename, tabname)
  " Check if the buffer is already open
  let bufnum = bufnr(a:filename)
  if bufnum != -1
    " Buffer exists, use :drop to open it in the current window
    execute 'drop ' . a:filename
  else
    " Buffer does not exist, check if the tab with the given name exists
    let tabfound = 0
    for i in range(tabpagenr('$'))
      if gettabvar(i + 1, 'tabname', '') == a:tabname
        let tabfound = i + 1
        break
      endif
    endfor

    if tabfound
      execute tabfound . 'tabnext'
    else
      tabnew
      let tabnum = tabpagenr()
      call settabvar(tabnum, 'tabname', a:tabname)
      execute 'file ' . a:filename
    endif
    execute 'edit ' . a:filename
  endif
endfunction

" Quick edit $MYVIMRC
nnoremap <leader>ve :call DropOrNewTab($MYVIMRC, 'VimConfig')<CR>
nnoremap <leader>veb :call DropOrNewTab(expand('~/.config/nvim/basic.vim'), 'VimConfig')<CR>
"nnoremap <leader>veb :tabnew ~/.config/nvim/basic.vim<cr>
nnoremap <leader>vr :source $MYVIMRC<cr>

" }}}

" {{{ Mapping: Emacs/Bash keymap

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

" }}}

" {{{ Mapping: Search and Replace

" Experimental Mappings
nnoremap <leader>/ :nohlsearch<CR>

" Use * to search the current selection
vnoremap <silent> * "zy/<C-R>=@z<CR><CR>
nnoremap <leader>bs /<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>

" Search/Replace word under cursor
nnoremap <leader>h :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>


" Text object for next and last parens/brackets.
" Use xnoremap to enable the text objects for visual mode.
onoremap inb :<c-u>execute "normal! /(\r:noh\rvi("<CR>
onoremap ilb :<c-u>execute "normal! ?)\r:noh\rvi)"<CR>
onoremap anb :<c-u>execute "normal! /(\r:noh\rva("<CR>
onoremap alb :<c-u>execute "normal! ?)\r:noh\rva)"<CR>

onoremap inB :<c-u>execute "normal! /{\r:noh\rvi{"<CR>
onoremap ilB :<c-u>execute "normal! ?}\r:noh\rvi}"<CR>
onoremap anB :<c-u>execute "normal! /{\r:noh\rva{"<CR>
onoremap alB :<c-u>execute "normal! ?}\r:noh\rva}"<CR>

" }}}

" {{{ Mapping: Selection

" Indent without killing the selection in vmode
vmap < <gv
vmap > >gv
" Select last pasted text
nnoremap <expr> gvp '`[' . strpart(getregtype(), 0, 1) . '`]'
" Reselect last pasted text
nnoremap gp `[v`]

" }}}

" {{{ Mapping: Cursor Movement

noremap <leader>h ^
noremap <leader>l $

" Retain cursor position when joining lines
noremap J mzJ`z
" Center cursor
noremap <C-d> <C-d>zz
noremap <C-u> <C-u>zz
" Center cursor and open folds
noremap n nzzzv
noremap N Nzzzv

" }}}

" {{{ Mapping: Copy and Paste

" Replace selection with last yanked text without modifying unnamed registers
vnoremap <leader>p "_dP
nnoremap <leader>p "+p " Paste from clipboard
nnoremap <leader>P "+P " Paste from clipboard
" Delete without modifying unnamed registers
nnoremap <leader>d "_d
nnoremap <leader>D "_d
vnoremap <leader>d "_d
" Yank to system clipboard
nnoremap <leader>y "+y
nnoremap <leader>Y "+Y
vnoremap <leader>y "+y

" }}}

" {{{ Mapping: File Explorer

" Browse in separate window. Requires g:netrw_browse_split = 4
" Also need to experiment with g:netrw_chgwin to use both :Exp and :Lex
" nnoremap <leader>9 :Lex \| vertical resize 35<cr>
nnoremap <leader>9 :execute exists("w:netrw_rexlocal")?":Rexplore":":Explore"<cr>

nnoremap <leader>pv :Lex<CR>

cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
" cnoremap $$ <C-R>=fnameescape(expand('%'))<cr>
map <leader>E :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%
nnoremap <leader>fo :browse oldfiles<CR>
nnoremap gb :ls<CR>:b<Space>
nnoremap <leader>ff :find *
set wildcharm=<C-z>
nnoremap <leader>b :buffer <C-z><S-Tab>

" }}}

" {{{ Mapping: Vim Surround

" Vim surround emulation

function! SurroundDelete(old)
  let l:char = nr2char(a:old)
  execute "normal! di" . l:char . "va" . l:char . "p`["
endfunction

nnoremap <silent>ds :call SurroundDelete(getchar())<CR>

" }}}

" {{{ Mapping: Vim Commentary

function! s:commentOp(...)
  '[,']call s:toggleComment()
endfunction

function! s:toggleComment() range
  let comment = substitute(get(b:, 'commentstring', &commentstring), '\s*\(%s\)\s*', '%s', '')
  let pattern = '\V' . printf(escape(comment, '\'), '\(\s\{-}\)\s\(\S\.\{-}\)\s\=')
  let replace = '\1\2'

  " for lnum in range(a:firstline, a:lastline)
  "   let nextindent = matchstr(getline(lnum), '^\s*')
  "   if !exists('indent') || (strlen(nextindent) <= strlen(indent))
  "     let indent = nextindent
  "   endif
  " endfor
  if getline('.') !~ pattern
    let indent = matchstr(getline('.'), '^\s*')
    let pattern = '^' . indent . '\zs\(\s*\)\(\S.*\)'
    let replace = printf(comment, '\1 \2' . (comment =~ '%s$' ? '' : ' '))
  endif
  for lnum in range(a:firstline, a:lastline)
    call setline(lnum, substitute(getline(lnum), pattern, replace, ''))
  endfor
endfunction

nnoremap gcc :<c-u>.,.+<c-r>=v:count<cr>call <SID>toggleComment()<cr>
nnoremap gc :<c-u>set opfunc=<SID>commentOp<cr>g@
xnoremap gc :call <SID>toggleComment()<cr>

" }}}

" {{{ Mapping: Execute Macro Over Visual Range

" Apply a macro line by line on the selected range in visual block mode
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

" }}}

" }}}

" {{{ Custom Commands

" {{{ MakeTags - Build ctags database

function! GetProjectRoot()
  let l:git_dir = system('git rev-parse --show-toplevel')

  if v:shell_error
    " Return current file's directory in case of error
  	return expand('%:p:h')
  endif

  return substitute(l:git_dir, '\n', '', '')
endfunction

function! MakeTags()
  " Get the project root directory
  let l:project_root = GetProjectRoot()

  " Initialize the ctags command
  let l:ctags_cmd = 'ctags --recurse=yes --verbose -f ' . l:project_root . '/.tags --exclude=.git --exclude=BUILD --exclude=.svn --exclude=vendor --exclude=node_modules --exclude=db --exclude=log'

  " Check for the existence of .ctagsignore or .ignore in the project root
  if filereadable(l:project_root . '/.ctagsignore')
    let l:ignore_file = l:project_root . '/.ctagsignore'
  elseif filereadable(l:project_root . '/.ignore')
    let l:ignore_file = l:project_root . '/.ignore'
  else
    let l:ignore_file = ''
  endif

  " Add the ignore file to the ctags command if it exists
  if !empty(l:ignore_file)
    let l:ctags_cmd .= ' --exclude=@' . l:ignore_file
  endif

  " Execute the ctags command
  execute '!' . l:ctags_cmd
endfunction

set tags+=.tags
command! MakeTags call MakeTags()

" }}}

" {{{ Redir - Redirect the output of command in scratch buffer
"     optionally passing the selection as argument (Gist: romainl/redir.md)

if !has('ide')
  " This command definition includes -bar, so that it is possible to "chain" Vim commands.
  " Side effect: double quotes can't be used in external commands
  command! -nargs=1 -complete=command -bar -range RedirVim silent call Redir(<q-args>, <range>, <line1>, <line2>)
  " This command definition doesn't include -bar, so that it is possible to use double quotes in external commands.
  " Side effect: Vim commands can't be "chained".
  command! -nargs=1 -complete=command -range Redir silent call Redir(<q-args>, <range>, <line1>, <line2>)
endif

function! Redir(cmd, rng, start, end)
  for win in range(1, winnr('$'))
    if getwinvar(win, 'scratch')
      execute win . 'windo close'
    endif
  endfor
  if a:cmd =~ '^!'
    let cmd = a:cmd =~' %'
      \ ? matchstr(substitute(a:cmd, ' %', ' ' . shellescape(escape(expand('%:p'), '\')), ''), '^!\zs.*')
      \ : matchstr(a:cmd, '^!\zs.*')
    if a:rng == 0
      let output = systemlist(cmd)
    else
      let joined_lines = join(getline(a:start, a:end), '\n')
      let cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
      let output = systemlist(cmd . " <<< $" . cleaned_lines)
    endif
  else
    redir => output
    execute a:cmd
    redir END
    let output = split(output, "\n")
  endif
  vnew
  let w:scratch = 1
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  call setline(1, output)
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

" {{{ Auto open omnicomplete
" From https://stackoverflow.com/a/70816950/465590

set completeopt+=menuone,noselect,noinsert " don't insert text automatically
" set pumheight=5 " keep the autocomplete suggestion menu small
" set shortmess+=c " don't give ins-completion-menu messages

" if completion menu closed, and two non-spaces typed, call autocomplete
let s:insert_count = 0
function! OpenCompletion()
    if string(v:char) =~ ' '
        let s:insert_count = 0
    else
        let s:insert_count += 1
    endif
    if !pumvisible() && s:insert_count >= 2
        silent! call feedkeys("\<C-n>", "n")
    endif
endfunction

function! TurnOnAutoComplete()
    augroup autocomplete
        autocmd!
        autocmd InsertLeave let s:insert_count = 0
        autocmd InsertCharPre * silent! call OpenCompletion()
    augroup END
endfunction

function! TurnOffAutoComplete()
    augroup autocomplete
        autocmd!
    augroup END
endfunction

function! ReplayMacroWithoutAutoComplete()
    call TurnOffAutoComplete()
    let reg = getcharstr()
    execute "normal! @".reg
    call TurnOnAutoComplete()
endfunction

" don't let the above mess with replaying macros
nnoremap <silent> @ :call ReplayMacroWithoutAutoComplete()<CR>

" use tab for navigating the autocomplete menu
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

" }}}

" {{{ Setup current working directory based on open file
"
" follow symlinked file
function! FollowSymlink()
  let current_file = expand('%:p')
  " check if file type is a symlink
  if getftype(current_file) == 'link'
    " if it is a symlink resolve to the actual file path
    "   and open the actual file
    let actual_file = resolve(current_file)
    silent! execute 'file ' . actual_file
  end
endfunction

function! SetProjectRoot()
  " Get the project root directory
  let l:project_root = GetProjectRoot()
  " Change local directory to the project root
  lcd `=l:project_root`
endfunction

" follow symlink and set working directory
"autocmd VimEnter * call FollowSymlink() | call SetProjectRoot()
"autocmd BufRead * call FollowSymlink() | call SetProjectRoot()
" netrw: follow symlink and set working directory
autocmd vimrc_basic CursorMoved silent *
  " short circuit for non-netrw files
  \ if &filetype == 'netrw' |
  \   call FollowSymlink() |
  \   call SetProjectRoot() |
  \ endif

" }}}

" }}}

" {{{ Builtin plugins

if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime macros/matchit.vim     " Hit `%` on `if` to jump to `else`.
endif

if exists(":Man") != 2
  runtime! ftplugin/man.vim      " Enable the :Man command
endif

" }}}

" {{{ Neovim Compatibility
" https://github.com/mikeslattery/nvim-defaults.vim/blob/main/plugin/.vimrc

function! VimCompat()
  function! Stdpath(id)
    return stdpath(a:id)
  endfunction

  command! MapQ :
endfunction

function! NeovimCompat()
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

  " If this is the .vimrc, not a plugin, then load init.vim
  if $MYVIMRC == expand('<sfile>:p')
    let $MYVIMRC = s:configdir . '/init.vim'
    source $MYVIMRC
  endif
endfunction

if !exists('g:loaded_nvim_defaults')
  let g:loaded_nvim_defaults = 1

  if has('nvim')
      call VimCompat()
  else
      call NeovimCompat()
  endif
endif


" }}}

" {{{ Toggle Term

function! TabTogTerm()
  let l:OpenTerm = {x -> x
        \  ? { -> execute('botright 15 split +term') }
        \  : { -> execute('botright term ++rows=15') }
        \ }(has('nvim'))
  let term = gettabvar(tabpagenr(), 'term',
        \ {'main': -1, 'winnr': -1, 'bufnr': -1})
  if ! bufexists(term.bufnr)
    call l:OpenTerm()
    call settabvar(tabpagenr(), 'term',
          \ {'main': winnr('#'), 'winnr': winnr(), 'bufnr': bufnr()})
    exe 'tnoremap <buffer> <leader>t <cmd>' . t:term.main . ' wincmd w<cr>'
    exe 'tnoremap <buffer> <c-t>j     <cmd>wincmd c<cr>'
    exe 'tnoremap <buffer> <c-t>k     <cmd>:resize 90<cr>'
    setlocal winheight=15
   	setlocal bufhidden=hide
    setlocal nospell nobuflisted nonumber
    setlocal winfixheight winfixwidth
    setlocal timeoutlen=250

	if has('nvim')
        setlocal nocursorcolumn
        startinsert
    endif
  else
    if ! len(filter(tabpagebuflist(), {_,x -> x == term.bufnr}))
      exe 'botright 15 split +b\ ' . term.bufnr
    else
	  exe term.winnr . 'close'
    endif
  endif
endfunction

augroup term_au
    au!
    au BufEnter * if &buftype == 'terminal' | startinsert | endif
augroup END

command! ToggleTerminal call TabTogTerm()
nnoremap <c-t>   :ToggleTerminal<CR>
tnoremap <c-t> <C-\><C-N>:ToggleTerminal<CR>
inoremap <c-t>   <C-O>:ToggleTerminal<CR>

" }}}
