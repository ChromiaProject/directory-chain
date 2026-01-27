# Economy Chain Configuration

### Module args

The Economy Chain has the following module args:

| Name                                                         | Description                                                                                                                   | Type      | Required           | Default             |
|--------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|-----------|--------------------|---------------------|
| `evm_bridges`                                                | List of CHR EVM bridges, containing `network_id`, `asset_address` and `bridge_address`.                                       | list      | :white_check_mark: |                     |
| `asset_name`                                                 | The Chromia Network asset name.                                                                                               | text      | :white_check_mark: |                     |
| `asset_symbol`                                               | The Chromia Network asset symbol.                                                                                             | text      | :white_check_mark: |                     |
| `asset_decimals`                                             | The Chromia Network asset number of decimals.                                                                                 | text      | :white_check_mark: |                     |
| `asset_icon`                                                 | The Chromia Network asset icon url.                                                                                           | text      | :white_check_mark: |                     |
| `amount_to_mint`                                             | Amount of asset to be minted for new registered accounts.                                                                     | int       | :white_check_mark: |                     |
| `pool_amount_to_mint`                                        | Maximum amount of asset that can be minted to the pool account over the interval of time defined by `pool_refill_limit_ms`.   | int       | :white_check_mark: |                     |
| `admin_pubkey`                                               | Admin pubkey.                                                                                                                 | pubkey    | :white_check_mark: |                     |
| `staking_oracle_pubkey`                                      | Staking oracle pubkey.                                                                                                        | pubkey    | :white_check_mark: |                     |
| `staking_initial_reward_rate`                                | Staking initial reward rate.                                                                                                  | decimal   | :white_check_mark: |                     |
| `staking_rate_change_delay_ms`                               | Amount of time required to pass between staking rate changes.                                                                 | int       | :white_check_mark: |                     |
| `staking_withdrawal_delay_ms`                                | Amount of time required to pass between staking withdrawals.                                                                  | int       | :white_check_mark: |                     |
| `staking_rewards_payout_interval_ms`                         | Amount of time required to pass between reward payouts.                                                                       | int       | :white_check_mark: |                     |
| `staking_withdrawals_payout_interval_ms`                     | Amount of time required to pass between withdrawal payouts.                                                                   | int       | :white_check_mark: |                     |
| `staking_rewards_start_time`                                 | Time after which staking reward should begin to accumulate                                                                    | timestamp |                    | 0                   |
| `pool_refill_limit_ms`                                       | Amount of time required to pass between pool refills.                                                                         | int       | :white_check_mark: |                     |
| `max_bridge_leases_per_container`                            | Max amount of bridge leases per container.                                                                                    | int       | :white_check_mark: |                     |
| `evm_transaction_submitters_bonus`                           | Bonus coefficient used in computing the reward for EVM transaction submitters.                                                | decimal   | :white_check_mark: |                     |
| `max_dapp_providers_per_lease`                               | Maximum number of dapp providers that can be added to lease.                                                                  | int       |                    | 100                 |
| `dapp_provider_creation_cost`                                | The cost to create a new dapp provider if you are not a lease owner.                                                          | int       |                    | 100                 |
| `evm_transaction_submitters_bonus`                           | Percentage of total gas cost that should be added to provider reward for submitting a TX to EVM.                              | decimal   | :white_check_mark: |                     |
| `container_removal_timeout`                                  | How long in milliseconds a container is allowed to have been expired before we automatically delete it, set to -1 to disable. | int       | :white_check_mark: |                     |
| `token_rate_update_interval_ms`                              | Minimum allowed amount of time in milliseconds between updates of token rates.                                                | int       | :white_check_mark: |                     |
| `container_reduce_space_margin_requirement`                  | The required margin of free space in percent to allow reducing space.                                                         | decimal   |                    | 0.2                 |
| `container_reduce_space_resource_usage_statistics_expire_ms` | A resource usage data from anchoring chain must be sent within this time period (in milliseconds) to allow reducing space.    | int       |                    | 1000 * 60 * 10      |
| `chromia_foundation_mint_amount_limit`                       | Max amount of CHR Chromia foundation is allowed to mint during `chromia_foundation_mint_time_limit_ms`.                       | int       |                    | 24 * 60 * 60 * 1000 |
| `chromia_foundation_mint_time_limit_ms`                      | Time interval in milliseconds that `chromia_foundation_mint_amount_limit` should be applied to.                               | int       |                    | 24 * 60 * 60 * 1000 |

Module args for FT4 configuration:

| Name                         | Description                                                                                  | Type | Required           | Default |
|------------------------------|----------------------------------------------------------------------------------------------|------|--------------------|---------|
| `active`                     | FT4 rate limit configuration. Configured under `lib.ft4.core.accounts.rate_limit` parameter. | int  | :white_check_mark: |         |
| `max_points`                 | FT4 rate limit configuration. Configured under `lib.ft4.core.accounts.rate_limit` parameter. | int  | :white_check_mark: |         |
| `recovery_time`              | FT4 rate limit configuration. Configured under `lib.ft4.core.accounts.rate_limit` parameter. | int  | :white_check_mark: |         |
| `points_at_account_creation` | FT4 rate limit configuration. Configured under `lib.ft4.core.accounts.rate_limit` parameter. | int  | :white_check_mark: |         |

### ICMF configuration

In addition, you also need to set up ICMF configuration so that it listens to.
From anchoring chain:
- `G_node_availability_report` 
From directory-chain:
- `L_create_cluster_error`
- `L_ticket_container_result`
- `L_cluster_update`
- `L_provider_update`
- `L_provider_auth_update`
- `L_node_update`
- `L_cluster_node_update`
- `L_token_price_changed`
- `L_blockchain_rid_topic`
- `L_subnode_image_update`
- `L_cluster_subnode_image_update`
- `L_subnode_jar_extension_update`
- `L_cluster_subnode_jar_extension_update`
From EVM Transaction Submitter chain:
- `G_evm_transaction_submitter_cost_topic`
From EIF EVM event receiver chain:
- `L_evm_block_events`

Example (mainnet config):
```yaml
  economy_chain:
    module: economy_chain_prod
    config:
      features:
        merkle_hash_version: 2
      sync_ext:
        - "net.postchain.d1.icmf.IcmfReceiverSynchronizationInfrastructureExtension"
      gtx:
        modules:
          - "net.postchain.d1.icmf.IcmfReceiverGTXModule"
          - "net.postchain.d1.icmf.IcmfSenderGTXModule"
          - 'net.postchain.eif.EifGTXModule'
          - "net.postchain.d1.iccf.IccfGTXModule"
      icmf:
        receiver:
          anchoring:
            topics:
              - G_node_availability_report
              - G_resource_usage_statistics
          directory-chain:
            topics:
              - L_create_cluster_error
              - L_ticket_container_result
              - L_cluster_update
              - L_provider_update
              - L_provider_auth_update
              - L_node_update
              - L_cluster_node_update
              - L_blockchain_rid_topic
              - L_subnode_image_update
              - L_cluster_subnode_image_update
              - L_subnode_jar_extension_update
              - L_cluster_subnode_jar_extension_update
          global:
            topics:
              - G_evm_transaction_submitter_cost_topic
              - G_token_price_changed
          local:
            - topic: L_evm_block_events
              bc-rid: x"51857CBDE9E58410BF371F8C1E480129D15939E5F98E03575B106702D7972C17"
    moduleArgs:
      lib.hbridge:
        evm_read_offsets:
          "56": 100
          "1": 50
      lib.ft4.core.accounts:
        rate_limit:
          active: 1
          max_points: 20
          recovery_time: 5000
          points_at_account_creation: 1
      lib.ft4.core.auth:
        evm_signatures_authorized_operations:
          - eif.hbridge.link_evm_eoa_account
      lib.ft4.core.accounts.strategies.transfer:
        rules:
          - sender_blockchain:
              - "4EED8C21E3AAB544F172945859E466E55CE3E60180D0C314DB648658CE8DC2A6" # chr repl -c '("EVM",1,x"8A2279d4A90B6fe1C4B30fa660cC9f926797bAA2").hash()' - token address from https://gitlab.com/chromaway/core/postchain-eif/-/blob/dev/postchain-eif-contracts/tasks/deployers/chromiabridge.ts?ref_type=heads#L21-L34
              - "BB3B3F342048A851B994BFD29995AF5F0B7C1D3E604F1A53C1E164677FA108BF" # chr repl -c '("EVM",56,x"f9CeC8d50f6c8ad3Fb6dcCEC577e05aA32B224FE").hash()' - token address from https://gitlab.com/chromaway/core/postchain-eif/-/blob/dev/postchain-eif-contracts/tasks/deployers/chromiabridge.ts?ref_type=heads#L21-L34
            sender: "*"
            recipient: "*"
            asset:
              - name: "Chromia" # Should match `economy_chain_module_args.asset_name`
                min_amount: 10000000L # 10.0 CHR
            timeout_days: 10
            strategy: "open"
          - sender_blockchain: "*"
            sender: "*"
            recipient: "*"
            asset:
              - name: "Chromia" # Should match `economy_chain_module_args.asset_name`
                min_amount: 10000000L # 10.0 CHR
            timeout_days: 1
            strategy: "fee"
      lib.ft4.core.accounts.strategies.transfer.fee:
        asset:
          - name: "Chromia"  # Should match `economy_chain_module_args.asset_name`
            amount: 10000000L # 10.0 CHR
        fee_account: x"A97CEAF65C5D7BE1B1307B0CD11AC9B3DB7065D24B8C1D36B135C68A846A4426" # pool account
      economy_chain:
        evm_bridges:
          - network_id: 56
            asset_address: "f9CeC8d50f6c8ad3Fb6dcCEC577e05aA32B224FE"
            bridge_address: "c5B2d0F1F659A72c3c94E6E654C859771161eFD3"
          - network_id: 1
            asset_address: "8A2279d4A90B6fe1C4B30fa660cC9f926797bAA2"
            bridge_address: "b1632e7de8B3d18277Cc3C99B6819795bBDe8654"
        asset_name: "Chromia"
        asset_symbol: "CHR"
        asset_decimals: 6
        asset_icon: "https://assets.chromia.com/chr.png"
        pool_amount_to_mint: 150000000000 # 150k CHR
        staking_withdrawal_delay_ms: 1209600000 # 14 days
        staking_delegation_delay_ms: 604800000 # 7 days
        staking_rewards_payout_interval_ms: 86400000 # 1 day
        staking_withdrawals_payout_interval_ms: 30000 # 60 seconds (approximately every other block)
        staking_rewards_payout_batch_size: 50
        staking_rewards_share: 0.1
        staking_rewards_start_time: 1727182800000 # Tues Sep 24 2024 15:00:00 GMT+0200 (Central European Summer Time)
        pool_refill_limit_ms: 86400000 # 1 day
        max_dapp_providers_per_lease: 50
        max_bridge_leases_per_container: 10
        evm_transaction_submitters_bonus: 0.1
        container_removal_timeout: 15778800000 # 6 months
        token_rate_update_interval_ms: 3600000 # 1 hour
        staking_oracle_pubkey: x"03C096B5A11941348CCFD305FB2F57C674E49882889DA2973635A2BDBA042D49A8"
        chromia_foundation_mint_amount_limit: 150000000000 # 150k CHR, at 2025-04-15 this is ~0.08 / 12500 USD

libs:
  com.chromia.ft4:
    version: 1.2.0
  price_oracle_messages:
    registry: https://gitlab.com/chromaway/core/price-oracle
    path: src/lib/price_oracle_messages
    tagOrBranch: "0.12"
    rid: x"2FFEB18A49FBD81C34225F482FF582071C43C914C5B5A15B16EBB01CE22E76BC"
    insecure: false
  com.chromia.eif:
    version: 1.3.0
  com.chromia.hbridge:
    version: 1.3.0
  transaction_submitter_messaging:
    registry: https://gitlab.com/chromaway/postchain-eif
    path: postchain-eif-rell/rell/src/transaction_submitter/messaging/
    tagOrBranch: 0.5.38
    rid: x"2AD7D6B1BA186616027D6ED5216BFC4BD5658D99A9CB0494FA67CC99AFAAA714"
    insecure: false
```

### Deployment

Deploy Economy chain via PMC

`pmc network initialize-economy-chain --economy-chain-config={PATH_TO_ECONOMY_CHAIN_CONFIG}`
