#!/bin/sh

set -e

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

cat <<EOF > $JB_ENV_DIR/.ignore
*~
.DS_Store
*.orig
*.swp
*.bak
*.otd
*.okd
*-OKD
*-OTD

.idea/
.cache/
tmp/
var/
EOF

cat <<EOF > $JB_ENV_DIR/.gitconfig
[core]
  excludesfile = $JB_ENV_DIR/.ignore
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
    "\C-e": end-of-line
    "\C-p": history-search-backward
    "\C-n": history-search-forward
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

_FIND_CMD='find'
if jb_check_for_executable fdfind; then
  _FIND_CMD=fdfind
elif jb_check_for_executable fd; then
  _FIND_CMD=fd
fi

cat <<EOF > $JB_ENV_DIR/.shrc
jb_check_for_executable() {
  type \$1 >/dev/null 2>/dev/null
}

jb_sudo() {
  if [ \$# -ge 2 ] && [ "\$1" = "su" ] && [ "\$2" = "-" ]; then
    \sudo --preserve-env=TMUX su -P --whitelist-environment=TMUX \\
      -c 'JB_SKIP_TMUX_UPDATE=1; eval "\`$JB_FETCH_EXE $JB_FETCH_FLAGS https://env.joycebabu.com\`"' "\${@:2}"
  else
    \sudo "\$@"
  fi
}

if jb_check_for_executable nvim; then
  alias vim='nvim'
  if [ -n "\$TMUX" ]; then
    alias nvim='jb_nvim'
  fi
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
  clear_opcache=""
  all_files=0
  # Reset OPTIND to ensure we are starting from beginning
  OPTIND=1

  while getopts "acC" opt; do
    case \$opt in
      a) all_files=1 ;;
      c) clear_opcache=1 ;;
      C) clear_opcache=0 ;;
    esac
  done

  shift \$((OPTIND - 1))

  if [ "\$all_files" = "1" ] || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    file=\$(find "\${1:-.}" -type f | jb_filter_non_binary | jb_fuzzy_find)
  else
    file=\$(git ls-files "\${1:-.}" | jb_filter_non_binary | jb_fuzzy_find)
  fi

  if [ -n "\$file" ]; then
    vim "\$file"

    # Run clear-opcache command if clear_opcache is non-empty (true) and file is .php
    echo "\$file" | grep -q '\.php\$'
    if [ \$? -ne 0 ]; then
      clear_opcache=0
    elif [ "\$clear_opcache" = "" ]; then
      echo "Do you want to clear the opcache for \$file? (y/N): "
      read -t 3 choice
      clear_opcache=\$(echo 'n' | grep '^[yY]\$' && echo 1 || echo 0)
    fi

    if [ "\$clear_opcache" = "1" ]; then
      ./bin/clear-opcache "\$file"
    fi
  fi
}

jb_nvim() {
  if [ -z "\$TMUX" ]; then
    command nvim -c "let g:tty='\$(tty)'" "\$@"
    return
  fi

  local CURRENT_SESS=\$(tmux display -p '#{session_name}')
  local CURRENT_WIN=\$(tmux display -p '#{window_id}')
  local IN_SCRATCH=0

  case "\$CURRENT_SESS" in
    scratch-*)
      local PARENT_INFO=\${CURRENT_SESS#scratch-}
      CURRENT_SESS=\${PARENT_INFO%-*}
      CURRENT_WIN=\${PARENT_INFO##*-}
          IN_SCRATCH=1
          ;;
  esac

  # Find nvim socket in current window
  local SOCK=''
  local SOCKET_PATH="\${XDG_RUNTIME_DIR:-\${TMPDIR:-/tmp/}}"

  for s in \$(find "\$SOCKET_PATH" "\${TMPDIR:-/tmp/}" -type s -user "\$USER" -path '*/nvim*' -name 'nvim.*.0' -maxdepth 3 2>/dev/null); do
    local PID=\$(echo \$s | awk -F'.' '{print \$(NF-1)}')
    local SEARCH_PID=\$PID
    local FOUND_WIN=''

    while [ -n "\$SEARCH_PID" ] && [ "\$SEARCH_PID" -gt 1 ]; do
      local PANE_INFO=\$(tmux list-panes -a -F "#{session_name} #{window_id} #{pane_index}" -f "#{==:#{pane_pid},\$SEARCH_PID}" 2>/dev/null)

      if [ -n "\$PANE_INFO" ]; then
        local SESS=\$(echo \$PANE_INFO | cut -d' ' -f1)
        local WIN=\$(echo \$PANE_INFO | cut -d' ' -f2)
        local PANE_IDX=\$(echo \$PANE_INFO | cut -d' ' -f3)

        if [ "\$SESS" = "\$CURRENT_SESS" ] && [ "\$WIN" = "\$CURRENT_WIN" ]; then
          SOCK=\$s
          local FOUND_WIN="\$CURRENT_SESS:\$CURRENT_WIN"
          break 2
        fi
      fi
      SEARCH_PID=\$(ps -o ppid= -p \$SEARCH_PID 2>/dev/null | tr -d ' ')
    done
  done

  if [ -n "\$SOCK" ] && [ -e "\$SOCK" ]; then
    if [ \$# -ne 1 ]; then
      command nvim --server "\$SOCK" --remote "$(realpath \"\$1\")"
    elif [ \$# -ne 0 ]; then
      command nvim --server "\$SOCK" --remote "\$@"
    fi

    tmux select-window -t "\$FOUND_WIN"
    tmux select-pane -t "\$FOUND_WIN.\$PANE_IDX"

    [ \$IN_SCRATCH -eq 1 ] && tmux detach-client
  else
    command nvim -c "let g:tty='\$(tty)'" "\$@"
  fi
}

alias fvim=jb_vim_edit_files

export JB_ENV_DIR="$JB_ENV_DIR"
export GIT_CONFIG_GLOBAL="\$JB_ENV_DIR/.gitconfig"
export INPUTRC="\$JB_ENV_DIR/.inputrc"
JB_SHELL=\$(basename \$SHELL)

unset jb_check_for_executable

[ -f "\$HOME/.\${JB_SHELL}rc" ] && . "\$HOME/.\${JB_SHELL}rc"

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
for ENV_SHELL in zsh bash "$SHELL"; do
  if jb_check_for_executable "$ENV_SHELL"; then
    JB_ENV_TMUX_DEF_CMD=$(which "$ENV_SHELL")
    break
  fi
done

JB_ENV_TMUX_DEF_ARGS='-i'
if [ "zsh" = "$ENV_SHELL" ]; then
  export JB_ZDOTDIR=$JB_ENV_DIR
  ln -sf $JB_ENV_DIR/.shrc $JB_ENV_DIR/.zshrc
elif [ "bash" = "$ENV_SHELL" ]; then
  JB_ENV_TMUX_DEF_ARGS="--rcfile $JB_ENV_DIR/.shrc -i"
else
  JB_ENV="$JB_ENV_DIR/.shrc"
fi

find "$JB_ENV_DIR" -maxdepth 1 -type f -exec chmod 0644 {} +
chmod 0755 "$JB_ENV_DIR"

if [ -z "$JB_SKIP_TMUX_UPDATE" ]; then
  # tmux installation detected
  echo "tmux found"
  jb_dl_config_file tmux/.tmux.conf .tmux.conf

  echo "set-option -g default-command '$JB_ENV_TMUX_DEF_CMD $JB_ENV_TMUX_DEF_ARGS'" >> $JB_ENV_DIR/.tmux.conf
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
  if [ -t 0 ] && [ -t 1 ]; then
    printf '\n'

    export ENV="$JB_ENV"
    export ZDOTDIR="$JB_ZDOTDIR"

    eval "exec $JB_ENV_TMUX_DEF_CMD $JB_ENV_TMUX_DEF_ARGS"
  else
    echo "Error: This script requires an interactive terminal" >&2
    exit 1
  fi
fi

# Cleanup
unset jb_dl_config_file
unset jb_check_for_executable
unset JB_ENV_TMUX_DEF_ARGS
unset JB_ENV_TMUX_DEF_CMD
unset JB_TMP_DIR
unset JB_ENV_UID
unset JB_ZDOTDIR
unset JB_ENV
unset JB_SKIP_TMUX_UPDATE
unset JB_FETCH_EXE
unset JB_FETCH_FLAGS
unset JB_USER
