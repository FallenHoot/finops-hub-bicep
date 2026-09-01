# FinOps Hub - Helper Scripts

This folder contains PowerShell scripts that help with deploying, validating, and managing the FinOps Hub AVM base kit. These scripts are **not required** for deployment but provide safer operational workflows around the Bicep template.

## Scripts Overview

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `Deploy-FinOpsHub.ps1` | Interactive deployment helper | When you want guided deployment with validation |
| `Get-BestAdxSku.ps1` | ADX SKU availability checker | Before deployment to find available SKUs |
| `Test-AvmVersionDrift.ps1` | AVM version drift checker against MCR | Before dependency upgrades and release hardening |
| `Convert-AiProviderToFocus.ps1` | AI provider payload normalizer to FOCUS-like records | When onboarding OpenAI, Anthropic, Copilot, or Foundry into ADF/ADX |
| `Switch-FinOpsHubState.ps1` | Pause/resume hub operations | When you want to optimize costs by pausing idle resources |
| `Sync-FocusDataset.ps1` | FOCUS version drift detection | Before any schema change; discovers the latest ratified FOCUS version |
| `Test-KqlMathSafety.ps1` | Unguarded division audit across dashboard and KQL | After any query, savings, or percentage change |
| `Test-AgentCustomizations.ps1` | Validates skills, agents, and AGENTS.md | After editing anything under `.github/skills` or `.github/agents` |

> **Test Data Generation**: Multi-cloud test data generation scripts are maintained in the official [Microsoft FinOps Toolkit](https://aka.ms/finops/toolkit) repository.

## Script Details

### Deploy-FinOpsHub.ps1

Interactive deployment script with:
- **Prerequisites validation** (Azure CLI, Az modules, permissions)
- **Subscription selection** (interactive picker)
- **Parameter validation** (names, regions, billing account types)
- **Base Cost Management export setup guidance** (automated where supported, otherwise guided manual)
- **Post-deployment verification**

```powershell
# Example: Deploy a minimal storage-only hub
.\Deploy-FinOpsHub.ps1 -HubName "myfinopshub" `
    -ResourceGroupName "rg-finops" `
    -Location "eastus" `
    -SubscriptionId "your-sub-id" `
    -TenantId "your-tenant-id"

# Example: Deploy with Azure Data Explorer
.\Deploy-FinOpsHub.ps1 -HubName "myfinopshub" `
    -ResourceGroupName "rg-finops" `
    -Location "eastus" `
    -SubscriptionId "your-sub-id" `
    -TenantId "your-tenant-id" `
    -DeploymentType "adx" `
    -DataExplorerClusterName "myfinopsadx"

# Example: Deploy with managed export automation disabled
.\Deploy-FinOpsHub.ps1 -HubName "myfinopshub" `
    -ResourceGroupName "rg-finops" `
    -Location "eastus" `
    -SubscriptionId "your-sub-id" `
    -TenantId "your-tenant-id" `
    -BillingAccountType "mca" `
    -DisableManagedExports
```

### Get-BestAdxSku.ps1

Checks ADX SKU availability by region to help select the right SKU:

```powershell
# Example: Find best Dev SKU for Italy North
$result = .\Get-BestAdxSku.ps1 -Location "italynorth" -DeploymentConfiguration "minimal"
Write-Host "Best SKU: $($result.Sku)"
# Output: Dev(No SLA)_Standard_E2a_v4

# Example: Find best production SKU for East US 2
$result = .\Get-BestAdxSku.ps1 -Location "eastus2" -DeploymentConfiguration "waf-aligned"
Write-Host "Best SKU: $($result.Sku)"
# Output: Standard_E2d_v5
```

### Test-AvmVersionDrift.ps1

Checks pinned AVM module versions in Bicep files against the latest stable tags in MCR:

```powershell
# Example: Show drift report
.\Test-AvmVersionDrift.ps1

# Example: Fail CI when updates are available
.\Test-AvmVersionDrift.ps1 -FailOnDrift
```

### Convert-AiProviderToFocus.ps1

Converts provider-specific AI usage/cost JSON payloads into a normalized FOCUS-like contract for ingestion pipelines:

```powershell
# Example: Normalize OpenAI payload to JSONL for ADF landing
.\Convert-AiProviderToFocus.ps1 -Provider openai `
    -InputPath .\samples\openai-usage.json `
    -OutputPath .\out\openai-focus.jsonl

# Example: Normalize Copilot payload to CSV
.\Convert-AiProviderToFocus.ps1 -Provider copilot `
    -InputPath .\samples\copilot-usage.json `
    -OutputPath .\out\copilot-focus.csv `
    -AsCsv

# Example: Pull OpenAI usage/cost directly from APIs
.\Convert-AiProviderToFocus.ps1 -Provider openai `
    -ApiKey $env:OPENAI_API_KEY `
    -StartDate (Get-Date).AddDays(-7) `
    -EndDate (Get-Date) `
    -OutputPath .\out\openai-focus.jsonl

# Example: Pull Anthropic usage/cost directly from Admin APIs
.\Convert-AiProviderToFocus.ps1 -Provider anthropic `
    -ApiKey $env:ANTHROPIC_ADMIN_KEY `
    -StartDate (Get-Date).AddDays(-7) `
    -EndDate (Get-Date) `
    -OutputPath .\out\anthropic-focus.jsonl

# Example: Pull GitHub Copilot enterprise usage metrics reports
.\Convert-AiProviderToFocus.ps1 -Provider copilot `
    -ApiKey $env:GITHUB_TOKEN `
    -CopilotScope enterprise `
    -Enterprise "your-enterprise-slug" `
    -StartDate (Get-Date).AddDays(-7) `
    -EndDate (Get-Date).AddDays(-1) `
    -OutputPath .\out\copilot-focus.jsonl
```

Expected secrets:

- `OPENAI_API_KEY`
- `ANTHROPIC_ADMIN_KEY`
- `GITHUB_TOKEN`

## Billing Account Types

Cost Management exports are **only supported** for certain billing account types:

| Billing Type | Export Support | Recommendation |
|--------------|---------------|----------------|
| Enterprise Agreement (EA) | ✅ Full | Use managed exports |
| Microsoft Customer Agreement (MCA) | Full (manual) | Configure exports manually |
| Microsoft Partner Agreement (MPA) | ✅ Full | Partner manages exports |
| Pay-As-You-Go (PAYGO) | ❌ None | Use test data scripts |
| Free Trial | ❌ None | Use test data scripts |
| Visual Studio / MSDN | ❌ None | Use test data scripts |
| CSP (customer-side) | ❌ Limited | Partner provides data |

For unsupported billing types, use the test data generation scripts from the [Microsoft FinOps Toolkit](https://aka.ms/finops/toolkit) to populate the hub with test data.

## Data Flow Paths

The scripts support two data ingestion paths:

```
Path 1: Ingestion Container (Parquet) - Faster
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Test Script     │────▶│ ingestion/      │────▶│ ingestion_*     │
│ (Parquet)       │     │ container       │     │ pipeline        │
└─────────────────┘     └─────────────────┘     └─────────────────┘

Path 2: MSExports Container (CSV) - Full Pipeline Test
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ Test Script     │────▶│ msexports/      │────▶│ msexports_*     │
│ (CSV)           │     │ container       │     │ pipeline        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Requirements

- **PowerShell 7.0+** (Core/Cross-platform)
- **Azure CLI** (authenticated)
- **Az PowerShell modules** (Az.Accounts, Az.Storage)
- Optional: Python with `pandas`, `pyarrow` (for Parquet generation)

## See Also

- [main.bicep](../main.bicep) - Bicep module for deployment
- [tests/](../tests/) - E2E test scenarios
- [FinOps Toolkit PowerShell](https://aka.ms/finops/powershell) - Official PowerShell module
