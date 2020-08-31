all:
	docker build --build-arg KERNEL=5.4.0-37-generic --build-arg USER_GROUP=$(shell id -u):$(shell id -g) -t linux-live .
	docker run -ti -v `pwd`/out:/tmp linux-live ./build-disk.sh
	