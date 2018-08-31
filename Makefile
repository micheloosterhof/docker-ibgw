IMAGENAME = ibgw

all: Dockerfile
	docker build -t ${IMAGENAME} .

run:
	docker run ${IMAGENAME} --name ${IMAGENAME}

clean:
	docker rmi ${IMAGENAME}

shell:
        docker exec -it ${IMAGENAME} bash
