# Economy Chain synchronization from Directory Chain

To be able to calculate the correct rewards in Economy Chain (EC) information needs to be synchronized over from Directory Chain (DC) to EC.

The synchronization is done via extension functions in DC that are extended and then converted to ICMF messages that are sent to EC.
EC then receives the messages and updates the internal information that mirrors the information in DC. The information that is synced
over are `Providers`, `Nodes`, `Clusters` and the relationship between these.

```mermaid
sequenceDiagram
    participant DC as Directory Chain
    participant EC as Economy Chain
    DC->>+DC: DC entity updated and trigger extension function
    DC->>+EC: ICMF update message
    EC->>+EC: Update EC entity
```
