#!/bin/bash
# Create two partitions (FAT16):
#   - Public partition: contains only README
#   - Hidden partition: contains only a tar.gz (with the flag text inside)
set -euo pipefail

IMG=file_stealer.img
SECTOR=512

# Geometry parameters
P1_START=2048       # 1MiB
P1_SIZE=65536       # 32MiB
P2_START=67584      # 33MiB
P2_SIZE=61440       # 30MiB

FLAG_CONTENT='is1abCTF{h1dd3n_p4rt1t10n_1s_4w3s0m3}'

# Required tools
for c in dd parted losetup mkfs.vfat mount umount tar gzip; do
  command -v "$c" >/dev/null || { echo "[-] Missing $c"; exit 1; }
done

# Create blank image
dd if=/dev/zero of="$IMG" bs=1M count=64 status=none

# Create MBR + partitions (FAT16, second partition marked hidden)
parted -s "$IMG" mklabel msdos
parted -s "$IMG" mkpart primary fat16 1MiB 33MiB
parted -s "$IMG" mkpart primary fat16 33MiB 63MiB
parted -s "$IMG" set 2 hidden on

mkdir -p /mnt/ctf
TMPDIR=$(mktemp -d)
LOOP1=""; LOOP2=""
cleanup() {
  set +e
  mountpoint -q /mnt/ctf && umount /mnt/ctf
  [[ -n "$LOOP1" ]] && losetup -d "$LOOP1"
  [[ -n "$LOOP2" ]] && losetup -d "$LOOP2"
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

# Partition 1 (Public)
LOOP1=$(losetup -f --show --offset $((P1_START*SECTOR)) --sizelimit $((P1_SIZE*SECTOR)) "$IMG")
mkfs.vfat -F 16 -n PUBLIC "$LOOP1" >/dev/null
mount "$LOOP1" /mnt/ctf
echo -e "Public area. Nothing interesting here.\nBut you might need this later: 'is1ab'." > /mnt/ctf/readme.txt
sync; umount /mnt/ctf; losetup -d "$LOOP1"; LOOP1=""

# Prepare tar.gz (internal filename avoids the word 'flag')
echo "$FLAG_CONTENT" > "$TMPDIR/doc.txt"
# -C changes working directory to avoid packing full paths; -z enables gzip
tar -C "$TMPDIR" -czf "$TMPDIR/media_update.tar.gz" doc.txt
rm -f "$TMPDIR/doc.txt"

# Partition 2 (Hidden): only store the tar.gz
# Do NOT put flag.txt directly into the partition!
LOOP2=$(losetup -f --show --offset $((P2_START*SECTOR)) --sizelimit $((P2_SIZE*SECTOR)) "$IMG")
mkfs.vfat -F 16 -n SECRET "$LOOP2" >/dev/null
mount "$LOOP2" /mnt/ctf
# Use a normal-looking filename
cp "$TMPDIR/media_update.tar.gz" /mnt/ctf/DCIM_0001.TGZ
sync; umount /mnt/ctf; losetup -d "$LOOP2"; LOOP2=""

echo "[+] Output: $IMG"
