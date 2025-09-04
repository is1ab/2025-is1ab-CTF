The disk image has **two** partitions:

* **p1 (FAT16)** — mounts normally and contains a generic `README.txt`.
* **p2 (exFAT)** — **unmountable** because the **first 24 sectors (main boot / backup boot / boot checksum)** were wiped.
  Inside p2 there is a **PNG** at `/DCIM/100CAM/CAM00001.PNG`, but its **8-byte PNG signature is corrupted** (the first byte was changed from `0x89` to `0x00`), so image viewers refuse to open it.
  Goal: recover p2 → extract the file → fix the PNG signature → open the image to read the flag.

---

# 0. Recon

```bash
fdisk -l file_stealer*.img
# Example (per the build script):
# p1: Start=2048,  Size=65536 sectors    (starts at 1 MiB, size 32 MiB)
# p2: Start=67584, Size=61440 sectors    (starts at 33 MiB, size 30 MiB)
```

Attempting to mount p2 (expected to fail):

```bash
SECTOR=512
P2_START=67584
P2_SIZE=61440
LOOP=$(sudo losetup -f --show --offset $((P2_START*SECTOR)) --sizelimit $((P2_SIZE*SECTOR)) file_stealer_revenge_revenge.img)
sudo mount "$LOOP" /mnt   # will fail
sudo losetup -d "$LOOP"
```

Verify that p2’s boot/backup/checksum area was zeroed (first 24 sectors):

```bash
dd if=file_stealer_revenge.img bs=$SECTOR skip=$P2_START count=24 status=none | hexdump -C | head
# should be mostly 00s
```

---

# Path A: Rebuild exFAT boot → Mount p2 → Fix PNG

## A-1. Extract p2 (raw)

```bash
dd if=file_stealer_revenge.img of=p2.enc.raw bs=$SECTOR skip=$P2_START count=$P2_SIZE status=none
```

## A-2. Create a same-size “stub exFAT” and copy its first 24 boot sectors

```bash
dd if=/dev/zero of=stub.img bs=$SECTOR count=$P2_SIZE status=none
mkfs.exfat -n STUB stub.img >/dev/null

# Copy stub’s first 24 sectors over p2.enc.raw
cp p2.enc.raw p2.rebuilt
dd if=stub.img of=p2.rebuilt bs=$SECTOR count=24 conv=notrunc status=none
```

> Why this works: with the same partition size and the same mkfs tool, exFAT boot geometry (FAT offsets, cluster heap start, cluster size, etc.) is usually identical. Restoring **main/backup boot + checksum (sectors 0..23)** gives the OS enough metadata to mount.

## A-3. Mount and extract the PNG

```bash
sudo mount -o loop p2.rebuilt /mnt
ls -R /mnt/DCIM/100CAM
# Expect: CAM00001.PNG and REPAIR_NOTE.txt

cp /mnt/DCIM/100CAM/CAM00001.PNG .
sudo umount /mnt
```

## A-4. Repair the PNG signature (set first byte back to 0x89)

Correct PNG signature: `89 50 4E 47 0D 0A 1A 0A`

We only need to change the **first** byte from `00` to `89`.

**Method 1 (hex patch via dd):**

```bash
printf '\x89' | dd of=CAM00001.PNG bs=1 seek=0 count=1 conv=notrunc
```

**Method 2 (Python one-liner):**

```bash
python3 - <<'PY'
p="CAM00001.PNG"
with open(p,"r+b") as f:
    f.seek(0); f.write(b'\x89')
PY
```

> Note: PNG chunk CRCs **do not include** the 8-byte file signature, so fixing the signature doesn’t invalidate any CRCs.

## A-5. Open the PNG to get the flag

Just open `CAM00001.PNG` (or the copied file) in any image viewer. The flag is rendered inside the image.

---

# Path B: Skip boot rebuild — find the “almost-PNG” in raw → Fix → Carve

Because the challenge only flips the first signature byte to `00`, the header bytes appear as:

```
00 50 4E 47 0D 0A 1A 0A
```

You can search the **entire image** for this 8-byte sequence, fix the first byte to `0x89`, then carve the PNG out.

## B-1. Find the broken signature sequence

```bash
# Print offsets (in bytes) where the broken signature occurs
python3 - <<'PY'
import re
data=open("file_stealer_revenge_revenge.img","rb").read()
pat=b"\x00PNG\r\n\x1a\n"
for m in re.finditer(re.escape(pat), data):
    print(m.start())
PY
# Record an offset, e.g. OFFSET=12345678
```

(You can also use `rg -aob`, `xxd`, or `binwalk -R`.)

## B-2. Patch that byte in place

```bash
OFFSET=12345678   # use the found offset
printf '\x89' | dd of=file_stealer_revenge_revenge.img bs=1 seek=$OFFSET count=1 conv=notrunc
```

## B-3. Carve the PNG starting at that offset (until `IEND`)

```bash
python3 - <<'PY'
import sys, struct
img="file_stealer_revenge_revenge.img"
offset=int(sys.argv[1])
with open(img,"rb") as f, open("carved.png","wb") as out:
    f.seek(offset)
    out.write(f.read(8))  # PNG signature
    while True:
        hdr=f.read(8)
        if len(hdr)<8: break
        length, ctype = struct.unpack(">I4s", hdr)
        data=f.read(length)
        crc=f.read(4)
        out.write(hdr+data+crc)
        if ctype == b'IEND':
            break
print("saved carved.png")
PY $OFFSET
```

Open `carved.png` to see the flag.

> Intuition: the signature differs by **one byte**. If you suspect a “nearly-PNG,” searching for `\x00PNG\r\n\x1a\n` lets you locate and repair it without rebuilding the filesystem.

---

# Why this challenge has two layers

1. **Filesystem layer:** exFAT main/backup boot + checksum (sectors 0..23) are zeroed, so you can’t mount. You must either rebuild the boot area or work with raw carving.
2. **File layer:** the PNG’s 8-byte signature has a 1-byte corruption. Changing it back to `89 50 4E 47 0D 0A 1A 0A` restores readability; per-chunk CRCs are unaffected by the signature.

---

# Common Pitfalls

* **Sector alignment:** extract/restore using 512-byte boundaries (this image uses 512-byte logical sectors).
* **Accurate `P2_SIZE`:** take “Size in sectors” from `fdisk -l`; wrong counts lead to truncated/overlong extracts.
* **Magic-based carving fails?** Standard PNG magic won’t match because the signature was altered; either rebuild exFAT or search for the **broken** signature and fix it.
* **Still won’t open after fix?** Ensure you patched the correct file/offset. It’s often easier to copy/carve the file out and patch the copy.
