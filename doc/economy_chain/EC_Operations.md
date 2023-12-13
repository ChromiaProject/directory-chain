# Economy Chain operations

## Operations

| Name                      | Arguments                                                                                                                                                                        | Description                                                                                                                                                                                                                                              |
|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| 
| register_provider_account | provider_pubkey: pubkey                                                                                                                                                          | Will create a new FT4 account associated with the provider. If the provider already have an account the operation will fail.                                                                                                                             |
| create_container          | provider_pubkey: pubkey<br>container_units: integer<br>cluster_class: text<br>duration_weeks: integer<br>extra_storage_gib: integer<br>cluster_name: text<br>auto_renew: boolean | Request creation of a container. If enough tokens are available on the users account an ICMF message will be sent to DC for creation of the container. A lease is setup for the request amount of weeks and the cost is deducted from the users account. |
| upgrade_container         | container_name: text<br>upgraded_container_units: integer<br>upgraded_cluster_class: text<br>upgraded_extra_storage_gib: integer<br>upgraded_cluster_name: text                  | If possible upgrade the container to requested specifications.                                                                                                                                                                                           |
| renew_container           | container_name: text<br>duration_weeks: integer                                                                                                                                  | Renew container lease.                                                                                                                                                                                                                                   |
| auto_renew_container      | container_name: text                                                                                                                                                             | Turn on auto-renewal of lease for container.                                                                                                                                                                                                             |
| cancel_renew_container    | container_name: text                                                                                                                                                             | Cancel auto-renewal of lease.                                                                                                                                                                                                                            |
| transfer_to_pool          | amount: big_integer                                                                                                                                                              | Transfer tokens to the common pool account.                                                                                                                                                                                                              |

## Arguments

| Name                       | Type        | Description                                        |
|----------------------------|-------------|----------------------------------------------------|
| provider_pubkey            | pubkey      | Pubkey of a provider                               |
| container_units            | integer     | Number of container_units                          |
| cluster_class              | text        | Tag on cluster. Used to find a suitable cluster    |
| duration_weeks             | integer     | Lease duration in weeks                            |
| extra_storage_gib          | integer     | Extra storage to associate with a container in GiB |
| cluster_name               | text        | Name of cluster to use                             |
| auto_renew                 | boolean     | Should a lease be auto-renewed or not              |
| upgraded_cluster_class     | text        | Number of container_units                          |
| upgraded_extra_storage_gib | integer     | Extra storage to associate with a container in GiB |
| upgraded_cluster_name      | text        | Name of cluster to use                             |
| amount                     | big_integer | An amount of tokens                                |