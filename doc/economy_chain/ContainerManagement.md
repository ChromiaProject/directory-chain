# Container management

This guide assumes that you have Chromia CLI installed and configured to use a node in the relevant network.

To get the blockchain RID of economy chain in a network:

```
chr query --blockchain-rid ${DIRECTORY_CHAIN_RID} get_economy_chain_rid
```

## Adding new dApp providers to your container voter set

When leasing a container you must provide an initial dApp provider public key to manage the container.
This will automatically create a new dApp provider to directory chain and add it to the container voter set. 

The container voter set can approve deployment of new blockchains, accept new configurations etc.
You may want to add more members to this voter set. However, only dApp providers can be part of a voter set.
This guide describes how to add a new dApp provider to directory chain and your container voter set.

### Process Overview

Adding a new dApp provider to the container voter set is a two-step process:
1. Container lease owner requests new dApp provider, this creates a new dApp provider on directory chain.
It also automatically triggers a proposal to add this new dApp provider to the container voter set.
2. Container voter set approves the automatically generated proposal from step 1.

### Step 1: Request new dApp provider (Lease Owner)

```shell-script
chr deployment voterset add-dapp-provider --container-id ${CONTAINER_NAME} --evm-auth ${LEASE_OWNER_EVM_ADRESS} --pubkey ${NEW_PROVIDER}
```

Replace:
- `${LEASE_OWNER_EVM_ADRESS}` with lease owners EVM address in order to authenticate the operation
- `${CONTAINER_NAME}` with lease container name
- `${NEW_PROVIDER}` with the public key of the new dApp provider

### Step 2: Approve proposal to add dApp provider (Container voter set)

Use the `chr deployment proposal` commands in order to approve the automatically created proposal to add the new
provider to the container voter set.

## Transferring lease ownership

This guide explains the process of transferring ownership of a container lease from one user to another, completely
removing access from the original owner.

### Process Overview

Container lease ownership transfer is a two-step process:
1. Current owner creates a transfer offer
2. New owner accepts the transfer offer

### Step 1: Create a Transfer Offer (Current Owner)

As the current container lease owner, execute the following command:

```shell script
chr tx --blockchain-rid ${ECONOMY_CHAIN_RID} --evm-auth ${CURRENT_OWNER_EVM_ADDRESS} \
  offer_container_lease_ownership_transfer ${CONTAINER_NAME} ${NEW_OWNER_ACCOUNT}
```

Replace:
- `${ECONOMY_CHAIN_RID}` with blockchain RID of the economy chain
- `${CURRENT_OWNER_EVM_ADDRESS}` with current owners EVM address in order to authenticate the operation
- `${CONTAINER_NAME}` with lease container name
- `${NEW_OWNER_ACCOUNT}` with the FT4 account ID of the new owner

### Step 2: Accept the Transfer Offer (New Owner)

As the new owner, execute the following command:

```shell script
chr tx --blockchain-rid ${ECONOMY_CHAIN_RID} --evm-auth ${NEW_OWNER_EVM_ADDRESS} \
  accept_container_lease_ownership_transfer_offer ${CONTAINER_NAME}
```

Replace:
- `${ECONOMY_CHAIN_RID}` with blockchain RID of the economy chain
- `${NEW_OWNER_EVM_ADDRESS}` with new owners EVM address in order to authenticate the operation
- `${CONTAINER_NAME}` with lease container name

### Error Recovery

If a mistake is made in the transfer offer, the current owner can remove it and start over:

```shell script
chr tx --blockchain-rid ${ECONOMY_CHAIN_RID} --evm-auth ${CURRENT_OWNER_EVM_ADDRESS} \
  remove_container_lease_ownership_transfer_offer ${CONTAINER_NAME}
```

Replace:
- `${ECONOMY_CHAIN_RID}` with blockchain RID of the economy chain
- `${CURRENT_OWNER_EVM_ADDRESS}` with current owners EVM address in order to authenticate the operation
- `${CONTAINER_NAME}` with lease container name
