# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Directory Chain is a **Rell-based blockchain application** that serves as the node management and cluster management system for the Chromia network infrastructure. This is not a traditional JavaScript/TypeScript project but a specialized blockchain application written in **Rell** (Chromia's domain-specific language for blockchain development).

## Essential Commands

### Development Workflow
```bash
# Install dependencies and libraries
chr install

# Build the project
chr build

# Build with specific configuration file (e.g. chromia-testnet.yml)
chr build --hide-lib-warnings --settings <config-file>

# Run all tests
chr test

# Run tests with detailed reporting
chr test --test-report

# Run tests for a specific module (e.g. blockchain_auth.test)
chr test -m <module-name>

# Run tests for a specific blockchain
chr test -bc <blockchain-name>

# Run a specific test
chr test -t <test-name>

# Run Rell tests for a specific module with specific test names
chr test -m <module-name> --tests <csv-list-of-test-names>

# Run Rell tests for a specific module matching a pattern (e.g. *blockchain_auth*)
chr test -m <module-name> --tests <test-pattern>

# Generate documentation site
chr generate docs-site --target public
```

### Database Setup
- Requires PostgreSQL for testing
- Docker users: specify database host (mac: `host.docker.internal`, linux/win: `172.17.0.1`)
- Environment variable: `CHR_DATABASE_HOST=<host>`

## Code Architecture

### High-Level Structure
The codebase follows a **modular blockchain architecture** with these key components:

- **`src/common/`** - Core shared logic for directory chain operations, queries, and utilities
- **`src/economy_chain/`** - Financial logic including staking, rewards, and tokenomics
- **`src/token_chain/`** - Token management and cross-chain bridging functionality  
- **`src/anchoring_chain_*/`** - Blockchain anchoring and consensus mechanisms
- **`src/proposal_*/`** - Governance system with proposal creation and voting
- **`src/lib/`** - Shared libraries (FT4, ICMF, ICCF, etc.)

### Key Configuration Files
- **`chromia.yml`** - Main configuration defining blockchain modules, arguments, and test setups
- **`src/version.rell`** - API version management (currently v97)
- **`module-docs.md`** - Module-level documentation

### Cross-Chain Communication
- **ICMF (Inter-Chain Messaging Facility)** - For sending messages between blockchains
- **ICCF (Inter-Chain Confirmation Facility)** - For transaction confirmations across chains

## Development Patterns

### Testing
- Tests are co-located in `test/` subdirectories within each module
- Uses Rell's `@test module` annotation system
- Test configuration defined in `chromia.yml` under `test:` section
- Run specific test modules via configuration, not individual test files

### API Versioning
- **Critical**: Increment `src/version.rell` when adding/changing query or operation signatures
- API changes in `nm_api` or `cm_api` require updating respective library versions
- Use minor version bumps for API changes, patch for internal changes

### Release Process
1. Update API version in `version.rell` if needed
2. After CI build on dev branch, trigger `release-patch` or `release-minor`
3. Semver format: `a.b.c` (major.api-version.patch)

### Governance-First Architecture
- All network changes go through proposal/voting mechanisms
- Multi-chain architecture with Directory, Economy, Token, and Anchoring chains
- Configuration-driven deployment via YAML files

## Dependencies
- **Rell version**: 0.14.12
- **Database**: PostgreSQL  
- **Runtime**: Postchain (Chromia's blockchain runtime)
- **External libraries**: FT4, EIF, hbridge, ICMF/ICCF

## Important Notes
- This is blockchain infrastructure code, not web application code
- Changes often require corresponding updates to the Postchain Management Console (PMC)
- CI/CD pipeline uses GitLab with PostgreSQL containers
- Documentation in `/doc/` includes network setup and configuration guides