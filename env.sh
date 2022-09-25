#!/bin/sh

JB_TMP_DIR=`mktemp -u 2>/dev/null || echo "/tmp/tmp"`
JB_ENV_DIR="`dirname $JB_TMP_DIR`/jb-$USER-tmux"
ENV_UID=`id -u`

if [ -e "$JB_ENV_DIR" ] && [ -z "`find "$JB_ENV_DIR" -user "$ENV_UID" -print -prune -o -prune`" ]; then
  echo "The config directory '$JB_ENV_DIR' is not owned by $USER."
  exit 1
fi

mkdir -p "$JB_ENV_DIR"
chmod 0700 "$JB_ENV_DIR"

jb_dl_config_file() {
  curl -s https://raw.githubusercontent.com/JoyceBabu/dotfiles/master/$1 > "$JB_ENV_DIR/$2"
  chmod 0600 "$JB_ENV_DIR/$2"
}

jb_check_for_executable() {
  type $1 >/dev/null 2>/dev/null
}

export MYVIMRC=$JB_ENV_DIR/.vimrc
export VIMINIT=":set runtimepath^=/tmp/jb-vim/.vim|:source $MYVIMRC"

cat <<EOF > $JB_ENV_DIR/.shrc
jb_check_for_executable() {
  type \$1 >/dev/null 2>/dev/null
}

if jb_check_for_executable nvim; then
  alias vim='nvim -c "let g:tty='\''$(tty)'\''"'
elif ! jb_check_for_executable vim; then
  alias vim='vi'
fi

export JB_ENV_DIR="$JB_ENV_DIR"

unset jb_check_for_executable

[ -f "\$HOME/.\${SHELL}rc" ] && . "\$HOME/.\${SHELL}rc"

alias tmux='\tmux -f"$JB_ENV_DIR/.tmux.conf"'
alias jbenvtest='ls -lah'

EOF

jb_dl_config_file vim/.config/nvim/basic.vim .vimrc

# Setup shell
for ENV_SHELL in zsh bash `echo $SHELL|rev|cut -d/ -f1|rev`; do
  if jb_check_for_executable $ENV_SHELL; then
    ENV_TMUX_DEF_CMD=`which $ENV_SHELL`
    break
  fi
done

if [ "zsh" = "$ENV_SHELL" ]; then
  export JB_ZDOTDIR=$JB_ENV_DIR
  ln -sf $JB_ENV_DIR/.shrc $JB_ENV_DIR/.zshrc
elif [ "bash" = "$ENV_SHELL" ]; then
  ENV_TMUX_DEF_CMD="$ENV_TMUX_DEF_CMD --rcfile $JB_ENV_DIR/.shrc"
else
  JB_ENV="$JB_ENV_DIR/.shrc"
fi

if jb_check_for_executable tmux; then
  # tmux installation detected
  echo "tmux found"
  jb_dl_config_file tmux/.tmux.conf .tmux.conf

  echo "set-option -g default-command '$ENV_TMUX_DEF_CMD -i'" >> $JB_ENV_DIR/.tmux.conf
  if [ -n "$JB_ENV" ]; then
    echo "set-environment -g ENV '$JB_ENV'" >> $JB_ENV_DIR/.tmux.conf
  fi
  if [ -n "$JB_ZDOTDIR" ]; then
    echo "set-environment -g ZDOTDIR '$JB_ZDOTDIR'" >> $JB_ENV_DIR/.tmux.conf
  fi

  if [ -n "$TMUX" ]; then
    # Reload configuration if we are under a tmux session
    tmux source "$JB_ENV_DIR/.tmux.conf"
  elif [ "`echo $TERM | cut -d- -f1`" != "screen" ]; then
    # Create a new tmux session, unless we are in a tmux session owned by
    # another user (after sudo su - user)
    tmux -f"$JB_ENV_DIR/.tmux.conf" new
  fi
else
  ENV="$JB_ENV" ZDOTDIR="$JB_ZDOTDIR" $ENV_TMUX_DEF_CMD -i
fi

# Cleanup
unset jb_dl_config_file
unset jb_check_for_executable
unset ENV_TMUX_DEF_CMD
unset JB_TMP_DIR
unset JB_ENV_UID
unset JB_ZDOTDIR
unset JB_ENV

