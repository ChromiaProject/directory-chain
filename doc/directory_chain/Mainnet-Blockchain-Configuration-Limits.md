# Mainnet blockchain configuration limitations

Directory chain will enforce limits on some blockchain configuration values.

Here are all limitations listed along with the current limits for mainnet:

| Blockchain configuration property     | Controlled by arg for module `proposal_blockchain` | Description                                                       | Mainnet restriction                                                     |
|---------------------------------------|----------------------------------------------------|-------------------------------------------------------------------|-------------------------------------------------------------------------|
| N/A                                   | `max_config_path_depth`                            | Maximum depth of a configuration key when requesting compression  | 10                                                                      |
| N/A                                   | `max_config_size`                                  | Maximum allowed size for a blockchain configuration.              | 5242880 (5 MiB)                                                         |
| `blockstrategy.maxblocksize`          | `max_block_size`                                   | Maximum value allowed for block size.                             | 27262976 (26 MiB)                                                       |
| `blockstrategy.mininterblockinterval` | `min_inter_block_interval`                         | Minimum value allowed for inter block interval in milliseconds.   | 1000 (1 second)                                                         |
| `revolt.fast_revolt_status_timeout`   | `min_fast_revolt_status_timeout`                   | Minimum value allowed fast revolt status timeout in milliseconds. | 2000 (2 seconds)                                                        |
| `gtx.modules`                         | `allowed_dapp_chain_gtx_modules`                   | Allowed dapp blockchain GTX modules.                              | [See below](#default-allowed-gtx-Modules)                               |
| `sync_ext`                            | `allowed_dapp_chain_sync_exts`                     | Allowed dapp blockchain synchronization extensions.               | [See below](#default-allowed-synchronization-infrastructure-extensions) |
| `features`                            | `allowed_features`                                 | Allowed Postchain features.                                       | ["merkle_hash_version"]                                                 |
| `features`                            | `required_blockchain_features`                     | Required Postchain features.                                      | []                                                                      |
| `eif.snapshot.version`                | `require_eif_snapshot_version`                     | Required EIF snapshot version                                     | 2                                                                       |


## Default allowed GTX Modules

These are the default allowed GTX Modules but custom extensions may also define some modules to be allowed.

- net.postchain.rell.module.RellPostchainModuleFactory
- net.postchain.gtx.StandardOpsGTXModule
- net.postchain.d1.icmf.IcmfSenderGTXModule
- net.postchain.d1.icmf.IcmfReceiverGTXModule
- net.postchain.d1.iccf.IccfGTXModule
- net.postchain.eif.EifGTXModule
- net.postchain.web.WebStaticGTXModuleFactory
- net.postchain.zkp.ZKPGTXModule

## Default allowed Synchronization Infrastructure Extensions

These are the default allowed GTX Modules but custom extensions may also define some extensions to be allowed.

- net.postchain.d1.icmf.IcmfReceiverSynchronizationInfrastructureExtension
- net.postchain.eif.EifSynchronizationInfrastructureExtension
