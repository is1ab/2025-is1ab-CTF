# Installation

To deploy this CTF challenge by using Docker, please follow these steps:

## Clone the repository

```shell
git clone <repository_url>
cd "[Web] EasySQLi"
```

## Build the Docker image

```shell
docker build -t is1ab-easy-sqli-ctf .
```

## Run the Docker container

```shell
docker run -d -p 8080:80 --name iis1ab-easy-sqli-ctf is1ab-easy-sqli-ctf
```

## Access the application

Open your web browser and navigate to `http://localhost:8080` to access the EasySQLi CTF challenge.

## 備註

- 此題網頁內的 request 會有 3 秒一次的 rate limit 以搞人心態。
