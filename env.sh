#!/bin/sh

JB_USER=$(id -un)
JB_TMP_DIR=$(mktemp -u 2>/dev/null || echo "/tmp/tmp")
JB_ENV_DIR="$(dirname $JB_TMP_DIR)/jb-$JB_USER-tmux"
ENV_UID=$(id -u)

if [ -e "$JB_ENV_DIR" ] && [ -z "$(find "$JB_ENV_DIR" -user "$ENV_UID" -print -prune -o -prune)" ]; then
  echo "The config directory '$JB_ENV_DIR' is not owned by $JB_USER."
  exit 1
fi

if [ -z "$SHELL" ]; then
  SHELL=$(ps | grep "^\s*$$\s" | sed -e "s/^ *$$ .* //" -e 's/^-//')
fi

jb_check_for_executable() {
  type "$1" >/dev/null 2>/dev/null
}

jb_dl_config_file() {
  $JB_FETCH_EXE $JB_FETCH_FLAGS https://raw.githubusercontent.com/JoyceBabu/dotfiles/master/$1 > "$JB_ENV_DIR/$2"
  chmod 0644 "$JB_ENV_DIR/$2"
}

JB_FETCH_EXE='wget'
JB_FETCH_FLAGS='-q -O-'

if jb_check_for_executable curl; then
  JB_FETCH_EXE='curl'
  JB_FETCH_FLAGS='-s'
fi

if [ -z "$JB_SKIP_TMUX_UPDATE" ] && ! jb_check_for_executable tmux; then
  JB_SKIP_TMUX_UPDATE=1
fi

mkdir -p "$JB_ENV_DIR"
chmod 0755 "$JB_ENV_DIR"

export MYVIMRC=$JB_ENV_DIR/.vimrc
export VIMINIT=":set runtimepath^=$JB_ENV_DIR/.vim|:source $MYVIMRC"

cat <<EOF > $JB_ENV_DIR/.gitconfig
[user]
  name = Joyce Babu
  email = joyce@ennexa.com
[pull]
  rebase = true
[rebase]
  autoStash = true
[merge]
  tool = vimdiff
  conflictstyle = diff3
[mergetool "vimdiff"]
  keepBackup = true
  prompt = false
  cmd = nvim -d \$BASE \$LOCAL \$REMOTE \$MERGED -c '\$wincmd w' -c 'wincmd J'
[mergetool "nvim"]
  keepBackup = true
  prompt = false
  cmd = nvim -f -c "Gdiffsplit!" "\$MERGED"
EOF
chmod 0644 "$JB_ENV_DIR/.gitconfig"

cat <<EOF > $JB_ENV_DIR/.inputrc
\$include /etc/inputrc

set editing-mode vi
\$if mode=vi
  # https://unix.stackexchange.com/a/533628/102730
  set show-mode-in-prompt on
  set vi-ins-mode-string \1\e[6 q\2
  set vi-cmd-mode-string \1\e[2 q\2
  set keymap vi-insert
    "\C-a": beginning-of-line
    "\C-p":history-search-backward
    "\C-n":history-search-forward
    "\C-d": delete-char
    "\C-f": forward-char
    "\C-b": backward-char
    "\C-w": unix-word-rubout
    "\C-k": kill-line
    # switch to block cursor before executing a command
    RETURN: "\e\n"
  set keymap vi-command
  "\C-h":"tmux select-pane -L \C-m"
  "\C-gd":"\C-u\`date +%Y%m%d%H%M\`\e\C-e\C-a\C-y\C-e"
  #"\C-p":history-search-backward
  #"\C-n":history-search-forward
  #"\C-h":""
\$endif

set colored-stats On
set mark-symlinked-directories On
#set show-all-if-ambiguous On
set visible-stats On
EOF

_PREVIEW_CMD='cat'
if command -v bat >/dev/null 2>&1; then
  _PREVIEW_CMD='bat --style=numbers --color=always'
fi

cat <<EOF > $JB_ENV_DIR/.shrc
jb_check_for_executable() {
  type \$1 >/dev/null 2>/dev/null
}

jb_sudo() {
  if [ \$# -eq 3 ] &&[ "\$1" = "su" ] && [ "\$2" = "-" ]; then
    \sudo --preserve-env=TMUX "\$@" -P --whitelist-environment=TMUX \\
      -c 'JB_SKIP_TMUX_UPDATE=1; eval "\`$JB_FETCH_EXE $JB_FETCH_FLAGS https://env.joycebabu.com\`"' -P "\$3"
  else
    \sudo "\$@"
  fi
}

if jb_check_for_executable nvim; then
  alias vim='nvim -c "let g:tty='\''\$(tty)'\''"'
elif ! jb_check_for_executable vim; then
  alias vim='vi'
fi

jb_fuzzy_find() {
  fzf --preview "$_PREVIEW_CMD {}"
}

jb_filter_non_binary () {
  # List of common binary file extensions to exclude
  local binary_extensions='\.(avif|jpe?g|png|gif|ico|svg|tif|tiff|webp|min\.js|min\.css|map|exe|dll|s?o|out|dylib|zip|[rt]ar|gz|bz2|7z|pdf|doc|docx|ppt|pptx|xls|xlsx|bin|iso|dmg|img|msi|jar|class|pyc|pyo|wav|mp[34]|avi|mov|mkv|db|sqlite|bak)$'
  grep -iEv "\$binary_extensions"
}

jb_vim_edit_files() {
  if [ "\$1" = "-a" ] || [ "$1" = "--all" ] || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    file=\$(find . -type f | jb_filter_non_binary | jb_fuzzy_find)
  else
    file=\$(git ls-files | jb_filter_non_binary | jb_fuzzy_find)
  fi

  if [ -n "\$file" ]; then
    vim "\$file"
  fi
}

alias fvim=jb_vim_edit_files

export JB_ENV_DIR="$JB_ENV_DIR"
export GIT_CONFIG_GLOBAL="\$JB_ENV_DIR/.gitconfig"
export INPUTRC="\$JB_ENV_DIR/.inputrc"

unset jb_check_for_executable

[ -f "\$HOME/.\${SHELL}rc" ] && . "\$HOME/.\${SHELL}rc"

alias tmux='\tmux -f"$JB_ENV_DIR/.tmux.conf"'
alias sd='\sudo --preserve-env=VIMINIT,TMUX,JB_ENV_DIR'
alias sudo='jb_sudo'
#alias fvim='vim \$(fzf)'

# Press <C-z> in shell to bring the last suspended process to foreground
# Useful to toggle between vim and shell using <C-z>
if [ "\$-" != "\${-#*i}" ]; then
  stty susp undef

  if [ -n "\$BASH_VERSION" ]; then
    bind '"\\C-z":" fg\\015"'
  elif [ -n "\$ZSH_VERSION" ]; then
	fg_widget() {
      fg
    }
    zle -N fg_widget
    bindkey '^Z' fg_widget
  fi
fi

EOF

chmod 0644 "$JB_ENV_DIR/.shrc"

jb_dl_config_file vim/.config/nvim/basic.vim .vimrc

# Setup shell
for ENV_SHELL in zsh bash `echo $SHELL|rev|cut -d/ -f1|rev`; do
  if jb_check_for_executable "$ENV_SHELL"; then
    JB_ENV_TMUX_DEF_CMD=$(which "$ENV_SHELL")
    break
  fi
done

if [ "zsh" = "$ENV_SHELL" ]; then
  export JB_ZDOTDIR=$JB_ENV_DIR
  ln -sf $JB_ENV_DIR/.shrc $JB_ENV_DIR/.zshrc
elif [ "bash" = "$ENV_SHELL" ]; then
  JB_ENV_TMUX_DEF_CMD="$JB_ENV_TMUX_DEF_CMD --rcfile $JB_ENV_DIR/.shrc"
else
  JB_ENV="$JB_ENV_DIR/.shrc"
fi

find "$JB_ENV_DIR" -maxdepth 1 -type f -exec chmod 0644 {} +
chmod 0755 "$JB_ENV_DIR"

if [ -z "$JB_SKIP_TMUX_UPDATE" ]; then
  # tmux installation detected
  echo "tmux found"
  jb_dl_config_file tmux/.tmux.conf .tmux.conf

  echo "set-option -g default-command '$JB_ENV_TMUX_DEF_CMD -i'" >> $JB_ENV_DIR/.tmux.conf
  if [ -n "$JB_ENV" ]; then
    echo "set-environment -g ENV '$JB_ENV'" >> $JB_ENV_DIR/.tmux.conf
  fi
  if [ -n "$JB_ZDOTDIR" ]; then
    echo "set-environment -g ZDOTDIR '$JB_ZDOTDIR'" >> $JB_ENV_DIR/.tmux.conf
  fi

  if [ -n "$TMUX" ]; then
    # Reload configuration if we are under a tmux session
    tmux source "$JB_ENV_DIR/.tmux.conf"
  elif [ "$(echo $TERM | cut -d- -f1)" != "screen" ]; then
    # Create a new tmux session, unless we are in a tmux session owned by
    # another user (after sudo su - user)
    tmux -f"$JB_ENV_DIR/.tmux.conf" new
  fi
else
  ENV="$JB_ENV" ZDOTDIR="$JB_ZDOTDIR" $JB_ENV_TMUX_DEF_CMD -i
fi

# Cleanup
unset jb_dl_config_file
unset jb_check_for_executable
unset JB_ENV_TMUX_DEF_CMD
unset JB_TMP_DIR
unset JB_ENV_UID
unset JB_ZDOTDIR
unset JB_ENV
unset JB_SKIP_TMUX_UPDATE
unset JB_FETCH_EXE
unset JB_FETCH_FLAGS
unset JB_USER

