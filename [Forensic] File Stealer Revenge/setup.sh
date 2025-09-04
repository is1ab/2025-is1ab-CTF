#!/bin/bash
# CTF "壞掉的相機" - 一鍵出題腳本（FAT16 + 整區 XOR 混淆）
set -euo pipefail

### === 參數 ===
IMG="file_stealer_revenge.img"
SIZE_MB=64
SECTOR=512

# 幾何（與 parted 對齊）
P1_START=2048    # 1 MiB
P1_SIZE=65536    # 32 MiB / 512 = 65536 sectors
P2_START=67584   # 33 MiB
P2_SIZE=61440    # 30 MiB

# 素材來源（qrcode.png 請放在這個資料夾內）
HIDDEN_SRC_DIR="./hidden_photos"

# XOR 金鑰
KEY="is1ab"

### === 檢查依賴 ===
need() { command -v "$1" >/dev/null 2>&1 || { echo "[-] 缺少指令：$1" >&2; exit 1; }; }
for c in dd parted losetup mkfs.vfat mount umount python3; do need "$c"; done
[[ -d "$HIDDEN_SRC_DIR" ]] || { echo "[-] 找不到資料夾：$HIDDEN_SRC_DIR" >&2; exit 1; }

# 收集圖片（png/jpg/jpeg；大小總量請自行控制 < 30 MiB）
shopt -s nullglob nocaseglob
HFILES=( "$HIDDEN_SRC_DIR"/*.png "$HIDDEN_SRC_DIR"/*.jpg "$HIDDEN_SRC_DIR"/*.jpeg )
shopt -u nocaseglob
if (( ${#HFILES[@]} == 0 )); then
  echo "[-] $HIDDEN_SRC_DIR 裡沒有 png/jpg/jpeg 檔（至少放一張，含你的 qrcode.png）" >&2
  exit 1
fi

### === 安全清理 ===
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

echo "[*] 建立 ${SIZE_MB}MiB 映像：$IMG"
dd if=/dev/zero of="$IMG" bs=1M count="$SIZE_MB" status=none

echo "[*] 建立分割表與分割區（FAT16, hidden #2）"
parted -s "$IMG" mklabel msdos
parted -s "$IMG" mkpart primary fat16 1MiB 33MiB
parted -s "$IMG" mkpart primary fat16 33MiB 63MiB
parted -s "$IMG" set 2 hidden on

echo "[*] 格式化公開分割區 (FAT16, 32MiB)"
LOOP1=$(losetup -f --show --offset $((P1_START*SECTOR)) --sizelimit $((P1_SIZE*SECTOR)) "$IMG")
mkfs.vfat -F 16 -n PUBLIC "$LOOP1" >/dev/null
mount "$LOOP1" "$MNT"
echo "此記憶卡只能使用 is1ab camera 查看" > "$MNT/README.txt"
sync
umount "$MNT"
losetup -d "$LOOP1" ; LOOP1=""

echo "[*] 格式化隱藏分割區 (FAT16, 30MiB) 並寫入多張圖片（包含 qrcode.png）"
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


echo "[*] 對隱藏分割區做整區 XOR（key = '${KEY}'）"
# 注意：收尾標記 PY 必須頂格，參數放在 <<'PY' 之前！
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
    pos = 0  # 以分割區起點為 0 對齊 key（還原時需相同）
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

echo "[+] 完成：$IMG"
echo "    - 第1分割區：可掛載，含 README.txt"
echo "    - 第2分割區：已整區 XOR，未復原前無法掛載、看不出檔案數量"
