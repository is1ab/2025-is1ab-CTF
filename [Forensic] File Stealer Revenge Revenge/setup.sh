#!/bin/bash
# Forensic/PNG repair challenge — p1: FAT16 note, p2: exFAT with destroyed boot; contains a PNG with a broken header
set -euo pipefail

IMG=file_stealer_revenge_revenge.img
SIZE_MB=64
SECTOR=512

# Geometry (MiB aligned)
P1_START=2048       # 1 MiB
P1_SIZE=65536       # 32 MiB
P2_START=67584      # 33 MiB
P2_SIZE=61440       # 30 MiB  (leave 1 MiB before end for safety)

# Your prepared PNG (shows the flag inside the image/frames you designed)
PNG_SRC="./camera.png"   # provide any PNG you like

# Dependency checks
need(){ command -v "$1" >/dev/null 2>&1 || { echo "[-] Missing: $1"; exit 1; }; }
for c in dd parted losetup mkfs.vfat mount umount mkfs.exfat python3 hexdump; do need "$c"; done
[[ -f "$PNG_SRC" ]] || { echo "[-] PNG not found: $PNG_SRC"; exit 1; }

mkdir -p /mnt/ctf
cleanup(){
  set +e
  mountpoint -q /mnt/ctf && umount /mnt/ctf
  [[ -n "${LOOP1:-}" ]] && losetup -d "$LOOP1" 2>/dev/null
  [[ -n "${LOOP2:-}" ]] && losetup -d "$LOOP2" 2>/dev/null
}
trap cleanup EXIT

echo "[*] Creating ${SIZE_MB}MiB image: $IMG"
dd if=/dev/zero of="$IMG" bs=1M count="$SIZE_MB" status=none

echo "[*] Creating partition table"
parted -s "$IMG" mklabel msdos
parted -s "$IMG" mkpart primary fat16 1MiB 33MiB
parted -s "$IMG" mkpart primary fat32 33MiB 63MiB
parted -s "$IMG" set 2 hidden on

# ---- p1: FAT16 + README (mountable) ----
echo "[*] Set up p1 (FAT16)"
LOOP1=$(losetup -f --show --offset $((P1_START*SECTOR)) --sizelimit $((P1_SIZE*SECTOR)) "$IMG")
mkfs.vfat -F 16 -n PUBLIC "$LOOP1" >/dev/null
mount "$LOOP1" /mnt/ctf
echo "Public area. Nothing interesting here." > /mnt/ctf/readme.txt
sync; umount /mnt/ctf
losetup -d "$LOOP1"; unset LOOP1

# ---- p2: exFAT + place PNG ----
echo "[*] Set up p2 (exFAT) and write PNG"
LOOP2=$(losetup -f --show --offset $((P2_START*SECTOR)) --sizelimit $((P2_SIZE*SECTOR)) "$IMG")
mkfs.exfat -n SECRET "$LOOP2" >/dev/null
mount "$LOOP2" /mnt/ctf

# Place file under a camera-like path
mkdir -p /mnt/ctf/DCIM/100CAM
cp "$PNG_SRC" /mnt/ctf/DCIM/100CAM/CAM00001.PNG

sync

# Break the PNG signature so viewers can't open it; players must fix the first 8 bytes
python3 - <<'PY'
import sys, os
p = "/mnt/ctf/DCIM/100CAM/CAM00001.PNG"
with open(p, "r+b") as f:
    header = f.read(8)
    # Correct PNG signature: 89 50 4E 47 0D 0A 1A 0A
    # Overwrite the first byte with 00
    bad = b"\x00" + header[1:]
    f.seek(0)
    f.write(bad)
# Note: PNG chunk CRCs do not cover the 8-byte signature, so this is a minimally repairable corruption.
PY

# Optional: subtle service note (no explicit signature bytes)
cat > /mnt/ctf/DCIM/100CAM/REPAIR_NOTE.txt <<'TXT'
[Camera Service Note]
- PNG sample cannot be previewed on PC.
- Header anomaly at the very start (first 8 bytes).
- Compare with a valid PNG file signature and restore accordingly.
TXT

umount /mnt/ctf
losetup -d "$LOOP2"; unset LOOP2

# ---- Finally: wipe exFAT Main/Backup Boot + Boot Checksum (first 24 sectors of the partition) ----
echo "[*] Destroying p2 boot/backup/checksum (sectors 0..23 relative to the partition)"
dd if=/dev/zero of="$IMG" bs=$SECTOR seek=$P2_START count=24 conv=notrunc status=none

echo "[+] Done: $IMG"
echo "    - p1: FAT16 mountable, contains readme.txt"
echo "    - p2: exFAT boot destroyed; contains one PNG with a broken header"
