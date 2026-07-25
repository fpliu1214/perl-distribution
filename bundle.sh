#!/bin/sh

set -e

COLOR_GREEN='\033[0;32m'
COLOR_PURPLE='\033[0;35m'
COLOR_OFF='\033[0m'

echo() {
    printf '%b\n' "$*"
}

run() {
    echo "${COLOR_PURPLE}==>${COLOR_OFF} ${COLOR_GREEN}$@${COLOR_OFF}"
    eval "$@"
}

__setup_midnightbsd() {
    run $sudo mport index
    run $sudo mport update perl5 || true
    run $sudo mport install curl coreutils findutils gsed gmake gcc || true

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

__setup_dragonflybsd() {
    run $sudo pkg install -y coreutils findutils gsed gmake gcc

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

__setup_freebsd() {
    run $sudo pkg install -y curl libnghttp2 coreutils findutils gsed gmake gcc

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
    if [ -z "$sudo" ] ; then
        printf 'http://ftp.eu.openbsd.org/pub/OpenBSD\n' > /etc/installurl
    else
        sudo sh -c 'printf "http://ftp.eu.openbsd.org/pub/OpenBSD\n" > /etc/installurl'
    fi

    run $sudo pkg_add coreutils findutils gsed gmake gcc%11 libarchive

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
    case "$(uname -r)" in
        10.1)
            run $sudo pkgin -y update
            run $sudo pkgin -y install coreutils findutils gsed gmake bsdtar

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
            ;;
        10.0)
            for x in 'grep-3.12' 'gsed-4.9' 'gmake-4.4.1' 'coreutils-9.4' 'findutils-4.9.0'
            do
                f="$x-netbsd-10.0-amd64.release.tar.xz"
                run curl -LO "https://github.com/leleliu008/uppm-package-repository-netbsd-10.0-amd64/releases/download/2025.07.25/$f"
                run bsdtar xf "$f" --strip-components=1
            done
            ;;
        9.*)
            for x in 'grep-3.12' 'gsed-4.9' 'gmake-4.4.1' 'coreutils-9.4' 'findutils-4.9.0'
            do
                f="$x-netbsd-10.0-amd64.release.tar.xz"
                run curl -LO "https://github.com/leleliu008/uppm-package-repository-netbsd-9.2-amd64/releases/download/2025.07.23/$f"
                run bsdtar xf "$f" --strip-components=1
            done
    esac
}

__setup_macos() {
    run brew install coreutils gnu-sed make
}

__setup_linux() {
    . /etc/os-release

    case $ID in
        ubuntu)
            run $sudo apt-get -y update
            run $sudo apt-get -y install curl sed libarchive-tools make g++
            run $sudo ln -sf /usr/bin/make bin/gmake
            run $sudo ln -sf /usr/bin/sed  bin/gsed
            ;;
        alpine)
            run $sudo apk update
            run $sudo apk add curl sed libarchive-tools make g++ libc-dev linux-headers
            run $sudo ln -sf /usr/bin/make bin/gmake
            run $sudo ln -sf     /bin/sed  bin/gsed
    esac
}

######################################################

unset IFS

unset sudo

[ "$(id -u)" -eq 0 ] || sudo=sudo

TARGET_PLATFORM_TYPE="${2%%-*}"

install -d bin/

export PATH="$PWD/bin:$PATH"

[ -f cacert.pem ] && run export SSL_CERT_FILE="$PWD/cacert.pem"

__setup_$TARGET_PLATFORM_TYPE

######################################################

PREFIX="perl-$1-$2"

run $sudo install -d -g $(id -g) -o $(id -u) "$PREFIX"

run ./build.sh install --prefix="$PREFIX"

######################################################

run mv README.md build.sh  bundle.sh config.pl config.txt elftool-print-interpreter.c elftool-print-needed.c perl.c sys-cdefs.h "$PREFIX/"

run cd "$PREFIX/"

######################################################

if [ "$TARGET_PLATFORM_TYPE" != macos ] ; then
    gsed -i 's|-bundle -undefined dynamic_lookup|-shared|' config.pl
fi

CONFIG_HEAVY_FILEPATH="$(find "lib/$1" -mindepth 2 -maxdepth 2 -type f -name 'Config_heavy.pl')"
CONFIG_DIR="${CONFIG_HEAVY_FILEPATH%/*}"
CONFIG_PM_FILEPATH="$CONFIG_DIR/Config.pm"

gsed -i "s|CONFIG_DIR|$CONFIG_DIR|" config.pl

gsed -i -e '/tie returns the object/r config.pl' -e '/cc => /d' -e '/version => /r config.txt' "$CONFIG_PM_FILEPATH"

if [ -r /usr/include/crypt.h ] ; then
    cp  /usr/include/crypt.h .

    gsed -i '/<sys\/cdefs.h>/r sys-cdefs.h' crypt.h
    gsed -i '/<sys\/cdefs.h>/d' crypt.h

    mv crypt.h "$CONFIG_DIR/CORE/"
fi

######################################################

run mv *.c bin/

run cd bin/

run rm perl

run mv "perl$1" perl.exe

unset CC

CC="$(command -v gcc || command -v clang || command -v cc)" || abort 1 'C Compiler not found.'

CC="$CC -std=gnu99 -Os -flto"

if [ "$TARGET_PLATFORM_TYPE" = macos ] ; then
    CC="$CC -Wl,-S"
else
    CC="$CC -Wl,-s -static"

    if [ "$TARGET_PLATFORM_TYPE" = linux ] ; then
        run "$CC" -o elftool-print-needed      elftool-print-needed.c
        run "$CC" -o elftool-print-interpreter elftool-print-interpreter.c

        NEEDEDs="$(./elftool-print-needed perl.exe)"

        DYNAMIC_LOADER_PATH="$(./elftool-print-interpreter perl.exe)"
        DYNAMIC_LOADER_NAME="${DYNAMIC_LOADER_PATH##*/}"

        gsed -i "s|ld-linux-x86-64\.so\.2|$DYNAMIC_LOADER_NAME|" perl.c

        ######################################################

        run install -d runtime/
        run cd         runtime/

        for FILENAME in $NEEDEDs
        do
            FILEPATH="$(gcc -print-file-name="$FILENAME")"
            run cp -L "$FILEPATH" .
        done

        [ -f    "$DYNAMIC_LOADER_NAME" ] || {
            case $DYNAMIC_LOADER_NAME in
                ld-musl-*.so.1)
                    run ln -s "libc.musl${DYNAMIC_LOADER_NAME#ld-musl}" "$DYNAMIC_LOADER_NAME"
            esac
        }

        run cd ..
    fi
fi

run "$CC" perl.c -o perl
run "$CC" perl.c -o perl-shim -DSCRIPT_MODE

for f in *
do
    [ -f "$f" ] || continue

    X="$(head -c2 "$f")"

    if [ "$X" = '#!' ] ; then
        Y="$(head -n 1 "$f")"
        Z="${Y##*/}"

        if [ "$Z" = perl ] ; then
            gsed -i '1,4d' "$f"
            run mv "$f" "$f.pl"
            run chmod a-x "$f.pl"
            run ln -s perl-shim "$f"
        fi
    fi
done

######################################################

run cd ../..

run bsdtar cvaPf "$PREFIX.tar.xz" "$PREFIX"
