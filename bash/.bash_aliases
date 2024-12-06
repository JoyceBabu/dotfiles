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

function tssh() {
  if [ "$#" -ne 1 ]; then
    # More than one argument. Just pass all to ssh.
    \ssh "$@"
  else
    # Only the server name is given. Try to attach to tmux session.
    \ssh "$1" -t "
            tmux attach -t 0 2>/dev/null || {
        source <(curl --max-time 5 -fsSL 'https://env.joycebabu.com') 2>/dev/null
      }
        "
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
