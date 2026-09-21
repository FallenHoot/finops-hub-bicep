# ODCR and CRG Workbook

This Azure Monitor workbook focuses on on-demand capacity reservations (ODCR) and capacity reservation groups (CRGs). It can run as a standalone Azure Resource Graph workbook, and it can be enhanced with FinOps hub billing data when the hub is available.

The workbook follows the pattern used by Azure Advisor and FinOps workbooks: start with a decision cockpit, then let users drill into actual cost, resource state, and operating guidance.

## Files

| File | Purpose |
|---|---|
| `workbook.json` | Importable Azure Monitor workbook JSON. |

## Data Sources

- **Azure Resource Graph** for current CRG and capacity reservation inventory.
- **Azure Resource Manager Instance View** for current allocation of the selected CRG.
- **Azure Cost Management Query API** for direct actual cost associated with capacity reservation resources in one selected subscription.
- **Azure Data Explorer** for optional billing usage and unused ODCR cost from the FinOps hub `Hub` database when **Use FinOps hub billing data** is set to **Yes**.

FinOps hub is an enrichment layer, not a workbook dependency. Without it, the workbook still shows the reservation estate, ownership, sharing authorization, compute references, authoritative current allocation, and direct Cost Management actual cost for capacity reservation resources in one selected subscription. With FinOps hub enabled, the workbook adds FOCUS `EffectiveCost`, explicit `Used`/`Unused` status when populated, cross-subscription analysis, and persistence classification.

## Operating Model

For supported GPU pools where ODCR reservation support is viable, shared CRGs are the preferred operating model: centralize ODCR capacity in one or more provider subscriptions, share those CRGs with workload subscriptions, and let workloads consume or release reserved units as they autoscale.

Billing follows the split model: workload subscriptions pay for VMs they run, while the provider subscription carries the cost of unused ODCR capacity. This makes showback or chargeback for idle reserved units a required operating process.

Simple example: if the provider subscription reserves 100 GPU VM instances and eligible workloads consume 60, the remaining 40 reserved units are available to another eligible workload associated with the shared CRG.

The gating question is not CRG sharing itself. The gating question is whether the specific SKU, region, and zone can support ODCR reservation behavior. For constrained GPU inventory, ODCR may not be viable if the platform cannot satisfy reservation behavior for the target hardware pool. For node-interconnect or per-cluster workloads, treat this as a separate placement or interconnect-group problem and validate with Product Group.

## Prerequisites

- Reader access to the selected subscriptions and CRGs, including permission to call the CRG Instance View endpoint.
- Cost Management Reader, or equivalent Cost Management query permission, on subscriptions used for direct cost mode.
- Optional: access to query the FinOps hub Azure Data Explorer database when using billing-backed ODCR cost views.
- Workbook Contributor if you want to save the imported workbook in Azure Monitor.

## Import

1. Open **Azure Monitor > Workbooks** in the Azure portal.
2. Select **New**.
3. Open **Advanced editor**.
4. Paste the contents of `workbook.json`.
5. Select **Apply** and then **Done editing**.
6. Leave **Use FinOps hub billing data** as **No** and select **Cost Management subscription** for direct actual-cost reporting.
7. To enable billing-backed ODCR cost views, set **Use FinOps hub billing data** to **Yes**, set **ADX cluster name** to the hub cluster name with region suffix, for example `mycluster.eastus2`, and keep **ADX database name** as `Hub` unless the deployment renamed the database.
8. Set **Use sample CRG data** to **Yes** to preview workbook behavior when you do not have live CRGs or ODCRs.

## Operating Modes

| Mode | Required data | Available views |
|---|---|---|
| Operations mode | Azure Resource Graph, ARM Instance View, and Cost Management Query API | Multi-subscription inventory and relationships, selected-CRG allocation, and direct actual cost for one selected subscription. |
| FinOps hub enhanced mode | Operations mode plus FinOps hub ADX | FOCUS EffectiveCost, used-versus-unused status when populated, multi-subscription analysis, CRG ranking, and persistence. |
| Sample data mode | Built-in workbook sample rows | Preview layout, calculations, and review flow without live CRGs, ODCRs, or FinOps hub data. |

## Sample Data Mode

Use **Use sample CRG data = Yes** when you need to test or demonstrate the workbook without live capacity reservation groups. The sample data models a provider subscription with two shared CRGs:

| Sample CRG | Reserved units | Allocated units | Available SLA-backed units | What it demonstrates |
|---|---:|---:|---:|---|
| `crg-gpu-eastus2-prod` | 100 | 60 | 40 | Capacity available; review reservation quantity under the sample policy. |
| `crg-t4-eastus2-batch` | 40 | 42 | 0 | Valid overallocation; two VMs are outside SLA-backed reserved capacity. |

Sample mode is fictional. Do not use sample cost, SKU, subscription, or utilization values for reporting.

## Validation Status

The workbook package is statically validated for JSON structure, embedded Azure Data Explorer payloads, and built-in JSON sample payloads. Sample mode can be used to confirm layout and calculations without live CRGs.

Live validation still requires an Azure tenant with capacity reservation groups and attached VMs. In particular, validate the ARM endpoint response and export the JSONPath result settings after configuring the Capacity table in the workbook editor.

Known safeguards applied after review:

- Resource-state association joins use CRG resource ID plus VM size, not CRG name alone.
- Associated compute views list standalone VMs, VM scale sets, and scale set VM instances where Azure Resource Graph exposes CRG association data.
- ARG compute rows are references only. They are not counted as current allocation, and VMSS parent `sku.capacity` is never used as ODCR consumption.
- Static price estimates are not used in live ARG mode; there is no default dollar fallback.
- Billing-backed ODCR views only classify explicit `Used` and `Unused` `CapacityReservationStatus` values.
- The Cost tab starts with an **ODCR billing data readiness** query. Empty reservation ID or status fields mean the financial views are not ready; they do not prove that unused cost is zero.

## Workbook Tabs

| Tab | What it shows |
|---|---|
| Overview | Estate counts from ARG and financial impact from direct Cost Management or optional FinOps hub enrichment. |
| Capacity | Reservation inventory plus authoritative ARM Instance View for the selected CRG. |
| Consumers | Compute resources that reference CRGs plus provider and authorized-consumer relationships. |
| Cost | Direct Cost Management actual cost without FinOps, or enhanced FOCUS cost/status analysis with FinOps hub. |
| Guidance | Operating sequence, source boundaries, and data caveats. |

## Charts

- **Reserved VM units by SKU** shows where reserved capacity is concentrated.
- **CRGs by owner tag** highlights ownership concentration and `Unassigned` tagging gaps.
- **Compute references by consumer subscription** shows relationship volume, not utilization.
- **Actual unused ODCR cost by day** and **ODCR cost trend** are available when FinOps hub is enabled.
- **Unused ODCR actual cost by reservation resource** and **by day** come directly from Cost Management when FinOps hub is disabled.
- **ODCR cost by SKU and region** shows used cost, unused cost, unused cost percentage, reservation count, and billing currency without approximating vCPU capacity.
- **Sample CRG utilization** demonstrates the intended allocation visual in sample mode. Live utilization remains a selected-CRG raw Instance View response until the ARM result is configured and exported with a verified JSONPath transform.

## Operational Questions

| Question | Workbook answer | Source | Coverage |
|---|---|---|---|
| What have we reserved? | Reservation, SKU, reserved VM units, reservation type, and provisioning state. | Azure Resource Graph | Complete within visible scope |
| Where is it? | Provider subscription, resource group, region, and zone. | Azure Resource Graph | Complete within visible scope |
| How much is being consumed right now? | `virtualMachinesAllocated` for the selected CRG. | ARM Instance View | Selected CRG; raw live response |
| How much SLA-backed capacity is left? | `max(0, ReservedUnits - AllocatedUnits)` for the selected CRG. | ARG inventory plus ARM Instance View | Selected CRG; manual until JSONPath transform |
| Who can use it? | Provider subscription and authorized consumer subscription IDs from the sharing profile. | Azure Resource Graph | Best effort; property and RBAC dependent |
| Who is actually referencing it? | VM and VMSS resources that reference the full CRG resource ID. | Azure Resource Graph | Scope-limited relationship view |
| Are we over-reserved or close to running out? | Compare selected-CRG allocated and reserved units; sample mode demonstrates underuse and overallocation. | ARM Instance View | Selected CRG; no live fleet rollup yet |
| Which CRGs require action? | Governance queue covers missing ownership, sharing limits, provisioning issues, and empty CRGs. FinOps persistence identifies CRGs with recurring or persistent waste. | ARG and optional FinOps hub | Complete for those finding classes; utilization findings remain selected-CRG |
| How much has unused capacity cost us without FinOps? | Direct `ActualCost`/`PreTaxCost` associated with capacity reservation resources, by resource and day. | Azure Cost Management Query API | One selected subscription; requires cost access |
| If FinOps exists, what additional cost evidence is available? | FOCUS `EffectiveCost`, used/unused status, CRG ranking, reservation detail, and persistence by billing currency. | FinOps hub ADX | Depends on ODCR field readiness and available exports |
| Is the problem temporary or persistent? | `Isolated`, `Recurring`, or `Persistent` classification based on unused-cost days in the selected window. | FinOps hub ADX | Workbook policy, not an Azure platform status |

All ARG answers are limited by selected subscription scope, RBAC, and Resource Graph consistency. Full CRG resource ID is the identity key; display name alone is not unique.

The Cost page also reports whether `CapacityReservationId` and `CapacityReservationStatus` are populated together in the selected period. These fields are consumed from the local FinOps hub model, but provider exports can leave them empty. When readiness is **partially populated** or **not populated**, treat downstream ODCR cost visuals as incomplete or unavailable rather than zero.

## Source of Truth Model

| Signal | Source | Use for |
|---|---|---|
| Direct unused-capacity actual cost | Azure Cost Management Query API | Cost charged to capacity reservation resource objects in one subscription. |
| FOCUS used/unused cost and persistence | FinOps hub ADX billing data | EffectiveCost, explicit status when populated, cross-subscription reporting, and persistence. |
| Current allocation and available SLA-backed capacity | ARM Capacity Reservation Group Instance View | Operational utilization, headroom, and overallocation review. |
| Inventory, sharing, and compute references | Azure Resource Graph | Estate discovery, ownership, authorization, and scope-limited diagnostics. |

## Multi-Subscription CRG Handling

CRG names are not globally unique. The workbook uses the full capacity reservation group resource ID as the identity key for joins and rollups, then shows the CRG name as a display field. This prevents subscriptions or resource groups with the same CRG name from being merged into one result.

Shared CRG monitoring should also track provider and consumer subscriptions separately. Microsoft Learn defines the provider subscription as the subscription that creates and hosts the CRG and capacity reservations. Consumer subscriptions are granted access to deploy VMs or VM scale sets into the shared pool. Shared CRGs can be shared with up to 100 consumer subscriptions, and VMs must match the reservation SKU, region, and zone where applicable.

The workbook includes two views for this:

| View | What it answers |
|---|---|
| CRG provider subscription and sharing profile | Where does the CRG live, who owns it based on normalized tags, how many subscriptions are listed in the sharing profile, and is the CRG near the 100 consumer subscription limit? |
| Compute associated with CRG | Which compute resources reference each CRG in the selected and visible scope? |

The sharing profile view is best-effort because it depends on Azure Resource Graph exposing `properties.sharingProfile.subscriptionIds` for the CRG resource. The consuming subscription view is inferred from VM resource state via `properties.capacityReservation.capacityReservationGroup.id`.

## Overallocation and Instance View

Azure permits more allocated VMs than reserved capacity. Extra VMs can run if Azure has available capacity, but they do not receive the capacity reservation SLA benefit. Treat `AllocatedUnits > ReservedUnits` as overallocation, not a query failure.

Azure documents Capacity Reservation Group Instance View as the runtime allocation source. Use `properties.instanceView.capacityReservations[].utilizationInfo.virtualMachinesAllocated` to validate actual reservation allocation. ARG remains useful for inventory, ownership, sharing profile, and visible association signals.

Suggested low- and high-utilization thresholds are organizational policy, not Azure platform limits. Configure them in the imported workbook before using them for operational decisions.

## Notes

This repository is community-maintained and is not officially supported by Microsoft or the FinOps toolkit team. FinOps workbooks are Azure Monitor workbooks and follow the same import and deployment model documented by the FinOps toolkit.

Authoring reference: [Create or edit an Azure Workbook](https://learn.microsoft.com/azure/azure-monitor/visualize/workbooks-create-workbook).

JSONPath reference: [Use JSONPath to transform JSON data in workbooks](https://learn.microsoft.com/azure/azure-monitor/visualize/workbooks-jsonpath).

Capacity Reservation Instance View endpoint: `GET {CRG resource ID}?$expand=instanceView&api-version=2021-04-01`.

Shared CRG reference: [Share a Capacity Reservation Group](https://learn.microsoft.com/azure/virtual-machines/capacity-reservation-group-share).