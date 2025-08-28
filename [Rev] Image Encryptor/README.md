# Installation

To compile this CTF challenge from the source, please follow these steps:

## Clone the repository

```shell
git clone <repository_url>
cd "[Rev] Image Encryptor"
```

## Compile the source

```shell
gcc -s .\encryptor.c -o encryptor.exe
```

## Pack this executable.

```shell
upx .\encryptor.exe
```

## Run the application

Before run it, make sure "image.jpg" is in the same directory

```shell
.\encryptor.exe
```