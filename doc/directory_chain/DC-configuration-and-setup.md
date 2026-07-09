# Directory Chain Configuration

## Module args

The Directory Chain has the following module args:

Module args for `common.init` module:

| Name               | Description            | Type      | Required           | Default |
|--------------------|------------------------|-----------|--------------------|---------|
| `initial_provider` | The initial provider.  | pubkey    | :white_check_mark: |         |
| `genesis_node`     | The genesis node info. | node_info | :white_check_mark: |         |

Module args for `common` module:

| Name                                 | Description                         | Type    | Required           | Default |
|--------------------------------------|-------------------------------------|---------|--------------------|---------|
| `allow_blockchain_dependencies`      | Allow blockchain dependencies.      | boolean | :white_check_mark: |         |
| `provider_quota_max_actions_per_day` | Provider max actions per day quota. | int     | :white_check_mark: |         |

Module args for `common.queries` module:

| Name         | Description                                       | Type       | Required           | Default |
|--------------|---------------------------------------------------|------------|--------------------|---------|
| `developers` | Developers authorized to sign Postchain releases. | list<text> | :white_check_mark: |         |

Module args for `proposal_blockchain` module:

| Name                                                     | Description                                                                      | Type      | Required           | Default |
|----------------------------------------------------------|----------------------------------------------------------------------------------|-----------|--------------------|---------|
| `max_config_path_depth`                                  | Maximum configuration path depth.                                                | integer   | :white_check_mark: |         |
| `max_config_size`                                        | Maximum config size.                                                             | integer   | :white_check_mark: |         |
| `max_block_size`                                         | Maximum block size.                                                              | integer   | :white_check_mark: |         |
| `min_inter_block_interval`                               | Minimum inter block interval in milliseconds.                                    | integer   | :white_check_mark: |         |
| `min_max_block_time`                                     | Minimum custom maxblocktime setting in milliseconds.                             | integer   |                    | 0       |
| `min_fast_revolt_status_timeout`                         | Minimum fast revolt status timeout in milliseconds.                              | integer   | :white_check_mark: |         |
| `allowed_dapp_chain_gtx_modules`                         | Allowed dapp chain gtx modules.                                                  | set<text> | :white_check_mark: |         |
| `allowed_dapp_chain_sync_exts`                           | Allowed dapp chain sync extensions.                                              | set<text> | :white_check_mark: |         |
| `allowed_blockchain_features`                            | Blockchain features allowed to be used.                                          | set<text> | :white_check_mark: |         |
| `required_blockchain_features`                           | Blockchain features required to be used.                                         | set<text> | :white_check_mark: |         |
| `require_min_merkle_hash_version`                        | Minimum allowed merkle hash version.                                             | integer   | :white_check_mark: |         |
| `require_min_merkle_hash_version_ignore_existing_chains` | Ignore existing chain updates when checking minimum allowed merkle hash version. | boolean   |                    | false   |
| `require_revolt_when_should_build_block`                 | Require that "revolt when should build block" feature is activated.              | boolean   |                    | true    |
| `require_add_primary_key_to_header`                      | Require that block builder node key is added to block header.                    | boolean   |                    | true    |
| `require_positive_eif_skip_to_height`                    | Require all EIF skip to height configurations to be positive.                    | boolean   |                    | true    |
| `require_eif_snapshot_version`                           | Minimum allowed version for EIF snapshots, set to `null` to accept any version.  | integer?  |                    | null    |
| `allowed_dapp_chain_native_functions`                    | Allowed dapp chain Rell native function implementations.                         | set<text> | :white_check_mark: |         |

Module args for `proposal_blockchain_move` module:

| Name                       | Description                                        | Type    | Required           | Default |
|----------------------------|----------------------------------------------------|---------|--------------------|---------|
| `provider_quota_move_cost` | How many points a blockchain move operation costs. | integer | :white_check_mark: |         |

Module args for `housekeeping` module:

| Name                       | Description                                                    | Type    | Required           | Default |
|----------------------------|----------------------------------------------------------------|---------|--------------------|---------|
| `max_empty_container_time` | Maximum time the container can live empty before housekeeping. | integer | :white_check_mark: |         |

Module args for `node_software_version`

| Name                    | Description                                                  | Type       | Required           | Default |
|-------------------------|--------------------------------------------------------------|------------|--------------------|---------|
| `node_image`            | Recommended Postchain master node image for the network.     | image_data | :white_check_mark: |         |
| `default_subnode_image` | Recommended default Postchain subnode image for the network. | image_data | :white_check_mark: |         |


See [Mainnet Blockchain Configuration Limits](Mainnet-Blockchain-Configuration-Limits.md) for module args for 
`proposal_blockchain.util` module.

Config type

| Type      | Fields                                                                           |
|-----------|:---------------------------------------------------------------------------------|
| node_info | pubkey<br>host: text<br>port: integer<br>api_url: text<br>territory: text?       |

## ICMF configuration

In addition, you also need to set up ICMF configuration so that it listens to.

From anchoring chain:

- `G_configuration_updated` 
- `G_configuration_failed` 

From economy-chain:

- `G_create_cluster`
- `G_create_cluster_V2`
- `G_create_container`
- `G_upgrade_container`
- `G_stop_container`
- `G_restart_container`
- `G_remove_container`
- `G_register_dapp_provider`
- `G_assign_subnode_image_to_container`
- `G_add_subnode_jar_extensions_to_container`

### Configuration example:
```yaml
  mainnet:
    module: management_chain_mainnet
    config:
      features:
        merkle_hash_version: 2
      signers:
        - x"037434C8D4F2B7B7DE44E80486A814676DC3D898FD4488E10E1940B1C4C5837200"
      sync_ext:
        - "net.postchain.d1.icmf.IcmfReceiverSynchronizationInfrastructureExtension"
      gtx:
        modules:
          - "net.postchain.d1.icmf.IcmfSenderGTXModule"
          - "net.postchain.d1.icmf.IcmfReceiverGTXModule"
          - "net.postchain.eif.transaction.signerupdate.directorychain.SignerUpdateGTXModule"
          - "net.postchain.d1.iccf.IccfGTXModule"
      icmf:
        receiver:
          anchoring:
            topics:
              - G_configuration_updated
              - G_configuration_failed
          global:
            topics:
              - G_create_cluster
              - G_create_cluster_v2
              - G_create_container
              - G_upgrade_container
              - G_assign_subnode_image_to_container
              - G_add_subnode_jar_extensions_to_container
              - G_stop_container
              - G_restart_container
              - G_remove_container
              - G_register_dapp_provider
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
      common.queries:
        developers:
          - andrei.ursu@chromaway.com
          - eugene.tykulov@chromaway.com
          - johan.nilsson@chromaway.com
          - mikael.staldal@chromaway.com
          - robert.wideberg@chromaway.com
      proposal_blockchain_move:
        provider_quota_move_cost: 35
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
          - "net.postchain.web.WebStaticGTXModuleFactory"
        allowed_dapp_chain_sync_exts:
          - "net.postchain.d1.icmf.IcmfReceiverSynchronizationInfrastructureExtension"
          - "net.postchain.eif.EifSynchronizationInfrastructureExtension"
        allowed_blockchain_features:
          - "merkle_hash_version"
        required_blockchain_features:
          - "merkle_hash_version"
        require_eif_snapshot_version: 2
        require_min_merkle_hash_version: 2
        allowed_dapp_chain_native_functions:
          - "net.postchain.d1.BlockWitnessRellNative"
      node_software_version:
        node_image:
          url: registry.gitlab.com/chromaway/postchain-chromia/chromaway/chromia-server
          tag: 3.28.1
          digest: sha256:f426ce4bda073d63ade194a3dbbe095a532466672ef4a80de71df8d165de879e
        default_subnode_image:
          url: registry.gitlab.com/chromaway/postchain-chromia/chromaway/chromia-subnode
          tag: 3.28.1
          digest: sha256:e736c6d1465b6a5ae480b5431619e16438000a500fae9214a5ef23c69614dd15
```

## Delayed blockchain configuration

A blockchain can be set to support delayed configuration updates to give users a heads-up and make them aware of upcoming changes. When a delay is enabled and a configuration proposal is accepted (with enough providers votes) it will wait the configured time before being applied to the blockchain. This also includes updating the delay setting itself.

This is disabled by default but can be enabled by setting `config_delay` to the number of milliseconds the delay should last.

```yaml
blockchains:
  name_of_blockchain:
    config:
      directory_chain:
        config_delay: 0 # Delay in milliseconds
```

The `list_delayed_blockchain_configs` query can be used to retrieve existing delayed configuration proposals.
