# Monstache test runner

Use the `run-tests.sh` script in this folder to run integration tests. You will need to have installed
`docker`. The script starts services for MongoDB, Elasticsearch or OpenSearch, and Monstache itself,
and then runs the tests in `monstache_test.go`.

The default images are MongoDB `4.1-xenial` and Elasticsearch OSS `7.0.0`.

```sh
./run-tests.sh
```

Each run writes `go test -json` output and a Markdown summary to `test-results/`. In GitHub Actions,
`run-tests.sh` appends the Markdown report to the workflow summary page for the matrix job.

Set `MONGO_IMAGE` and `SEARCH_IMAGE` to test other MongoDB or Elasticsearch images.

```sh
MONGO_IMAGE=mongodb/mongodb-community-server:8.3.2-ubi9 SEARCH_FLAVOR=elasticsearch-modern SEARCH_IMAGE=docker.elastic.co/elasticsearch/elasticsearch:9.4.1 ./run-tests.sh
```

Set `SEARCH_FLAVOR=opensearch` for OpenSearch 1.x/2.x. The OpenSearch compose override disables
security and enables the Elasticsearch 7 compatibility response. Use `opensearch-modern` for
OpenSearch versions where that compatibility setting has been removed.

```sh
MONGO_IMAGE=mongodb/mongodb-community-server:8.3.2-ubi9 SEARCH_FLAVOR=opensearch-modern SEARCH_IMAGE=opensearchproject/opensearch:3.6.0 ./run-tests.sh
```
