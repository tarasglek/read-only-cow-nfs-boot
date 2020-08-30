all:
	docker build --build-arg KERNEL=5.4.0-37-generic -t linux-live .
	docker run -ti -v `pwd`/out:/tmp linux-live ./build-disk.sh
	