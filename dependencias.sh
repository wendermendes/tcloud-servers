#!/bin/bash

apt update && apt upgrade -y

apt remove docker docker-engine docker.io containerd runc

apt update

apt install ca-certificates curl gnupg -y

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose docker-compose-plugin -y

sudo mkdir -p /docker/config
#mkdir -p /docker/volumes/tcloud-cu01

sudo echo "
---
version: "2.1"
services:
  unifi-controller:
    image: lscr.io/linuxserver/unifi-controller:latest
    container_name: unifi-controller
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - MEM_LIMIT=1024
      - MEM_STARTUP=1024
    volumes:
      - /path/to/data:/config
    ports:
      - 8443:8443 #pagina administracao web
      - 3478:3478/udp #unifi stun
      - 10001:10001/udp #descoberta ap
      - 8080:8080 #comunicacao dispositivo
      - 1900:1900/udp #descoberta controladora l2
      - 8843:8843 #redirecionamento https portal visitantes
      - 8880:8880 #redirecionamento http portal visitantes
      - 6789:6789 #teste de velocidade mobile
    restart: unless-stopped
" >> /docker/config/docker-compose.yml

docker-compose up -d

#docker ps
