# Token Chain Configuration

## Module args

The Token Chain has the following module args:

| Name                           | Description                                                                                             | Type       | Required           | Default |
|--------------------------------|---------------------------------------------------------------------------------------------------------|------------|--------------------|---------|
| `init_pubkey`                  | The initial member of the token chain governance voter set that is also allowed to initialize the chain | byte_array | :white_check_mark: |         |
| `asset_name`                   | The Chromia Network asset name.                                                                         | text       | :white_check_mark: |         |
| `asset_symbol`                 | The Chromia Network asset symbol.                                                                       | text       | :white_check_mark: |         |
| `asset_decimals`               | The Chromia Network asset number of decimals.                                                           | text       | :white_check_mark: |         |
| `asset_icon`                   | The Chromia Network asset icon url.                                                                     | text       | :white_check_mark: |         |
| `economy_chain_blockchain_rid` | Blockchain RID of the economy chain                                                                     | byte_array | :white_check_mark: |         |
| `proposal_revoke_timeout_days` | The minimum amount of days required since proposal was proposed before it can be revoked                | integer    | :white_check_mark: |         |

Example (mainnet config):
```yaml
  token_chain:
    module: token_chain
    config:
      gtx:
        modules:
          - "net.postchain.d1.icmf.IcmfSenderGTXModule"
          - "net.postchain.d1.icmf.IcmfReceiverGTXModule"
          - "net.postchain.d1.iccf.IccfGTXModule"
          - "net.postchain.eif.EifGTXModule"
      sync_ext:
        - "net.postchain.d1.icmf.IcmfReceiverSynchronizationInfrastructureExtension"
      icmf:
        receiver:
          local:
            - topic: L_evm_block_events
              bc-rid: x"0000000000000000000000000000000000000000000000000000000000000000" # Set to EVM token chain receiver bcrid
      eif:
        snapshot:
          version: 2
    moduleArgs:
      token_chain:
        init_pubkey: x"" # TODO set to initial governance member
        asset_name: "Chromia"
        asset_symbol: "CHR"
        asset_decimals: 6
        asset_icon: "https://assets.chromia.com/chr.png"
        economy_chain_blockchain_rid: x"15C0CA99BEE60A3B23829968771C50E491BD00D2E3AE448580CD48A8D71E7BBA" # economy chain RID
        proposal_revoke_timeout_days: 1
      lib.hbridge:
        evm_read_offsets:
          "56": 100
          "1": 50
        version: 2 # multiple bridges
      lib.ft4.core.auth:
        evm_signatures_authorized_operations:
          - eif.hbridge.link_evm_eoa_account
      lib.ft4.core.accounts.strategies.transfer:
        rules:
          - sender_blockchain: "*"
            sender: "*"
            recipient: "*"
            asset:
              - name: "Chromia" # Should match `economy_chain_module_args.asset_name`
                min_amount: 1000000L # 1.0 CHR
                issuing_blockchain_rid: x"15C0CA99BEE60A3B23829968771C50E491BD00D2E3AE448580CD48A8D71E7BBA" # economy chain RID
            timeout_days: 10
            strategy: "fee"
          - sender_blockchain: x"15C0CA99BEE60A3B23829968771C50E491BD00D2E3AE448580CD48A8D71E7BBA" # set to economy chain RID
            sender: "X"
            recipient: "X"
            asset:
              - name: "Chromia Test" # Should match `economy_chain_module_args.asset_name`
                min_amount: 1L # Smallest possible unit of CHR should be OK
                issuing_blockchain_rid: x"15C0CA99BEE60A3B23829968771C50E491BD00D2E3AE448580CD48A8D71E7BBA" # set to economy chain RID
            timeout_days: 10
            strategy: "open"
      lib.ft4.core.accounts.strategies.transfer.fee:
        asset:
          - name: "Chromia"  # Should match `economy_chain_module_args.asset_name`
            amount: 1000000L # 1.0 CHR
            issuing_blockchain_rid: x"15C0CA99BEE60A3B23829968771C50E491BD00D2E3AE448580CD48A8D71E7BBA" # economy chain RID
        fee_account: x"06F63A7A83FF05273516DD468943DA15B106AC4736C63C3FCC6EB2F2C1590B22" # Token chain governance account id - chr repl -c "\"TOKEN_CHAIN_GOVERNANCE\".hash()"
```

## Deployment

Deploy token chain via PMC

`pmc network initialize-token-chain --token-chain-config={PATH_TO_TOKEN_CHAIN_CONFIG}`
