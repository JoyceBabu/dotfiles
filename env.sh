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
  type $1 >/dev/null 2>/dev/null
}

export MYVIMRC=$ENV_DIR/.vimrc
export VIMINIT=":set runtimepath^=/tmp/jb-vim/.vim|:source $MYVIMRC"

cat <<EOF > $ENV_DIR/.shrc
check_for_executable() {
  type \$1 >/dev/null 2>/dev/null
}

if check_for_executable nvim; then
  alias vim='nvim'
elif ! check_for_executable vim; then
  alias vim='vi'
fi

export ENV_DIR="$ENV_DIR"

unset check_for_executable

[ -f "\$HOME/.\${SHELL}rc" ] && . "\$HOME/.\${SHELL}rc"

alias tmux='\tmux -f"$ENV_DIR/.tmux.conf"'
alias envtest='ls -lah'

EOF

for ENV_SHELL in zsh bash `echo $SHELL|rev|cut -d/ -f1|rev`; do
  if check_for_executable $ENV_SHELL; then
    ENV_TMUX_DEF_CMD=`which $ENV_SHELL`
    break
  fi
done

if [ "zsh" = "$ENV_SHELL" ]; then
  export ZDOTDIR=$ENV_DIR
  ln -s $ENV_DIR/.shrc $ENV_DIR/.zshrc
elif [ "bash" = "$ENV_SHELL" ]; then
  ENV_TMUX_DEF_CMD="$ENV_TMUX_DEF_CMD --rcfile $ENV_DIR/.shrc"
else
  export ENV="$ENV_DIR/.shrc"
fi

dl_config_file vim/.config/nvim/basic.vim .vimrc

if check_for_executable tmux; then
  # tmux installation detected
  echo "tmux found"
  dl_config_file tmux/.tmux.conf .tmux.conf
  echo "set-option -g default-command '$ENV_TMUX_DEF_CMD -i'" >> $ENV_DIR/.tmux.conf

  if [ -n "$TMUX" ]; then
    # Reload configuration if we are under a tmux session
    tmux source "$ENV_DIR/.tmux.conf"
  elif [ "`echo $TERM | cut -d- -f1`" != "screen" ]; then
    # Create a new tmux session, unless we are in a tmux session owned by
    # another user (after sudo su - user)
    tmux -f"$ENV_DIR/.tmux.conf" new
  fi
fi

