#!/bin/bash

SOURCE_DIR="/media/medion/Build"
KERNEL_BRANCH="v6.8.10"
SURFACE_KERNEL="6.8"

grep -q "unstable" /etc/apt/sources.list || \
sudo -u root /bin/bash -c 'echo -e "deb https://deb.debian.org/debian/ unstable main contrib non-free-firmware
deb-src https://deb.debian.org/debian/ unstable main contrib non-free-firmware" >> /etc/apt/sources.list'

sudo apt-get update && sudo apt install -y build-essential binutils-dev libncurses5-dev \
libssl-dev ccache bison flex libelf-dev linux-config-6.8 xz-utils git

sudo xz --decompress --keep --stdout /usr/src/linux-config-6.8/config.amd64_none_amd64.xz > "$SOURCE_DIR/base-config"

cd "$SOURCE_DIR"

[ -d "$SOURCE_DIR/linux-surface" ] || git clone https://github.com/linux-surface/linux-surface
[ -d "$SOURCE_DIR/linux" ] || git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git --depth=1 --branch "$KERNEL_BRANCH"

cd linux

git checkout "$KERNEL_BRANCH"
git branch | grep -q "$KERNEL_BRANCH" || git switch -c "$KERNEL_BRANCH"

for i in $SOURCE_DIR/linux-surface/patches/$SURFACE_KERNEL/*.patch; do patch -p1 < "$i"; done

./scripts/kconfig/merge_config.sh "$SOURCE_DIR/base-config" "$SOURCE_DIR/linux-surface/configs/surface-$SURFACE_KERNEL.config"

make -j `getconf _NPROCESSORS_ONLN` deb-pkg LOCALVERSION=-linux-surface | tee "$SOURCE_DIR/build.log"

#make -j `getconf _NPROCESSORS_ONLN` bindeb-pkg LOCALVERSION=-linux-surface
