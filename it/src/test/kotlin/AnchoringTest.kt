import assertk.assertThat
import assertk.assertions.isEqualTo
import assertk.assertions.isTrue
import net.postchain.chain0.common.operations.registerProviderOperation
import net.postchain.chain0.model.ProviderTier
import net.postchain.client.config.PostchainClientConfig
import net.postchain.common.tx.TransactionStatus
import net.postchain.d1.client.StandardChromiaClient
import org.awaitility.Awaitility
import org.awaitility.Duration
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Timeout
import java.util.concurrent.TimeUnit

@Timeout(10, unit = TimeUnit.MINUTES)
class AnchoringTest {

    @Test
    fun anchoring() {
        val client = StandardChromiaClient(PostchainClientConfig.fromProperties(".chromia/config"))
        val directoryChain = client.getDirectoryChainClient()

        val otherProviderKey = client.config.cryptoSystem.generateKeyPair()
        val result = directoryChain.transactionBuilder()
                .registerProviderOperation(
                        myPubkey = client.config.signers.first().pubKey.data,
                        pubkey = otherProviderKey.pubKey,
                        providerTier = ProviderTier.DAPP_PROVIDER,
                ).postAwaitConfirmation()
        assertThat(result.status).isEqualTo(TransactionStatus.CONFIRMED)

        Awaitility.await().atMost(Duration.ONE_MINUTE).untilAsserted {
            assertThat(client.isTxClusterAnchored(client.directoryChainRid, result.txRid)).isTrue()
        }

        Awaitility.await().atMost(Duration.ONE_MINUTE).untilAsserted {
            assertThat(client.isTxSystemAnchored(client.directoryChainRid, result.txRid)).isTrue()
        }
    }
}
