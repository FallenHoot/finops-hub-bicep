# FinOps Hub — RBAC Reference

> Complete role-based access control (RBAC) reference for all FinOps Hub deployment types.
> Roles are listed by deployment type so you can see exactly what permissions are needed.

## Quick Reference

| Deployment Type | Auto-Assigned (Azure RBAC) | Auto-Assigned (ADX Principals) | Manual (Fabric Portal) | Manual (Billing Scope) |
|----------------|---------------------------|-------------------------------|----------------------|----------------------|
| **storage-only** | 3–6 | 0 | 0 | 0–2 |
| **adx** | 6–11 | 2–4 | 0 | 0–2 |
| **fabric** | 3–6 | 0 | 1–2 | 0–2 |

---

## Core RBAC (All Deployment Types)

These roles are assigned **automatically by the module** during deployment.

### Always Assigned

| # | Principal | Target Resource | Role Name | Role GUID | Purpose |
|---|-----------|----------------|-----------|-----------|---------|
| 1 | User-Assigned MI | Storage Account | Storage Blob Data Reader | `2a2b9908-6ea1-4ae2-8e65-a410df84e7d1` | Read config container for settings |
| 2 | ADF System MI | Storage Account | Storage Blob Data Contributor | `ba92f5b4-2d11-453d-a403-e96b0029c9fe` | Read/write for ingestion pipelines |
| 3 | ADF System MI | Key Vault | Key Vault Secrets User | `4633458b-17de-408a-b874-0445c86b69e6` | Read secrets (when `enableRbacAuthorization = true`) |

### Conditional — Trigger Management

Assigned when `enableTriggerManagement = true` (recommended for idempotent redeployments):

| # | Principal | Target Resource | Role Name | Role GUID | Purpose |
|---|-----------|----------------|-----------|-----------|---------|
| 4 | User-Assigned MI | Storage Account | Storage File Data Privileged Contributor | `69566ab7-960f-475b-8e7c-b3118f30c6bd` | Deployment script storage access |
| 5 | User-Assigned MI | Data Factory | Data Factory Contributor | `673868aa-7521-48a0-acc6-0f60742d39f5` | Stop/start ADF triggers during redeployment |

### Conditional — Deployer Access

Assigned when `deployerPrincipalId` is provided:

| # | Principal | Target Resource | Role Name | Role GUID | Purpose |
|---|-----------|----------------|-----------|-----------|---------|
| 6 | Deployer (User) | Storage Account | Storage Blob Data Contributor | `ba92f5b4-2d11-453d-a403-e96b0029c9fe` | Upload test data, troubleshoot |

---

## Private Endpoint RBAC (Managed / BYO Network)

Assigned when `networkIsolationMode` is `Managed` or `BringYourOwn` **and** `enableManagedPeAutoApproval = true`.
These grant ADF control-plane permissions to auto-approve its managed private endpoint connections.

| # | Principal | Target Resource | Role Name | Role GUID | Purpose |
|---|-----------|----------------|-----------|-----------|---------|
| 7 | ADF System MI | Storage Account | Storage Account Contributor | `17d1049b-9a84-46fb-8f53-869881c3d3ab` | Auto-approve ADF managed PE to storage |
| 8 | ADF System MI | Key Vault | Key Vault Contributor | `f25e0fa2-a7c8-4377-a976-54943a77a395` | Auto-approve ADF managed PE to Key Vault |

> **Note**: If `enableManagedPeAutoApproval = false`, private endpoint connections must be approved manually via Azure Portal or CLI.

---

## ADX-Specific RBAC

### Azure RBAC (Auto-Assigned)

| # | Principal | Target Resource | Role Name | Role GUID | Condition |
|---|-----------|----------------|-----------|-----------|-----------|
| 9 | ADX System MI | Storage Account | Storage Blob Data Reader | `2a2b9908-6ea1-4ae2-8e65-a410df84e7d1` | When creating new ADX cluster |

### ADX Cluster Principal Assignments (Auto-Assigned)

These use the ADX principal assignment model, **not** Azure RBAC.

| # | Principal | Role | Principal Type | Identity Format | Condition |
|---|-----------|------|---------------|-----------------|-----------|
| 10 | ADF System MI | AllDatabasesAdmin | App | principalId (object ID) | Always (ADX mode) |
| 11 | User-Assigned MI | AllDatabasesAdmin | App | **clientId (application ID)** | Always (ADX mode) |
| 12 | Deployer (User) | AllDatabasesAdmin | User | principalId (object ID) | When `deployerPrincipalId` provided |
| 13 | Additional Admins | AllDatabasesAdmin | User | principalId (object ID) | When `adxAdminPrincipalIds` provided |

> ⚠️ **Critical: ADX Identity Format Gotcha**
>
> ADX `clusterPrincipalAssignments` with `principalType: 'App'` require the **client ID (application ID)**, not the principal ID (object ID) of managed identities.
>
> | Identity Property | ARM/RBAC Term | ADX Term | When to Use |
> |------------------|---------------|----------|-------------|
> | `principalId` | Object ID | Principal ID | Azure RBAC (`principalType: 'ServicePrincipal'`) |
> | `clientId` | Application ID | Application ID | ADX principals (`principalType: 'App'`) |
>
> Using the wrong ID results in **HTTP 401 Unauthorized** at runtime — the ARM deployment succeeds but REST API calls fail. See [ADR-012](../ADR.md#adr-012-adx-principal-assignment-identity-format) for the full debugging story.

---

## Fabric-Specific RBAC

Fabric uses **Fabric workspace permissions**, not Azure RBAC. These **cannot be auto-assigned** by the module — they must be configured manually in the Fabric portal before deployment.

| # | Principal | Target | Permission | How to Configure |
|---|-----------|--------|-----------|-----------------|
| 14 | ADF System MI | Fabric Eventhouse workspace | Admin or Contributor | Fabric Portal → Workspace → Manage access → Add the ADF system MI object ID |
| 15 | User-Assigned MI | Fabric Eventhouse workspace | Viewer (minimum) | Fabric Portal → Workspace → Manage access → Add the MI object ID |

### Steps to Configure Fabric Permissions

1. Get the ADF system-assigned managed identity principal ID from deployment outputs (`dataFactoryPrincipalId`)
2. Open [Microsoft Fabric](https://app.fabric.microsoft.com/)
3. Navigate to the workspace containing your Eventhouse
4. Click **Manage access** → **Add people or groups**
5. Search by the principal ID (object ID) of the ADF managed identity
6. Assign **Contributor** role (minimum for data ingestion)
7. Repeat for the User-Assigned MI if deployment scripts need Eventhouse access

> **Why can't this be automated?** Fabric workspace permissions are managed by the Fabric control plane, which has no ARM/Bicep resource provider. There is no `Microsoft.Fabric/workspaces/roleAssignments` resource type.

---

## External RBAC (User Must Configure)

These roles are **not assigned by the module** — they must be configured by the user for Cost Management exports to work (Enterprise mode).

### Cost Management Exports

| # | Principal | Target | Role Name | Scope | When Needed |
|---|-----------|--------|-----------|-------|-------------|
| 16 | ADF System MI | Billing Account | Cost Management Reader | `/providers/Microsoft.Billing/billingAccounts/{id}` | Enterprise mode (EA/MCA/MPA) |
| 17 | ADF System MI | Billing Account | Billing Account Reader | `/providers/Microsoft.Billing/billingAccounts/{id}` | When MACC tracking enabled (`billingAccountId` provided) |

### How to Assign Billing Scope Roles

```powershell
# Get the ADF managed identity principal ID from deployment outputs
$adfPrincipalId = (Get-AzDataFactoryV2 -ResourceGroupName 'rg-finops' -Name 'adf-myhub-abc123').Identity.PrincipalId

# Assign Cost Management Reader on billing account
New-AzRoleAssignment `
  -ObjectId $adfPrincipalId `
  -RoleDefinitionName 'Cost Management Reader' `
  -Scope '/providers/Microsoft.Billing/billingAccounts/12345678'

# (Optional) Assign Billing Account Reader for MACC tracking
New-AzRoleAssignment `
  -ObjectId $adfPrincipalId `
  -RoleDefinitionName 'Billing Account Reader' `
  -Scope '/providers/Microsoft.Billing/billingAccounts/12345678'
```

> **Note**: Billing scope role assignments require **Billing Account Administrator** permissions. Contact your billing admin if you don't have access.

---

## Role GUID Quick Reference

| Role Name | GUID | Scope |
|-----------|------|-------|
| Storage Blob Data Reader | `2a2b9908-6ea1-4ae2-8e65-a410df84e7d1` | Storage |
| Storage Blob Data Contributor | `ba92f5b4-2d11-453d-a403-e96b0029c9fe` | Storage |
| Storage File Data Privileged Contributor | `69566ab7-960f-475b-8e7c-b3118f30c6bd` | Storage |
| Storage Account Contributor | `17d1049b-9a84-46fb-8f53-869881c3d3ab` | Storage |
| Key Vault Secrets User | `4633458b-17de-408a-b874-0445c86b69e6` | Key Vault |
| Key Vault Contributor | `f25e0fa2-a7c8-4377-a976-54943a77a395` | Key Vault |
| Data Factory Contributor | `673868aa-7521-48a0-acc6-0f60742d39f5` | Data Factory |
| Cost Management Reader | `72fafb9e-0641-4937-9268-a91bfd8191a3` | Billing |
| Billing Account Reader | `fa23ad8b-c56e-40d8-ac0c-ce449e1d2c64` | Billing |

---

## Least Privilege Recommendations

For production deployments, follow least privilege:

1. **Use `enableRbacAuthorization = true`** for Key Vault — avoids broad access policies
2. **Scope billing roles narrowly** — assign Cost Management Reader only on the specific billing account/enrollment, not management group
3. **Use BYO identity** (`existingManagedIdentityResourceId`) — pre-create the MI with your security team's approval
4. **Disable `enableManagedPeAutoApproval`** in strict environments — manually approve PE connections instead of granting Storage Account Contributor
5. **Limit `adxAdminPrincipalIds`** — only add users who need cluster-level admin access
6. **Don't provide `deployerPrincipalId`** in production — it's for dev/test convenience only
