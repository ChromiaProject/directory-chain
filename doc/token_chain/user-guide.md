# Token chain user guide

This guide assumes that you have Chromia CLI installed and configured to use a node in the relevant network.

Placeholders in the commands below are written as `${PLACEHOLDER}` and should be replaced by actual value. 
To get detailed type information for these values, please refer to the auto-generated documentation: 
https://chromaway.gitlab.io/core/directory-chain/-directory%20chain/token_chain/index.html

To get the blockchain RID of token chain in a network:

```
chr query --blockchain-rid ${DIRECTORY_CHAIN_RID} get_token_chain_rid
```

## Create an account

You can create an account on token chain by transferring CHR from economy chain to your own account ID on token chain.
If you don't have an account on economy chain you can also create it by transferring from another account on token chain
or by doing a cross-chain transfer from another chain, this will cost a small fee.

This can be all be done with the Vault UI.

## Propose a new token

In order to propose a token on token chain you need to have enough funds to cover the listing fee.
You can see the price for listing a token (or adding a bridge with query):

```
chr query --blockchain-rid ${TOKEN_CHAIN_RID} get_token_chain_constants
```

Use Chromia CLI to propose the token:

```
chr tx --evm-auth EVM_WALLET_ADDRESS --blockchain-rid ${TOKEN_CHAIN_RID} propose_token ${NAME} ${SYMBOL} ${DECIMALS} ${ICON} ${[MINTING_POLICY]} ${[ACCOUNT_CREATION_BRIDS]}
```

To check the status of your token proposal:

```
chr query --blockchain-rid ${TOKEN_CHAIN_RID} get_proposals_by_proposer proposer=${YOUR_ACCOUNT_ID}
```

Once approved you can fetch the asset ID of your newly created asset:

```
chr query --blockchain-rid ${TOKEN_CHAIN_RID} ft4.get_assets_by_name name=${YOUR_TOKEN_NAME} page_size=null page_cursor=null
```

## Propose a bridge for the token

Use Chromia CLI to propose the token bridge:

```
chr tx --evm-auth EVM_WALLET_ADDRESS --blockchain-rid ${TOKEN_CHAIN_RID} propose_token_bridge ${ASSET_ID} ${[BRIDGE_CONFIGURATION]}
```

Where bridge configurations are defined by the following struct:

```
struct bridge_configuration {
    network_id: integer;
    bridge_contract: byte_array;
    token_contract: byte_array;
    eif.hbridge.bridge_mode;
    use_snapshots: boolean;
}
```

You can use the same query as listed above to see the status of your proposal.

## Minting

You can define zero or more minting policies for your token. It has the following format:

```
struct minting_policy {
    minters: set<byte_array>;
    /** 0 to disable */
    max_supply: big_integer;
    minting_interval_ms: integer;
    minting_amount: big_integer;
    accumulating_amount: boolean;
}
```

If you are a minter and the policy allows it you can mint new tokens to your account by calling the operation below:

```
chr tx --evm-auth EVM_WALLET_ADDRESS --blockchain-rid ${TOKEN_CHAIN_RID} mint_token ${ASSET_ID} ${AMOUNT}
```

## User account creation

You can specify blockchains that are allowed to create accounts on token chain on your behalf.
You can read more in the documentation of the `ras_token_iccf` operation.
