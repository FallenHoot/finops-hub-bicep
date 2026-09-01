# FinOps Hub - Internal Bicep Modules

This folder contains internal helper modules used by the main `main.bicep` template. These are **not** standalone AVMs - they are implementation details for the AVM base kit and should not be used directly.

The modules in this folder are limited to foundational deployment concerns:
resource composition, network isolation, Data Factory orchestration, ADX schema
bootstrap, and deployment idempotency. Optional FinOps Toolkit add-ons such as
dashboard packs, recommendation content packs, and advanced analytics experiences
belong in the official Microsoft FinOps Toolkit repository.

## Module Architecture

```
main.bicep (the AVM-first entry point)
    │
    ├── br/public:avm/res/managed-identity/user-assigned-identity
    ├── br/public:avm/res/storage/storage-account
    ├── br/public:avm/res/key-vault/vault
    ├── br/public:avm/res/data-factory/factory
    ├── br/public:avm/res/kusto/cluster
    ├── br/public:avm/ptn/authorization/resource-role-assignment
    │
    ├── modules/dataFactoryResources.bicep  → ADF child resources (pipelines, datasets, triggers)
    ├── modules/network.bicep               → Composes AVM NSG, VNet, and Private DNS zone modules
    ├── modules/triggerManagement.bicep     → PowerShell deployment scripts for trigger control
    │
    ├── modules/adxSchemaSetup.bicep        → Orchestrates KQL script deployment order
    ├── modules/hub-database.bicep          → Generic KQL script runner for ADX
    ├── modules/adxManagedIdentityPolicy.bicep   → ADX MI policy configuration (reference only)
    ├── modules/adxManagedPrivateEndpoint.bicep  → ADF managed PE to ADX
    ├── modules/adxPrivateEndpointApproval.bicep → PE approval logic
    │
    └── modules/scripts/                    → KQL scripts (see scripts/README.md)
```

## How Modules Work

### 1. Azure Verified Modules (called directly from `main.bicep`)

This solution is AVM-first. `main.bicep` references Azure Verified Modules
directly rather than wrapping them in local modules. There are no
`storage.bicep`, `keyVault.bicep`, or `dataFactory.bicep` wrapper modules.

| AVM module | Purpose |
|------------|---------|
| `avm/utl/types/avm-common-types` | Shared `lockType` and `diagnosticSettingFullType` |
| `avm/res/managed-identity/user-assigned-identity` | Hub managed identity |
| `avm/res/storage/storage-account` | ADLS Gen2 data lake |
| `avm/res/key-vault/vault` | Secret storage for Data Factory |
| `avm/res/data-factory/factory` | Ingestion orchestration |
| `avm/res/kusto/cluster` | Azure Data Explorer cluster |
| `avm/ptn/authorization/resource-role-assignment` | All RBAC role assignments |
| `avm/res/network/network-security-group` | Managed network NSG (via `network.bicep`) |
| `avm/res/network/virtual-network` | Managed VNet and subnets (via `network.bicep`) |
| `avm/res/network/private-dns-zone` | Blob, DFS, Key Vault, Data Factory, Kusto zones (via `network.bicep`) |

All AVM references are version-pinned. `enableTelemetry` is plumbed from the
top-level parameter into every AVM module call. Before adding any `resource`
declaration, check for an existing AVM resource, pattern, or utility module.

### 2. Custom Resource Modules
These modules create resources not available as AVMs:

| Module | Purpose |
|--------|---------|
| `network.bicep` | Composes AVM network modules into the managed VNet topology |
| `dataFactoryResources.bicep` | All ADF pipelines, datasets, linked services, triggers |
| `triggerManagement.bicep` | Deployment scripts to stop/start triggers |

### 3. ADX Schema Modules
These modules deploy the FinOps Hub schema to Azure Data Explorer:

| Module | Purpose |
|--------|---------|
| `adxSchemaSetup.bicep` | Orchestrates KQL script deployment in correct order |
| `hub-database.bicep` | Generic wrapper that creates `Microsoft.Kusto/clusters/databases/scripts` resources |
| `adxManagedIdentityPolicy.bicep` | ⚠️ **Legacy / not used** — See note below |

> **Note on `adxManagedIdentityPolicy.bicep`**: This module is retained as reference only and is **not wired into the deployment graph**. ADX does not natively support executing cluster-level management commands (e.g., `.alter-merge cluster policy managed_identity`) through ARM-deployable resources — `Microsoft.Kusto/clusters/databases/scripts` is limited to database-scoped commands, and deployment scripts face a known ARM→ADX control-plane timing gap. This limitation has been reported to the ADX Product Group. The accepted workaround is to set the managed identity policy at runtime via an ADF `AzureDataExplorerCommand` pipeline activity (see ADR-013).

## Key Concepts

### Script Deployment Mechanism

KQL scripts are deployed using native ADX `scripts` resources:

```bicep
// 1. adxSchemaSetup.bicep loads KQL at compile time
var rawTablesScript = loadTextContent('scripts/IngestionSetup_RawTables.kql')

// 2. Passes to hub-database.bicep module
module ingestionScripts 'hub-database.bicep' = {
  params: {
    scripts: {
      RawTables: rawTablesScript
    }
  }
}

// 3. hub-database.bicep creates ADX script resources
resource script 'scripts' = [for scr in items(scripts): {
  name: scr.key
  properties: {
    scriptContent: scr.value
    continueOnErrors: true
    forceUpdateTag: utcNow()  // Forces re-execution each deployment
  }
}]
```

### Network Isolation Modes

The `network.bicep` module supports the "Managed" mode:

| Mode | What Module Creates | Who Manages Upgrades |
|------|--------------------|--------------------|
| `None` | Nothing (public access) | Just redeploy |
| `Managed` | VNet, subnet, NSG, DNS zones, PEs | Just redeploy |
| `BringYourOwn` | Nothing (customer provides) | Customer tests before upgrade |

## Adding New Modules

When adding new functionality:

1. **Keep the base-kit boundary**: Add only foundational deployment plumbing here; leave add-on content in FinOps Toolkit
2. **Prefer AVMs**: If an AVM exists for the resource, create a thin wrapper
3. **Follow naming**: Use descriptive names that match Azure resource types
4. **Keep types separate**: Use `types.bicep` for shared type definitions
5. **Document dependencies**: Add comments explaining module dependencies

## See Also

- [scripts/README.md](./scripts/README.md) - KQL script documentation
- [main.bicep](../main.bicep) - Main module entry point
- [FinOps Toolkit](https://aka.ms/finops/toolkit) - Official documentation
