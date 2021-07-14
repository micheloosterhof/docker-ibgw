IMAGENAME = ibgw
CONTAINERNAME= ibgw

.PHONY: all
all: Dockerfile
	docker build -t ${IMAGENAME} .

.PHONY: start
start:
	docker run -p 4000:4000/tcp -d --name ${CONTAINERNAME} ${IMAGENAME}

.PHONY: stop
stop:
	docker stop ${CONTAINERNAME}
	docker rm ${CONTAINERNAME}

.PHONY: clean
clean:
	docker rmi ${IMAGENAME}

.PHONY: shell
shell:
	docker exec -it ${CONTAINERNAME} bash

.PHONY: logs
logs:
	docker logs ${CONTAINERNAME}

.PHONY: ps
ps:
	docker ps -a -f name=${CONTAINERNAME}

.PHONY: status
status: ps

.PHONY: ip
ip:
	docker inspect ${CONTAINERNAME} | jq '..|.IPAddress?' | grep -v null | sort -u

.PHONY: download
download: IBCLinux-3.8.7.zip ibgateway-stable-standalone-linux-x64.sh ibgateway-latest-standalone-linux-x64.sh

IBCLinux-3.8.7.zip:
	wget https://github.com/IbcAlpha/IBC/releases/download/3.8.7/IBCLinux-3.8.7.zip

ibgateway-stable-standalone-linux-x64.sh:
	wget https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh

ibgateway-latest-standalone-linux-x64.sh:
	wget https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh
