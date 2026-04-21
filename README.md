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

## Configuration Variables

### Economy Chain

Please see the [separate Economy Chain set-up and configuration guide](doc/economy_chain/EC-configuration-and-setup.md).

## Dependencies on the PMC Tool

Changes to this project will often necessitate changes to the [Postchain Management Console](https://docs.chromia.com/category/postchain-management-console) for elements that can be configured by providers. This is often true for Economy Chain changes.

For example, the change that allowed the reward rate to be voted on by providers led to [this merge request](https://chromaway.atlassian.net/wiki/x/AYAMDw) for the PMC.

For all such changes, `version.rell` needs to be incremented appropriately. Otherwise existing PMC users will not know to upgrade to use the new features.


## Integration Tests (`it/`)

The `it/` directory contains Maven/Kotlin integration tests that run against a live node, separate from `chr test`.

### Running locally

```bash
# 1. Build the IT configuration
chr build --hide-lib-warnings --settings chromia-it.yml

# 2. Start a local node (from repo root)
chr node start --settings chromia-it.yml --name manager_it --hide-lib-warnings --managed-mode --wipe >> node.log 2>&1 &
# Wait for "Node is initialized" in node.log

# 3. Bootstrap the network
cd it
pmc network initialize -cac ../build/cluster_anchoring_it.xml -sac ../build/system_anchoring_it.xml \
  -ecc ../build/economy_chain_it.xml -tcc ../build/token_chain_it.xml --lookup-brid
pmc economy add-tag --name tag --scu-price 1 --extra-storage-price 1
pmc economy add-cluster --tag tag --name dappCluster --cluster-units 1 --voter-set SYSTEM_P --governor SYSTEM_P

# 4. Run tests
mvn test
```

### Keeping versions in sync

`it/pom.xml` has its own version properties that must be kept in sync with the main project. When bumping dependencies, check these too:

| What changed | Update in `it/pom.xml` | Update in `.gitlab-ci.yml` |
|---|---|---|
| `postchain-client` / `chromia-client` | `postchain.client.version` | — |
| Postchain BOM | `postchain.version` | — |
| Rell Maven plugin | `rell.maven.plugin.version` | — |
| `chr` CLI | — | `apt-get install -y chr=<version>` in `integration-test` job |
| `pmc` CLI | — | `apt-get install -y pmc=<version>` in `integration-test` job |

## Releases

Whenever an api is added or changed (signature of query/operations), the api version should be updated in `version.rell`. If the api is changed in `nm_api` or `cm_api`, the respective version of those libs should also be updated.

After dev branch has been built in the CI, open up the pipeline and start either `release-patch` or `release-minor` stage to create a release. If the api-version is updated, a minor release should be created, otherwise create a patch.

We use the following syntax for semver: a.b.c
- a: major version, which is 1 for Directory 1
- b: minor version / api version
- c: patch version / internal changes to the source code
