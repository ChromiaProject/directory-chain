# Dapp Directory chain

The directory chain framework contains the logic for the system chains on Chromia:

### Directory chain:

A dapp for managing all blockchains in the network, including itself. It stores all the needed information to run the network, such as a list of providers, nodes and configurations (code) of all blockchains on the Chromia network. This information is crucial for nodes to synchronize and maintain a consistent network state.

### Economy chain:

The economy chain acts as the financial core of the network, managing container pricing, provider rewards, and dapp payments through leases. It communicates with the directory chain for resource allocation and leverages a pooled reward system to incentivize node providers. Cost and reward calculations factor in metrics like node availability, occupancy, and set fees.

### Cluster Anchoring Chain:

Each cluster has its own anchoring chain, specifically responsible for anchoring blocks from its associated chains. This process involves serializing and committing the headers of all blockchains within a cluster to the cluster anchoring chain. Subsequently, these committed blocks can be further anchored to either a system anchoring chain or an external blockchain like Ethereum.

### System Anchoring Chain:

The system anchoring chain stands as the top-level anchoring point for the entire Chromia network. It serves as a repository for anchoring blocks from all cluster anchoring chains. This comprehensive anchoring mechanism provides a unified view of the network's state, facilitating the detection and resolution of consensus failures. In the event of a consensus failure, blocks anchored in the system anchoring chain take precedence over conflicting versions, ensuring the integrity and reliability of the Chromia network.

# Module cm_api

Cluster Management API

# Module nm_api

Node Management API

# Module anchoring_chain_cluster

Cluster Anchoring Chain

# Module anchoring_chain_common

Common logic for anchoring chains

# Module anchoring_chain_system

System Anchoring Chain

# Module auth_service

Authenticates providers using an auth-server

# Module common

Common logic for directory chain

# Module common.init

Initialization module for the common logic

# Module common.operations

Common operations always accessed withing the directory chain

# Module common.queries

Common queries always accessed withing the directory chain


