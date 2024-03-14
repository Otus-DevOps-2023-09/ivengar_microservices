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

ДЗ 16 / Устройство Gitlab CI. Процесс непрерывной интеграции.

Gitlab на статичном ip:

yc vpc address create --external-ipv4 zone=ru-central1-a
51.250.85.155

yc compute instance create \
  --name gitlab-ci-vm \
  --cores 4 \
  --memory 8 \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4,nat-address=51.250.85.155 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2004-lts,size=15 \
  --ssh-key ~/.ssh/id_rsa.pub

docker-machine create \
  --driver generic \
  --generic-ip-address=51.250.85.155 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/id_rsa \
  gitlab-ci-vm

docker-machine ls
eval $(docker-machine env gitlab-ci-vm)
docker-machine ls

docker-compose up -d ( для прогона docker-compose c gitlab)


docker-machine ssh gitlab-ci-vm
Или
docker exec -it $(docker ps -q) /bin/bash
cat /etc/gitlab/initial_root_password

http://51.250.85.155/users/sign_in

 Обязательно сменить пароль  root
Создать группу, Потом проект,

Запушить в проект:
git remote add gitlab2 http://51.250.85.155//homework/example.git
git remote -v
—git remote rm gitlab2
git push gitlab2 gitlab-ci-1

docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:alpine

docker run -it -v gitlab-runner-config:/etc/gitlab-runner gitlab/gitlab-runner:ubuntu-v16.7.0 register


#sudo docker run --rm -it -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner:alpine register \
#  --non-interactive \
#  --url http://51.250.85.155/ \
#  --registration-token GR1348941jm_8UZU4-srwDWjs4V_d \
#  --executor docker \
#  --description "Brief description for the project" \
#  --tag-list "docker" \
#  --docker-image alpine:latest \
#  --docker-privileged \
#  --docker-volumes "/certs/client"

sudo gitlab-runner register \
sudo docker exec -it gl-runner gitlab-runner register \
  --
  --non-interactive \
  --url "https://gitlab.com" \
  --registration-token "GR1348941Mgi2hKkw5ATCCykkvwqK" \
  --executor "docker" \
  --docker-image alpine:latest  \
  --description "docker-runner" \
  --maintenance-note "Free-form maintainer notes about this runner" \
  --tag-list "docker,aws" \
  --run-untagged="true" \
  --locked="false" \
  --docker-privileged \
  --docker-volumes "/certs/client" \
  --access-level="not_protected"

docker exec -it otus-glr gitlab/gitlab-runner:ubuntu-v16.7.0 register \

## - Этот код работает!
sudo docker exec -it gl-runner gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com" \
  --registration-token "GR1348941Q75b3MeVfp2DV9m8wi9A" \
  --executor docker \
  --description "Brief description for the project" \
  --tag-list "docker" \
  --docker-image alpine:latest \
  --docker-privileged \
  --docker-volumes "/certs/client"


docker restart
docker exec -it otus-glr gitlab-runner run
docker logs


usermod -aG root gitlab-runner

sudo gitlab-runner start
sudo gitlab-runner run

git add .
git commit -m 'fix err2'
git push gitlab2 gitlab-ci-1

git add .
git commit -m '1.0.2'
git tag 1.0.2
git push gitlab2 gitlab-ci-1 --tags

image:
  name: jetty:latest
  user: jetty

sudo GITLAB_ROOT_PASSWORD="<strongpassword>" EXTERNAL_URL="http://gitlab.example.com" apt install gitlab-ee

ДЗ 17 / monitoring-1

yc compute instance create \
  --name docker-host \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/id_rsa.pub

docker-machine create \
  --driver generic \
  --generic-ip-address=51.250.70.24 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/id_rsa \
  docker-host

eval $(docker-machine env docker-host)

export USER_NAME=ivengar
docker build -t $USER_NAME/prometheus .

for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done


docker push $USER_NAME/ui
docker push $USER_NAME/comment
docker push $USER_NAME/post
docker push $USER_NAME/prometheus

git remote add d09 https://github.com/Otus-DevOps-2023-09/ivengar_microservices.git
git remote -v
git commit -a -m 'monitoring-1 '
git push  d09 HEAD


git clone --branch monitoring-1 https://github.com/Otus-DevOps-2023-09/ivengar_microservices.git

git fetch
git checkout origin/master

ДЗ 18 / kubernetes 1

Установка ВМ ubuntu1804

yc compute instance create \
  --name worker \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=45,type=network-ssd \
  --memory 4 \
  --cores 4 \
  --ssh-key ~/.ssh/id_rsa.pub

yc compute instance create \
  --name master \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=45,type=network-ssd \
  --memory 4 \
  --cores 4 \
  --ssh-key ~/.ssh/id_rsa.pub

Получаем адреса

    worker address: 62.84.125.246
    master address: 84.201.156.61

Заходим на воркер

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/engineer
    ssh yc-user@158.160.116.245
ssh -i ~/.ssh/id_rsa yc-user@62.84.125.246

Ставим докер 19.03

    sudo apt-get update
    sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install docker-ce=5:19.03.12~3-0~ubuntu-bionic docker-ce-cli=5:19.03.12~3-0~ubuntu-bionic containerd.io

Ставим кубер 1.19

    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
    sudo apt install kubectl=1.19.14-00 kubelet=1.19.14-00 kubeadm=1.19.14-00

Делаем то же самое на мастере
ssh -i ~/.ssh/id_rsa yc-user@84.201.156.61

Инициализируем мастер где 158.160.127.58 - мастер

    sudo kubeadm init --apiserver-cert-extra-sans=84.201.156.61 --apiserver-advertise-address=0.0.0.0 --control-plane-endpoint=84.201.156.61 --pod-network-cidr=10.244.0.0/16

В результате получаем команду, которую выполняем на воркере

Then you can join any number of worker nodes by running the following on each as root:

    sudo kubeadm join 158.160.127.58:6443 --token lrm8su.4n7nhhunqrv6g2je \
    --discovery-token-ca-cert-hash sha256:1111111111111111111111111111111111111111111111111111111111111111

Выполняем команды на мастере

    mkdir $HOME/.kube/
    sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $USER $HOME/.kube/config

Теперь можно посмотреть ноды

    kubectl get nodes

Смотрим описание

    kubectl describe node fhmh0n0e7jmkeoojeubk
    kubectl describe node fhmrd2jm0lloqod8n97d

Ставим калико (мастер нода)

    curl https://docs.projectcalico.org/archive/v3.15/manifests/calico.yaml -O


    vim calico.yaml

Листаем в почти в самый низ кнопкой PgDn (Page Down)

Раскомментируем и меняем строки

            - name: CALICO_IPV4POOL_CIDR
              value: "10.244.0.0/16"

Применяем

    kubectl apply -f calico.yaml

Проверяем

    kubectl get nodes

Создаем на мастере файлы из задания
Пробуем запустить

    kubectl apply -f ui-deployment.yml
    kubectl apply -f  post-deployment.yml
    kubectl apply -f  comment-deployment.yml
    kubectl apply -f  mongo-deployment.yml

Проверяем

    kubectl get pods

добавил terraform

ДЗ 19 // Применение системы логирования в инфраструктуре на основе Docker

создал тачку:

yc compute instance create \
  --name logging \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
   --memory 4 \
  --ssh-key ~/.ssh/id_rsa.pub

docker-machine create \
  --driver generic \
  --generic-ip-address=84.201.159.223 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/id_rsa \
  logging


eval $(docker-machine env logging)
eval $(docker-machine env --unset)

docker exec -it $(docker ps -q)

вот так запустить кибану:
eval $(docker-machine env logging)
cd ~/gith/ivengar_microservices/logging/fluentd/ && docker build -t ivengar/fluentd .
cd ~/gith/ivengar_microservices/src && docker-compose -f docker-compose-logging.yml up -d fluentd

zipkin в докер-машин не запустился, сделал на основном.

основные файлы в ~/gith/ivengar_microservices/src



ДЗ 20 // Основные модели безопасности и контроллеры в Kubernetes


minikube start --kubernetes-version=v1.19.7
minikube status

kubeclt config current-context
kubectl config get-contexts

kubectl get pods
kubectl get deployment

kubectl apply -f ./kubernetes/reddit


kubectl port-forward ui-5db787d674-gbk7w 9292:9292

minikube service list (-p minikube2)

minikube addons list

kubectl get all -n kube-system --selector k8s-app=kubernetes-dashboard

Если упал или ошибка можно удалить и пересоздать
minikube delete --profile=minikube2

minikube service ui -n dev

yc managed-kubernetes cluster get-credentials master-k8s --external
kubectl config current-context
kubectl apply -f ./kubernetes/reddit/dev-namespace.yml
kubectl apply -f ./kubernetes/reddit/ -n dev

kubectl get nodes -o wide
kubectl describe service ui -n dev | grep NodePort
