# Changelog

The latest version of the changelog can be found [here](https://github.com/Azure/bicep-registry-modules/blob/main/avm/ptn/finops-toolkit/finops-hub/CHANGELOG.md).

## 0.14.0

> **Aligns with [FinOps toolkit v14](https://github.com/microsoft/finops-toolkit/releases/tag/v14) (April 2026).**

### Changes

- Updated module version to track upstream FinOps toolkit v14 (April 2026 release)
- Confirmed FinOps hubs v14 add-ons such as recommendations packs, custom Azure Resource Graph query content, dashboards, and Copilot Studio templates remain owned by the official FinOps Toolkit repository
- Updated deployment constants and telemetry tags to report FinOps toolkit `14.0` across Bicep and ADF modules
- Fixed `src/Deploy-FinOpsHub.ps1` parameter mapping to match `main.bicep` (`existingDataExplorerClusterId`, `networkIsolationMode=BringYourOwn`, `byoSubnetResourceId`)
- Removed legacy `useExistingDataExplorer` and `privateEndpointSubnetId` parameter usage from deployment helper
- Aligned managed exports automation gating with upstream behavior (EA and MPA only; MCA remains manual export setup)
- Added the upstream-aligned `enableManagedExports` deployment switch and deployment-helper controls for billing type and disabling managed exports automation
- Upgraded all pinned AVM module references to current stable tags (including Storage `0.33.0`, Key Vault `0.14.0`, Data Factory `0.12.0`, Kusto `0.11.0`, VNet `0.10.2`, and AVM common types `0.7.0`)
- Added `src/Test-AvmVersionDrift.ps1` to detect AVM module version drift against MCR and support release hardening workflows

### Upstream Fixes (reference)

The following upstream hub fixes shipped in v14 that may affect deployments built on this module:

- Multi-currency Data Explorer dashboard sum correction
- US Government cloud time zone deployment fix
- Empty export file handling improvement
- Data Factory Init-DataFactory Event Grid race condition fix
- Power BI `P10Y` (10-year reservation) Term value storage refresh fix

See the [upstream v14 release notes](https://github.com/microsoft/finops-toolkit/releases/tag/v14) for the full list.

---

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
