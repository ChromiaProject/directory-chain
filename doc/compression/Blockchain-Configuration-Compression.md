# Configuration compression

The directory chain allows compression of values in blockchain configurations. It is up to the client to request
compression and also to find and use already compressed values.

## How to use compressed configurations

A client can check what content has already been compressed before uploading a new configuration by using the query:

```
get_compressed_configuration_parts(configuration_part_hashes: set<byte_array>): list<byte_array>
```

The client can compute the hashes of all the values in the configuration paths that it wants to compress and pass them
to the query above. The returned hashes belong to values that are already compressed. These keys can safely be removed
from the configuration.

Now the client can build a `compressed_roots` configuration that will give instructions to the directory chain on which
configuration paths that it should compress and which keys that are already compressed.

It looks like follows (GTV example in YAML format):

```
# List of nodes in the configuration that contains compressed content
compressed_roots:
  - compressed_keys: # List of content keys that are already compressed and their corresponding hash
      - content_hash: x"28567C8238DA6341B3F19255BF6AEE373A562AC8CF61303FB36D67294629EA7F"
        content_key: example.rell
    path: # Specifies the search path to the node in the configuration that contains the keys to compress
      - gtx
      - rell
      - sources
```

So why does the client need to inform the directory chain about which values that are already compressed? It should know
this already. Well, we also want to decrease the size of the transactions made to the directory chain. We will
achieve this by just referring to the content hashes.
