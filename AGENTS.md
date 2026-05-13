# Repository Guidelines

## Project Shape

- This is the `github.com/rwynn/monstache/v6` Go module. The main binary and most runtime behavior live in `monstache.go`.
- `monstachemap/` contains plugin-facing types and BSON-to-JSON helpers. Keep exported fields and function signatures backward compatible.
- `pkg/oplog/` contains focused oplog timestamp helpers with unit tests.
- Docker assets are split by use case: `docker/test/` for integration tests, `docker/release/` for release helpers, and `docker/local/` for local images.

## Coding Style

- Run `gofmt` on Go changes and keep imports grouped by the standard Go formatter.
- Preserve existing CLI flag names, TOML option names, environment variables, and default behavior unless a task explicitly changes compatibility.
- Prefer narrow changes. `monstache.go` is large and stateful; avoid unrelated refactors when touching runtime logic.
- Use the existing MongoDB driver and `github.com/olivere/elastic/v7` client patterns for database/search changes.

## Testing

- Run `go test ./...` for Go-only changes.
- Run integration tests with `cd docker/test && ./run-tests.sh` when changing Docker, MongoDB, Elasticsearch/OpenSearch, or end-to-end sync behavior.
- The integration test drops MongoDB database `test` and Elasticsearch/OpenSearch indexes prefixed with `test`; do not point it at shared services.

## Workflow Notes

- GitHub Actions workflows live in `.github/workflows/`.
- Release Docker images publish to GitHub Container Registry under `ghcr.io/${{ github.repository }}`.
- In this Codex workspace, prefix shell commands with `rtk`.
