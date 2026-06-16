# Licensing & SaaS (Preview)

- Page ID: c0f4a5b3-7e8d-4c9f-d9b2-3f4a5b6c7d8e
- Tile count: 24

## Tile: About Licensing & SaaS

- Tile ID: d1a5b6c4-8f9e-4d0a-e0c3-4a5b6c7d8e9f
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: c1a6fad6-1482-41e3-b077-07db4cb5062c
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: 805cac8c-a189-45cb-8ba3-fbb1a06dfba0
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Hybrid Benefit summary (last n days)

- Tile ID: d2e4a321-9c2c-411b-8a20-19fd86dab3fe
- Visual: multistat
- Query ID: 1a400b6c-9204-434d-88ff-2dc5260a95bf

### What this query does

- Reads from: costs, x_SkuCoreCount.
- Consumes shared variables: CostsByDayAHB.
- Applies filters to narrow scope. Examples: isnotempty(x_SkuLicenseStatus)
- Aggregates data with summarize. Examples: arg_max(ChargePeriodStart, *) by ResourceId | x_ResourceCount = dcount(ResourceId),
- Shapes output columns with project operations. Examples: Order = 1, Label = 'Coverage %', Value = percentstring(covered, all, 1)
- Orders or ranks output for visualization. Examples: Order asc
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let costs = CostsByDayAHB
| where isnotempty(x_SkuLicenseStatus)
//
// Get the latest resource record first to guarrantee we have the latest status
| summarize arg_max(ChargePeriodStart, *) by ResourceId
| summarize
    x_ResourceCount = dcount(ResourceId),
    x_SkuLicenseUnusedQuantity = sum(x_SkuLicenseUnusedQuantity)
    by
    x_SkuLicenseStatus,
    x_SkuLicenseQuantity,
    x_SkuCoreCount
| union (
    print json = dynamic([
        { "x_SkuLicenseStatus": "Enabled" },
        { "x_SkuLicenseStatus": "Not Enabled" }
    ])
    | mv-expand json
    | evaluate bag_unpack(json)
);
//
// Coverage first
costs
| summarize covered = sumif(x_ResourceCount, x_SkuLicenseStatus == 'Enabled'), all = sum(x_ResourceCount)
| project Order = 1, Label = 'Coverage %', Value = percentstring(covered, all, 1)
//
// First column
| union (costs | where x_SkuLicenseStatus == 'Enabled'     | summarize Value = numberstring(sum(x_ResourceCount)) by Order = 3, Label = 'Covered resources')
| union (costs | where x_SkuLicenseStatus == 'Not Enabled' | summarize Value = numberstring(sum(x_ResourceCount)) by Order = 5, Label = 'Eligible resources')
//
// Second column
| union (costs | where x_SkuLicenseStatus == 'Enabled'     | summarize Value = numberstring(sum(x_SkuLicenseUnusedQuantity)) by Order = 2, Label = 'Underutilized vCPU capacity')
| union (costs | where x_SkuLicenseStatus == 'Enabled'     | summarize Value = numberstring(sum(x_SkuLicenseQuantity)) by Order = 4, Label = 'Covered vCPU capacity')
| union (costs | where x_SkuLicenseStatus == 'Not Enabled' | summarize Value = numberstring(sum(x_SkuLicenseQuantity)) by Order = 6, Label = 'Eligible vCPU capacity')
| order by Order asc

```

## Tile: Underutilized vCPU capacity (last n days)

- Tile ID: 80e1ecb4-69f6-451d-9e1c-f90d17b7f865
- Visual: table
- Query ID: c2ad5370-f4df-4a13-ac31-2c095f88754d

### What this query does

- Reads from: CostsByDayAHB, SubAccountName.
- Consumes shared variables: CostsByDayAHB.
- Applies filters to narrow scope. Examples: x_SkuLicenseStatus == 'Enabled'
- Aggregates data with summarize. Examples: arg_max(ChargePeriodStart, *),
- Shapes output columns with project operations. Examples: ["License type"] = x_SkuLicenseType,
- Orders or ranks output for visualization. Examples: ["Unused vCore hours"] desc

### KQL

```kql
// Underutilized capacity
// Fully utilized capacity
// Eligible resources
CostsByDayAHB
| where x_SkuLicenseStatus == 'Enabled'
//
// Get the latest resource record first to guarrantee we have the latest status
| summarize
    arg_max(ChargePeriodStart, *),
    TotalConsumedQuantity = sum(ConsumedQuantity),
    TotalEffectiveCost = sum(EffectiveCost)
    by
    ResourceId
| project 
    ["License type"] = x_SkuLicenseType,
    ResourceName,
    ResourceType,
    SKU = x_SkuInstanceType,
    ["SKU cores"] = x_SkuCoreCount,
    ["Required capacity"] = x_SkuLicenseQuantity,
    ["Unused capacity"] = x_SkuLicenseUnusedQuantity,
    ["Unused vCore hours"] = x_SkuLicenseUnusedQuantity * ConsumedQuantity,
    EffectiveCost = TotalEffectiveCost,
    x_ResourceGroupName,
    SubAccountName
| order by ["Unused vCore hours"] desc

```

## Tile: Fully utilized vCPU capacity (last n days)

- Tile ID: 59a1756c-7586-4364-8047-604aa7d6f09a
- Visual: table
- Query ID: 4614acfb-2288-4a71-97f7-32845a9ddcb2

### What this query does

- Reads from: CostsByDayAHB, SubAccountName.
- Consumes shared variables: CostsByDayAHB.
- Applies filters to narrow scope. Examples: x_SkuLicenseStatus == 'Enabled' | x_SkuLicenseUnusedQuantity == 0
- Aggregates data with summarize. Examples: arg_max(ChargePeriodStart, *),
- Shapes output columns with project operations. Examples: ["License type"] = x_SkuLicenseType,
- Orders or ranks output for visualization. Examples: ["vCore hours"] desc

### KQL

```kql
CostsByDayAHB
| where x_SkuLicenseStatus == 'Enabled'
| where x_SkuLicenseUnusedQuantity == 0
//
// Get the latest resource record first to guarrantee we have the latest status
| summarize
    arg_max(ChargePeriodStart, *),
    TotalConsumedQuantity = sum(ConsumedQuantity),
    TotalEffectiveCost = sum(EffectiveCost)
    by
    ResourceId
| project 
    ["License type"] = x_SkuLicenseType,
    ResourceName,
    ResourceType,
    SKU = x_SkuInstanceType,
    ["SKU cores"] = x_SkuCoreCount,
    ["vCore hours"] = x_SkuLicenseQuantity * ConsumedQuantity,
    EffectiveCost = TotalEffectiveCost,
    x_ResourceGroupName,
    SubAccountName
| order by ["vCore hours"] desc

```

## Tile: Eligible resources (last n days)

- Tile ID: 9197f822-bdf3-42af-8b43-5609c9b91f00
- Visual: table
- Query ID: 99d44f1f-c53a-40ee-b749-8e5557ec58c7

### What this query does

- Reads from: CostsByDayAHB, SubAccountName.
- Consumes shared variables: CostsByDayAHB.
- Applies filters to narrow scope. Examples: x_SkuLicenseStatus == 'Not Enabled'
- Aggregates data with summarize. Examples: arg_max(ChargePeriodStart, *),
- Shapes output columns with project operations. Examples: ["License type"] = x_SkuLicenseType,
- Orders or ranks output for visualization. Examples: ["Eligible vCore hours"] desc

### KQL

```kql
CostsByDayAHB
| where x_SkuLicenseStatus == 'Not Enabled'
//
// Get the latest resource record first to guarrantee we have the latest status
| summarize
    arg_max(ChargePeriodStart, *),
    TotalConsumedQuantity = sum(ConsumedQuantity),
    TotalEffectiveCost = sum(EffectiveCost)
    by
    ResourceId
| project 
    ["License type"] = x_SkuLicenseType,
    ResourceName,
    ResourceType,
    SKU = x_SkuInstanceType,
    ["SKU cores"] = x_SkuCoreCount,
    ["Required capacity"] = x_SkuLicenseQuantity,
    ["Eligible vCore hours"] = x_SkuLicenseQuantity * ConsumedQuantity,
    EffectiveCost = TotalEffectiveCost,
    x_ResourceGroupName,
    SubAccountName
| order by ["Eligible vCore hours"] desc

```

## Tile: (untitled tile)

- Tile ID: 1d5dc241-50b5-42eb-afd4-c1cdb60335fa
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: f615d6ea-41f3-44de-aff3-95f661b68b35
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: SaaS Spend Summary

- Tile ID: 3c4196e1-4ee6-4269-9232-819f9c874952
- Visual: multistat
- Query ID: ed34de1f-3e00-467f-bc70-304e2c25262a

### What this query does

- Reads from: marketplace.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: x_PublisherCategory == 'Marketplace' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: TotalSpend = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[', | Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let marketplace = Costs
| where x_PublisherCategory == 'Marketplace'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
marketplace
| summarize 
    TotalSpend = round(sum(EffectiveCost), 2),
    Publishers = dcount(PublisherName),
    Products = dcount(ServiceName)
| project json = todynamic(strcat('[',
    '{"Label":"Total Spend","Value":"', TotalSpend, '"},',
    '{"Label":"Publishers","Value":"', Publishers, '"},',
    '{"Label":"Products","Value":"', Products, '"}',
']'))
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

## Tile: SaaS Spend by Month

- Tile ID: 4fac3388-31f5-496b-b13a-d3a6661753a2
- Visual: column
- Query ID: 891f3114-1466-42d7-8c3d-6f329ba9b816

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: x_PublisherCategory == 'Marketplace' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart)
- Orders or ranks output for visualization. Examples: Month asc

### KQL

```kql
Costs
| where x_PublisherCategory == 'Marketplace'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart)
| order by Month asc
```

## Tile: Top Publishers

- Tile ID: 903b7a84-e206-4ec4-8924-21ff8ce63c82
- Visual: bar
- Query ID: 61be1ce6-fd98-4961-bc00-ee23c5ade3eb

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: x_PublisherCategory == 'Marketplace' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by PublisherName
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
Costs
| where x_PublisherCategory == 'Marketplace'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2) by PublisherName
| order by Cost desc
| take 10
```

## Tile: Top Products

- Tile ID: c2b7f97e-ff16-4ace-8582-216afa688a26
- Visual: table
- Query ID: e2be6de9-ae28-46ca-a974-be2d014d4542

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: x_PublisherCategory == 'Marketplace' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by ServiceName, PublisherName
- Shapes output columns with project operations. Examples: Product = ServiceName, Publisher = PublisherName, Cost
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
Costs
| where x_PublisherCategory == 'Marketplace'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2) by ServiceName, PublisherName
| order by Cost desc
| take 15
| project Product = ServiceName, Publisher = PublisherName, Cost
```

## Tile: SaaS Spend by Subscription

- Tile ID: bb0ba12b-c5f4-4458-b987-e436c2c953fe
- Visual: table
- Query ID: 3159144e-e894-4fd3-9320-eeeaa5fabd0c

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: x_PublisherCategory == 'Marketplace' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2),
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
Costs
| where x_PublisherCategory == 'Marketplace'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter)
| summarize 
    Cost = round(sum(EffectiveCost), 2),
    Products = dcount(ServiceName),
    Publishers = dcount(PublisherName)
by SubAccountName
| order by Cost desc
```

## Tile: Databricks Spend Summary (Preview)

- Tile ID: d4f0f3a2-4b17-4f1f-a2a1-7396d6aa1111
- Visual: multistat
- Query ID: cf020001-3529-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: databricks.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -numberOfMonths) | x_PublisherCategory == 'Marketplace'
- Aggregates data with summarize. Examples: TotalSpend = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[', | Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let databricks = Costs
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| where x_PublisherCategory == 'Marketplace'
| where tolower(strcat(PublisherName, ' ', ServiceName, ' ', ChargeDescription)) has 'databricks'
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
databricks
| summarize
    TotalSpend = round(sum(EffectiveCost), 2),
    Subscriptions = dcount(SubAccountId),
    Products = dcount(ServiceName)
| extend TotalSpend = iff(isnull(TotalSpend), 0.0, TotalSpend), Subscriptions = iff(isnull(Subscriptions), 0, Subscriptions), Products = iff(isnull(Products), 0, Products)
| project json = todynamic(strcat('[',
    '{"Label":"Total Spend","Value":"', TotalSpend, '"},',
    '{"Label":"Subscriptions","Value":"', Subscriptions, '"},',
    '{"Label":"Products","Value":"', Products, '"}',
']'))
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

## Tile: Fabric Spend Summary (Preview)

- Tile ID: d4f0f3a2-4b17-4f1f-a2a1-7396d6aa2222
- Visual: multistat
- Query ID: cf020002-3529-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: fabric.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -numberOfMonths) | (x_PublisherCategory == 'Marketplace' or (ProviderName == 'Microsoft' and ServiceName has_cs 'Fabric'))
- Aggregates data with summarize. Examples: TotalSpend = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[', | Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let fabric = Costs
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| where (x_PublisherCategory == 'Marketplace' or (ProviderName == 'Microsoft' and ServiceName has_cs 'Fabric'))
| where tolower(strcat(PublisherName, ' ', ServiceName, ' ', ChargeDescription)) has 'fabric'
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
fabric
| summarize
    TotalSpend = round(sum(EffectiveCost), 2),
    Subscriptions = dcount(SubAccountId),
    Products = dcount(ServiceName)
| extend TotalSpend = iff(isnull(TotalSpend), 0.0, TotalSpend), Subscriptions = iff(isnull(Subscriptions), 0, Subscriptions), Products = iff(isnull(Products), 0, Products)
| project json = todynamic(strcat('[',
    '{"Label":"Total Spend","Value":"', TotalSpend, '"},',
    '{"Label":"Subscriptions","Value":"', Subscriptions, '"},',
    '{"Label":"Products","Value":"', Products, '"}',
']'))
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

## Tile: (untitled tile)

- Tile ID: 0caa172c-a54f-4c09-8c0f-0030eb9ebc20
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: ea6c815d-af8b-4a74-8ede-9574911f8d49
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Spot Summary

- Tile ID: 78ddd908-bed3-480e-b736-263e5719ded1
- Visual: multistat
- Query ID: 886ef328-6a85-4f47-8a52-4261281a0c4f

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: PricingCategory == 'Dynamic' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: SpotCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[', | Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
Costs
| where PricingCategory == 'Dynamic'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize 
    SpotCost = round(sum(EffectiveCost), 2),
    SpotResources = dcount(ResourceId),
    SpotSavings = round(sum(ListCost - EffectiveCost), 2),
    OnDemandEquivalent = round(sum(ListCost), 2),
    _ListTotal = sum(ListCost)
| extend SavingsRate = iff(_ListTotal > 0, strcat(round(100.0 * SpotSavings / OnDemandEquivalent, 1), '%'), 'N/A')
| project json = todynamic(strcat('[',
    '{"Label":"Spot Spend","Value":"', SpotCost, '"},',
    '{"Label":"On-Demand Equiv.","Value":"', OnDemandEquivalent, '"},',
    '{"Label":"Savings","Value":"', SpotSavings, '"},',
    '{"Label":"Savings Rate","Value":"', SavingsRate, '"},',
    '{"Label":"Resources","Value":"', SpotResources, '"}'
']'))
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

## Tile: Pricing Category Breakdown

- Tile ID: a95553d6-7eaf-46af-832a-ec4543afe659
- Visual: pie
- Query ID: 647bfaef-4a54-42c0-aaeb-186b8dea47ee

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by PricingCategory
- Shapes output columns with project operations. Examples: Category, Cost
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2) by PricingCategory
| extend Category = case(
    PricingCategory == 'Standard', 'On-Demand',
    PricingCategory == 'Dynamic', 'Spot/Preemptible',
    PricingCategory == 'Committed', 'Commitment Discounts',
    coalesce(PricingCategory, 'Other')
)
| project Category, Cost
| order by Cost desc
```

## Tile: Spot vs On-Demand Trend

- Tile ID: 629459f2-df5f-43df-9b5e-d01a62dc1b33
- Visual: stackedarea
- Query ID: e60a2844-d918-481a-81bc-ebf9bef4fd2c

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: PricingCategory in ('Standard', 'Dynamic') | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart), PricingCategory
- Shapes output columns with project operations. Examples: Month, Cost, Category

### KQL

```kql
Costs
| where PricingCategory in ('Standard', 'Dynamic')
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart), PricingCategory
| extend Category = case(PricingCategory == 'Dynamic', 'Spot', 'On-Demand')
| project Month, Cost, Category
```

## Tile: Top Spot Resources

- Tile ID: 3d5aa022-877b-4dfc-a6c0-1de2c582be92
- Visual: table
- Query ID: cf56343c-7597-43b7-bebe-4e86ea7d3da7

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: PricingCategory == 'Dynamic' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: ResourceName, ResourceType, RegionName, Cost, Savings, SavingsPercent
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
Costs
| where PricingCategory == 'Dynamic'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize 
    Cost = round(sum(EffectiveCost), 2),
    Savings = round(sum(ListCost - EffectiveCost), 2),
    ResourceType = take_any(ResourceType),
    RegionName = take_any(RegionName)
by ResourceName, ResourceId
| extend SavingsPercent = iff((Cost + Savings) > 0, round(100.0 * Savings / (Cost + Savings), 1), 0.0)
| order by Cost desc
| take 15
| project ResourceName, ResourceType, RegionName, Cost, Savings, SavingsPercent
```

## Tile: (untitled tile)

- Tile ID: 1f0d7f8d-65aa-4f7f-95bd-4f1bf5e2d8b1
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Sentinel spend comparison (current vs previous months)

- Tile ID: 9cbb9f47-6c8c-4ad6-8f6b-5ed31bf42a6f
- Visual: table
- Query ID: f2a1e4c8-3b47-4e65-9f7d-4a1c0dbf7f11

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -2) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart);

### KQL

```kql
let sentinel = Costs
| where ChargePeriodStart >= startofmonth(now(), -2)
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter)
| extend SentinelSignal = tolower(strcat(
    tostring(column_ifexists('ServiceName', '')), ' ',
    tostring(column_ifexists('ServiceCategory', '')), ' ',
    tostring(column_ifexists('ChargeDescription', '')), ' ',
    tostring(column_ifexists('ResourceType', '')), ' ',
    tostring(column_ifexists('x_ResourceType', '')), ' ',
    tostring(column_ifexists('PublisherName', ''))
))
| where SentinelSignal has 'sentinel' or SentinelSignal has 'microsoft.securityinsights'
| summarize Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart);
let currentMonth = toscalar(sentinel | where Month == startofmonth(now()) | summarize sum(Cost));
let lastMonth = toscalar(sentinel | where Month == startofmonth(now(), -1) | summarize sum(Cost));
let monthBeforeLast = toscalar(sentinel | where Month == startofmonth(now(), -2) | summarize sum(Cost));
let current = iff(isnull(currentMonth), 0.0, currentMonth);
let last = iff(isnull(lastMonth), 0.0, lastMonth);
let prev2 = iff(isnull(monthBeforeLast), 0.0, monthBeforeLast);
let delta = round(current - last, 2);
let deltaPercent = iff(last > 0, round((current - last) / last * 100.0, 1), real(null));
print
    ['Month -2'] = round(prev2, 2),
    ['Last month'] = round(last, 2),
    ['Current month (MTD)'] = round(current, 2),
    ['Delta vs last month'] = delta,
    ['Delta vs last month %'] = iff(isnull(deltaPercent), 'n/a', strcat(iff(deltaPercent >= 0, '+', ''), tostring(deltaPercent), '%'))
```

