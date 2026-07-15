run-project:
	# run project
	@echo "Grafana UI: http://localhost:3000"

test-api:
	curl -X POST "https://localhost/predict" \
     -H "Content-Type: application/json" \
     -d '{"sentence": "Oh yeah, that was soooo cool!"}' \
	 --user admin:admin \
     --cacert ./deployments/nginx/certs/nginx.crt;

test-apiv2:
	curl -X POST "https://localhost/predict" \
     -H "Content-Type: application/json" \
	 -H "X-Experiment-Group: debug" \
     -d '{"sentence": "Oh yeah, that was soooo cool!"}' \
	 --user admin:admin \
     --cacert ./deployments/nginx/certs/nginx.crt;

start-project: 
	docker compose -p nginx-exam up -d --build

stop-project:
	docker compose -p nginx-exam down

rerun: stop-project start-project

test:
	./tests/run_tests.sh