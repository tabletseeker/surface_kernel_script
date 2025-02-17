#!/bin/bash

SOURCE_DIR="~/build"
LOG_DIR="$SOURCE_DIR/logs"
KERNEL_SOURCE="$SOURCE_DIR/linux"
KERNEL_BRANCH="v6.12.12"
LINUX_CONFIG=$(echo "$KERNEL_BRANCH" | sed -E 's|\.[0-9]+$||; s|v||')
SURFACE_KERNEL="$LINUX_CONFIG"
PATCH_DIR="$SOURCE_DIR/linux-surface/patches/$SURFACE_KERNEL"
FULL_VERSION="$(echo "$KERNEL_BRANCH" | sed -E 's|v||')-surface-amd64"

mkdir -p "$SOURCE_DIR/$KERNEL_BRANCH-dco" "$LOG_DIR"
#add sources for latest version of linux-config package
grep -q "unstable" /etc/apt/sources.list || \
sudo -u root /bin/bash -c 'echo -e "deb https://deb.debian.org/debian/ unstable main contrib non-free-firmware
deb https://deb.debian.org/debian/ experimental main contrib non-free-firmware" >> /etc/apt/sources.list'

sudo apt-get update && sudo apt install -y build-essential binutils-dev libncurses5-dev \
libssl-dev ccache bison flex libelf-dev xz-utils git

[ -d "$SOURCE_DIR/linux-surface" ] || git clone https://github.com/linux-surface/linux-surface "$SOURCE_DIR/linux-surface"
[ -d "$SOURCE_DIR/linux" ] || git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git --depth=1 --branch "$KERNEL_BRANCH" "$SOURCE_DIR/linux"
#check if kernel version matches linux-config version or install latest version available
sudo apt show linux-config-$LINUX_CONFIG &> /dev/null || \ 
LINUX_CONFIG=$(sudo apt show linux-config-* 2> /dev/null | tac | grep -Pom1 "linux-config-\d.\d+" | cut -d- -f3)
sudo apt install -y linux-config-$LINUX_CONFIG
#extract base-config
sudo xz --decompress --keep --stdout /usr/src/linux-config-$LINUX_CONFIG/config.amd64_none_amd64.xz > "$SOURCE_DIR/base-config"

cd "$SOURCE_DIR/linux"

git checkout "$KERNEL_BRANCH"
git branch | grep -q "$KERNEL_BRANCH" || git switch -c "$KERNEL_BRANCH"

for i in $SOURCE_DIR/linux-surface/patches/$SURFACE_KERNEL/*.patch; do patch -p1 < "$i"; [ $? -ne 0 ] && { echo -e "\npatch $i failed!"; exit; }; done

./scripts/kconfig/merge_config.sh "$SOURCE_DIR/base-config" "$SOURCE_DIR/linux-surface/configs/surface-$SURFACE_KERNEL.config"

make -j `getconf _NPROCESSORS_ONLN` deb-pkg LOCALVERSION=-surface-amd64 | tee "$LOG_DIR/deb_build.log"
