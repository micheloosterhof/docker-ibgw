IMAGENAME = ibgw

all: Dockerfile
	docker build -t ${IMAGENAME} .

run:
	docker run ${IMAGENAME} --name ${IMAGENAME}
