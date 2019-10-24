alias adb_init='
    export ANDROID_SDK_ROOT=$ANDROID_HOME
    export ANDROID_NDK_HOME="${ANDROID_NDK_ROOT:-$ANDROID_HOME/ndk-bundle}"
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
alias open_ports="sudo lsof -iTCP -sTCP:LISTEN -P -n"

if /usr/bin/which -s nvim; then
    alias vim=nvim
    alias vi=nvim
fi

proxy-start () {
    if [ $# -eq 0 ]; then
        echo "Usage: proxy-start <remote_host> [<local_port=8123>]"
        return 1
    fi
    ssh -D ${2:-8123} -q -C -N ${1}
}

docker-ip() {
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}

docker-ips() {
    docker ps | while read line; do
        if `echo $line | grep -q 'CONTAINER ID'`; then
            echo -e "IP ADDRESS\t$line"
        else
            CID=$(echo $line | awk '{print $1}');
            IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" $CID);
            printf "${IP}\t${line}\n"
        fi
    done;
}

mygrants() {
  mysql -B -N $@ -e "SELECT DISTINCT CONCAT(
    'SHOW GRANTS FOR \'', user, '\'@\'', host, '\';'
    ) AS query FROM mysql.user" | \
  mysql $@ | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/## \1 ##/;/##/{x;p;x;}'
}
