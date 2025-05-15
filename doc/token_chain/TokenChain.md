# Token Chain

Token Chain is a dedicated blockchain designed to streamline token management, account creation and
bridging tokens between EVM and Chromia.

The idea is that any user should be able to create a new token on Chromia mainnet via token chain. Since the only
alternative way to introduce a token is to lease a container and create your own blockchain, this simplifies token
creation greatly. Even for container owners it might be beneficial to use token chain since it can add credibility to
the token and it also decouples it from the actual dApp chain where it is used.

It is also possible to add EVM bridges for tokens created via token chain.
Chromia-side setup is then done automatically.

Both creating a token and adding an EVM bridge costs a fee in CHR.

Token chain is a system chain and it should also be a safe hub for users to move their tokens to in case they are
worried about upcoming updates on dApp chains.

Will all EVM bridges be deployed on token chain? No, token chain just offers a somewhat simpler way to set up a bridge
but it is still perfectly possible for dApps to deploy their own bridges.

## User guide

For users that want to list tokens and add bridges, see [user-guide](user-guide.md)

## Governance

See [token-chain-governance-guide](token-chain-governance-guide.md)

## Economy chain configuration properties

Why does token chain configuration require so much information about economy chain since they seemingly have little
relation to each other? Token chain needs this information mainly for two reasons:

1. An account holder on economy chain can create an account for free on token chain
2. All payments on token chain are done with CHR. Meaning token chain needs to know all details about CHR and the
   economy chain RID so that it can enable cross-chain transfers of CHR to it (since economy chain is the origin chain
   for CHR token).
