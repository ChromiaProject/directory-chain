# Guide for governance on token chain

This guide assumes that you have Chromia CLI installed and configured to use a node in the relevant network.

Placeholders in the commands below are written as `${PLACEHOLDER}` and should be replaced by actual value.
To get detailed type information for these values, please refer to the auto-generated documentation:
https://chromaway.gitlab.io/core/directory-chain/-directory%20chain/token_chain/index.html

To get the blockchain RID of token chain in a network:

```shell
chr query --blockchain-rid ${DIRECTORY_CHAIN_RID} get_token_chain_rid
```

## Listing proposals

You can list all relevant proposals with query (replace YOUR_KEY with your public key):

```shell
chr query --blockchain-rid ${TOKEN_CHAIN_RID} get_relevant_common_proposals from=0 until=99999999999999 only_pending=1 my_pubkey=${YOUR_KEY}
```

To list information for a specific proposal use the id from previous query:

For token proposals (type = tc_propose_token):

```shell
chr query --blockchain-rid ${TOKEN_CHAIN_RID} get_token_proposal id=${ID}
```

For bridge proposals (type = tc_propose_token_bridge):

```shell
chr query --blockchain-rid ${TOKEN_CHAIN_RID} get_token_bridge_proposal id=${ID}
```

## Voting

To vote on a proposal (replace YOUR_PUBKEY with your public key, ID with proposal ID and VOTE with 0 to reject or 1 to accept):

```shell
chr tx --blockchain-rid ${TOKEN_CHAIN_RID} make_common_vote ${YOUR_PUBKEY} ${ID} ${VOTE} 
```
