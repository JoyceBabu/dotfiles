alias adb_init='
  export ANDROID_SDK_ROOT=$ANDROID_HOME
  export ANDROID_NDK_HOME="${ANDROID_NDK_ROOT:-$ANDROID_HOME/ndk/${ANDROID_NDK_VERSION:-25.2.9519653}}"
  export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME
  export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/${OS_NAME}-x86_64:$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/:$ANDROID_HOME/tools/bin:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/${OS_NAME}-x86_64/bin
'
# alias java_init='export JAVA_HOME=$(/usr/libexec/java_home -v 1.8);PATH=${JAVA_HOME}/bin:${PATH}'
alias node_init='
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
'
alias ruby_init='
  if /usr/bin/which rbenv > /dev/null; then
      eval "$(rbenv init -)"
  fi
'
alias go_init='
  export GOPATH=${GOPATH:-$HOME/Projects/golang};
  export GOROOT=${GOROOT:-/usr/local/opt/go/libexec}
  export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
'
alias rust_init='
  export RUSTUP_HOME=${RUSTUP_HOME:-$HOME/.rustup}
  export CARGO_HOME=${CARGO_HOME:-$HOME/.cargo}
  export PATH=$CARGO_HOME/bin:$PATH
'
alias python_init="alias venv='python3 -m venv'"
alias composer_init='PATH=$PATH:~/.composer/vendor/bin'
alias open_ports="sudo lsof -iTCP -sTCP:LISTEN -P -n"
alias ..='cd ..'
alias ssh=tssh
alias fvim=jb_vim_edit_files
alias pstorm=phpstorm
alias alert='toastify send "$([ $? = 0 ] && echo Completed || echo Error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias lg=lazygit

if /usr/bin/which nvim >/dev/null; then
  alias vim=nvim
  alias vi=nvim
  if [ -n "$TMUX" ]; then
    alias nvim=tvim
  fi
fi

_PREVIEW_CMD='cat'
if command -v bat >/dev/null 2>&1; then
  _PREVIEW_CMD='bat --style=numbers --color=always'
fi

jb_fuzzy_find() {
  fzf --preview "$_PREVIEW_CMD {}"
}

jb_filter_non_binary () {
  # List of common binary file extensions to exclude
  local binary_extensions='\.(avif|jpe?g|png|gif|ico|svg|tif|tiff|webp|min\.js|min\.css|map|exe|dll|s?o|out|dylib|zip|[rt]ar|gz|bz2|7z|pdf|doc|docx|ppt|pptx|xls|xlsx|bin|iso|dmg|img|msi|jar|class|pyc|pyo|wav|mp[34]|avi|mov|mkv|db|sqlite|bak)$'
  grep -iEv "$binary_extensions"
}

jb_vim_edit_files() {
  clear_opcache=0
  all_files=0

  while getopts "ac" opt; do
    case $opt in
      a) all_files=1 ;;
      c) clear_opcache=1 ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$all_files" = "1" ] || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    file=$(find "${1:-.}" -type f | jb_filter_non_binary | jb_fuzzy_find)
  else
    file=$(git ls-files "${1:-.}" | jb_filter_non_binary | jb_fuzzy_find)
  fi

  if [ -n "$file" ]; then
    vim "$file"

    if [ "$clear_opcache" = "1" ]; then
      ./bin/clear-opcache "$file"
    fi
  fi
}

colourize() {
  sed -E \
    -e "s/\[red\]/"$'\e[31m'"/g" \
    -e "s/\[\/red\]/"$'\e[m'"/g" \
    -e "s/\[green\]/"$'\e[32m'"/g" \
    -e "s/\[\/green\]/"$'\e[m'"/g" \
    -e "s/\[yellow\]/"$'\e[33m'"/g" \
    -e "s/\[\/yellow\]/"$'\e[m'"/g" \
    -e "s/\[blue\]/"$'\e[34m'"/g" \
    -e "s/\[\/blue\]/"$'\e[m'"/g" \
    -e "s/\[magenta\]/"$'\e[35m'"/g" \
    -e "s/\[\/magenta\]/"$'\e[m'"/g" \
    -e "s/\[cyan\]/"$'\e[36m'"/g" \
    -e "s/\[\/cyan\]/"$'\e[m'"/g" \
    -e "s/\[white\]/"$'\e[37m'"/g" \
    -e "s/\[\/white\]/"$'\e[m'"/g" \
    -e "s/FATAL/"$'\e[31m'"&"$'\e[m'"/g" \
    -e "s/ERROR/"$'\e[31m'"&"$'\e[m'"/g" \
    -e "s/WARNING/"$'\e[33m'"&"$'\e[m'"/g" \
    -e "s/INFO/"$'\e[32m'"&"$'\e[m'"/g" \
    -e "s/DEBUG/"$'\e[34m'"&"$'\e[m'"/g"
}


function tssh() {
  if [ "$#" -ne 1 ]; then
    # More than one argument. Just pass all to ssh.
    \ssh "$@"
  else
    # Only the server name is given. Try to attach to tmux session.
	ssh "$1" -tt 'tmux attach -t 0 2>/dev/null || eval "$(curl -s https://env.joycebabu.com)"'
  fi
}

proxy-start() {
  if [ $# -eq 0 ]; then
    echo "Usage: proxy-start <remote_host> [<local_port=8123>]"
    return 1
  fi
  \ssh -D ${2:-8123} -q -C -N ${1}
}

docker-ip() {
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}

docker-ips() {
  docker ps | while read line; do
    if $(echo $line | grep -q 'CONTAINER ID'); then
      echo -e "IP ADDRESS\t$line"
    else
      CID=$(echo $line | awk '{print $1}')
      IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $CID)
      printf "${IP}\t${line}\n"
    fi
  done
}

mygrants() {
  mysql -uroot -B -N $@ -e "SELECT DISTINCT CONCAT(
    'SHOW GRANTS FOR \'', user, '\'@\'', host, '\';'
    ) AS query FROM mysql.user" |
    mysql -uroot $@ |
    sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/## \1 ##/;/##/{x;p;x;}'
}

tvim() {
  if [ -z "$TMUX" ]; then
    command nvim "$@"
    return
  fi

  # Get current tmux window
  local CURRENT_SESS=$(tmux display -p '#{session_name}')
  local CURRENT_WIN=$(tmux display -p '#{window_id}')
  local IN_SCRATCH=0

  # If in scratch session, extract parent session and window from the name
  case "$CURRENT_SESS" in
    scratch-*)
      local PARENT_INFO=${CURRENT_SESS#scratch-}
      CURRENT_SESS=${PARENT_INFO%-*}
      CURRENT_WIN=${PARENT_INFO##*-}
    IN_SCRATCH=1
    ;;
  esac

  # Find nvim socket in current window
  local SOCK=''
  local SOCKET_PATH="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp/}nvim.${USER}}/nvim.$USER"
  for s in $(find "$SOCKET_PATH" -type s -user "$USER" -name 'nvim.*.0' -maxdepth 3 2>/dev/null); do
    local PID=$(echo $s | awk -F'.' '{print $(NF-1)}')
    local SEARCH_PID=$PID
    local FOUND_WIN=''

    # Walk up process tree to find tmux pane
  while [ -n "$SEARCH_PID" ] && [ "$SEARCH_PID" -gt 1 ]; do
      local PANE_INFO=$(tmux list-panes -a -F "#{session_name} #{window_id} #{pane_index}" -f "#{==:#{pane_pid},$SEARCH_PID}" 2>/dev/null)

      if [ -n "$PANE_INFO" ]; then
        local SESS=$(echo $PANE_INFO | cut -d' ' -f1)
        local WIN=$(echo $PANE_INFO | cut -d' ' -f2)
        local PANE_IDX=$(echo $PANE_INFO | cut -d' ' -f3)

        if [ "$SESS" = "$CURRENT_SESS" ] && [ "$WIN" = "$CURRENT_WIN" ]; then
          SOCK=$s
          local FOUND_WIN="$CURRENT_SESS:$CURRENT_WIN"
          break 2
        fi
      fi
      SEARCH_PID=$(ps -o ppid= -p $SEARCH_PID 2>/dev/null | tr -d ' ')
    done
  done

  if [ -n "$SOCK" ] && [ -e "$SOCK" ]; then
    # Found nvim in current window, send files to it
    if [ $# -ne 0 ]; then
      command nvim --server "$SOCK" --remote "$@"
    fi

    # Focus the nvim pane
    tmux select-window -t "$FOUND_WIN"
    tmux select-pane -t "$FOUND_WIN.$PANE_IDX"

    # If in scratch session, detach
  [ $IN_SCRATCH -eq 1 ] && tmux detach-client
  else
    # No nvim in current window, start new instance
    command nvim "$@"
  fi
}

