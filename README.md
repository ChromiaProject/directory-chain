# Directory Chain

The directory chain is an implementation of the node management api for use when running postchain in managed mode. It also defines the cluster management api used in the chromia infrastructure.

## Build

Build this repo using the chromia cli:
```
chr build
chr test
```
If using docker, specify the database host as the docker host. (mac: host.docker.internal, linux/win: 172.17.0.1)

```
database:
  host: <host>
```
Or as an environment variable to the docker container `-e CHR_DATABASE_HOST=<host>`

## Releases

Whenever an api is added or changed (signature of query/operations), the api version should be updated in `version.rell`. If the api is changed in `nm_api` or `cm_api`, the respective version of those libs should also be updated.

After dev branch has been built in the CI, open up the pipeline and start either `release-patch` or `release-minor` stage to create a release. If the api-version is updated, a minor release should be created, otherwise create a patch.

We use the following syntax for semver: a.b.c
- a: major version, which is 1 for Directory 1
- b: minor version / api version
- c: patch version / internal changes to the source code

## ICMF

To include the ICMF module in your rell project, specify in your config file:
```yaml
libs:
  icmf:
    registry: https://gitlab.com/chromaway/core/directory-chain
    path: src/messaging/icmf
    tagOrBranch: 1.35.0
    rid: x"19D6BC28D527E6D2239843608486A84F44EDCD244E253616F13D1C65893F35F6"
```
Then use `chr install` to install the icmf-library.

## ICCF

To include the ICCF module in your rell project, specify in your config file:
```yaml
libs:
  iccf:
    registry: https://gitlab.com/chromaway/core/directory-chain
    path: src/iccf
    tagOrBranch: 1.35.0
    rid: x"1D567580C717B91D2F188A4D786DB1D41501086B155A68303661D25364314A4D"
```
Then use `chr install` to install the iccf-library.
