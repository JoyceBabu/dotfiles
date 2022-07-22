#!/bin/sh

TMP_DIR=`mktemp -u 2>/dev/null || echo "/tmp/tmp"`
ENV_DIR="$TMP_DIR/jb-$USER-tmux"
ENV_UID=`id -u`

if [ -e "$ENV_DIR" ] && [ -z "`find "$ENV_DIR" -user "$ENV_UID" -print -prune -o -prune`" ]; then
  echo "The config directory '$ENV_DIR' is not owned by $USER."
  exit 1
fi

mkdir -p "$ENV_DIR"

chmod 0700 "$ENV_DIR"

curl -s https://raw.githubusercontent.com/JoyceBabu/dotfiles/master/tmux/.tmux.conf > "$ENV_DIR/.tmux.conf"
curl -s https://raw.githubusercontent.com/JoyceBabu/dotfiles/master/vim/.config/nvim/basic.vim > "$ENV_DIR/.vimrc"

find "$ENV_DIR" -type f -exec chmod 0600 {} +

chmod -R 0600 "$ENV_DIR"
chmod 0700 "$ENV_DIR"

export MYVIMRC=$ENV_DIR/.vimrc

export VIMINIT=":set runtimepath^=/tmp/jb-vim/.vim|:source $MYVIMRC"

tmux -f"$ENV_DIR/.tmux.conf" new
