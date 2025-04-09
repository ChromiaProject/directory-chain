# Begin block library

This library provides common functionality such as detecting configuration updates or scheduling jobs.

See [api.rell](../../src/lib/begin_block/api.rell) for the complete API reference and implementation details.

## Begin block

Extend `on_begin_block(height: integer)` to execute code on every block. This works similarly to the built-in `__begin_block` function, but can be extended by multiple functions if needed.

```rell
import lib.begin_block.*;

@extend(on_begin_block) function on_every_block(height: integer) {
    // code
}
```

## Detect configuration updates

Monitor configuration updates in your dapp by enabling this feature and extending the triggered function.

Enable with module args:

```yaml
blockchains:
  my_chain:
    moduleArgs:
      lib.begin_block:
        detect_configuration_updates: true
```

```rell
import lib.begin_block.*;

@extend(on_configuration_update) function chain_config_is_updated() {
    // code
}
```

## Scheduled callbacks

This feature enables your dapp to schedule jobs for execution, either once or multiple times. Since time on the blockchain is approximate and depends on your configuration, callbacks cannot be guaranteed to execute at exact times. The only guarantee is that callbacks will execute as soon as possible after the specified time has elapsed.

Each scheduled callback is given a `context` number and a `ref_id` number. These are useful to keep track of what this callback is for, e.g., by using the `ref_id` to point to a specific entity, and `context` to distinguish types of `ref_id`.

```rell
import lib.begin_block.*;

val my_entity_context = 1;

entity my_entity {
    // ...
}

function add_future_event() {
    val ref_id = create my_entity().rowid.to_integer();
    create_scheduled_callback_after(
        my_entity_context,
        ref_id,
        1000 * 60 * 60 * 3, // Execution in 3 hours
    );
}

function cancel_future_event(my_entity) {
    remove_scheduled_callback(my_entity_context, my_entity.rowid.to_integer());
}

@extend(on_scheduled_callback)
function my_callback(context: integer, ref_id: integer) {
    if (context == my_entity_context) {
        val my_entity = my_entity @? { rowid(ref_id) };
        // ...
    }
}
```