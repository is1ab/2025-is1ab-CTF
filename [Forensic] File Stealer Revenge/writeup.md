# TL;DR

You are given `file_stealer.img`. `fdisk`/`testdisk` shows two partitions: one is mountable (and contains a hint), the other appears corrupted.

The second partition's entire byte range was XORed repeatedly with the key `is1ab`. XORing the same partition byte range again with the same key (starting at the partition boundary) restores the filesystem. After mounting you will find multiple images; one contains a QR code with the flag.

## Solution steps

### 1) Inspect partitions and get the hint

```bash
# List partition geometry
fdisk -l file_stealer.img
# Example output (your values may differ):
# Start=2048, Size=65536 (partition 1, ~32MiB)
# Start=67584, Size=61440 (partition 2, ~30MiB)

# Record these numbers from your fdisk output
P1_START=2048
P1_SIZE=65536
P2_START=67584
P2_SIZE=61440
SECTOR=512

# Mount partition 1 (public)
sudo losetup -f --show --offset $((P1_START*SECTOR)) --sizelimit $((P1_SIZE*SECTOR)) file_stealer.img
# output like /dev/loopX — note it
LOOP1=/dev/loopX
sudo mkdir -p /mnt/p1 && sudo mount "$LOOP1" /mnt/p1
cat /mnt/p1/README.txt
# Expected hint: "this card can only be viewed by is1ab camera" → suggests key is "is1ab"
sudo umount /mnt/p1 && sudo losetup -d "$LOOP1"
```

Attempting to mount partition 2 will fail because it was XORed and appears corrupted:

```bash
sudo losetup -f --show --offset $((P2_START*SECTOR)) --sizelimit $((P2_SIZE*SECTOR)) file_stealer.img
# mount will error — this is expected
sudo losetup -d /dev/loopY
```

### 2A) Recover partition 2 (when you know the key)

Work on a copy to avoid modifying the original image: extract the partition to a file, XOR-decode that file, then mount the decoded file.

```bash
# Extract raw bytes of partition 2
dd if=file_stealer.img of=p2.enc.raw bs=$SECTOR skip=$P2_START count=$P2_SIZE status=none

# XOR the file with key "is1ab" (start at offset 0)
python3 - <<'PY'
key = b"is1ab"
with open("p2.enc.raw","rb") as f:
   data = f.read()
dec = bytes([b ^ key[i % len(key)] for i, b in enumerate(data)])
with open("p2.dec.img","wb") as out:
   out.write(dec)
print("decoded -> p2.dec.img")
PY

# Mount the restored partition image (FAT16)
sudo mkdir -p /mnt/p2 && sudo mount -o loop p2.dec.img /mnt/p2
ls -l /mnt/p2
```

You should see multiple image files, including a QR image. Scan it:

```bash
# If available, use zbarimg to scan QR codes from the command line
zbarimg /mnt/p2/*.png /mnt/p2/*.jpg 2>/dev/null
# Example output: QR-Code:is1abCTF{...}
```

If you don't have `zbarimg`, open the image with a viewer or scan it with a phone.

After finishing, unmount:

```bash
sudo umount /mnt/p2
```

### 2B) Recover without the key (optional)

FAT16 boot sector (at partition offset 0) has predictable fields such as a jump instruction, OEM name, BytesPerSec (512), ReservedSectors (1), NumFATs (2), and the trailing signature 0x55AA at offsets 510–511. If you suspect a short repeated XOR key, you can brute-force short key lengths (e.g., 1–8 bytes) and test whether decoded BPB fields look consistent. Below is a simple detector example for learning purposes.

```python
# detect_key.py
import sys

img = open("p2.enc.raw","rb").read()
boot = img[:512]

def score(buf):
   bps = int.from_bytes(buf[11:13], 'little')
   spc = buf[13]
   rs  = int.from_bytes(buf[14:16], 'little')
   nf  = buf[16]
   re  = int.from_bytes(buf[17:19], 'little')
   sig = buf[510:512]
   ok = 0
   ok += (bps in (512,1024,2048,4096))
   ok += (spc in (1,2,4,8,16,32,64))
   ok += (rs == 1)
   ok += (nf in (1,2))
   ok += (re % 16 == 0 and re > 0)
   ok += (sig == b'\x55\xaa')
   return ok

for L in range(1,9):
   for key_int in range(256**L):
      key = key_int.to_bytes(L, 'big')
      dec = bytes([b ^ key[i % L] for i, b in enumerate(boot)])
      if score(dec) >= 5:
            print("candidate key len", L, "=", key)
            sys.exit(0)
print("no key found")
```

In this challenge the public partition already hints `is1ab`, so 2A is the faster route; 2B is shown for forensic practice.

## Why files are not visible before recovery

The entire partition byte range was XORed, including:

- Boot sector (BPB)
- FAT tables
- Root and subdirectories
- Data clusters

Before XOR recovery, filesystem metadata (directory entries, FAT chains) are unreadable, so files can't be listed or mounted. XORing the same byte range with the same key restores the bytes and makes FAT16 valid again.

## Common pitfalls & troubleshooting

- Mounting partition 2 always fails: expected — it was XORed. Decode first.
- XOR alignment: you must align to the partition start (not the whole image header). Extracting the partition with `dd` ensures correct alignment because `p2.enc.raw` starts at the partition boundary.
- Repeating key: `is1ab` is 5 bytes; decode with key[i % 5].
- Don't modify the original image: `dd` the partition first and work on a copy to preserve evidence.
- No QR visible: confirm you decoded the correct partition (used skip=P2_START) and used the key `is1ab`.

## Quick reference commands

```bash
# geometry (use your fdisk output)
P2_START=67584; P2_SIZE=61440; SECTOR=512

# extract → decode → mount
dd if=file_stealer.img of=p2.enc.raw bs=$SECTOR skip=$P2_START count=$P2_SIZE status=none
python3 - <<'PY'
data = open("p2.enc.raw","rb").read()
key = b"is1ab"
open("p2.dec.img","wb").write(bytes([b ^ key[i%len(key)] for i,b in enumerate(data)]))
PY
sudo mount -o loop p2.dec.img /mnt/p2
ls /mnt/p2
```

Scan the QR to get the flag. 🎉

## Summary

This challenge applies a repeated-key XOR at the partition level. The public partition provides a hint for the key. XOR the same partition byte range with that key to restore the filesystem, then mount and retrieve the hidden images and QR flag.


