IMAGENAME = ibgw
CONTAINERNAME= ibgw

all: Dockerfile
	docker build -t ${IMAGENAME} .

start:
	docker run -p 4001:4001/tcp -p 4002:4002/tcp -d --name ${CONTAINERNAME} ${IMAGENAME}

stop:
	docker stop ${CONTAINERNAME}
	docker rm ${CONTAINERNAME}

clean:
	docker rmi ${IMAGENAME}

shell:
	docker exec -it ${CONTAINERNAME} bash

logs:
	docker logs ${CONTAINERNAME}

ps:
	docker ps -a -f name=${CONTAINERNAME}

status: ps

ip:
	docker inspect ${CONTAINERNAME} | jq '..|.IPAddress?' | grep -v null | sort -u

