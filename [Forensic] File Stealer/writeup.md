
# 📝 Writeup

### Background

You received a Micro SD card image (`easy.img`), but no files are visible. Your task is to find the hidden files.

### Solution Steps

1. Use **fdisk** / **parted** to check the disk structure:

    ```bash
    fdisk -l easy.img
    ```

    ➝ You will find **two partitions**, but one is marked as hidden.

2. Use **testdisk** to scan:

    ```bash
    testdisk easy.img
    ```

    * Select `Analyse` → `Quick Search`
    * Discover the **second partition**
    * Choose `List Files` → Find the files

