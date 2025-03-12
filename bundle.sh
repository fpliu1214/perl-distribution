#!/bin/sh

set -e

COLOR_GREEN='\033[0;32m'        # Green
COLOR_PURPLE='\033[0;35m'       # Purple
COLOR_OFF='\033[0m'             # Reset

echo() {
    printf '%b\n' "$*"
}

run() {
    echo "${COLOR_PURPLE}==>${COLOR_OFF} ${COLOR_GREEN}$@${COLOR_OFF}"
    eval "$@"
}

__setup_dragonflybsd() {
__setup_freebsd
}

__setup_freebsd() {
    run $sudo pkg install -y curl libnghttp2 coreutils gsed gmake gcc

    run $sudo ln -sf /usr/local/bin/gln        bin/ln
    run $sudo ln -sf /usr/local/bin/gsed       bin/sed
    run $sudo ln -sf /usr/local/bin/gmake      bin/make
    run $sudo ln -sf /usr/local/bin/gstat      bin/stat
    run $sudo ln -sf /usr/local/bin/gdate      bin/date
    run $sudo ln -sf /usr/local/bin/ghead      bin/head
    run $sudo ln -sf /usr/local/bin/gnproc     bin/nproc
    run $sudo ln -sf /usr/local/bin/gbase64    bin/base64
    run $sudo ln -sf /usr/local/bin/gunlink    bin/unlink
    run $sudo ln -sf /usr/local/bin/ginstall   bin/install
    run $sudo ln -sf /usr/local/bin/grealpath  bin/realpath
    run $sudo ln -sf /usr/local/bin/gsha256sum bin/sha256sum
}

__setup_openbsd() {
    run $sudo pkg_add coreutils gsed gmake gcc%11 libarchive

    run $sudo ln -sf /usr/local/bin/gln        bin/ln
    run $sudo ln -sf /usr/local/bin/gsed       bin/sed
    run $sudo ln -sf /usr/local/bin/gmake      bin/make
    run $sudo ln -sf /usr/local/bin/gstat      bin/stat
    run $sudo ln -sf /usr/local/bin/gdate      bin/date
    run $sudo ln -sf /usr/local/bin/ghead      bin/head
    run $sudo ln -sf /usr/local/bin/gnproc     bin/nproc
    run $sudo ln -sf /usr/local/bin/gbase64    bin/base64
    run $sudo ln -sf /usr/local/bin/gunlink    bin/unlink
    run $sudo ln -sf /usr/local/bin/ginstall   bin/install
    run $sudo ln -sf /usr/local/bin/grealpath  bin/realpath
    run $sudo ln -sf /usr/local/bin/gsha256sum bin/sha256sum
}

__setup_netbsd() {
    run $sudo pkgin -y update
    run $sudo pkgin -y install coreutils gsed gmake bsdtar

    run $sudo ln -sf /usr/pkg/bin/gln        bin/ln
    run $sudo ln -sf /usr/pkg/bin/gsed       bin/sed
    run $sudo ln -sf /usr/pkg/bin/gmake      bin/make
    run $sudo ln -sf /usr/pkg/bin/gstat      bin/stat
    run $sudo ln -sf /usr/pkg/bin/gdate      bin/date
    run $sudo ln -sf /usr/pkg/bin/ghead      bin/head
    run $sudo ln -sf /usr/pkg/bin/gnproc     bin/nproc
    run $sudo ln -sf /usr/pkg/bin/gbase64    bin/base64
    run $sudo ln -sf /usr/pkg/bin/gunlink    bin/unlink
    run $sudo ln -sf /usr/pkg/bin/ginstall   bin/install
    run $sudo ln -sf /usr/pkg/bin/grealpath  bin/realpath
    run $sudo ln -sf /usr/pkg/bin/gsha256sum bin/sha256sum
}

__setup_macos() {
    run brew install coreutils gnu-sed make
}

__setup_linux() {
    . /etc/os-release

    case $ID in
        ubuntu)
            run $sudo apt-get -y update
            run $sudo apt-get -y install curl sed libarchive-tools make g++ patchelf
            run $sudo ln -sf /usr/bin/make bin/gmake
            run $sudo ln -sf /usr/bin/sed  bin/gsed
            ;;
        alpine)
            run $sudo apk update
            run $sudo apk add curl sed libarchive-tools make g++ libc-dev linux-headers patchelf
            run $sudo ln -sf /usr/bin/make bin/gmake
            run $sudo ln -sf     /bin/sed  bin/gsed
    esac
}

unset IFS

unset sudo

[ "$(id -u)" -eq 0 ] || sudo=sudo

TARGET_OS_KIND="${2%%-*}"

install -d bin/

__setup_$TARGET_OS_KIND

export PATH="$PWD/bin:$PATH"

PREFIX="perl-$1-$2"

run $sudo install -d -g `id -g` -o `id -u` "$PREFIX"

[ -f cacert.pem ] && run export SSL_CERT_FILE="$PWD/cacert.pem"

run ./build.sh install --prefix="$PREFIX"

run cp build.sh bundle.sh "$PREFIX/"

######################################################

ORIGIN_DIR="$PWD"

run cd "$PREFIX/bin"

# change hard-link to soft-link
ln -sf perl5.* perl

for f in *
do
    X="$(head -c2 "$f")"

    if [ "$X" = '#!' ] ; then
        Y="$(head -n 1 "$f")"

        if [ "$Y" = "#!$PWD/perl" ] ; then
            gsed -i '1,4d' "$f"
            gsed -i '1s|^|#!/bin/sh\nexec "$(dirname "$0")"/perl -x "$0" "$@"\n#!perl\n|' "$f"
        fi
    fi
done

gsed -i '3a =pod' pod2html

if [ "$TARGET_OS_KIND" = linux ] ; then
    run mv "perl$1" "perl$1.exe"

    run chmod -x "perl$1.exe"

    DYNAMIC_LOADER_PATH="$(patchelf --print-interpreter "perl$1.exe")"
    DYNAMIC_LOADER_NAME="${DYNAMIC_LOADER_PATH##*/}"

    run mv "$ORIGIN_DIR/perl.c" .

    gsed -i "s|ld-linux-x86-64.so.2|$DYNAMIC_LOADER_NAME|" perl.c

    run gcc -static -std=gnu99 -Os -flto -s -o "perl$1" perl.c

    NEEDEDs="$(patchelf --print-needed "perl$1.exe")"

    run install -d ../runtime/
    run cd         ../runtime/

    for NEEDED_FILENAME in $NEEDEDs
    do
        NEEDED_FILEPATH="$(gcc -print-file-name="$NEEDED_FILENAME")"
        run cp -L "$NEEDED_FILEPATH" .
    done

    [ -f    "$DYNAMIC_LOADER_NAME" ] || {
        case $DYNAMIC_LOADER_NAME in
            ld-musl-*.so.1)
                run ln -s "libc.musl${DYNAMIC_LOADER_NAME#ld-musl}" "$DYNAMIC_LOADER_NAME"
        esac
    }
fi

run cd "$ORIGIN_DIR"

run bsdtar cvaPf "$PREFIX.tar.xz" "$PREFIX"
