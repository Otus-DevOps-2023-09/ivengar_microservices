# ivengar_microservices
ivengar microservices repository

ДЗ 12 / Введение в Docker

1. Осовные комманды
docker run # создает и запускает новый контейнер из образа
docker ps # отображает список запущенных контейнеров
docker images # отображает список доступных образов
docker pull # загружает образ из репозитория Docker Hub
docker build # создает новый образ на основе Dockerfile
docker stop # останавливает контейнер
docker start # запускает ранее остановленный контейнер
docker rm # удаляет контейнер
docker rmi # удаляет образ
docker info # информация о работоспособности клиент-сервера
docker inventori # Полная информация о онтейнере

ДЗ 13 / Docker под капотом.

2. Удалени образов:
docker ps -a
docker stop $(docker ps -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)

3. Установка docker-machine
curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
docker-machine -v

4. ssh-keygen -h

yc compute instance create \
  --name docker-host \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/id_rsa.pub

docker-machine create \
  --driver generic \
  --generic-ip-address=51.250.70.208 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/id_rsa \
  docker-host

docker-machine ls
eval $(docker-machine env docker-host) # переключение на работу в докер машине
eval $(docker-machine env --unset)  # переключение обратно на локальную машину

5. docker-hub
docker tag reddit:latest ivengar/otus-reddit:1.0
docker push ivengar/otus-reddit:1.0
docker run --name reddit -d -p 9292:9292 ivengar/otus-reddit:1.0

6. docker-machine rm docker-host
yc compute instance delete docker-host

ДЗ 14 / Микросервисы
1.
docker pull mongo:4
docker build -t ivengar/post:1.0 ./post-py
docker build -t ivengar/comment:1.0 ./comment
docker build -t ivengar/ui:1.0 ./ui
2.
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:4
docker run -d --network=reddit --network-alias=post ivengar/post:1.0
docker run -d --network=reddit --network-alias=comment ivengar/comment:1.0
docker run -d --network=reddit -p 9292:9292 ivengar/ui:1.0

http://51.250.88.216:9292/
3.
docker run --rm -i hadolint/hadolint < Dockerfile
4.
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:4
docker run -d --network=reddit --network-alias=post ivengar/post:2.0
docker run -d --network=reddit --network-alias=comment ivengar/comment:1.0
docker run -d --network=reddit -p 9292:9292 ivengar/ui:2.0

http://ip:9292/

ДЗ 15 / Сетевое взаимодействие. Docker Compose.


docker run -d --network=reddit mongo:4
docker run -d --network=reddit ivengar/post:1.0
docker run -d --network=reddit ivengar/comment:1.0
docker run -d --network=reddit -p 9292:9292 ivengar/ui:1.0

--network-alias=post_db --networkalias=comment_db
docker run -d --network=reddit --network-alias=post_db --networkalias=comment_db mongo:4
docker run -d --network=reddit --network-alias=post ivengar/post:1.0
docker run -d --network=reddit --network-alias=comment ivengar/comment:1.0
docker run -d --network=reddit -p 9292:9292 ivengar/ui:1.0

docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24

docker run -d --network=front_net -p 9292:9292 --name ui  ivengar/ui:1.0
docker run -d --network=back_net --name comment  ivengar/comment:1.0
docker run -d --network=back_net --name post  ivengar/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:4

docker network connect front_net post
docker network connect front_net comment

docker-machine ssh docker-host
sudo apt-get update && sudo apt-get install bridge-utils
Sudo docker network ls
ifconfig | grep br
brctl show br-85be08b0eae0
sudo iptables -nL -t nat
ps ax | grep docker-proxy
Exit

export USERNAME=ivengar
docker-compose up -d
docker-compose ps

-p, --project-name NAME     Specify an alternate project name
