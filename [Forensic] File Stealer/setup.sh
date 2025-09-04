#!/bin/bash
# 建兩分割區（FAT16），公開區放 README，隱藏區只放 tar.gz（內含 flag 文本）
set -euo pipefail

IMG=file_stealer.img
SECTOR=512

# 幾何參數
P1_START=2048       # 1MiB
P1_SIZE=65536       # 32MiB
P2_START=67584      # 33MiB
P2_SIZE=61440       # 30MiB

FLAG_CONTENT='is1abCTF{h1dd3n_p4rt1t10n_1s_4w3s0m3}'

# 需求工具
for c in dd parted losetup mkfs.vfat mount umount tar gzip; do
  command -v "$c" >/dev/null || { echo "[-] 缺少 $c"; exit 1; }
done

# 建立映像
dd if=/dev/zero of="$IMG" bs=1M count=64 status=none

# 建 MBR + 分割區（FAT16，第二顆 hidden）
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

# p1（公開）
LOOP1=$(losetup -f --show --offset $((P1_START*SECTOR)) --sizelimit $((P1_SIZE*SECTOR)) "$IMG")
mkfs.vfat -F 16 -n PUBLIC "$LOOP1" >/dev/null
mount "$LOOP1" /mnt/ctf
echo "Public area. Nothing interesting here." > /mnt/ctf/readme.txt
sync; umount /mnt/ctf; losetup -d "$LOOP1"; LOOP1=""

# 準備 tar.gz（内部檔名避免出現 'flag' 字樣）
echo "$FLAG_CONTENT" > "$TMPDIR/doc.txt"
# -C 切換工作目錄，避免把路徑打包進去；-z 使用 gzip
tar -C "$TMPDIR" -czf "$TMPDIR/media_update.tar.gz" doc.txt
rm -f "$TMPDIR/doc.txt"

# p2（隱藏）：只放 tar.gz；不要把 flag.txt 直接放分割區！
LOOP2=$(losetup -f --show --offset $((P2_START*SECTOR)) --sizelimit $((P2_SIZE*SECTOR)) "$IMG")
mkfs.vfat -F 16 -n SECRET "$LOOP2" >/dev/null
mount "$LOOP2" /mnt/ctf
# 檔名做得普通一點
cp "$TMPDIR/media_update.tar.gz" /mnt/ctf/DCIM_0001.TGZ
sync; umount /mnt/ctf; losetup -d "$LOOP2"; LOOP2=""

echo "[+] Output: $IMG"
