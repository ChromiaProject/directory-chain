import assertk.assertThat
import assertk.assertions.hasSize
import assertk.assertions.isEmpty
import assertk.assertions.isEqualTo
import com.chromia.ft4.EvmSigner
import com.chromia.ft4.addEvmAuthenticationOp
import com.chromia.lib.ft4.core.auth.Signature
import net.postchain.chain0.common.queries.getContainerData
import net.postchain.chain0.economy_chain_in_directory_chain.getEconomyChainRid
import net.postchain.client.config.PostchainClientConfig
import net.postchain.common.BlockchainRid
import net.postchain.common.hexStringToByteArray
import net.postchain.common.tx.TransactionStatus
import net.postchain.common.wrap
import net.postchain.crypto.KeyPair
import net.postchain.crypto.sha256Digest
import net.postchain.d1.client.StandardChromiaClient
import net.postchain.economy.economy_chain.CREATE_CONTAINER_WITH_SUBNODE_IMAGE
import net.postchain.economy.economy_chain.createContainerWithSubnodeImageOperation
import net.postchain.economy.economy_chain.getLeasesByAccount
import net.postchain.economy.economy_chain_test_claim_tchr.createAccountOperation
import net.postchain.gtv.GtvFactory.gtv
import net.postchain.gtv.merkle.GtvMerkleHashCalculatorV2
import net.postchain.gtv.merkleHash
import org.awaitility.Awaitility
import org.awaitility.Duration
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Timeout
import org.web3j.crypto.ECKeyPair
import org.web3j.crypto.Keys
import org.web3j.crypto.Sign
import java.math.BigInteger
import java.nio.charset.StandardCharsets
import java.util.concurrent.TimeUnit

const val DAPP_CLUSTER = "dappCluster"

@Timeout(10, unit = TimeUnit.MINUTES)
class EconomyChainTest {

    companion object {
        val client = StandardChromiaClient(PostchainClientConfig.fromProperties(".chromia/config"))
        val directoryChain = client.getDirectoryChainClient()
        val economyChainRid = BlockchainRid(directoryChain.getEconomyChainRid()!!)
        val economyChain = client.getClient(economyChainRid)
        val providerPubkey = client.config.signers.first().pubKey.data
        val providerEvmKeyPair: ECKeyPair = ECKeyPair.create(client.config.signers.first().privKey.data)
        val providerEvmAddress = Keys.getAddress(providerEvmKeyPair.publicKey).hexStringToByteArray()
        val providerAccountId = gtv(providerEvmAddress).merkleHash(GtvMerkleHashCalculatorV2(::sha256Digest))

        val evmSigner = EvmSigner { _, message ->
            val signatureData = Sign.signPrefixedMessage(
                    message.toByteArray(StandardCharsets.UTF_8),
                    providerEvmKeyPair,
            )
            Signature(signatureData.r.wrap(), signatureData.s.wrap(), BigInteger(signatureData.v).longValueExact())
        }

        @BeforeAll
        @JvmStatic
        fun setup() {
            registerAccount()
        }

        private fun registerAccount() {
            val result = economyChain.transactionBuilder(listOf(
                    KeyPair("03766AC6BF7B7BFED3CCFC09B58D1BEB9F1B0A9E35FC3DA3BE1CF70120618C7BFB".hexStringToByteArray(),
                            "F5216FCCF80F13A2CCEA31F331D881A620F60596B21A9737989297896A8F7E65".hexStringToByteArray())))
                    .createAccountOperation(providerEvmAddress)
                    .postAwaitConfirmation()
            assertThat(result.status).isEqualTo(TransactionStatus.CONFIRMED)
        }
    }

    @Test
    fun `create container`() {
        assertThat(economyChain.getLeasesByAccount(providerAccountId)).isEmpty()

        val result = economyChain.transactionBuilder()
                .apply {
                    addEvmAuthenticationOp(
                            economyChain, this,
                            opName = CREATE_CONTAINER_WITH_SUBNODE_IMAGE,
                            opArgs = listOf(gtv(providerPubkey), gtv(1), gtv(1), gtv(0), gtv(DAPP_CLUSTER), gtv(false), gtv(""), gtv(0)),
                            evmAddress = providerEvmAddress,
                            accountId = providerAccountId,
                            signer = evmSigner,
                    )
                }
                .createContainerWithSubnodeImageOperation(
                        providerPubkey = providerPubkey,
                        containerUnits = 1,
                        durationWeeks = 1,
                        extraStorageGib = 0,
                        clusterName = DAPP_CLUSTER,
                        autoRenew = false,
                        subnodeImageName = "",
                        extraComputeRequests = 0,
                ).postAwaitConfirmation()
        assertThat(result.status).isEqualTo(TransactionStatus.CONFIRMED)

        Awaitility.await().atMost(Duration.FIVE_MINUTES).untilAsserted {
            val leases = economyChain.getLeasesByAccount(providerAccountId)
            assertThat(leases).hasSize(1)
            assertThat(leases[0].clusterName).isEqualTo(DAPP_CLUSTER)
            val containerName = leases[0].containerName

            val containerData = directoryChain.getContainerData(containerName)
            assertThat(containerData.cluster).isEqualTo(DAPP_CLUSTER)
        }
    }
}
