#!/bin/bash
# CTF "Broken Camera" - One-click challenge generator (FAT16 + full-partition XOR obfuscation)
set -euo pipefail

### === Parameters ===
IMG="file_stealer_revenge.img"
SIZE_MB=64
SECTOR=512

# Geometry (aligned with parted)
P1_START=2048    # 1 MiB
P1_SIZE=65536    # 32 MiB / 512 = 65536 sectors
P2_START=67584   # 33 MiB
P2_SIZE=61440    # 30 MiB

# Source materials (put qrcode.png in this folder)
HIDDEN_SRC_DIR="./hidden_photos"

# XOR key
KEY="is1ab"

### === Dependency check ===
need() { command -v "$1" >/dev/null 2>&1 || { echo "[-] Missing command: $1" >&2; exit 1; }; }
for c in dd parted losetup mkfs.vfat mount umount python3; do need "$c"; done
[[ -d "$HIDDEN_SRC_DIR" ]] || { echo "[-] Folder not found: $HIDDEN_SRC_DIR" >&2; exit 1; }

# Collect images (png/jpg/jpeg; total size < 30 MiB recommended)
shopt -s nullglob nocaseglob
HFILES=( "$HIDDEN_SRC_DIR"/*.png "$HIDDEN_SRC_DIR"/*.jpg "$HIDDEN_SRC_DIR"/*.jpeg )
shopt -u nocaseglob
if (( ${#HFILES[@]} == 0 )); then
  echo "[-] No png/jpg/jpeg files in $HIDDEN_SRC_DIR (must include at least one, e.g. qrcode.png)" >&2
  exit 1
fi

### === Safe cleanup ===
MNT=$(mktemp -d /tmp/is1abcam.XXXX)
LOOP1="" ; LOOP2=""
cleanup() {
  set +e
  mountpoint -q "$MNT" && umount "$MNT"
  [[ -n "${LOOP1}" ]] && losetup -d "$LOOP1" 2>/dev/null
  [[ -n "${LOOP2}" ]] && losetup -d "$LOOP2" 2>/dev/null
  rmdir "$MNT" 2>/dev/null || true
}
trap cleanup EXIT

echo "[*] Creating ${SIZE_MB}MiB image: $IMG"
dd if=/dev/zero of="$IMG" bs=1M count="$SIZE_MB" status=none

echo "[*] Creating partition table and partitions (FAT16, hidden #2)"
parted -s "$IMG" mklabel msdos
parted -s "$IMG" mkpart primary fat16 1MiB 33MiB
parted -s "$IMG" mkpart primary fat16 33MiB 63MiB
parted -s "$IMG" set 2 hidden on

echo "[*] Formatting public partition (FAT16, 32MiB)"
LOOP1=$(losetup -f --show --offset $((P1_START*SECTOR)) --sizelimit $((P1_SIZE*SECTOR)) "$IMG")
mkfs.vfat -F 16 -n PUBLIC "$LOOP1" >/dev/null
mount "$LOOP1" "$MNT"
echo "This memory card can only be viewed with is1ab camera" > "$MNT/README.txt"
sync
umount "$MNT"
losetup -d "$LOOP1" ; LOOP1=""

echo "[*] Formatting hidden partition (FAT16, 30MiB) and writing multiple images (including qrcode.png)"
LOOP2=$(losetup -f --show --offset $((P2_START*SECTOR)) --sizelimit $((P2_SIZE*SECTOR)) "$IMG")
dd if=/dev/urandom of="$LOOP2" bs=1M status=none
mkfs.vfat -F 16 -n SECRET "$LOOP2" >/dev/null
mount "$LOOP2" "$MNT"

idx=1
for f in "${HFILES[@]}"; do
  ext="${f##*.}"
  cp "$f" "$MNT/photo_${idx}.${ext,,}"
  ((idx++))
done

dd if=/dev/urandom of="$MNT/.filler" bs=1M status=none || true
sync
rm -f "$MNT/.filler"

umount "$MNT"
losetup -d "$LOOP2" ; LOOP2=""


echo "[*] Performing full-partition XOR on hidden partition (key = '${KEY}')"
# NOTE: The end marker PY must start at column 0; arguments go before <<'PY'
python3 - "$IMG" "$P2_START" "$P2_SIZE" "$KEY" <<'PY'
import sys
img_path      = sys.argv[1]
part_start_lba= int(sys.argv[2])
part_size_sec = int(sys.argv[3])
key           = sys.argv[4].encode()

SECTOR=512
offset = part_start_lba * SECTOR
length = part_size_sec * SECTOR
chunk  = 1024*1024  # 1 MiB

with open(img_path, "rb+") as f:
    f.seek(offset)
    remain = length
    pos = 0  # Align key with partition start (must match when restoring)
    while remain > 0:
        n = min(chunk, remain)
        data = f.read(n)
        if not data:
            break
        enc = bytes([b ^ key[(pos+i) % len(key)] for i,b in enumerate(data)])
        f.seek(f.tell() - n)
        f.write(enc)
        remain -= n
        pos += n
PY

echo "[+] Done: $IMG"
echo "    - Partition 1: mountable, contains README.txt"
echo "    - Partition 2: fully XORed, cannot be mounted or inspected before restoration"
