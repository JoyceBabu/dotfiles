#!/usr/bin/env bash

# https://writingco.de/how-to-manage-your-dotfiles-with-stow

# make sure we have pulled in and updated any submodules
git submodule init
git submodule update

# what directories should be installable by all users including the root user
base=(
    bash
)

# folders that should, or only need to be installed for a local user
useronly=(
    editorconfig
    ghostty
    git
    gitui
    hammerspoon
    karabiner
    kitty
    phpactor
    process-compose
    ripgrep
    tmux
    vim
    wezterm
    warpd
    yazi
    zellij
    zsh
)

# run the stow command for the passed in directory ($2) in location $1
stowit() {
    usr=$1
    app=$2
    # -v verbose
    # -R recursive
    # -t target
    stow -v -R -t ${usr} ${app}
}

echo ""
echo "Stowing apps for user: ${whoami}"

# install apps available to local users and root
for app in ${base[@]}; do
    echo ""
    echo -e "\033[1mStowing $app\033[0m"
    stowit "${HOME}" $app
done

# install only user space folders
for app in ${useronly[@]}; do
    if [[ ! "$(whoami)" = *"root"* ]]; then
        echo ""
        echo -e "\033[1mStowing $app\033[0m"
        stowit "${HOME}" $app
    fi
done

echo ""
echo "##### ALL DONE"

