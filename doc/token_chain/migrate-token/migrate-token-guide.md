# Token Migration Guide

This guide explains one way to migrate an FT4 token asset on your chain to [Token chain](https://docs.chromia.com/intro/about/architecture/chains/token-chain). This is done by replacing the token with a new one and transferring the same amount to all accounts that are holding the old token.

This document consists of two main parts:
- [Token migration on a local network](#token-migration-on-a-local-network) to set up a local network similar to a public network that allows you to test locally.
- [Token migration on testnet](#token-migration-on-testnet) to run your migration on a real network.

## Overview of the Migration Process

The migration process involves the following high-level steps:

1. Register a new token on [Token chain](https://docs.chromia.com/intro/about/architecture/chains/token-chain). This token will replace the existing token on your chain.
2. Mint the same amount of tokens on the new token to a distribution account.
3. Move all tokens from Token chain to your chain via a cross-chain transfer.
4. Distribute tokens to existing accounts on the chain by transferring the amount from the distribution account.

In this guide, we assume that the original token exists only on one chain.

## Token migration on a local network

This chapter will describe and illustrate how the migration works in a safe local environment. The same setup can be used to test your migration before moving on to a real network. For this, we'll use an example chain, [my-dapp](./my-dapp), to illustrate the process.

### Prerequisites

- [Chromia CLI](https://docs.chromia.com/intro/getting-started/installation/cli-installation) for posting transactions.
- [Docker](https://www.docker.com/) and a basic understanding of how to manage containers.
- `jq` for JSON parsing (optional but recommended).
- A basic understanding of [Token chain](https://docs.chromia.com/intro/about/architecture/chains/token-chain).

### Step-by-Step Migration Guide

#### 1. Start a local node

Start a local environment that is similar to real networks by running a Docker container:

```bash
docker run --rm -it -p 7740:7740/tcp registry.gitlab.com/chromaway/example-projects/directory1-example/managed-single:latest --with-economy-chain --with-token-chain
```

This will start a Postchain node and set up management chains, Economy chain, and Token chain just like a real network. When ready, you will see output similar to this:

```
##########################################################################
##########################################################################

Node started successfully

!! This is a test node - DO NOT USE IN PRODUCTION !!

Versions:
  Postchain      : 3.30.0
  Directory chain: 1.94.1

Provider and container owner:
  public key : 03ECD350EEBC617CBBFBEF0A1B7AE553A748021FD65C7C50C5ABB4CA16D4EA5B05
  private key: BBBDFE956021912512E14BB081B27A35A0EABC4098CB687E973C434006BCE114

Blockchains:
  270A5E0B8DBCAFFFDF772596BF3E5C814EBC492E95F099147AC4076BA22621AB    directory_chain
  3E483D9483C47558A50A3B9119E933F49F426BE4602A96EBE13AB74E1F14B644    system_anchoring
  4DDF508FF56F9BCCB036E04A89D9D197EAAEDDB149F13AB0E32F16955D4C78C8    cluster_anchoring_system
  7F15F4CC069DEF925211CD9A00136A5B06B7D3D1374C76C7DA29AAFA1A70D1EF    economy_chain
  FB754340A84B631612B11B3F73B77D979F0C410DE49A4160A5DACE4058CE9B77    cluster_anchoring_dapp_cluster
  3DFD2590883CC72FC5A68A25F0037A234EB651E4796D8F0992E0A5A94F79DF2C    evm_event_receiver_token_chain
  2E8017CE314D42B9AB41255A2BF0D8AC4CBE044722D7CB7A7D4598C4F5B93157    token_chain

Containers:
  1ddfc8b1bd46968dead137487cbe9069cf15fa5c3cd7e40a6085ee8995d7d82b
  dapp_cluster_system
  system

Extensions available:
  vector-db v0.5.1
  custom-sql-query v0.1.0
  stork-oracle v1.2.2
  ai-inference v0.1.11

Economy chain summary:
  tCHR asset ID                        : E1DD546E9DC2E5EC4CB06D6C60D604FF1BDA567B9282594D6D7C3BE358A3A6A6
  Account ID on economy chain.         : E198A02FDEC009B278E6A6E331E3AA962B26BAEC08AF53221951DF2A01DF8E01
  Account tCHR balance on economy chain: 9964000000

Token chain summary:
  Account ID on token chain.         : E198A02FDEC009B278E6A6E331E3AA962B26BAEC08AF53221951DF2A01DF8E01
  Account tCHR balance on token chain: 1000000
  Governor info (can approve proposals on token chain):
    Public key : 02466d7fcae563e5cb09a0d1870bb580344804617879a14949cf22285f1bae3f27
    Private key: 2222222222222222222222222222222222222222222222222222222222222222

##########################################################################
```

Based on this output, we'll create a key file and set a few environment variables to store some blockchain resource IDs for later use:

```bash
# Unless already created, this is where chr keeps configuration
mkdir -p ~/.chromia/

# Store the container owner keys from "Provider and container owner:"
echo BBBDFE956021912512E14BB081B27A35A0EABC4098CB687E973C434006BCE114 > ~/.chromia/token-migration-guide
echo 03ECD350EEBC617CBBFBEF0A1B7AE553A748021FD65C7C50C5ABB4CA16D4EA5B05 > ~/.chromia/token-migration-guide.pubkey

# Store the Token chain governor from "Governor info (can approve proposals on Token chain):"
echo 2222222222222222222222222222222222222222222222222222222222222222 > ~/.chromia/token-migration-guide-tc-governor
echo 02466d7fcae563e5cb09a0d1870bb580344804617879a14949cf22285f1bae3f27 > ~/.chromia/token-migration-guide-tc-governor.pubkey

# These will come in handy later
DC_BRID=270A5E0B8DBCAFFFDF772596BF3E5C814EBC492E95F099147AC4076BA22621AB
TC_BRID=2E8017CE314D42B9AB41255A2BF0D8AC4CBE044722D7CB7A7D4598C4F5B93157

# Dapp container name from "Containers:"
DAPP_CONTAINER=2fb301ad0c84708be00663b31c9993f1bb4c7e765959205357bd5ebf794cc8fc

# This will be the owner of our new token and also serve as the account distributing tokens. Based on the
# token-migration-guide keys. From "Account ID on Economy chain."
ACCOUNT_ID=E198A02FDEC009B278E6A6E331E3AA962B26BAEC08AF53221951DF2A01DF8E01
```

Now we have a local node ready to be used. This node persists no data and will be reset on restart.

#### 2. Deploy example dApp

We'll use [my-dapp](./my-dapp) as our example dApp which will create a token, `Original Token`, during setup. This token is what we'll migrate to a new token registered on Token chain.

First, prepare and build the dApp:

```bash
cd my-dapp
chr install
chr build --hide-lib-warnings
```

Update the deployment [configuration](./my-dapp/chromia.yml) and set `container` to the name from the node summary at startup:

```bash
sed -i "s/container: .*/container: $DAPP_CONTAINER/" chromia.yml
```

The `deployment` section should now look similar to this:

```yaml
deployments:
  local:
    url: http://localhost:7740
    container: 1ddfc8b1bd46968dead137487cbe9069cf15fa5c3cd7e40a6085ee8995d7d82b
```

Deploy the dApp by running `chr deployment create`:

```bash
chr deployment create -d local -bc my_dapp --hide-lib-warnings --key-id token-migration-guide -y
Building Blockchain: my_dapp
Errors: 0, User Warnings: 0, Lib Warnings: 71
Deployment of blockchain my_dapp was successful
Add the following to your project settings file:
deployments:
  local:
    chains:
      my_dapp: x"479CD6DCFB5CE12495D6BFAF005E85706BD638D61510DA3AB10CCE81CFCD9316"
```

Store the dApp BRID for later use:

```bash
MD_BRID=479CD6DCFB5CE12495D6BFAF005E85706BD638D61510DA3AB10CCE81CFCD9316
```

#### 3. Initialize dApp and create test data

Now let's initialize the chain to create the token we would like to migrate (the `Original Token`) and store the asset ID in a variable. The initialization will also create the same account we already have on Economy chain and Token chain:

```bash
chr tx -brid $MD_BRID init x\"$ACCOUNT_ID\"
ORIGINAL_ASSET_ID="$(chr query -brid $MD_BRID get_original_token_asset_id)"
echo "Original asset id: $ORIGINAL_ASSET_ID"
```

Verify that the `Original Token` exists on our chain:

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

Now let's create some data to migrate by minting `Original Token` tokens to a few accounts:

```bash
# Create 10 accounts with tokens
for n in $(seq 1 10); do
  chr tx -brid $MD_BRID --no-await mint "x\"03ECD350EEBC617CBBFBEF0A1B7AE553A748021FD65C7C50C5ABB4CA16D4EA$(printf "%04d\n" "$n")\"" "$ORIGINAL_ASSET_ID" $((1000 + 100 * $n))
done

# To verify
chr query -brid $MD_BRID -f json ft4.get_balances_filtered balance_filter=null page_size=null page_cursor=null | jq -r '.data[] | .account.id + ": " + (.amount | tostring)'
CEE22CE41E394462A40D102D1277F1FF27D887F150CEE3537090C43FC11CFD42: 1100
1FB08B6F1ED3CC0356EF6228C1FE96CA57B67FD11E893E296E1554AFEA416A5F: 1200
8C1E3EC02E5454DB8DD3E1385EEB05191BB57A7B8D69A18D6335C17532553621: 1300
DEFCA412F903145050F8294AEF2C547BE260886B5312606E9AB2596BB1DAE474: 1400
BBD1078149EF32291CDF4B299E85787DBBFBD847FCFDC52D901BA893E3747927: 1500
8B0F64D4D404DD9AFA9228ED0C59EA612385F24EC50A93650BB0A09260CC6A12: 1600
998C1AB20541159DE989FDC44C4A7056F43FF7DCFC50985785899EAA3934D68B: 1700
D8E29A29C6465F8903C9C573F4429B4EF1BAD97489C3A9ABB3EE4C0DA98D17AB: 1800
76F59423CAFD46D071313EFACF61E35F4BC4C9F37180F2568129B3252D2F93FC: 1900
1CFD696690CC4263E8825DE713ED9D08711C206F164907FCB3E39CE35BBC2624: 2000
```

#### 4. Register new token on Token chain

To create our new token on Token chain we need to register and approve the token. In our local environment we'll approve it ourselves, but on a real network this needs to be done by a Token chain governor.

Before we register our new token we need to know how much the total supply is of `Original Token` to be able to mint enough of our new token and cover the distribution to all accounts. Get and store the total supply:

```bash
ORIGINAL_TOKEN_SUPPLY=$(chr query -brid $MD_BRID -f json ft4.get_asset_by_id asset_id=$ORIGINAL_ASSET_ID | jq -r .supply)
echo "Original token supply: $ORIGINAL_TOKEN_SUPPLY"
```

On Token chain, propose a new token. Make sure you use the desired key pair for `chr` since this will be the token owner.

This will request the creation of a token named `New Token` and also provide one minting policy that will allow our transfer account to mint the initial supply that will be transferred to [my-dapp](./my-dapp) and distributed to all existing accounts.

```bash
# Propose the token
chr tx --ft-auth -brid $TC_BRID --key-id token-migration-guide propose_token "New Token" NT 6 "https://www.icon.com" "[[[x\"${ACCOUNT_ID}\"], ${ORIGINAL_TOKEN_SUPPLY}L, 1000000, ${ORIGINAL_TOKEN_SUPPLY}L, 0]]" '[]'

# Get the proposal id
PROPOSAL_ID=$(chr query -brid $TC_BRID -f json get_common_proposals_range from=0 until=9999999999999 only_pending=1 | jq -r '.[] | .rowid')
echo "Token proposal id: $PROPOSAL_ID"
```

Approve the token proposal as Token chain governor:

```bash
chr tx -brid $TC_BRID --key-id token-migration-guide-tc-governor make_common_vote x\"$(cat ~/.chromia/token-migration-guide-tc-governor.pubkey)\" $PROPOSAL_ID 1
```

Once approved, get and set the asset ID in a variable:

```bash
NEW_ASSET_ID="$(chr query -brid $TC_BRID -f json ft4.get_assets_by_name "name=New Token" page_size=null page_cursor=null | jq -r '.data[] | .id')"
echo "New asset id: $NEW_ASSET_ID"
```

#### 5. Mint the New Token

We now need to mint new tokens and transfer them to [my-dapp](./my-dapp) to distribute them to the accounts on that chain.

Mint the initial supply of the new token using the key for our transfer account (and the one in the minting policy):

```bash
chr tx --ft-auth -brid $TC_BRID mint_token --key-id token-migration-guide x\"$NEW_ASSET_ID\" ${ORIGINAL_TOKEN_SUPPLY}L

# Verify
chr query -brid $TC_BRID -f json ft4.get_assets_by_name "name=New Token" page_size=null page_cursor=null | jq -r '.data[] | .supply'
15500
```

Now we have a new token with the same supply of tokens as our original token.

#### 6. Register the new Token on dApp chain

Before we can transfer our new tokens we need to configure it in [my-dapp](./my-dapp) to accept the asset. This is done here in an operation, but would probably be more static in a real chain:

```bash
chr tx -brid $MD_BRID register_cross_chain_asset x\"$NEW_ASSET_ID\" "New Token" "NT" x\"$TC_BRID\"
```

#### 7. Transfer New Tokens to your Chain

Make a cross-chain transfer to move the new tokens from the Token chain to our [my-dapp](./my-dapp) chain:

```bash
# Initiate cross-chain transfer - make sure to use your transfer account keypair
chr tx --ft-auth --blockchain-rid $TC_BRID --key-id token-migration-guide ft4.crosschain.init_transfer "x\"$ACCOUNT_ID\"" 'x"'$NEW_ASSET_ID'"' ${ORIGINAL_TOKEN_SUPPLY}L '[x"'$MD_BRID'"]' 9999999999999
INIT_TRANSFER_TX_RID=99AB9F... # Set to the transaction RID from previous command

INIT_TRANSFER_TX_DATA=$(curl -s "http://localhost:7740/tx/$TC_BRID/$INIT_TRANSFER_TX_RID" | jq -r .tx)
INIT_TRANSFER_TX_GTV="$(chr tools gtv --hex $INIT_TRANSFER_TX_DATA | tr -d '[:space:]\n')"

# Apply transfer
chr tx --iccf-tx $INIT_TRANSFER_TX_RID --iccf-source $TC_BRID --iccf-force-intra-network --blockchain-rid $MD_BRID ft4.crosschain.apply_transfer 1 $INIT_TRANSFER_TX_GTV 1 0
APPLY_TRANSFER_TX_RID=61A8E7... # Set to the transaction RID from previous command

# Complete transfer
chr tx --iccf-tx $APPLY_TRANSFER_TX_RID --iccf-source $MD_BRID --blockchain-rid $TC_BRID ft4.crosschain.complete_transfer 1
```

Our transfer account should now have the initial supply of the new token:

```bash
chr query -brid $MD_BRID -f json ft4.get_asset_balance account_id=$ACCOUNT_ID asset_id=$NEW_ASSET_ID | jq -r .amount
15500
```

#### 8. Start the Migration Process

Start the migration process to convert original tokens to new tokens. Set `<batch size>` to a reasonable amount of account migrations per block, which depends on the number of accounts available and block time. For [my-dapp](./my-dapp), we can use a `<batch size>` of `4` to test the iteration, which should be 3 times due to our 10 accounts.

```bash
chr tx -brid $MD_BRID --key-id token-migration-guide migrate_asset $ORIGINAL_ASSET_ID x\"$NEW_ASSET_ID\" x\"$ACCOUNT_ID\" 4
```

What this will do in [my-dapp](./my-dapp):

1. Enable migration mode
2. Disable all transfers and minting of the original token
3. For each block, migrate `<batch size>` of accounts:
   1. Move tokens from our transfer account to the account.
   2. Burn all original tokens for this account.

With only 10 accounts, this shouldn't take long. You can check the node's logs and follow the migration:

```
INFO 2025-07-17 09:39:10.545 [0-BaseBlockDatabaseWorker] Rell - [bc-rid=47:9316, chain-id=100]: [main:migrate_asset(main.rell:113)] Migration of token 0x6250f686d8dc3095655aca1cfcdc7cc4eb747dd8fe255d74bfb70f41b6571c41 to 0xf4abed330029e4f87e54f0401869043a142fd030e479f23731e08f1a1c3a17d2 has started, with account 0xe198a02fdec009b278e6a6e331e3aa962b26baec08af53221951df2a01df8e01
INFO 2025-07-17 09:39:10.545 [0-BaseBlockDatabaseWorker] Rell - [bc-rid=47:9316, chain-id=100]: [main:run_batch_migration(main.rell:131)] Token batch migration, 0 accounts migrated out of 11
INFO 2025-07-17 09:39:10.546 [0-BaseBlockDatabaseWorker] Rell - [bc-rid=47:9316, chain-id=100]: [main:run_batch_migration(main.rell:147)] Migrating 3 accounts
INFO 2025-07-17 09:39:10.546 [0-BaseBlockDatabaseWorker] Rell - [bc-rid=47:9316, chain-id=100]: [main:run_batch_migration(main.rell:155)] Transferring 1100 to account 0xcee22ce41e394462a40d102d1277f1ff27d887f150cee3537090c43fc11cfd42
INFO 2025-07-17 09:39:10.549 [0-BaseBlockDatabaseWorker] Rell - [bc-rid=47:9316, chain-id=100]: [main:run_batch_migration(main.rell:155)] Transferring 1200 to account 0x1fb08b6f1ed3cc0356ef6228c1fe96ca57b67fd11e893e296e1554afea416a5f
...
INFO 2025-07-17 09:41:11.701 [0-BaseBlockDatabaseWorker] Rell - [bc-rid=47:9316, chain-id=100]: [main:run_batch_migration(main.rell:173)] Token migration completed
```

Verify the account balances:

```bash
# No accounts have any Original Token 
chr query -brid $MD_BRID -f json ft4.get_balances_filtered "balance_filter=[\"account_ids\":null, \"asset_ids\":[${ORIGINAL_ASSET_ID}]]" page_size=null page_cursor=null | jq -r '.data[] | .account.id + ": " + (.amount | tostring)'

# No supply of Original Token
chr query -brid $MD_BRID -f json ft4.get_asset_by_id asset_id=$ORIGINAL_ASSET_ID | jq -r .supply
0

# Accounts have new token
chr query -brid $MD_BRID -f json ft4.get_balances_filtered "balance_filter=[\"account_ids\":null, \"asset_ids\":[x\"${NEW_ASSET_ID}\"]]" page_size=null page_cursor=null | jq -r '.data[] | .account.id + ": " + (.amount | tostring)'

# Supply on my-dapp is 0, but this is expected
chr query -brid $MD_BRID -f json ft4.get_asset_by_id asset_id=$NEW_ASSET_ID | jq -r .supply
0

# Instead the total supply is available on TC, which is now the chain that can mint new tokens
chr query -brid $TC_BRID -f json ft4.get_asset_by_id asset_id=$NEW_ASSET_ID | jq -r .supply
15500
```

### Implement migration in your dApp

To migrate a token in your dApp, you can use [my-dapp](./my-dapp) as an example and copy the concept. However, it might need some adjustments to fit your needs. Some things to keep in mind:

- This guide assumes no minting or burning takes place from the point we read the Original tokens total supply and forward. Make sure this is also the case for your dApp, or prevent this from happening during the migration. Consider disabling minting and burning, if possible.
- Adjust batch size based on the number of accounts. Try to find a large number that speeds up the migration, but not too large to risk spending too much time building a block, which might trigger revolts. This can be hardcoded in your dApp.
- Do thorough testing before a migration on a real network. If something goes wrong you might end up in a complicated state.
- Verify and get details about your new token correct before requesting that it be created on Token chain. The token will be manually approved and can't be removed or updated once it is in use.



## Token migration on testnet

This section will describe how to migrate your token on a real network such as `testnet` or `mainnet`. Be aware of the network, since the steps will point to `testnet` but official documentation linked will refer to `mainnet`. Please make sure you have read [Token migration on a local network](#token-migration-on-a-local-network) and have implemented a tested migration in your dApp.

This guide follows the same process as [Token migration on a local network](#token-migration-on-a-local-network), except we use available frontends instead of `chr` for some account creation and transfer steps. The guide also assumes your dApp works in the same way as our example [my-dapp](./my-dapp).

> **⚠️ Warning:** This guide describes one of multiple ways to do this migration. Make sure to adapt it to your dApp and test thoroughly before attempting to migrate on a public network to avoid breaking assets or accounts. Prepare a rollback plan to be able to recover if this should happen. 

### Prerequisites

- [Chromia CLI](https://docs.chromia.com/intro/getting-started/installation/cli-installation) for posting transactions.
- `jq` for JSON parsing (optional but recommended).
- A cryptocurrency wallet extension, such as MetaMask.
- A basic understanding of [Token chain](https://docs.chromia.com/intro/about/architecture/chains/token-chain).
- A deployed dApp with a token, accounts, and necessary migration operations implemented.

### Preparation

To register a new token on Token chain we need to have an account on Token chain. This account will be the owner of the new token and will also be used to distribute tokens to all accounts on the `my-dapp` chain.

You need to decide which account you want to use for this and also make sure you have enough funds for the fees. At the time this guide was written the fee to register a new token is `100 CHR`. Read the current fee using this [query](https://chromaway.gitlab.io/core/directory-chain/-directory%20chain/token_chain/get_token_chain_constants.html). Make sure your account has enough funds to register a new token and possibly include some margin depending on how accounts are created.


### Step-by-Step Migration Guide

#### 1. Prepare the Token owner account

You need to decide which [account](#preparation) to use or [create a new account](https://docs.chromia.com/use-cases/integrations/exchange-guide/step-1-account). This account must exist or be created on Economy chain.

This account will be the owner of the new token and also be used to distribute the tokens to accounts on your chain. This will be done by first minting tokens to this account, transferring them from Token chain to your chain, and then running the migration job to distribute tokens to all accounts on that chain.

With an account on Economy chain, we need to create the same account on Token chain by transferring `CHR` by using the [vault transfer](https://vault.testnet.chromia.com/en/transfer/). Make sure you have enough `CHR` to cover the token registration [fee](#preparation).

Let's store our wallet address and compute the account ID in an environment variable for later use in this guide. Obtain your wallet address from your wallet extension.

```bash
WALLET_ADDRESS=1c918FC9C7f3D8943e67cAD0BfB4B8e57220490D # Replace with your address with any 0x prefix removed
ACCOUNT_ID=$(chr repl -c "x\"${WALLET_ADDRESS}\".hash()" | sed 's/[x"]//g')
echo "Account id: $ACCOUNT_ID"
```

#### 2. Prepare environment variables

To make later commands easier to execute, let's define some environment variables. Start by setting these manually:

```bash
# Set this for your network
API_URL=https://node0.testnet.chromia.com

# Set BRID of your dApp
MD_BRID="..."

# Set your current/original asset ID. This can be found by: chr query --api-url $API_URL -brid $MD_BRID ft4.get_assets_by_name name="<name>" page_size=null page_cursor=null
ORIGINAL_ASSET_ID="..."
```

Here are some more that can be set automatically:

```bash
DC_BRID=$(curl -s $API_URL/brid/iid_0)
echo "DC brid: $DC_BRID"

TC_BRID=$(chr query --api-url $API_URL -brid $DC_BRID get_token_chain_rid | sed 's/[x"]//g')
echo "TC brid: $TC_BRID"

ORIGINAL_TOKEN_SUPPLY=$(chr query --api-url $API_URL -brid $MD_BRID -f json ft4.get_asset_by_id asset_id=$ORIGINAL_ASSET_ID | jq -r .supply)
echo "Original token supply: $ORIGINAL_TOKEN_SUPPLY"
```


#### 3. Register new token on Token chain

To register a new token, we'll use `chr` since there is no frontend yet for this. When you register a new token, a proposal is created that must be approved by the Token chain governor before the token is created.

> **⚠️ Warning:** Make sure to verify all details for your token, since it might not be possible to revert or update later.

Register a new token and verify that the proposal is created. Note that this will open your web browser, and the wallet extension will ask you to sign the transaction.

```bash
chr tx --api-url $API_URL --ft-auth --evm-auth=$WALLET_ADDRESS -brid $TC_BRID propose_token "New Token" JN1 6 "https://www.icon.com" "[[[x\"${ACCOUNT_ID}\"], ${ORIGINAL_TOKEN_SUPPLY}L, 1000000, ${ORIGINAL_TOKEN_SUPPLY}L, 0]]" '[]'

# Check the proposal
chr query --api-url $API_URL -brid $TC_BRID get_proposals_by_proposer proposer=$ACCOUNT_ID
```

Await the manual review and approval before continuing with the next step.


#### 4. Store new asset id

Once the new token is approved and created, store the asset ID:

```bash
NEW_ASSET_ID=$(chr query --api-url $API_URL -brid $TC_BRID -f json ft4.get_assets_by_name name="New Token" page_size=null page_cursor=null | jq -r '.data[] | .id')
echo "New asset ID: $NEW_ASSET_ID"
```


#### 5. Mint the New Token

We now need to mint new tokens and transfer them to your dApp to distribute them to accounts on that chain.

Mint the initial supply of the new token with the key used for our transfer account (and the one in the minting policy):

```bash
chr tx --api-url $API_URL --ft-auth --evm-auth=$WALLET_ADDRESS -brid $TC_BRID mint_token x\"$NEW_ASSET_ID\" ${ORIGINAL_TOKEN_SUPPLY}L
```

Verify that the total supply matches `$ORIGINAL_TOKEN_SUPPLY`:

```bash
chr query --api-url $API_URL -brid $TC_BRID -f json ft4.get_asset_by_id asset_id=$NEW_ASSET_ID | jq -r .supply
```

We now have a new token with the same amount of tokens as our original token.


#### 6. Register the new token on dApp chain

Before we can transfer our new tokens back to our chain, we need to register it with the same asset ID. In the example [my-dapp](./my-dapp), we used an operation to do so, but this might not be the case for your dApp:

```bash
chr tx -brid $MD_BRID register_cross_chain_asset x\"$NEW_ASSET_ID\" "New Token" "NT" x\"$TC_BRID\"
```

#### 7. Transfer New Tokens to your chain

The final step before running the migration is to make a cross-chain transfer of all newly minted tokens from Token chain to our chain by a [vault transfer](https://vault.testnet.chromia.com/en/transfer/).

> **ℹ️ Information**: Your account needs to exist or support being created on your chain for this to succeed. In [my-dapp](./my-dapp), this account was created in the init operation. 

Verify the account balance after the transfer:

```bash
chr query -brid $MD_BRID -f json ft4.get_asset_balance account_id=$ACCOUNT_ID asset_id=$NEW_ASSET_ID | jq -r .amount
```

#### 8. Run the Migration

Start the migration process to convert the original tokens to new tokens. In [my-dapp](./my-dapp), this was done by calling the operation `migrate_asset` with some parameters:

```bash
chr tx -brid $MD_BRID migrate_asset $ORIGINAL_ASSET_ID x\"$NEW_ASSET_ID\" x\"$ACCOUNT_ID\" <batch size>
```

Use the same queries as in [start the migration process](#8-start-the-migration-process) to verify the result.
