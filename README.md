# snapshot-cli
An opinionated binary that helps services to take schema snapshots from PostgreSQL and restore them.

## Temp

Test the installation in a docker container:
```
docker build --platform=linux/amd64 -t pf-mock . && docker run --platform=linux/amd64 --rm -it pf-mock bash
```
