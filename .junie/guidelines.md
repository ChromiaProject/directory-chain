# Directory Chain Development Guidelines

This document provides essential information for developers working on the Directory Chain project.

## Build/Configuration Instructions

### Building the Project

The project is built using the Chromia CLI (`chr`). To build the project:

```bash
# Build the entire project
chr build --hide-lib-warnings

# Build specific blockchains
chr build --hide-lib-warnings --blockchain=<blockchain_name>
```

### Database Configuration

The project requires a PostgreSQL database. Configure it in your `chromia.yml` file or provide environment variables:

```yaml
database:
  host: <host>  # For Docker: host.docker.internal (Mac) or 172.17.0.1 (Linux/Windows)
  logSqlErrors: true
  schema: chain0test
  driver: org.postgresql.Driver
```

### Configuration Files

The main configuration file is `chromia.yml`, which defines:
- Blockchains and their modules
- Module arguments
- Library dependencies
- Test configurations
- Database settings
- Compilation settings

For Economy Chain specific configuration, refer to the detailed configuration guide in `doc/economy_chain/EC-configuration-and-setup.md`.

## Testing Information

### Test Structure

Tests in the Directory Chain project are written in Rell and organized by component:
- Each module typically has a `test` directory containing test files
- Test modules are annotated with `@test module`
- Test functions are prefixed with `test_`
- The Rell test API (`rell.test`) provides utilities for testing

### Running Tests

To run tests:

```bash
# Run all tests
chr test --hide-lib-warnings

# Run tests for specific blockchains
chr test --hide-lib-warnings --blockchain=<blockchain_name>

# Run tests in specific modules
chr test --hide-lib-warnings --modules=<module_name>

# Run a specific test function
chr test --hide-lib-warnings --tests=<test_name>

# Run without database connection (for simple tests)
chr test --hide-lib-warnings --no-db

# Enable SQL logging
chr test --hide-lib-warnings --sql-log
```

### Example Test

Here's a simple example of a test in Rell:

```rell
@test module;

// A simple test function
function test_simple_assertion() {
    // Simple assertion
    assert_equals(1 + 1, 2);
    
    // Test with a calculation
    val result = 2 * 2;
    assert_equals(result, 4);
    
    // Debug logging
    print("[DEBUG_LOG] Test message");
}
```

### Adding New Tests

To add new tests:

1. Create a new file in the appropriate `test` directory
2. Annotate it with `@test module`
3. Write test functions prefixed with `test_`
4. Use assertions like `assert_equals`, `assert_true`, etc.
5. Run the tests using the `chr test` command described above

## Additional Development Information

### Project Structure

The Directory Chain is organized into multiple modules:
- `src/common`: Common utilities and models
- `src/economy_chain`: Economy Chain implementation
- `src/token_chain`: Token Chain implementation
- `src/management_chain`: Management Chain implementation
- `src/cm_api`: Cluster Management API
- `src/nm_api`: Node Management API
- `src/proposal`: Proposal system
- Various other modules for specific functionality

### Cross-Chain Communication

The project uses two facilities for communication between blockchains:

1. **Inter-Chain Messaging Facility (ICMF)**:
   - Import with `import lib.icmf.*;`
   - Send messages with `send_message(topic: text, body: gtv)`
   - Receive messages by extending `receive_icmf_message()`

2. **Inter-Chain Confirmation Facility (ICCF)**:
   - Used for cross-chain transaction verification

### Code Style and Conventions

- Use the Rell language's built-in formatting
- Follow the existing code structure and naming conventions
- Use descriptive names for functions, variables, and modules
- Write comprehensive tests for new functionality

### Versioning

When changing API (queries and operations), update the version in `version.rell`. For changes to `nm_api` or `cm_api`, update their respective versions as well.

When changing API (queries and operations) in Economy Chain, update the version in `economy_chain/version.rell`.

The project follows semantic versioning with the format `a.b.c`:
- `a`: Major version (1 for now)
- `b`: Minor version / Directory Chain API version, should match `version.rell`
- `c`: Patch version / API changes in any other chain (e.g., Economy Chain)

### Dependencies on PMC Tool

Changes to this project often require corresponding changes to the Postchain Management Console (PMC) for elements that can be configured by providers. Remember to increment `version.rell` appropriately so existing PMC users know to upgrade.
