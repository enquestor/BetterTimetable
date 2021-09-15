.PHONY: build dev clean

all: build

build: 
	./build.sh

dev:
	(trap 'kill 0' SIGINT; (docker-compose up redis) & (cd server && npm run dev))

clean:
	rm *.zip