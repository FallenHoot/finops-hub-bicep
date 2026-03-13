# Changelog

The latest version of the changelog can be found [here](https://github.com/Azure/bicep-registry-modules/blob/main/avm/ptn/finops-toolkit/finops-hub/CHANGELOG.md).

## 0.12.0

> **Why version 0.12?** This AVM module version aligns with [FinOps toolkit v0.12](https://github.com/microsoft/finops-toolkit/releases/tag/v0.12) to maintain parity with the upstream project. The jump from 0.1.x to 0.12.0 skips intermediate versions because 2-3 years of upstream FinOps toolkit evolution (v0.2 through v0.11) occurred before this module was rewritten as an AVM pattern module. Rather than artificially using a low version number that misrepresents the maturity of the underlying solution, the version reflects the actual upstream release this module is built against.

### Changes

- Complete rewrite using Azure Verified Modules (AVM) resource modules
- Support for three deployment types: `storage-only`, `adx` (Azure Data Explorer), `fabric` (Microsoft Fabric)
- Configuration profiles: `minimal` for dev/test, `waf-aligned` for production
- Azure Data Explorer integration with automatic schema deployment
- Microsoft Fabric eventhouse integration
- Private endpoint support for all resources (storage, Key Vault, Data Factory, ADX)
- Managed identity support with option to bring existing identity
- Existing ADX cluster support
- RBAC-based Key Vault authorization (recommended)
- Automatic trigger management for idempotent deployments
- MACC (Microsoft Azure Consumption Commitment) tracking support

### Breaking Changes

- Parameter `storageSku` replaced by `deploymentConfiguration` profile
- Parameter `exportScopes` removed (not applicable to new architecture)
- Container names now follow FinOps toolkit standard: `config`, `msexports`, `ingestion`
- New required parameter `hubName` constraints: 3-24 characters
