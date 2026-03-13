# FinOps Hub - Community Bicep Module

> **⚠️ DISCLAIMER**: This is a **community-maintained** project and is **NOT officially supported by Microsoft** or the Microsoft FinOps Toolkit team. For the official FinOps Toolkit, see [microsoft/finops-toolkit](https://github.com/microsoft/finops-toolkit).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Why This Exists

The [Microsoft FinOps Toolkit](https://github.com/microsoft/finops-toolkit) provides an excellent monolithic deployment for FinOps Hubs. However, we noticed a gap in the market for enterprise customers who need:

- **Modular deployments** — deploy only what you need (storage-only, ADX, or Fabric)
- **Customizable security policies** — bring your own network, identity, and compliance requirements
- **WAF-aligned configurations** — production-grade defaults following the Azure Well-Architected Framework
- **Enterprise regulatory compliance** — private endpoints, managed VNets, RBAC, and diagnostic settings out of the box
- **Infrastructure-as-Code best practices** — built on [Azure Verified Modules (AVM)](https://aka.ms/avm) for reliability and consistency

This project takes the architecture patterns from the official FinOps Toolkit and wraps them in a modular, enterprise-ready Bicep deployment that lets you bring or customize your regulatory and security requirements.

## Official References

| Resource | Link |
|----------|------|
| **Microsoft FinOps Toolkit** | [github.com/microsoft/finops-toolkit](https://github.com/microsoft/finops-toolkit) |
| **FinOps Hubs Overview** | [learn.microsoft.com/.../finops-hubs-overview](https://learn.microsoft.com/cloud-computing/finops/toolkit/hubs/finops-hubs-overview) |
| **FinOps Toolkit Power BI Reports** | [aka.ms/finops/toolkit/powerbi](https://aka.ms/finops/toolkit/powerbi) |
| **FOCUS Specification** | [focus.finops.org](https://focus.finops.org/) |
| **FinOps Foundation Framework** | [finops.org/framework](https://www.finops.org/framework/) |
| **Azure Verified Modules** | [aka.ms/avm](https://aka.ms/avm) |

## Deployment Types

| Type | Description | Use Case |
|------|-------------|----------|
| `storage-only` | ADLS Gen2 + Key Vault + Data Factory | Power BI-only scenarios, getting started |
| `adx` | + Azure Data Explorer cluster | Real-time analytics, KQL queries, dashboards |
| `fabric` | + Microsoft Fabric Eventhouse | Fabric-native analytics |

## Configuration Profiles

| Profile | Description | Key Defaults |
|---------|-------------|-------------|
| `minimal` | Lowest cost, dev/test | Standard_LRS, public access, no HA |
| `waf-aligned` | Production, WAF-aligned | Premium_ZRS, private endpoints, managed VNet |

## Network Isolation Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `None` | Public endpoints | Dev/test, demos |
| `Managed` | Module creates VNet, PEs, DNS zones | Production without existing network |
| `BringYourOwn` | You provide subnet and DNS zones | Enterprise hub-spoke topology |

## Quick Start

### Storage-Only (Minimal)

```bicep
module finopsHub 'main.bicep' = {
  name: 'finops-hub'
  params: {
    hubName: 'myfinopshub'
    location: 'eastus'
    deploymentType: 'storage-only'
    deploymentConfiguration: 'minimal'
  }
}
```

### ADX with Private Endpoints (WAF-Aligned)

```bicep
module finopsHub 'main.bicep' = {
  name: 'finops-hub'
  params: {
    hubName: 'myfinopshub'
    location: 'eastus'
    deploymentType: 'adx'
    deploymentConfiguration: 'waf-aligned'
    dataExplorerClusterName: 'myadxcluster'
    networkIsolationMode: 'Managed'
  }
}
```

### BYO Network (Enterprise)

```bicep
module finopsHub 'main.bicep' = {
  name: 'finops-hub'
  params: {
    hubName: 'myfinopshub'
    location: 'eastus'
    deploymentType: 'adx'
    deploymentConfiguration: 'waf-aligned'
    dataExplorerClusterName: 'myadxcluster'
    networkIsolationMode: 'BringYourOwn'
    byoSubnetResourceId: '/subscriptions/.../subnets/pe-subnet'
    byoBlobDnsZoneResourceId: '/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net'
    byoDfsDnsZoneResourceId: '/subscriptions/.../privateDnsZones/privatelink.dfs.core.windows.net'
    byoVaultDnsZoneResourceId: '/subscriptions/.../privateDnsZones/privatelink.vaultcore.azure.net'
    byoDataFactoryDnsZoneResourceId: '/subscriptions/.../privateDnsZones/privatelink.datafactory.azure.net'
    byoKustoDnsZoneResourceId: '/subscriptions/.../privateDnsZones/privatelink.eastus.kusto.windows.net'
  }
}
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      FinOps Hub                              │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Storage  │  │Key Vault │  │  Data    │  │ Managed  │   │
│  │ (ADLS)   │  │          │  │ Factory  │  │ Identity │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────────┘   │
│       │              │              │                         │
│       └──────────────┼──────────────┘                        │
│                      │                                       │
│              ┌───────┴───────┐                               │
│              │  Analytics    │                               │
│              │  (ADX/Fabric) │                               │
│              └───────────────┘                               │
│                                                              │
│  Optional: Managed VNet + Private Endpoints + DNS Zones      │
└─────────────────────────────────────────────────────────────┘
```

## What's Included

```
finops-hub-bicep/
├── main.bicep                    # Primary deployment module
├── main.json                     # Compiled ARM template
├── modules/                      # Child Bicep modules
│   ├── network.bicep             # Managed VNet + PEs + DNS
│   ├── dataFactoryResources.bicep# ADF pipelines & triggers
│   ├── managedExportsPipelines.bicep # Cost export pipelines
│   ├── adxSchemaSetup.bicep      # ADX database schema
│   ├── triggerManagement.bicep   # Idempotent trigger stop/start
│   ├── types.bicep               # Shared type definitions
│   └── scripts/                  # KQL schema scripts
├── src/                          # Deployment helper scripts
│   ├── Deploy-FinOpsHub.ps1      # PowerShell deployment wrapper
│   ├── Get-BestAdxSku.ps1       # ADX SKU recommender
│   └── Switch-FinOpsHubState.ps1 # State management
├── tests/e2e/                    # End-to-end test scenarios
│   ├── storage-minimal/          # Storage-only deployment
│   ├── adx-minimal/              # ADX dev/test
│   ├── adx-waf-aligned/          # ADX production
│   ├── adx-managed-network/      # ADX with managed VNet
│   ├── fabric-minimal/           # Fabric dev/test
│   ├── fabric-waf-aligned/       # Fabric production
│   └── managed-network/          # Network isolation only
├── ADR.md                        # Architecture Decision Records
├── CHANGELOG.md                  # Version history
└── version.json                  # Module version
```

## Relationship to Official FinOps Toolkit

This module deploys **Azure infrastructure only**. For analytics, reporting, and visualization:

| Asset | Source |
|-------|--------|
| ADX Dashboards | [FinOps Toolkit](https://aka.ms/finops/toolkit) |
| Power BI Reports | [aka.ms/finops/toolkit/powerbi](https://aka.ms/finops/toolkit/powerbi) |
| Test Data Generators | [FinOps Toolkit](https://github.com/microsoft/finops-toolkit) |
| KQL Query Library | [FinOps Toolkit](https://github.com/microsoft/finops-toolkit) |

## Built With

This module uses [Azure Verified Modules (AVM)](https://aka.ms/avm) under the hood:

| Resource | AVM Module |
|----------|-----------|
| Storage Account | `avm/res/storage/storage-account` |
| Key Vault | `avm/res/key-vault/vault` |
| Data Factory | `avm/res/data-factory/factory` |
| Data Explorer | `avm/res/kusto/cluster` |
| Managed Identity | `avm/res/managed-identity/user-assigned-identity` |
| Virtual Network | `avm/res/network/virtual-network` |
| Private DNS Zone | `avm/res/network/private-dns-zone` |
| NSG | `avm/res/network/network-security-group` |
| Role Assignments | `avm/ptn/authorization/resource-role-assignment` |

## Contributing

Contributions are welcome! Please open an issue or PR.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

## Acknowledgments

- [Microsoft FinOps Toolkit](https://github.com/microsoft/finops-toolkit) — the foundational patterns this module is built upon
- [Azure Verified Modules](https://aka.ms/avm) — the infrastructure modules powering this deployment
- [FinOps Foundation](https://www.finops.org/) — the framework and FOCUS specification
