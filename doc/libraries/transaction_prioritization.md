# Transaction prioritization

This [library](../../src/lib/transaction_prioritization/module.rell) contains structs and help function to add [transaction prioritization](https://gitlab.com/chromaway/postchain/blob/dev/postchain-base/src/main/kotlin/net/postchain/base/BaseTransactionPrioritizer.kt).

The [main module](../../src/lib/transaction_prioritization/module.rell) adds the model and help functions to generate results.

The [extendable module](../../src/lib/transaction_prioritization/extendable.rell) adds extender functions for both v1 and v2. You can either use module and extend the functions, or simply implement them directly in your dapp.
