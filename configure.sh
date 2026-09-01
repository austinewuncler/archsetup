#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/logger.sh"

log_step "Configuring time"
ln --force --symbolic /usr/share/zoneinfo/Africa/Nairobi /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd

log_step "Configuring localization"

LOCALE="en_US.UTF-8"

sed --in-place "s/^#$LOCALE/$LOCALE/" /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" >/etc/locale.conf
echo "FONT=ter-132n" >/etc/vconsole.conf

log_step "Configuring network"
read -rp "Enter hostname: " HOSTNAME
echo "$HOSTNAME" >/etc/hostname
echo
systemctl enable NetworkManager
echo

log_step "Creating initramfs"
mkinitcpio -P

log_step "Setting root password"
passwd

USERNAME="austine"
log_step "Creating new user $USERNAME"
useradd --create-home --groups wheel --shell "$(which fish)" "$USERNAME"
passwd "$USERNAME"

sed --in-place "s/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

log_step "Configuring bootloader"
refind-install
printf '"Arch Linux" "root=PARTUUID=%s rw rootflags=subvol=@ rootfstype=btrfs"' "$(findmnt -no PARTUUID /)" >/boot/refind_linux.conf
REFIND_CONFIG_DIR="/boot/EFI/refind"
REFIND_THEMES_DIR="$REFIND_CONFIG_DIR/themes"
git clone https://github.com/catppuccin/refind.git "$REFIND_THEMES_DIR/catppuccin" --depth 1
echo "include themes/catppuccin/mocha.conf" >>"$REFIND_CONFIG_DIR/refind.conf"

log_step "Carrying out additional configurations"

PACMAN_CONF_PATH="/etc/pacman.conf"

sed --in-place "s/^#Color/Color/" "$PACMAN_CONF_PATH"
sed --in-place "s/^#VerbosePkgLists/VerbosePkgLists/" "$PACMAN_CONF_PATH"

pkgfile --update
systemctl enable pkgfile-update.timer
systemctl enable tuned{,-ppd}
systemctl enable bluetooth
systemctl enable docker.service
