# Token Migration Guide

This guide explains how to migrate tokens from an old token asset on a custom chain to a new token asset in Token chain. The old token is kept but disabled.

In this guide we will use an example chain, [my-dapp](./my-dapp), for our tokens, but replace it with your chain with similar functionality.

## Overview of the Migration Process

The migration process involves the following high-level steps:

1. Register a new token on Token chain. This one will replace the existing token on your chain.
2. Mint new tokens to the account used to distribute the tokens, from now on referred to as the transfer account.
3. Transfer tokens to the same account on your chain.
4. Distribute tokens to existing accounts on the chain by transferring the amount from the transfer account.

## Prerequisites

1. Install `chr`
2. Install `pmc` (can be replaced by slightly different commands)
3. The original token exists only on one chain.
4. The chain with the original token needs to disable minting and burning during migration.

## Step-by-Step Migration Guide

### 1. Create the transfer account

For the migration we will use a temporary FT4 account, a transfer account, to mint new tokens, move them to [my-dapp](./my-dapp) and distribute them to existing accounts. Once the migration is completed the balance of this account should be `0`. It is recommended to create a new key pair with either `chr` or `pmc` to be able to use it with `chr` further down the guide.

Set the pubkey of your transfer account ID:

```bash
TRANSFER_ACCOUNT_ID=141B929B815CAECE1F0451C23B09CD835349740ECCE028CC52D74732E6AE09E2 # Replace with your FT4 account id, not the pubkey
```

Make sure the account exists on Token chain. One way to do this is to transfer a small amount of CHR from an existing account on Economy chain to this account on Token chain. This can be done through the Vault UI.

### 2. Optional: Create the example dapp

As an example in this guide we will use [my-dapp](./my-dapp) as a chain to migrate an existing token to a new token. Feel free to replace this with your own chain, but keep in mind this guide will still refer to the example implementation of queries and operations through the guide.

First, navigate to the [my-dapp](./my-dapp) directory and build the application:

```bash
cd doc/token_chain/migrate-token/my-dapp
chr install
chr build
```

Deploy the dapp to your container and initialize it:

```bash
pmc blockchain add -c my_dapp_container -bc build/my_dapp.xml -n my_dapp
```

Set variable for future reference:

```bash
MD_BRID="7AAB956BA453805AC63CFD085ACB20A3383B84AFBC95B7F18AEBD7A8B71A1BCB" # Replace with your blockchain rid
```

Initialize the chain and set the transfer account id and store the original asset id in a variable:

```bash
chr tx -brid $MD_BRID init x\"$TRANSFER_ACCOUNT_ID\"
ORIGINAL_ASSET_ID="$(chr query -brid $MD_BRID get_original_token_asset_id)"; echo "Original asset id: $ORIGINAL_ASSET_ID"
```

This will create a token on the chain:

```
chr query -brid $MD_BRID ft4.get_asset_by_id asset_id=$ORIGINAL_ASSET_ID
[
  "blockchain_rid": x"7AAB956BA453805AC63CFD085ACB20A3383B84AFBC95B7F18AEBD7A8B71A1BCB",
  "decimals": 6,
  "icon_url": "",
  "id": x"39AFF63A9DF6C8ED6AD2BDAE8142A361B61DCDF00D3A68695C0A41FCFC13F9E2",
  "name": "Original Token",
  "supply": 0L,
  "symbol": "OT",
  "type": "ft4"
]
```

Now let's create some basic accounts and balances to be migrated:

```bash
chr tx -brid $MD_BRID mint 'x"03ECD350EEBC617CBBFBEF0A1B7AE553A748021FD65C7C50C5ABB4CA16D4EA5B05"' "$ORIGINAL_ASSET_ID" 10000
chr tx -brid $MD_BRID mint 'x"03D01591E5466B07AC1D1F77BEBE2164AB0BA31366FBF005907F28FD144D64B871"' "$ORIGINAL_ASSET_ID" 9988
chr tx -brid $MD_BRID mint 'x"02B6F2967CF9AFC4D289EF475A2C2DDEC9EAB79AC60C1C99683E3134074619E635"' "$ORIGINAL_ASSET_ID" 1234
```

### 3. Register new token on Token chain

First, setup a variable to refer to the Token chain brid on your network:

```bash
TC_BRID=335C75E08AFAC7D6678263F1A13D5AFED9CD009344B6349107D7CEEA3A40EA08 # TC on devnet1, replace with the one for your network
```

Now request a new token to be used to replace the old token. This will create a proposal that needs to be approved by the Token chain governor.

Set the `INITIAL_SUPPLY` to the total `supply` for your original token (`chr query -brid $MD_BRID ft4.get_asset_by_id asset_id=$ORIGINAL_ASSET_ID`):

```bash
INITIAL_SUPPLY=21222 # Same as total supply of the original token
```

**⚠️ Warning**
> It is important that the total supply for the original token isn't changed from now on. This guide and [my-dapp](./my-dapp) assumes this won't happen, but make sure to disable it in your dapp. One way to do this is to introduce one pre-step to disable minting and burning until the migration starts.

On Token chain, propose a new token. Make sure you use the desired keypair for `chr` since this will be the token owner.

This will request the creation of a token named `New Token` and also provide one minting policy that will allow our transfer account to mint the initial supply that will be transferred to [my-dapp](./my-dapp) and distributed to all existing accounts.

```bash
# Propose the token as alpha
chr tx --ft-auth -brid $TC_BRID propose_token "New Token" NT 6 "https://www.icon.com" "[[[x\"${TRANSFER_ACCOUNT_ID}\"], ${INITIAL_SUPPLY}L, 1000000, ${INITIAL_SUPPLY}L, 0]]" '[]'

# Check the proposal
chr query --blockchain-rid $TC_BRID get_proposals_by_proposer proposer=e198a02fdec009b278e6a6e331e3aa962b26baec08af53221951df2a01df8e01
```

This proposal needs to be approved by the Token chain governor, but if this is you then you can approve it by:

```bash
chr tx -brid $TC_BRID make_common_vote x\"$(pmc config --get pubkey)\" <proposal id> 1
```

Once approved set the asset id in a variable:

```bash
chr query -brid $TC_BRID ft4.get_assets_by_name "name=New Token" page_size=null page_cursor=null
NEW_ASSET_ID="02D05904953A421C2ACFB19974F5EC7DF8893CFEAB8DE63E2FC96C342D132D81" # Replace with the "id" value.
```

### 4. Mint the New Token

We now need to mint new tokens and transfer them to [my-dapp](./my-dapp) to distribute them to accounts on that chain.

Mint the initial supply of the new token with the key used for our transfer account (and the one in the minting policy):

```bash
chr tx --ft-auth -brid $TC_BRID mint_token x\"$NEW_ASSET_ID\" ${INITIAL_SUPPLY}L
```

We now have a new token with the same amount of tokens as our original token.

### 5. Register the New Token on Your Token chain

Before we can transfer our new tokens we need to configure it in [my-dapp](./my-dapp) to accept the asset. This is here done in an operation, but would probably be more static in a real chain:

```bash
chr tx -brid $MD_BRID register_cross_chain_asset x\"$NEW_ASSET_ID\" "New Token" "NT" x\"$TC_BRID\"
```

### 6. Transfer New Tokens to the my-dapp chain

Make a cross chain transfer to move the new tokens from the Token chain to our [my-dapp](./my-dapp) chain:

```bash
# Initiate cross chain transfer - make sure to use your transfer account keypair
chr tx --ft-auth --blockchain-rid $TC_BRID ft4.crosschain.init_transfer "x\"$TRANSFER_ACCOUNT_ID\"" 'x"'$NEW_ASSET_ID'"' ${INITIAL_SUPPLY}L '[x"'$MD_BRID'"]' 9999999999999
INIT_TRANSFER_TX_RID=214C6D4A128F1D783602436B6E7C944E383918DE0ED41DD528A0BE67FB5E474D # Set to the transaction rid from previous command
curl -s "$(grep -oP '(?<=api.url = ).+' .chromia/config)/tx/$TC_BRID/$INIT_TRANSFER_TX_RID"
INIT_TRANSFER_TX_DATA=A58201B6308201B2... # Set to value from "tx" attribute in previous command
INIT_TRANSFER_TX_GTV="$(chr tools gtv --hex $INIT_TRANSFER_TX_DATA | tr -d '[:space:]\n')"

# Apply transfer
chr tx --iccf-tx $INIT_TRANSFER_TX_RID --iccf-source $TC_BRID --iccf-force-intra-network --blockchain-rid $MD_BRID ft4.crosschain.apply_transfer 1 $INIT_TRANSFER_TX_GTV 1 0
APPLY_TRANSFER_TX_RID=AABBCC.... # Set the transaction rid from previous command

# Complete transfer
chr tx --iccf-tx $APPLY_TRANSFER_TX_RID --iccf-source $MD_BRID --blockchain-rid $TC_BRID ft4.crosschain.complete_transfer 1
```

Our transfer account should now have the initial supply of the new token:

```bash
chr query -brid $MD_BRID  ft4.get_asset_balance account_id=$TRANSFER_ACCOUNT_ID asset_id=$NEW_ASSET_ID
[
  "amount": 21222L,
 ...
```

### 7. Start the Migration Process

Start the migration process to convert old tokens to new tokens. Set `<batch size>` to a reasonable amount of account migrations per block which depends on the number of accounts available and block time. For [my-dapp](./my-dapp) we can use a single batch size of `1` to test the iteration.

```bash
chr tx -brid $MD_BRID migrate_asset $ORIGINAL_ASSET_ID x\"$NEW_ASSET_ID\" x\"$TRANSFER_ACCOUNT_ID\" <batch size>
```

What this will do in [my-dapp](./my-dapp):

1. Enable migration mode
2. Disable all transfers of the old token
3. For each block, migrate <batch size> of accounts:
   1. Move tokens from our transfer account to the account.
   2. Burn all original tokens for this account.

The migration time depends on number of accounts and block build time, but eventually will log `Token migration completed` when done.
