# Orphaned Resources (Preview)

- Page ID: fb47b0be-7563-4ca6-8b8c-cf01f9a8a3c8
- Tile count: 6

## Tile: (untitled tile)

- Tile ID: 65b713d6-424a-4a79-931a-be4f8793c485
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Waste summary (last 30 days)

- Tile ID: 4361755a-074c-4a52-bb6e-7821ded339a6
- Visual: multistat
- Query ID: e975f824-6c9e-44ce-a539-083dadae47fd

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: numberOfDays, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= lookback | ChargeCategory == 'Usage'
- Aggregates data with summarize. Examples: MonthlyCost = sum(EffectiveCost) by ResourceId, ResourceType, x_ResourceType, SubAccountName, x_ResourceGroupName = column_ifexists('x_ResourceGroupName', '');
- Combines datasets with join operations. Examples: kind=leftanti vmRGs on x_ResourceGroupName | kind=leftanti (vmSubAccounts | union lbSubAccounts) on SubAccountName
- Shapes output columns with project operations. Examples: Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
// Orphaned Resources - Summary KPIs (heuristic from Costs data)
let lookback = ago(numberOfDays * 1d);
let costs = Costs
    | where ChargePeriodStart >= lookback
    | where ChargeCategory == 'Usage'
    | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
    | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
    | summarize MonthlyCost = sum(EffectiveCost) by ResourceId, ResourceType, x_ResourceType, SubAccountName, x_ResourceGroupName = column_ifexists('x_ResourceGroupName', '');
// Unattached disks: disks with cost but no VM compute in same resource group
let vmRGs = costs | where x_ResourceType =~ 'Microsoft.Compute/virtualMachines' | distinct x_ResourceGroupName;
let orphanedDisks = costs
    | where x_ResourceType =~ 'Microsoft.Compute/disks'
    | join kind=leftanti vmRGs on x_ResourceGroupName
    | extend DetectionRule = 'Unattached Disk';
// Unused public IPs: public IPs with no associated VM/LB
let vmSubAccounts = costs | where x_ResourceType =~ 'Microsoft.Compute/virtualMachines' | distinct SubAccountName;
let lbSubAccounts = costs | where x_ResourceType =~ 'Microsoft.Network/loadBalancers' | distinct SubAccountName;
let ipResources = costs
    | where x_ResourceType =~ 'Microsoft.Network/publicIPAddresses'
    | join kind=leftanti (vmSubAccounts | union lbSubAccounts) on SubAccountName
    | extend DetectionRule = 'Unused Public IP';
// Idle load balancers: LBs with minimal cost and no backend traffic
let orphanedLBs = costs
    | where x_ResourceType =~ 'Microsoft.Network/loadBalancers'
    | where MonthlyCost < 50
    | extend DetectionRule = 'Idle Load Balancer';
// Union all orphans
let allOrphans = union orphanedDisks, ipResources, orphanedLBs;
let totalWaste = toscalar(allOrphans | summarize round(sum(MonthlyCost), 2));
let resourceCount = toscalar(allOrphans | summarize dcount(ResourceId));
let topType = toscalar(allOrphans | summarize count() by ResourceType | top 1 by count_ | project ResourceType);
print json = pack_array(
    pack('Label', 'Monthly Waste Estimate', 'Value', strcat('$', iff(isnull(totalWaste), '0', tostring(totalWaste)))),
    pack('Label', 'Orphaned Resources', 'Value', tostring(iff(isnull(resourceCount), 0, resourceCount))),
    pack('Label', 'Top Orphan Type', 'Value', iff(isempty(topType), 'None detected', tostring(topType)))
)
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

## Tile: Waste by detection rule

- Tile ID: f081b178-493c-43b8-a7fb-12299a8966ee
- Visual: pie
- Query ID: 119e09db-a213-4ff2-95a9-da3894623da6

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: numberOfDays, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= lookback | ChargeCategory == 'Usage'
- Aggregates data with summarize. Examples: MonthlyCost = sum(EffectiveCost) by ResourceId, ResourceType, x_ResourceType, SubAccountName, x_ResourceGroupName = column_ifexists('x_ResourceGroupName', ''); | WasteCost = round(sum(MonthlyCost), 2) by DetectionRule
- Orders or ranks output for visualization. Examples: WasteCost desc

### KQL

```kql
// Orphaned Resources - Waste by Type
let lookback = ago(numberOfDays * 1d);
let costs = Costs
    | where ChargePeriodStart >= lookback
    | where ChargeCategory == 'Usage'
    | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
    | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
    | summarize MonthlyCost = sum(EffectiveCost) by ResourceId, ResourceType, x_ResourceType, SubAccountName, x_ResourceGroupName = column_ifexists('x_ResourceGroupName', '');
let vmRGs = costs | where x_ResourceType =~ 'Microsoft.Compute/virtualMachines' | distinct x_ResourceGroupName;
let orphanedDisks = costs | where x_ResourceType =~ 'Microsoft.Compute/disks' | join kind=leftanti vmRGs on x_ResourceGroupName | extend DetectionRule = 'Unattached Disk';
let vmSubAccounts = costs | where x_ResourceType =~ 'Microsoft.Compute/virtualMachines' | distinct SubAccountName;
let lbSubAccounts = costs | where x_ResourceType =~ 'Microsoft.Network/loadBalancers' | distinct SubAccountName;
let ipResources = costs | where x_ResourceType =~ 'Microsoft.Network/publicIPAddresses' | join kind=leftanti (vmSubAccounts | union lbSubAccounts) on SubAccountName | extend DetectionRule = 'Unused Public IP';
let orphanedLBs = costs | where x_ResourceType =~ 'Microsoft.Network/loadBalancers' | where MonthlyCost < 50 | extend DetectionRule = 'Idle Load Balancer';
union orphanedDisks, ipResources, orphanedLBs
| summarize WasteCost = round(sum(MonthlyCost), 2) by DetectionRule
| order by WasteCost desc
```

## Tile: Projected annual waste

- Tile ID: bdcd2838-ddf4-4f86-9be7-4c01ffc9da31
- Visual: table
- Query ID: a4e65583-94aa-498c-96cc-1155248a167e

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: numberOfDays, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= lookback | ChargeCategory == 'Usage'
- Aggregates data with summarize. Examples: MonthlyCost = sum(EffectiveCost) by ResourceId, ResourceType, x_ResourceType, SubAccountName, x_ResourceGroupName = column_ifexists('x_ResourceGroupName', ''); | MonthlyWaste = round(sum(MonthlyCost), 2) by DetectionRule
- Shapes output columns with project operations. Examples: DetectionRule, MonthlyWaste, AnnualWaste
- Orders or ranks output for visualization. Examples: AnnualWaste desc

### KQL

```kql
// Orphaned Resources - Annual Waste Projection
let lookback = ago(numberOfDays * 1d);
let costs = Costs
    | where ChargePeriodStart >= lookback
    | where ChargeCategory == 'Usage'
    | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
    | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
    | summarize MonthlyCost = sum(EffectiveCost) by ResourceId, ResourceType, x_ResourceType, SubAccountName, x_ResourceGroupName = column_ifexists('x_ResourceGroupName', '');
let vmRGs = costs | where x_ResourceType =~ 'Microsoft.Compute/virtualMachines' | distinct x_ResourceGroupName;
let orphanedDisks = costs | where x_ResourceType =~ 'Microsoft.Compute/disks' | join kind=leftanti vmRGs on x_ResourceGroupName | extend DetectionRule = 'Unattached Disk';
let vmSubAccounts = costs | where x_ResourceType =~ 'Microsoft.Compute/virtualMachines' | distinct SubAccountName;
let lbSubAccounts = costs | where x_ResourceType =~ 'Microsoft.Network/loadBalancers' | distinct SubAccountName;
let ipResources = costs | where x_ResourceType =~ 'Microsoft.Network/publicIPAddresses' | join kind=leftanti (vmSubAccounts | union lbSubAccounts) on SubAccountName | extend DetectionRule = 'Unused Public IP';
let orphanedLBs = costs | where x_ResourceType =~ 'Microsoft.Network/loadBalancers' | where MonthlyCost < 50 | extend DetectionRule = 'Idle Load Balancer';
union orphanedDisks, ipResources, orphanedLBs
| summarize MonthlyWaste = round(sum(MonthlyCost), 2) by DetectionRule
| extend AnnualWaste = round(MonthlyWaste * 12, 2)
| project DetectionRule, MonthlyWaste, AnnualWaste
| order by AnnualWaste desc
```

## Tile: Orphaned resources detail

- Tile ID: e8348976-c91e-433a-9482-f68a6daae2dd
- Visual: table
- Query ID: 69fedb94-871f-4cac-a171-56156c9ad7d0

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: numberOfDays, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= lookback | ChargeCategory == 'Usage'
- Aggregates data with summarize. Examples: MonthlyCost = sum(EffectiveCost) by ResourceId, ResourceName = column_ifexists('ResourceName', ''), ResourceType, x_ResourceType, SubAccountName, x_ResourceGroupName = column_ifexists('x_ResourceGroupName', '');
- Shapes output columns with project operations. Examples: ResourceName, ResourceType, SubAccountName, ResourceGroup = x_ResourceGroupName, MonthlyCost = round(MonthlyCost, 2), AnnualImpact = round(MonthlyCost * 12, 2), DetectionRule, Confidence
- Orders or ranks output for visualization. Examples: MonthlyCost desc

### KQL

```kql
// Orphaned Resources - Detail Table
let lookback = ago(numberOfDays * 1d);
let costs = Costs
    | where ChargePeriodStart >= lookback
    | where ChargeCategory == 'Usage'
    | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
    | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
    | summarize MonthlyCost = sum(EffectiveCost) by ResourceId, ResourceName = column_ifexists('ResourceName', ''), ResourceType, x_ResourceType, SubAccountName, x_ResourceGroupName = column_ifexists('x_ResourceGroupName', '');
let vmRGs = costs | where x_ResourceType =~ 'Microsoft.Compute/virtualMachines' | distinct x_ResourceGroupName;
let orphanedDisks = costs | where x_ResourceType =~ 'Microsoft.Compute/disks' | join kind=leftanti vmRGs on x_ResourceGroupName | extend DetectionRule = 'Unattached Disk', Confidence = 'Medium';
let vmSubAccounts = costs | where x_ResourceType =~ 'Microsoft.Compute/virtualMachines' | distinct SubAccountName;
let lbSubAccounts = costs | where x_ResourceType =~ 'Microsoft.Network/loadBalancers' | distinct SubAccountName;
let ipResources = costs | where x_ResourceType =~ 'Microsoft.Network/publicIPAddresses' | join kind=leftanti (vmSubAccounts | union lbSubAccounts) on SubAccountName | extend DetectionRule = 'Unused Public IP', Confidence = 'Low';
let orphanedLBs = costs | where x_ResourceType =~ 'Microsoft.Network/loadBalancers' | where MonthlyCost < 50 | extend DetectionRule = 'Idle Load Balancer', Confidence = 'Low';
union orphanedDisks, ipResources, orphanedLBs
| project ResourceName, ResourceType, SubAccountName, ResourceGroup = x_ResourceGroupName, MonthlyCost = round(MonthlyCost, 2), AnnualImpact = round(MonthlyCost * 12, 2), DetectionRule, Confidence
| order by MonthlyCost desc
```

## Tile: Monthly waste trend

- Tile ID: 68b14c96-92fd-4914-af82-f7817ac7940a
- Visual: column
- Query ID: ace6d8d9-df64-4a64-9b1c-55fcc7481eef

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: numberOfDays, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= ago(numberOfDays * 1d) | ChargeCategory == 'Usage'
- Aggregates data with summarize. Examples: MonthlyCost = sum(EffectiveCost) by ResourceId, ResourceType, x_ResourceType, SubAccountName, x_ResourceGroupName = column_ifexists('x_ResourceGroupName', ''), Month = startofmonth(ChargePeriodStart); | WasteCost = round(sum(MonthlyCost), 2) by Month, DetectionRule
- Orders or ranks output for visualization. Examples: Month asc, DetectionRule asc

### KQL

```kql
// Orphaned Resources - Monthly Waste Trend
let costs = Costs
    | where ChargePeriodStart >= ago(numberOfDays * 1d)
    | where ChargeCategory == 'Usage'
    | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
    | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
    | summarize MonthlyCost = sum(EffectiveCost) by ResourceId, ResourceType, x_ResourceType, SubAccountName, x_ResourceGroupName = column_ifexists('x_ResourceGroupName', ''), Month = startofmonth(ChargePeriodStart);
let vmRGsByMonth = costs | where x_ResourceType =~ 'Microsoft.Compute/virtualMachines' | distinct x_ResourceGroupName, Month;
let orphanedDisks = costs | where x_ResourceType =~ 'Microsoft.Compute/disks' | join kind=leftanti vmRGsByMonth on x_ResourceGroupName, Month | extend DetectionRule = 'Unattached Disk';
let vmSubByMonth = costs | where x_ResourceType =~ 'Microsoft.Compute/virtualMachines' | distinct SubAccountName, Month;
let lbSubByMonth = costs | where x_ResourceType =~ 'Microsoft.Network/loadBalancers' | distinct SubAccountName, Month;
let ipResources = costs | where x_ResourceType =~ 'Microsoft.Network/publicIPAddresses' | join kind=leftanti (vmSubByMonth | union lbSubByMonth) on SubAccountName, Month | extend DetectionRule = 'Unused Public IP';
let orphanedLBs = costs | where x_ResourceType =~ 'Microsoft.Network/loadBalancers' | where MonthlyCost < 50 | extend DetectionRule = 'Idle Load Balancer';
union orphanedDisks, ipResources, orphanedLBs
| summarize WasteCost = round(sum(MonthlyCost), 2) by Month, DetectionRule
| order by Month asc, DetectionRule asc
```

