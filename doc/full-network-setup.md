# How to set up a complete mainnet-like network

This guide describes how to set up a new network with the same components that are available on Chromia mainnet.
It is not strictly necessary to follow the order in this document, but it is designed to be the least complicated one.

This guide is somewhat opinionated, there are alternative simplified setups that are not covered here. The idea
being that the setup on mainnet is also the best practice.

Any PMC commands are just listed with their name, use `--help` flag to see the exact arguments.

Please note that all blockchains that are documented here are system chains and should _always_ be deployed using a
`pmc network` command. Be wary that some guides that are linked here are generic and can be used for regular dApp chains
as well, so ensure that you always follow the deployment instructions in this document.

## Directory chain

You will need three configurations:

1. Directory chain
2. System anchoring chain
3. Cluster anchoring chain

To read more about directory chain configuration options, please
see: [DC-configuration-and-setup](directory_chain/DC-configuration-and-setup.md)

Now you can follow the instructions here (ensure you initialize the network with system and cluster anchoring chains):
[setup new network](https://gitlab.com/chromaway/postchain-chromia/-/blob/dev/doc/provider/setup-new-network.md?ref_type=heads)

## Price oracle

Please follow the guide [setup-price-oracle](setup-price-oracle.md).

## Economy chain

Start by deploying the CHR bridge(s). There is
a [general guide](https://gitlab.com/chromaway/core/postchain-eif/-/blob/dev/doc/contract/deployment.md?ref_type=heads).
This guide gives you some alternatives, you should go for the following options:

- *Chromia token bridge* contract, since CHR is a _native_ token
- *Managed* validator contract

Now you can set up the event receiver chain. Follow the guide for dual-chain
configuration [token-bridge-configuration](https://gitlab.com/chromaway/core/postchain-eif/-/blob/dev/doc/token-bridge-configuration.md?ref_type=heads).

Deploy the event receiver chain with the command:

```shell
pmc network initialize-evm-event-receiver-chain
```

Ensure that the nodes in the network have RPC urls configured for the network(s) you deploy the bridge on.

To read more about economy chain configuration options and how to deploy, please
see: [EC-configuration-and-setup](economy_chain/EC-configuration-and-setup.md)

In that guide you will see a list of ICMF topics that the economy chain will listen to. Ensure that blockchain RIDs
are set properly. You can omit the topic for transaction submitter chain until you have completed the
[transaction submitter](#transaction-submitter) section.

## Token chain

The first step is to set up an event receiver chain. Since bridges are added dynamically to token chain you need to
also deploy a dynamic event receiver. See docs [event receiver](https://gitlab.com/chromaway/core/postchain-eif/-/blob/dev/doc/event-receiver-chain-configuration.md?ref_type=heads#dynamic-receiver).
Set module arg `configuration_chain` to `token_chain`.

Ensure that the nodes in the network have RPC urls configured for the network(s) you want to support. See 
[EVM Event Receiver Node Configuration](https://gitlab.com/chromaway/core/postchain-eif/-/blob/dev/doc/event-receiver-chain-configuration.md?ref_type=heads#evm-event-receiver-node-configuration) 
for details.

To read more about token chain configuration options and how to deploy, please
see: [TC-configuration-and-setup](token_chain/TC-configuration-and-setup.md)

Ensure that blockchain RID for economy chain is set correctly and that the event receiver chain RID is properly set in
the ICMF configuration.

Deploy a managed validator contract on EVM for token chain (will be used in
the [transaction submitter](#transaction-submitter) section). See the
[guide](https://gitlab.com/chromaway/core/postchain-eif/-/blob/dev/doc/contract/deployment.md?ref_type=heads#deploying-validator-contract)
you should supply the token chain RID with the `--blockchain-rid` flag.

## Transaction submitter

To read more about transaction submitter configuration and how to deploy, please
see: [transaction-submitter-configuration-and-setup.md](https://gitlab.com/chromaway/core/postchain-eif/-/blob/dev/doc/transaction-submitter-configuration-and-setup.md?ref_type=heads)

Ensure that the nodes in the network have RPC urls configured for the network(s) you want to support. Also, ensure that
at least one of the nodes has enough balance in its configured wallet on EVM.

Ensure that blockchain RIDs for directory chain, system anchoring chain and economy chain are set correctly.

Ensure that economy chain bridge is added to the "system_bridges" section of the transaction submitter configuration as
well as token chain (address can be left empty for token chain).

Update economy chain ICMF configuration to listen to transaction submitter topic
`G_evm_transaction_submitter_cost_topic`.
