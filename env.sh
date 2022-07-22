#!/bin/sh

TMP_DIR=`mktemp -u 2>/dev/null || echo "/tmp/tmp"`
ENV_DIR="`dirname $TMP_DIR`/jb-$USER-tmux"
ENV_UID=`id -u`

if [ -e "$ENV_DIR" ] && [ -z "`find "$ENV_DIR" -user "$ENV_UID" -print -prune -o -prune`" ]; then
  echo "The config directory '$ENV_DIR' is not owned by $USER."
  exit 1
fi

mkdir -p "$ENV_DIR"
chmod 0700 "$ENV_DIR"

dl_config_file() {
  curl -s https://raw.githubusercontent.com/JoyceBabu/dotfiles/master/$1 > "$ENV_DIR/$2"
  chmod 0600 "$ENV_DIR/$2"
}

check_for_executable() {
  echo "checking for $1"
  type $1 >/dev/null 2>/dev/null
}

export MYVIMRC=$ENV_DIR/.vimrc
export VIMINIT=":set runtimepath^=/tmp/jb-vim/.vim|:source $MYVIMRC"

if check_for_executable nvim; then
  alias vim='abc'
elif ! check_for_executable vim; then
  alias vim='vi'
fi

dl_config_file vim/.config/nvim/basic.vim .vimrc

if check_for_executable tmux; then
  echo "tmux found"
  # tmux installation detected
  if [ -n "$TMUX" ]; then
    # Reload configuration if we are under a tmux session
    dl_config_file tmux/.tmux.conf .tmux.conf
    tmux source "$ENV_DIR/.tmux.conf"
  elif [ "`echo $TERM | cut -d- -f1`" != "screen" ]; then
    # Create a new tmux session, unless we are in a tmux session owned by
    # another user (after sudo su - user)
    dl_config_file tmux/.tmux.conf .tmux.conf
    tmux -f"$ENV_DIR/.tmux.conf" new
  fi
fi

