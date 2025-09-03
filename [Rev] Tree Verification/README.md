# 安裝

1. 開啟 CMD
2. `cd` 到 `chal.c`、`packer.py`、以及 `unpack_stub.c` 所在的目錄
3. 使用 `gcc` 以 32 位元編譯
4. 使用自製加殼器 `packer.py` 為執行檔加殼

## 編譯方式

```shell
gcc -s -m32 .\chal.c -o chal.exe
```

- `-s`: 去除符號表和重定位資訊表

## 加殼方式

```shell
python packer.py chal.exe -o chal.exe
```