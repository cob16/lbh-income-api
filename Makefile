build:
	docker-compose build

serve:
	-rm tmp/pids/server.pid &> /dev/null
	docker-compose up

bundle:
	docker-compose run --rm app bundle
	docker-compose build
