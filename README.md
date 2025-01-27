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


## Releases

Whenever an api is added or changed (signature of query/operations), the api version should be updated in `version.rell`. If the api is changed in `nm_api` or `cm_api`, the respective version of those libs should also be updated.

After dev branch has been built in the CI, open up the pipeline and start either `release-patch` or `release-minor` stage to create a release. If the api-version is updated, a minor release should be created, otherwise create a patch.

We use the following syntax for semver: a.b.c
- a: major version, which is 1 for Directory 1
- b: minor version / api version
- c: patch version / internal changes to the source code

# Cross-chain Communication

By default, blockchains in the Chromia ecosystem cannot transact directly with one another. Chromia provides two 
facilities for communication between blockchains.

## Inter-Chain Messaging Facility (ICMF)

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

## Inter-Chain Confirmation Facility (ICCF)

To include the ICCF module in your rell project, specify in your config file:
```yaml
libs:
  iccf:
    registry: https://gitlab.com/chromaway/core/directory-chain
    path: src/lib/iccf
    tagOrBranch: 1.66.1
    rid: x"23BB9A9B967EED88642E08FFA336D7E35A6A49BFA7E86776FFBDCDA047D018F4"
```
Then use `chr install` to install the iccf-library.
