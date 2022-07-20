#!/bin/sh

curl https://raw.githubusercontent.com/JoyceBabu/dotfiles/master/tmux/.tmux.conf >/tmp/jb-tmux
chmod 0600 /tmp/jb-tmux
tmux -f/tmp/jb-tmux new

