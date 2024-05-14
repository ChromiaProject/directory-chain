# Economy Chain Configuration

### Module args

The Economy Chain has the following module args:

| Name                                | Description                                                                                                                              | Type    | Required           | Default |
|-------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|---------|--------------------|---------|
| `evm_asset_network_id`              | The EVM network id where the asset resides.                                                                                              | int     | :white_check_mark: |         |
| `evm_asset_address`                 | The EVM asset address.                                                                                                                   | text    | :white_check_mark: |         |
| `evm_asset_name`                    | The EVM asset name.                                                                                                                      | text    | :white_check_mark: |         |
| `evm_asset_symbol`                  | The EVM asset symbol.                                                                                                                    | int     | :white_check_mark: |         |
| `evm_asset_decimals`                | The EVM asset number of decimals.                                                                                                        | int     | :white_check_mark: |         |
| `asset_name`                        | The Chromia Network asset name.                                                                                                          | text    | :white_check_mark: |         |
| `asset_symbol`                      | The Chromia Network asset symbol.                                                                                                        | text    | :white_check_mark: |         |
| `asset_decimals`                    | The Chromia Network asset number of decimals.                                                                                            | text    | :white_check_mark: |         |
| `asset_icon`                        | The Chromia Network asset icon url.                                                                                                      | text    | :white_check_mark: |         |
| `amount_to_mint`                    | Amount of asset to be minted for new registered accounts.                                                                                | int     | :white_check_mark: |         |
| `pool_amount_to_mint`               | Maximum amount of asset that can be minted to the pool account over the interval of time defined by `test_chr_pool_refill_limit_millis`. | int     | :white_check_mark: |         |
| `admin_pubkey`                      | Admin pubkey.                                                                                                                            | pubkey  | :white_check_mark: |         |
| `staking_initial_reward_rate`       | Staking initial reward rate.                                                                                                             | decimal | :white_check_mark: |         |
| `staking_rate_change_delay_ms`      | Amount of time required to pass between staking rate changes.                                                                            | int     | :white_check_mark: |         |
| `staking_withdrawal_delay_ms`       | Amount of time required to pass between staking withdrawals.                                                                             | int     | :white_check_mark: |         |
| `staking_payout_interval_ms`        | Amount of time required to pass between payouts.                                                                                         | int     | :white_check_mark: |         |
| `test_chr_pool_refill_limit_millis` | Amount of time required to pass between pool refills.                                                                                    | int     | :white_check_mark: |         |
| `max_bridge_leases_per_container`   | Max amount of bridge leases per container.                                                                                               | int     | :white_check_mark: |         |
| `evm_transaction_submitters_bonus`  | Bonus coefficient used in computing the reward for EVM transaction submitters.                                                           | decimal | :white_check_mark: |         |

Module args for FT4 configuration:

| Name                         | Description                                                                             | Type   | Required           | Default |
|------------------------------|-----------------------------------------------------------------------------------------|--------|--------------------|---------|
| `admin_pubkey`               | FT4 admin pubkey. Configured under `lib.ft4.admin` parameter.                           | pubkey | :white_check_mark: |         |
| `active`                     | FT4 rate limit configuration. Configured under `lib.ft4.accounts.rate_limit` parameter. | int    | :white_check_mark: |         |
| `max_points`                 | FT4 rate limit configuration. Configured under `lib.ft4.accounts.rate_limit` parameter. | int    | :white_check_mark: |         |
| `recovery_time`              | FT4 rate limit configuration. Configured under `lib.ft4.accounts.rate_limit` parameter. | int    | :white_check_mark: |         |
| `points_at_account_creation` | FT4 rate limit configuration. Configured under `lib.ft4.accounts.rate_limit` parameter. | int    | :white_check_mark: |         |
| `auth_pubkey`                | FT4 authorization server private key. Configured under `lib.auth` parameter.            | int    | :white_check_mark: |         |


### ICMF configuration

In addition, you also need to set up ICMF configuration so that it listens to.
From anchoring chain:
- `G_node_availability_report` 
From directory-chain:
- `L_create_cluster_error`
- `L_ticket_container_result`
- `L_cluster_update`
- `L_provider_update`
- `L_node_update`
- `L_cluster_node_update`
- `L_token_price_changed`
- `L_blockchain_rid_topic`
From EVM Transaction Submitter chain:
- `G_evm_transaction_submitter_cost_topic`

### EIF configuration

Economy Chain configuration also contains configuration for EIF.

Example:
```yaml
  economy_chain:
    module: economy_chain
    config:
      config_consensus_strategy: HEADER_HASH
      revolt:
        fast_revolt_status_timeout: 2000
      sync_ext:
        - "net.postchain.d1.icmf.IcmfReceiverSynchronizationInfrastructureExtension"
      gtx:
        modules:
          - "net.postchain.d1.icmf.IcmfReceiverGTXModule"
          - "net.postchain.d1.icmf.IcmfSenderGTXModule"
          - 'net.postchain.eif.EifGTXModule'
      icmf:
        receiver:
          anchoring:
            topics:
              - G_node_availability_report
          directory-chain:
            topics:
              - L_create_cluster_error
              - L_ticket_container_result
              - L_cluster_update
              - L_provider_update
              - L_node_update
              - L_cluster_node_update
              - L_token_price_changed
              - L_blockchain_rid_topic
          global:
            topics:
              - G_evm_transaction_submitter_cost_topic
      eif:
        # event processing 
        snapshot:
          levels_per_page: 2
          snapshots_to_keep: 2
        # event receiver  
        chains:
          bsc:
            network_id: 97
            contracts:
              - "0x6e42297d0374B78b695bd7d91f92C76E24B551F4"
              - "0x753218363422002DF74F3D0D8d67f6CB38bE32D0"
            evm_read_offset: 3
            read_offset: 3
            events: !include config/events.yaml
    moduleArgs:
      lib.ft4.admin:
         admin_pubkey: x"" # Replace this with FT4 admin pubkey
      lib.ft4.accounts:
         rate_limit:
            active: 1
            max_points: 20
            recovery_time: 5000
            points_at_account_creation: 1
      lib.auth:
         auth_pubkey: x"" # Replace this with FT4 authorization server private key
      economy_chain:
         evm_asset_network_id: 97
         evm_asset_address: "8A2279d4A90B6fe1C4B30fa660cC9f926797bAA2"
         evm_asset_name: "tCHR"
         evm_asset_symbol: "tCHR"
         evm_asset_decimals: 6
         asset_name: "Chromia Test"
         asset_symbol: "tCHR"
         asset_decimals: 6
         asset_icon: "https://s3.eu-central-1.amazonaws.com/www.chromiadev.net/assets/tCHR.png"
         amount_to_mint: 1000000000
         pool_amount_to_mint: 1000000000
         admin_pubkey: x"" # Replace this admin key
         staking_initial_reward_rate: 0.15
         staking_rate_change_delay_ms: 604800000
         staking_withdrawal_delay_ms: 1209600000
         staking_payout_interval_ms: 31536000000 
         test_chr_pool_refill_limit_millis: 86400000 
         max_bridge_leases_per_container: 10
         evm_transaction_submitters_bonus: 0.1
         
libs:
  ft4:
     registry: https://bitbucket.org/chromawallet/ft3-lib
     path: rell/src/lib/ft4
     tagOrBranch: v0.5.0r
     rid: x"125809B57980D6E36C07210D0541E7BCAD86A66F324FC1C0DA9CA7D1F8D5A720"
     insecure: false
  auth:
     registry: https://bitbucket.org/chromawallet/auth-server-ft4.git
     path: rell/src/auth
     tagOrBranch: v2.0.0r
     rid: x"85C0F206DE187AB84197AE2ADD721AE5DE7B4A495ADF7FA84244329A320CC92A"
     insecure: false
  priceoracle:
     registry: https://bitbucket.org/chromawallet/priceoracle.git
     path: src
     tagOrBranch: "0.2"
     rid: x"E0D3FAD15812941D2FD52A43BB3E4F2AA8BC8D795A5C27EBA4F9791CC43BE250"
     insecure: false
  eif:
     registry: https://gitlab.com/chromaway/postchain-eif
     path: postchain-eif-rell/rell/src/eif/
     tagOrBranch: "0.3.8"
     rid: x"B023B96EF2331FC912A39D56489810935E718D10BA8EE953BF09526250F6AB53"
     insecure: false
  eif_event_receiver_chain/messaging:
     registry: https://gitlab.com/chromaway/postchain-eif
     path: postchain-eif-rell/rell/src/eif_event_receiver_chain/messaging
     tagOrBranch: "0.3.8"
     rid: x"B635B3174B65768C88690382F1A08CF7E507D3CA5A5818A86B7A54D8D0E58978"
     insecure: false
```

### Deployment

Deploy Economy chain via PMC

`pmc network initialize-economy-chain --economy-chain-config={PATH_TO_ECONOMY_CHAIN_CONFIG}`


