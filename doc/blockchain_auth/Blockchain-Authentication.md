# Blockchain Authentication of directory chain operations

## Overview

Blockchain authentication allows a provider to authenticate its operations via a transaction on another blockchain using
ICCF or ICMF. One provider can enable blockchain-based authentication via either ICCF or ICMF, but not both at the same 
time. 

## Enabling Blockchain-Based Provider Authentication

The provider signs the initial transaction but does not need to sign further transactions. Note that the provider will 
not be able to sign transactions normally after this, be careful to not lock yourself out.

### ICCF

The `add_provider_blockchain_auth` operation enables a provider to use another blockchain for authentication via ICCF. 

**Parameters:**

- **`my_pubkey` (byte_array)**: The provider pubkey.

- **`blockchain_rid` (byte_array)**: The identifier (RID) of the blockchain whose operation will be used for
  authentication.

### ICMF

The `add_icmf_provider_blockchain_auth` operation enables a provider to use another blockchain for authentication via ICMF. 

**Parameters:**

- **`my_pubkey` (byte_array)**: The provider pubkey.

- **`blockchain_rid` (byte_array)**: The identifier (RID) of the blockchain will be sending ICMF messages on topic 
  "L_blockchain_auth".

- **`skip_to_height` (integer)**: The height on the other blockchain to start read messages from. 
  
## Usage

### ICCF

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

### ICMF

The controlling blockchain sends messages in the "L_blockchain_auth" topic, the message body has the following structure: 

```rell
struct blockchain_auth_message {
    /** pubkey of provider */ 
    my_pubkey: pubkey;

    /** the action */
    action: text;

    /** arguments to the action */
    args: list<gtv>;
}
```

The following actions are available, with expected arguments. 
They work like the corresponding regular operation in directory chain.

* remove_provider_blockchain_auth()
* propose_blockchain(config_data: byte_array, bc_name: text, container_name: text)
* propose_blockchain_action(blockchain_rid: byte_array, action: blockchain_action)
* propose_configuration(blockchain_rid: byte_array, config_data: byte_array)
* propose_forced_configuration(blockchain_rid: byte_array, config_data: byte_array, height: integer)
* propose_blockchain_rename(blockchain_rid: byte_array, name)

## Disabling Blockchain-Based Provider Authentication

A provider's ability to use a blockchain-based operation can be revoked, and normal signing re-enabled.

### ICCF

Use the `remove_provider_blockchain_auth_iccf` operation.

### ICMF

Send a message with the action "remove_provider_blockchain_auth". 
