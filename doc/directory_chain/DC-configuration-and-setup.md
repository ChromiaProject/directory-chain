# Directory Chain Configuration

### Module args

The Directory Chain has the following module args:

| Name                  | Description                                   | Type       | Required           | Default |
|-----------------------|-----------------------------------------------|------------|--------------------|---------|
| `initial_provider`    | The initial provider.                         | pubkey     | :white_check_mark: |         |
| `genesis_node`        | The genesis node info.                        | node_info  | :white_check_mark: |         |
| `common`              | Module args for `common` module.              | map        | :white_check_mark: |         |
| `proposal_blockchain` | Module args for `proposal_blockchain` module. | map        | :white_check_mark: |         |
| `auth_service`        | Module args for `auth_service` module.        | map        | :white_check_mark: |         |
| `housekeeping`        | Module args for `housekeeping` module.        | map        | :white_check_mark: |         |


Module args for `common` module:

| Name                                 | Description                         | Type    | Required           | Default |
|--------------------------------------|-------------------------------------|---------|--------------------|---------|
| `allow_blockchain_dependencies`      | Allow blockchain dependencies.      | boolean | :white_check_mark: |         |
| `provider_quota_max_actions_per_day` | Provider max actions per day quota. | int     | :white_check_mark: |         |

Module args for `proposal_blockchain` module:

| Name                             | Description                                         | Type      | Required           | Default |
|----------------------------------|-----------------------------------------------------|-----------|--------------------|---------|
| `max_config_path_depth`          | Maximum configuration path depth.                   | integer   | :white_check_mark: |         |
| `max_config_size`                | Maximum config size.                                | integer   | :white_check_mark: |         |
| `max_block_size`                 | Maximum block size.                                 | integer   | :white_check_mark: |         |
| `min_inter_block_interval`       | Minimum inter block interval in milliseconds.       | integer   | :white_check_mark: |         |
| `min_fast_revolt_status_timeout` | Minimum fast revolt status timeout in milliseconds. | integer   | :white_check_mark: |         |
| `allowed_dapp_chain_gtx_modules` | Allowed dapp chain gtx modules.                     | set<text> | :white_check_mark: |         |
| `allowed_dapp_chain_sync_exts`   | Allowed dapp chain sync extensions.                 | set<text> | :white_check_mark: |         |

Module args for `auth_service` module:

| Name                     | Description                                           | Type    | Required           | Default |
|--------------------------|-------------------------------------------------------|---------|--------------------|---------|
| `pubkey`                 | Pubkey used to sign `auth_service` module operations. | pubkey  | :white_check_mark: |         |
| `include_system_cluster` | Include system cluster.                               | boolean | :white_check_mark: |         |

Module args for `housekeeping` module:

| Name                       | Description                                                    | Type    | Required           | Default |
|----------------------------|----------------------------------------------------------------|---------|--------------------|---------|
| `max_empty_container_time` | Maximum time the container can live empty before housekeeping. | integer | :white_check_mark: |         |

Config type

| Type      | Fields                                                                           |
|-----------|:---------------------------------------------------------------------------------|
| node_info | pubkey<br>host: text<br>port: integer<br>api_url: text<br>territory: text?       |


### ICMF configuration

In addition, you also need to set up ICMF configuration so that it listens to.

From anchoring chain:

- `G_configuration_updated` 
- `G_configuration_failed` 
- `G_last_anchored_heights` 

From economy-chain:

- `G_create_cluster`
- `G_create_container`
- `G_upgrade_container`
- `G_stop_container`
- `G_restart_container`

### Configuration example:
```yaml
  mainnet:
    module: management_chain_mainnet
    config:
      config_consensus_strategy: HEADER_HASH
      blockstrategy:
        maxblocktime: 2000
      revolt:
        fast_revolt_status_timeout: 2000
      signers:
        - x"0350fe40766bc0ce8d08b3f5b810e49a8352fdd458606bd5fafe5acdcdc8ff3f57"
      sync_ext:
        - "net.postchain.d1.icmf.IcmfReceiverSynchronizationInfrastructureExtension"
      gtx:
        modules:
          - "net.postchain.d1.icmf.IcmfSenderGTXModule"
          - "net.postchain.d1.icmf.IcmfReceiverGTXModule"
          - "net.postchain.eif.transaction.signerupdate.directorychain.SignerUpdateGTXModule"
      icmf:
        receiver:
          anchoring:
            topics:
              - G_configuration_updated
              - G_configuration_failed
              - G_last_anchored_heights
          global:
            topics:
              - G_create_cluster
              - G_create_container
              - G_upgrade_container
              - G_stop_container
              - G_restart_container
    moduleArgs:
      common.init:
        initial_provider: ${INITIAL_PROVIDER:-03ECD350EEBC617CBBFBEF0A1B7AE553A748021FD65C7C50C5ABB4CA16D4EA5B05}
        genesis_node:
          - ${GENESIS_NODE:-0350fe40766bc0ce8d08b3f5b810e49a8352fdd458606bd5fafe5acdcdc8ff3f57}
          - ${GENESIS_HOST_NAME:-localhost}
          - 9870
          - ${GENESIS_API_URL:-http://localhost:7740}
          - ${GENESIS_TERRITORY}
      common:
        allow_blockchain_dependencies: false
        provider_quota_max_actions_per_day: 100
      auth_service:
        pubkey: x"02B6F2967CF9AFC4D289EF475A2C2DDEC9EAB79AC60C1C99683E3134074619E635"
        include_system_cluster: true
      housekeeping:
        # 48h
        max_empty_container_time: 172800000
      proposal_blockchain.util: 
        max_config_path_depth: 10
        max_config_size: 5242880 # 5 MiB
        max_block_size: 27262976 # 26 MiB
        min_inter_block_interval: 1000
        min_fast_revolt_status_timeout: 2000
        allowed_dapp_chain_gtx_modules:
          - "net.postchain.rell.module.RellPostchainModuleFactory"
          - "net.postchain.gtx.StandardOpsGTXModule"
          - "net.postchain.d1.icmf.IcmfSenderGTXModule"
          - "net.postchain.d1.icmf.IcmfReceiverGTXModule"
          - "net.postchain.d1.iccf.IccfGTXModule"
          - "net.postchain.eif.EifGTXModule"
        allowed_dapp_chain_sync_exts:
          - "net.postchain.d1.icmf.IcmfReceiverSynchronizationInfrastructureExtension"
          - "net.postchain.eif.EifSynchronizationInfrastructureExtension" 
```
