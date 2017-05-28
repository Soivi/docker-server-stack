#! /bin/bash

sudo docker-compose -f docker-compose.fluentd.yaml up -d
sleep 5s
sudo docker-compose -f docker-compose.soivi.lamp.yaml up -d
sudo docker-compose -f docker-compose.kontiomaa.lamp.yaml up -d
sudo docker-compose -f docker-compose.soivi.wp.yaml up -d
sudo docker-compose -f docker-compose.kontiomaa.wp.yaml up -d
sleep 5s
sudo docker-compose -f docker-compose.proxy.yaml up -d
