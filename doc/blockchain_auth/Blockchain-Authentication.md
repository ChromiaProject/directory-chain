# Blockchain Authentication of directory chain operations

## Overview

Blockchain authentication allows a provider to authenticate its operations via a transaction on another blockchain using
ICCF.

## Enabling Blockchain-Based Provider Authentication

The `add_provider_blockchain_auth` operation enables a provider to use another blockchain for authentication. The
provider signs the initial transaction but does not need to sign further operations. Note that the provider will not
be able to use sign transactions normally after this operation, be careful to not lock yourself out.

**Parameters:**

- **`my_pubkey`(byte_array)**: The provider pubkey.

- **`blockchain_rid` (byte_array)**: The identifier (RID) of the blockchain whose operation will be used for
  authentication.

## Disabling Blockchain-Based Provider Authentication

The `remove_provider_blockchain_auth_iccf` operation revokes a provider's ability to use a blockchain-based operation for
authentication, and re-enabling normal signing.

## General Workflow

1. A provider initiates authentication using an external blockchain by calling `add_provider_blockchain_auth`.
2. The provider signs the initial transaction, linking them to the specified blockchain.
3. Subsequent operations for authentication rely on the external blockchain, without requiring the provider to sign each
   operation.
4. If at any point the provider decides to stop using the external blockchain for authentication, they call
   `remove_provider_blockchain_auth_iccf`.

## Available operations

These operations are available for blockchain authentication in directory chain:

* remove_provider_blockchain_auth_iccf
* propose_blockchain_iccf
* propose_blockchain_action_iccf
* propose_configuration_iccf
* propose_forced_configuration_iccf
* propose_blockchain_rename_iccf

They have the same parameters:

- **`my_pubkey` (pubkey)**: The public key of the provider.
- **`tx_to_prove` (gtx_transaction)**: The transaction from the external blockchain proving authentication.
- **`op_index` (integer)**: The index of the relevant operation within the external transaction.

And require an ICCF proof of `tx_to_prove` to be included in the transaction.

The transaction from the external blockchain needs to include an operation with the same name but different parameters.
The operations in the external blockchain have parameters like the corresponding non-ICCF operation in directory chain 
(excluding `my_pubkey` and `description`):

* operation remove_provider_blockchain_auth_iccf()
* operation propose_blockchain_iccf(config_data: byte_array, bc_name: text, container_name: text)
* operation propose_blockchain_action_iccf(blockchain_rid: byte_array, action: blockchain_action)
* operation propose_configuration_iccf(blockchain_rid: byte_array, config_data: byte_array)
* operation propose_forced_configuration_iccf(blockchain_rid: byte_array, config_data: byte_array, height: integer)
* operation propose_blockchain_rename_iccf(blockchain_rid: byte_array, name)
