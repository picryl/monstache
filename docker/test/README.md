# Monstache test runner

Use the `run-tests.sh` script in this folder to run integration tests. You will need to have installed
`docker`. The script starts services for MongoDB, Elasticsearch or OpenSearch, and Monstache itself,
and then runs the tests in `monstache_test.go`.

The default search image is Elasticsearch OSS `7.0.0`.

```sh
./run-tests.sh
```

Set `SEARCH_IMAGE` to test another Elasticsearch 7 image.

```sh
SEARCH_IMAGE=docker.elastic.co/elasticsearch/elasticsearch:7.17.29 ./run-tests.sh
```

Set `SEARCH_FLAVOR=opensearch` for OpenSearch. The OpenSearch compose override disables security and
enables the Elasticsearch 7 compatibility response.

```sh
SEARCH_FLAVOR=opensearch SEARCH_IMAGE=opensearchproject/opensearch:2.19.5 ./run-tests.sh
```
