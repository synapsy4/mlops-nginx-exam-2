# NGINX Exam

## Architecture

```text
. 
├── Makefile
├── README.md
├── README_student.md
├── deployments
│   ├── nginx
│   │   ├── Dockerfile
│   │   ├── certs
│   │   │   ├── nginx.crt
│   │   │   └── nginx.key
│   │   ├── .htpasswd
│   │   └── nginx.conf
│   └── prometheus
│       └── prometheus.yml
├── docker-compose.yml
├── model
│   └── model.joblib
├── src
│   └── api
│       ├── requirements.txt
│       ├── v1
│       │   ├── Dockerfile
│       │   └── main.py
│       └── v2
│           ├── Dockerfile
│           └── main.py
└── tests
    └── run_tests.sh
```

## Usage

In the **Makefile** the most important commands are defined, which can be called by:

- `make start-project`: Runs _docker compose up_ which starts the API containers, the nginx container, as well as the tracking containers (nginx_exporter, prometheus, and grafana).

- `make stop-project`: Runs _docker compose down_ for the previously started project.

- `make rerun`: Chains _stop-project_ and _start-project_ for a quick restart.

- `make test`: Executes the tests defined in _tests/run_tests.sh_. Make sure to start the project first and wait some seconds s.t. the API endpoints become available.

- `make test-api`: Sends a request to the predict endpoint of api-v1. 

- `make test-apiv2`: Sends a request to the predict endpoint of api-v2. 

## Notes

In the project setup, I followed the project setup from the lessons, i.e. most of the files ad their content orient heavily on what I implemented during the lessons. 

Only the **A/B Testing** part was new here, so I will go through this in a bit more detail. To implement it, I did the following:

1. Add a _Dockerfile_ to _src/api/v2_. The content of this file is almost the same as for the api-v1, as api-v2 uses the same dependencies, the same model and the same port as api-v1.

2. Add the service _api-v2_ to _docker-compose.yml_. Again, I oriented on the service setup for api-v1 with the main difference that for api-v2 only 1 replica should be deployed. With this goal in mind, I could have left the deploy part out, but it felt cleaner to stick as closely as possible to the api-v1 service setup.

3. In the _nginx.config_ I added:
    ```conf
    upstream v2-apis {
        server api-v2:8000;
    }

    map $http_x_experiment_group $backend {
        default http://v1-apis;
        debug   http://v2-apis;
    }
    ```

    and changed  `proxy_pass http://v1-apis;` to `proxy_pass $backend;`.

    Although there is only 1 replica of api-v2, it again felt cleaner to me to stick to the upstream block setup of api-v1, so I added a second upstream block for api-v2.

    The mapping then ensures dynamic routing for the A/B Tests where based on the _$http\_x\_experiment\_group_, the _$backend_ is set. The _$backend_ variable is then the proxy target at the _predict/_ endpoint.
