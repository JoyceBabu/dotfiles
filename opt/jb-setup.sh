#!/bin/sh

set -eu

usage() {
  cat <<'EOF'
Usage: jb_setup <utility>

Utilities:
  rsync
  curl
  xh
  ripgrep | rg
  fzf
  neovim | nvim
  yazi
  utils | coreutils | uutils
  zoxide | z
  tealdeer | tldr
  ytop | top | htop
  dust | du
  procs | ps
  herdr
  lazygit
EOF
}

die() {
  printf 'jb_setup: %s\n' "$*" >&2
  exit 1
}

download() {
  url=$1
  destination=$2
  DOWNLOAD_PATH=$PATH

  # Avoid using an installed curl replacement to bootstrap later downloads.
  while :; do
    case "$DOWNLOAD_PATH" in
      "$BIN_DIR") DOWNLOAD_PATH=; break ;;
      "$BIN_DIR":*) DOWNLOAD_PATH=${DOWNLOAD_PATH#*:} ;;
      *) break ;;
    esac
  done

  if CURL_EXE=$(PATH="$DOWNLOAD_PATH" command -v curl 2>/dev/null); then
    "$CURL_EXE" -fsSL --retry 3 -o "$destination" "$url"
  elif WGET_EXE=$(PATH="$DOWNLOAD_PATH" command -v wget 2>/dev/null); then
    "$WGET_EXE" -q -O "$destination" "$url"
  else
    die 'curl or wget is required to download releases'
  fi
}

extract_archive() {
  archive=$1
  destination=$2

  case "$archive" in
    *.tar.gz)
      command -v tar >/dev/null 2>&1 || die 'tar is required to extract this release'
      tar -xzf "$archive" -C "$destination"
      ;;
    *.zip)
      if command -v unzip >/dev/null 2>&1; then
        unzip -q "$archive" -d "$destination"
      elif command -v bsdtar >/dev/null 2>&1; then
        bsdtar -xf "$archive" -C "$destination"
      elif command -v python3 >/dev/null 2>&1; then
        python3 -m zipfile -e "$archive" "$destination"
      else
        die 'unzip, bsdtar, or python3 is required to extract this release'
      fi
      ;;
    *) die "unsupported archive: $archive" ;;
  esac
}

find_binary() {
  directory=$1
  name=$2
  find "$directory" -type f -name "$name" -print | head -n 1
}

install_binary() {
  source_path=$1
  target_name=$2

  [ -n "$source_path" ] && [ -f "$source_path" ] || die "release does not contain $target_name"
  temporary_target="$BIN_DIR/.$target_name.$$"
  cp "$source_path" "$temporary_target"
  chmod 0755 "$temporary_target"
  mv -f "$temporary_target" "$BIN_DIR/$target_name"
}

link_binary() {
  target=$1
  name=$2
  temporary_link="$BIN_DIR/.$name.$$"

  rm -f "$temporary_link"
  ln -s "$target" "$temporary_link"
  mv -f "$temporary_link" "$BIN_DIR/$name"
}

[ "$#" -eq 1 ] || {
  usage >&2
  exit 2
}

: "${JB_ENV_DIR:?JB_ENV_DIR must be set before running jb_setup}"

requested=$1
VERSION=
TAG=
REPOSITORY=
ASSET=
ASSET_KIND=archive
canonical=

case "$(uname -s)" in
  Darwin) OS=darwin ;;
  Linux) OS=linux ;;
  *) die "unsupported operating system: $(uname -s)" ;;
esac

case "$(uname -m)" in
  x86_64 | amd64) ARCH=x86_64 ;;
  arm64 | aarch64) ARCH=aarch64 ;;
  *) die "unsupported architecture: $(uname -m)" ;;
esac

case "$requested" in
  rsync)
    canonical=rsync
    VERSION=0.6.3
    TAG=v$VERSION
    REPOSITORY=oferchen/rsync
    case "$OS-$ARCH" in
      darwin-aarch64) ASSET="oc-rsync-$VERSION-darwin-aarch64.tar.gz" ;;
      darwin-x86_64) ASSET="oc-rsync-$VERSION-darwin-x86_64.tar.gz" ;;
      linux-aarch64) ASSET="oc-rsync-$VERSION-linux-aarch64-musl.tar.gz" ;;
      linux-x86_64) ASSET="oc-rsync-$VERSION-linux-x86_64-musl.tar.gz" ;;
    esac
    ;;
  curl)
    canonical=curl
    VERSION=0.2.0
    TAG=v$VERSION
    REPOSITORY=jonwiggins/urlx
    case "$OS-$ARCH" in
      darwin-aarch64) target=aarch64-apple-darwin ;;
      darwin-x86_64) target=x86_64-apple-darwin ;;
      linux-aarch64) target=aarch64-unknown-linux-gnu ;;
      linux-x86_64) target=x86_64-unknown-linux-gnu ;;
    esac
    ASSET="urlx-$target.tar.gz"
    ;;
  xh)
    canonical=xh
    VERSION=0.26.1
    TAG=v$VERSION
    REPOSITORY=ducaale/xh
    case "$OS-$ARCH" in
      darwin-aarch64) target=aarch64-apple-darwin ;;
      darwin-x86_64) target=x86_64-apple-darwin ;;
      linux-aarch64) target=aarch64-unknown-linux-musl ;;
      linux-x86_64) target=x86_64-unknown-linux-musl ;;
    esac
    ASSET="xh-v$VERSION-$target.tar.gz"
    ;;
  ripgrep | rg)
    canonical=ripgrep
    VERSION=15.1.0
    TAG=$VERSION
    REPOSITORY=BurntSushi/ripgrep
    case "$OS-$ARCH" in
      darwin-aarch64) target=aarch64-apple-darwin ;;
      darwin-x86_64) target=x86_64-apple-darwin ;;
      linux-aarch64) target=aarch64-unknown-linux-gnu ;;
      linux-x86_64) target=x86_64-unknown-linux-musl ;;
    esac
    ASSET="ripgrep-$VERSION-$target.tar.gz"
    ;;
  fzf)
    canonical=fzf
    VERSION=0.74.0
    TAG=v$VERSION
    REPOSITORY=junegunn/fzf
    case "$ARCH" in
      aarch64) release_arch=arm64 ;;
      x86_64) release_arch=amd64 ;;
    esac
    ASSET="fzf-$VERSION-${OS}_$release_arch.tar.gz"
    ;;
  neovim | nvim)
    canonical=neovim
    VERSION=0.12.4
    TAG=v$VERSION
    REPOSITORY=neovim/neovim
    case "$ARCH" in
      aarch64) release_arch=arm64 ;;
      x86_64) release_arch=x86_64 ;;
    esac
    case "$OS" in
      darwin) ASSET="nvim-macos-$release_arch.tar.gz" ;;
      linux) ASSET="nvim-linux-$release_arch.tar.gz" ;;
    esac
    ;;
  yazi)
    canonical=yazi
    VERSION=26.5.6
    TAG=v$VERSION
    REPOSITORY=sxyazi/yazi
    case "$OS-$ARCH" in
      darwin-aarch64) target=aarch64-apple-darwin ;;
      darwin-x86_64) target=x86_64-apple-darwin ;;
      linux-aarch64) target=aarch64-unknown-linux-musl ;;
      linux-x86_64) target=x86_64-unknown-linux-musl ;;
    esac
    ASSET="yazi-$target.zip"
    ;;
  utils | coreutils | uutils)
    canonical=coreutils
    VERSION=0.9.0
    TAG=$VERSION
    REPOSITORY=uutils/coreutils
    case "$OS-$ARCH" in
      darwin-aarch64) target=aarch64-apple-darwin ;;
      darwin-x86_64) target=x86_64-apple-darwin ;;
      linux-aarch64) target=aarch64-unknown-linux-musl ;;
      linux-x86_64) target=x86_64-unknown-linux-musl ;;
    esac
    ASSET="coreutils-$VERSION-$target.tar.gz"
    ;;
  zoxide | z)
    canonical=zoxide
    VERSION=0.10.0
    TAG=v$VERSION
    REPOSITORY=ajeetdsouza/zoxide
    case "$OS-$ARCH" in
      darwin-aarch64) target=aarch64-apple-darwin ;;
      darwin-x86_64) target=x86_64-apple-darwin ;;
      linux-aarch64) target=aarch64-unknown-linux-musl ;;
      linux-x86_64) target=x86_64-unknown-linux-musl ;;
    esac
    ASSET="zoxide-$VERSION-$target.tar.gz"
    ;;
  tealdeer | tldr)
    canonical=tealdeer
    VERSION=1.8.1
    TAG=v$VERSION
    REPOSITORY=dbrgn/tealdeer
    ASSET_KIND=binary
    case "$OS-$ARCH" in
      darwin-aarch64) ASSET=tealdeer-macos-aarch64 ;;
      darwin-x86_64) ASSET=tealdeer-macos-x86_64 ;;
      linux-aarch64) ASSET=tealdeer-linux-aarch64-musl ;;
      linux-x86_64) ASSET=tealdeer-linux-x86_64-musl ;;
    esac
    ;;
  ytop | top | htop)
    canonical=ytop
    VERSION=0.6.2
    TAG=$VERSION
    REPOSITORY=cjbassi/ytop
    case "$OS-$ARCH" in
      darwin-x86_64) ASSET="ytop-$VERSION-x86_64-apple-darwin.tar.gz" ;;
      linux-x86_64) ASSET="ytop-$VERSION-x86_64-unknown-linux-gnu.tar.gz" ;;
    esac
    ;;
  dust | du)
    canonical=dust
    VERSION=1.2.4
    TAG=v$VERSION
    REPOSITORY=bootandy/dust
    case "$OS-$ARCH" in
      darwin-x86_64) target=x86_64-apple-darwin ;;
      linux-aarch64) target=aarch64-unknown-linux-musl ;;
      linux-x86_64) target=x86_64-unknown-linux-musl ;;
    esac
    [ -n "${target:-}" ] && ASSET="dust-v$VERSION-$target.tar.gz"
    ;;
  procs | ps)
    canonical=procs
    VERSION=0.14.12
    TAG=v$VERSION
    REPOSITORY=dalance/procs
    case "$OS-$ARCH" in
      darwin-aarch64) target=aarch64-mac ;;
      darwin-x86_64) target=x86_64-mac ;;
      linux-aarch64) target=aarch64-linux ;;
      linux-x86_64) target=x86_64-linux ;;
    esac
    ASSET="procs-v$VERSION-$target.zip"
    ;;
  herdr)
    canonical=herdr
    VERSION=0.7.3
    TAG=v$VERSION
    REPOSITORY=ogulcancelik/herdr
    ASSET_KIND=binary
    case "$OS" in
      darwin) release_os=macos ;;
      linux) release_os=linux ;;
    esac
    ASSET="herdr-$release_os-$ARCH"
    ;;
  lazygit)
    canonical=lazygit
    VERSION=0.63.0
    TAG=v$VERSION
    REPOSITORY=jesseduffield/lazygit
    case "$ARCH" in
      aarch64) release_arch=arm64 ;;
      x86_64) release_arch=x86_64 ;;
    esac
    ASSET="lazygit_${VERSION}_${OS}_${release_arch}.tar.gz"
    ;;
  -h | --help | help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    die "unknown utility: $requested"
    ;;
esac

[ -n "$ASSET" ] || die "$requested is unavailable for $OS/$ARCH"

OPT_DIR="$JB_ENV_DIR/opt"
BIN_DIR="$OPT_DIR/bin"
PACKAGE_DIR="$OPT_DIR/packages"
MARKER_DIR="$OPT_DIR/installed"
MARKER="$MARKER_DIR/$canonical"
EXPECTED_MARKER="$VERSION $ASSET"
mkdir -p "$BIN_DIR" "$PACKAGE_DIR" "$MARKER_DIR"

is_installed() {
  [ -f "$MARKER" ] && [ "$(cat "$MARKER")" = "$EXPECTED_MARKER" ] || return 1

  case "$canonical" in
    rsync) [ -x "$BIN_DIR/rsync" ] ;;
    curl) [ -x "$BIN_DIR/curl" ] ;;
    xh) [ -x "$BIN_DIR/xh" ] ;;
    ripgrep) [ -x "$BIN_DIR/rg" ] ;;
    fzf) [ -x "$BIN_DIR/fzf" ] ;;
    neovim) [ -x "$BIN_DIR/nvim" ] ;;
    yazi) [ -x "$BIN_DIR/yazi" ] && [ -x "$BIN_DIR/ya" ] ;;
    coreutils) [ -x "$BIN_DIR/coreutils" ] ;;
    zoxide) [ -x "$BIN_DIR/zoxide" ] && [ -x "$BIN_DIR/z" ] ;;
    tealdeer) [ -x "$BIN_DIR/tldr" ] && [ -x "$BIN_DIR/tealdeer" ] ;;
    ytop) [ -x "$BIN_DIR/htop" ] && [ -x "$BIN_DIR/ytop" ] ;;
    dust) [ -x "$BIN_DIR/dust" ] ;;
    procs) [ -x "$BIN_DIR/procs" ] ;;
    herdr) [ -x "$BIN_DIR/herdr" ] ;;
    lazygit) [ -x "$BIN_DIR/lazygit" ] ;;
  esac
}

if is_installed; then
  printf '%s %s is already installed in %s\n' "$canonical" "$VERSION" "$BIN_DIR"
  exit 0
fi

WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/jb-setup.XXXXXX")
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM
ARCHIVE="$WORK_DIR/$ASSET"
EXTRACT_DIR="$WORK_DIR/extracted"
URL="https://github.com/$REPOSITORY/releases/download/$TAG/$ASSET"
mkdir -p "$EXTRACT_DIR"

printf 'Downloading %s %s for %s/%s...\n' "$canonical" "$VERSION" "$OS" "$ARCH"
download "$URL" "$ARCHIVE"
if [ "$ASSET_KIND" = archive ]; then
  extract_archive "$ARCHIVE" "$EXTRACT_DIR"
fi

case "$canonical" in
  rsync)
    binary=$(find_binary "$EXTRACT_DIR" oc-rsync)
    [ -n "$binary" ] || binary=$(find_binary "$EXTRACT_DIR" rsync)
    install_binary "$binary" rsync
    ;;
  curl)
    install_binary "$(find_binary "$EXTRACT_DIR" urlx)" curl
    ;;
  xh)
    install_binary "$(find_binary "$EXTRACT_DIR" xh)" xh
    ;;
  ripgrep)
    install_binary "$(find_binary "$EXTRACT_DIR" rg)" rg
    ;;
  fzf)
    install_binary "$(find_binary "$EXTRACT_DIR" fzf)" fzf
    ;;
  neovim)
    binary=$(find_binary "$EXTRACT_DIR" nvim)
    [ -n "$binary" ] || die 'release does not contain nvim'
    extracted_package=$(dirname -- "$(dirname -- "$binary")")
    installed_package="$PACKAGE_DIR/neovim-$VERSION"
    temporary_package="$PACKAGE_DIR/.neovim-$VERSION.$$"
    rm -rf "$temporary_package"
    mv "$extracted_package" "$temporary_package"
    rm -rf "$installed_package"
    mv "$temporary_package" "$installed_package"
    link_binary "../packages/neovim-$VERSION/bin/nvim" nvim
    ;;
  yazi)
    install_binary "$(find_binary "$EXTRACT_DIR" yazi)" yazi
    install_binary "$(find_binary "$EXTRACT_DIR" ya)" ya
    ;;
  coreutils)
    install_binary "$(find_binary "$EXTRACT_DIR" coreutils)" coreutils
    for applet in $("$BIN_DIR/coreutils" --list); do
      case "$applet" in
        '' | */* | coreutils) continue ;;
      esac
      link_binary coreutils "$applet"
    done
    ;;
  zoxide)
    install_binary "$(find_binary "$EXTRACT_DIR" zoxide)" zoxide
    link_binary zoxide z
    ;;
  tealdeer)
    install_binary "$ARCHIVE" tldr
    link_binary tldr tealdeer
    ;;
  ytop)
    install_binary "$(find_binary "$EXTRACT_DIR" ytop)" htop
    link_binary htop ytop
    ;;
  dust)
    install_binary "$(find_binary "$EXTRACT_DIR" dust)" dust
    ;;
  procs)
    install_binary "$(find_binary "$EXTRACT_DIR" procs)" procs
    ;;
  herdr)
    install_binary "$ARCHIVE" herdr
    ;;
  lazygit)
    install_binary "$(find_binary "$EXTRACT_DIR" lazygit)" lazygit
    ;;
esac

printf '%s\n' "$EXPECTED_MARKER" > "$MARKER"
chmod 0644 "$MARKER"
printf 'Installed %s %s in %s\n' "$canonical" "$VERSION" "$BIN_DIR"
