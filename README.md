# OwnCloudX with Apache and SSL

## Technology Used
- OwnCloudX
- Apache2
- OpenSSL
- PHP7.4
- Docker & Docker Compose


## Installation
Clone the repository and perform the following commands in your terminal:
```sh
git clone https://github.com/kiranparajuli589/ownCloudX-apache-ssl.git
cd ownCloudX-apache-ssl
docker compose up --build # using compose version 2
```

## Configuration
- Apache
  - SSL Certificates: already generated and placed at `./certs` directory
- OwncloudX
  - `config.php` in sync with the container config location with docker volumes

## Usage
- Open your browser and go to `https://localhost:8443`, a test html page is shown.
- Then browse to `https://localhost:8443/owncloud` to access owncloudX.