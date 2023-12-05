# Ticket Chain queries

## Queries

| Name                                        | Arguments              | Return type            | Description                                                 |
|---------------------------------------------|------------------------|------------------------|-------------------------------------------------------------| 
| get_pool_balance                            |                        | big_integer            | Returns current balance of reward pool                      |
| get_balance                                 | account_id: byte_array | big_integer            | Get balance of the account                                  |
| get_create_container_ticket_by_transaction  | tx_rid: byte_array     | container_ticket_data? | Returns ticket information for the create container ticket  |
| get_create_container_ticket_by_id           | ticket_id: integer     | container_ticket_data? | Returns ticket information for the create container ticket  |
| get_upgrade_container_ticket_by_transaction | tx_rid: byte_array     | container_ticket_data? | Returns ticket information for the upgrade container ticket |
| get_upgrade_container_ticket_by_id          | ticket_id: integer     | container_ticket_data? | Returns ticket information for the upgrade container ticket |
| get_leases_by_account                       | account_id: byte_array | list<lease_data>       | Get leases for an account                                   |
| get_lease_by_container_name                 | container_name: text   | lease_data?            | Get current lease for a container                           |
| get_min_lease_duration                      |                        | integer                | Get minimum lease time in weeks                             |
| get_max_lease_duration                      |                        | integer                | Get maximum lease time in weeks                             |
| get_chr_asset                               |                        | asset info             | Get information about the CHR asset                         |

## Return types

| Name                  | Type   | Fields                                                                                                                                                                         |
|-----------------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| container_ticket_data | struct | ticket_id: integer<br>type: ticket_type<br>state: ticket_state<br>error_message: text<br>container_name: text                                                                  |
| lease_data            | struct | container_name: text<br>cluster_name: text<br>container_units: integer<br>extra_storage_gib: integer<br>expire_time_millis: integer<br>expired: boolean<br>auto_renew: boolean |
| asset info            | tuple  | id: byte_array<br>name: text<br>symbol: text<br>decimals: integer<br>brid: byte_array<br>icon_url: text<br>supply: big_integer                                                 |

For more information about accounts and asset info see the FT4 [documentation](https://docs.chromia.com/category/ft4-accounts-and-tokens).