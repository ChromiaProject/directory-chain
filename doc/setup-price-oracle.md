# Setup Price oracle

The [Price oracle](https://bitbucket.org/chromawallet/priceoracle/src/main/) collects exchange rates from EVM contracts and sends the results on a global ICMF topic. It is currently only used by economy change and runs as a system chain.

## Requirements
 - EVM receiver listening on EVM contracts (see [postchain-eif](https://gitlab.com/chromaway/core/postchain-eif) repository).
 - Price oracle token configuration (default will support CHR/USD)

## Setup

1. Deploy EVM receiver for Price oracle

   Price oracle needs a dedicated evm receiver deployed in a similar way as the bridge & staking evm receiver. Build it from the [postchain-eif](https://gitlab.com/chromaway/core/postchain-eif) repository and deploy the `eif_event_receiver_price_oracle_mainnet` configuration by using `pmc`:

   `pmc network initialize-evm-event-receiver-price-oracle-chain -erc eif_event_receiver_price_oracle_mainnet.xml`

2. Clone price oracle

   ```
   git clone git@bitbucket.org:chromawallet/priceoracle.git
   cd priceoracle
   git checkout <tag>
   ```

3. Configuration

   Set the EVM receiver blockchain rid to be able to retrieve evm blocks through ICMF from it:

   ```
   icmf:
     receiver:
       local:
         - topic: L_evm_block_events
           bc-rid: x"0000000000000000000000000000000000000000000000000000000000000000" # TODO Set to EVM receiver bcrid
   ```
   
   Default pool and token configuration should be fine.

4. Deploy

   Now build and deploy:

   ```
   chr build
   pmc network initialize-price-oracle-chain -poc build/price_oracle.xml
   ```

5. Verify

    You might need to wait a few minutes for the first results but eventually the `CHR_per_USD` value should be updated with something else than the default value `5`:

   ```
   pmc economy get-constants |  grep CHR_per_USD
   ```