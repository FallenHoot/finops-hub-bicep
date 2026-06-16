# Invoicing & Allocation

- Page ID: f416685d-f559-4514-8e45-5e0e09aec286
- Tile count: 17

## Tile: About this capability

- Tile ID: 876b81e5-4f71-4c69-bd62-8d470f50bf31
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Cost last month

- Tile ID: acf2ca3d-9d8f-477f-b259-f3937bf938d4
- Visual: multistat
- Query ID: 152f2041-bbc1-41e4-b155-271b2e0cf6e9

### What this query does

- Reads from: CostsLastMonth.
- Consumes shared variables: CostsLastMonth.
- Aggregates data with summarize. Examples: BilledCost = round(sum(BilledCost), 2), EffectiveCost = round(sum(EffectiveCost), 2) by BillingPeriodStart = startofmonth(BillingPeriodStart)
- Shapes output columns with project operations. Examples: Type = strcat(json.type, ' (', monthname[monthofyear(BillingPeriodStart)], ' ', format_datetime(BillingPeriodStart, 'yyyy'), ')'), Cost = todouble(json.Cost)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let monthname = dynamic(['(ignore)', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']);
let costs = materialize(
    CostsLastMonth
    | summarize BilledCost = round(sum(BilledCost), 2), EffectiveCost = round(sum(EffectiveCost), 2) by BillingPeriodStart = startofmonth(BillingPeriodStart)
    | extend json = todynamic(strcat('[{"type":"Billed cost", "Cost":', BilledCost, '}, {"type":"Effective cost", "Cost":', EffectiveCost, '}]'))
    | mv-expand json
    | project Type = strcat(json.type, ' (', monthname[monthofyear(BillingPeriodStart)], ' ', format_datetime(BillingPeriodStart, 'yyyy'), ')'), Cost = todouble(json.Cost)
);
costs
```

## Tile: Cost over time

- Tile ID: 595e39e5-02ff-4ee7-99f9-68694ffd0495
- Visual: column
- Query ID: bc24e050-f2b9-4b4a-a08d-69fc4a4bb95e

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: BilledCost = round(sum(BilledCost), 2), EffectiveCost = round(sum(EffectiveCost), 2) by BillingPeriodStart = startofmonth(BillingPeriodStart)

### KQL

```kql
CostsByMonth
| summarize BilledCost = round(sum(BilledCost), 2), EffectiveCost = round(sum(EffectiveCost), 2) by BillingPeriodStart = startofmonth(BillingPeriodStart)
| render timechart
```

## Tile: Change over time

- Tile ID: efd2b03d-c80d-4d78-b77a-efa3f932efdb
- Visual: column
- Query ID: 0d91ea4a-c81d-4a21-b708-b6af37be1eec

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: BilledCost = sum(BilledCost), EffectiveCost = sum(EffectiveCost) by BillingPeriodStart = startofmonth(BillingPeriodStart)
- Shapes output columns with project operations. Examples: BillingPeriodStart
- Orders or ranks output for visualization. Examples: BillingPeriodStart asc

### KQL

```kql
CostsByMonth
// | summarize BilledCost = round(sum(BilledCost), 2), EffectiveCost = round(sum(EffectiveCost), 2) by BillingPeriodStart = startofmonth(BillingPeriodStart)
// | render timechart
| summarize BilledCost = sum(BilledCost), EffectiveCost = sum(EffectiveCost) by BillingPeriodStart = startofmonth(BillingPeriodStart)
| order by BillingPeriodStart asc
| extend PreviousBilledCost = prev(BilledCost)
| extend PreviousEffectiveCost = prev(EffectiveCost)
| project BillingPeriodStart
    , BilledCost = iif(isempty(PreviousBilledCost), todouble(0), todouble((BilledCost - PreviousBilledCost) * 100.0 / PreviousBilledCost))
    , EffectiveCost = iif(isempty(PreviousEffectiveCost), todouble(0), todouble((EffectiveCost - PreviousEffectiveCost) * 100.0 / PreviousEffectiveCost))

```

## Tile: Counts

- Tile ID: 9c5e208a-f0ce-4e2e-9969-35130eef22c1
- Visual: multistat
- Query ID: f2cecbb0-13f8-4642-afa4-bbcc0558f777

### What this query does

- Reads from: CostsLastMonth.
- Consumes shared variables: CostsLastMonth.
- Aggregates data with summarize. Examples: Subscriptions = dcount(SubAccountId),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[{ "Type":"Subscriptions", "Count":', Subscriptions, ' }, { "Type":"Resource groups", "Count":', ResourceGroups, ' }, { "Type":"Resources", "Count":', Resources, ' }, { "Type":"Services", "Count":', Services, ' }]')) | Label = tostring(json.Type), Count = tolong(json.Count)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = materialize(
    CostsLastMonth
    | summarize
        Subscriptions = dcount(SubAccountId),
        ResourceGroups = dcount(strcat(SubAccountId, x_ResourceGroupName)),
        Resources = dcount(ResourceId),
        Services = dcount(ServiceName)
    | project json = todynamic(strcat('[{ "Type":"Subscriptions", "Count":', Subscriptions, ' }, { "Type":"Resource groups", "Count":', ResourceGroups, ' }, { "Type":"Resources", "Count":', Resources, ' }, { "Type":"Services", "Count":', Services, ' }]'))
    | mv-expand json
    | project Label = tostring(json.Type), Count = tolong(json.Count)
);
data
```

## Tile: (untitled tile)

- Tile ID: c191a000-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Chargeback by tag value (last month)

- Tile ID: c191a001-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: bar
- Query ID: c1910001-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: tagKeyFilter, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: TotalCost = sum(EffectiveCost), Resources = dcount(ResourceId) by TagValue
- Shapes output columns with project operations. Examples: TagValue, TotalCost = round(TotalCost, 0), Resources
- Orders or ranks output for visualization. Examples: TotalCost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| extend TagValue = iff(isnotempty(tagKeyFilter) and isnotempty(Tags) and bag_has_key(Tags, tagKeyFilter), tostring(Tags[tagKeyFilter]), 'Untagged')
| summarize TotalCost = sum(EffectiveCost), Resources = dcount(ResourceId) by TagValue
| project TagValue, TotalCost = round(TotalCost, 0), Resources
| order by TotalCost desc
| take 15
```

## Tile: Showback by department (last 3 months)

- Tile ID: c191a002-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: table
- Query ID: c1910002-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: TotalCost = sum(EffectiveCost), Resources = dcount(ResourceId), Subscriptions = dcount(SubAccountName) by Department, Month = startofmonth(ChargePeriodStart)
- Shapes output columns with project operations. Examples: Month, Department, TotalCost = round(TotalCost, 0), Resources, Subscriptions
- Orders or ranks output for visualization. Examples: Month desc, TotalCost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| extend Department = case(
    isnotempty(Tags) and bag_has_key(Tags, 'Department'), tostring(Tags['Department']),
    isnotempty(Tags) and bag_has_key(Tags, 'department'), tostring(Tags['department']),
    isnotempty(Tags) and bag_has_key(Tags, 'CostCenter'), tostring(Tags['CostCenter']),
    isnotempty(Tags) and bag_has_key(Tags, 'costcenter'), tostring(Tags['costcenter']),
    isnotempty(Tags) and bag_has_key(Tags, 'BusinessUnit'), tostring(Tags['BusinessUnit']),
    'Unassigned')
| summarize TotalCost = sum(EffectiveCost), Resources = dcount(ResourceId), Subscriptions = dcount(SubAccountName) by Department, Month = startofmonth(ChargePeriodStart)
| project Month, Department, TotalCost = round(TotalCost, 0), Resources, Subscriptions
| order by Month desc, TotalCost desc
```

## Tile: (untitled tile)

- Tile ID: 0c040005-c191-4f5a-6b7c-8d9e0f1a2b3c
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Cost by provider and invoice issuer

- Tile ID: 0c040004-c191-4f5a-6b7c-8d9e0f1a2b3c
- Visual: table
- Query ID: 0c040003-c191-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= monthsago(numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: BilledCost = round(sum(BilledCost), 2),
- Shapes output columns with project operations. Examples: Month, Provider, InvoiceIssuer, BilledCost, EffectiveCost
- Orders or ranks output for visualization. Examples: Month desc, BilledCost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= monthsago(numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize
    BilledCost = round(sum(BilledCost), 2),
    EffectiveCost = round(sum(EffectiveCost), 2)
    by Provider = coalesce(ProviderName, 'Unknown'),
       InvoiceIssuer = coalesce(InvoiceIssuerName, ProviderName, 'Unknown'),
       Month = startofmonth(ChargePeriodStart)
| order by Month desc, BilledCost desc
| project Month, Provider, InvoiceIssuer, BilledCost, EffectiveCost
```

## Tile: (untitled tile)

- Tile ID: 33ab7ff0-5738-4b9a-8bf8-9719712a65b7
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: f2b3c4d5-0001-4a8b-9c0d-1e2f3a4b5c6d
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Tag Coverage

- Tile ID: f2b3c4d5-0002-4a8b-9c0d-1e2f3a4b5c6d
- Visual: multistat
- Query ID: f2b3c4d5-1001-4a8b-9c0d-1e2f3a4b5c6d

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage'
- Aggregates data with summarize. Examples: TaggedCost = round(sumif(EffectiveCost, HasTags), 0),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[', | Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
// Tag Coverage Summary
let data = materialize(
    CostsByMonth
    | where ChargeCategory == 'Usage'
    | extend TagBag = iff(isnotempty(Tags), todynamic(tostring(Tags)), dynamic({}))
    | extend HasTags = array_length(bag_keys(TagBag)) > 0
    | summarize
        TaggedCost = round(sumif(EffectiveCost, HasTags), 0),
        UntaggedCost = round(sumif(EffectiveCost, not(HasTags)), 0),
        TaggedResources = dcountif(ResourceId, HasTags and isnotempty(ResourceId)),
        UntaggedResources = dcountif(ResourceId, not(HasTags) and isnotempty(ResourceId)),
        TotalResources = dcountif(ResourceId, isnotempty(ResourceId))
    | extend TagCoveragePercent = round(100.0 * TaggedCost / (TaggedCost + UntaggedCost), 1)
    | project json = todynamic(strcat('[',
        '{"Label":"Tagged Cost","Value":"', TaggedCost, '"},',
        '{"Label":"Untagged Cost","Value":"', UntaggedCost, '"},',
        '{"Label":"Tag Coverage %","Value":"', TagCoveragePercent, '%"},',
        '{"Label":"Tagged Resources","Value":"', TaggedResources, '"},',
        '{"Label":"Untagged Resources","Value":"', UntaggedResources, '"}',
    ']'))
    | mv-expand json
    | project Label = tostring(json.Label), Value = tostring(json.Value)
);
data
```

## Tile: Cost by tag key (last n months)

- Tile ID: f2b3c4d5-0003-4a8b-9c0d-1e2f3a4b5c6d
- Visual: bar
- Query ID: f2b3c4d5-1002-4a8b-9c0d-1e2f3a4b5c6d

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' | array_length(bag_keys(TagBag)) > 0
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2) by TagKey
- Shapes output columns with project operations. Examples: TagKey, EffectiveCost
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
// Cost by Tag Key - Top tag keys by total effective cost
CostsByMonth
| where ChargeCategory == 'Usage'
| extend TagBag = iff(isnotempty(Tags), todynamic(tostring(Tags)), dynamic({}))
| where array_length(bag_keys(TagBag)) > 0
| mv-apply TagKey = bag_keys(TagBag) to typeof(string) on (
    project TagKey
)
| where isnotempty(TagKey)
| summarize EffectiveCost = round(sum(EffectiveCost), 2) by TagKey
| order by EffectiveCost desc
| take maxGroupCount
| project TagKey, EffectiveCost
```

## Tile: Cost by tag value (last n months)

- Tile ID: f2b3c4d5-0004-4a8b-9c0d-1e2f3a4b5c6d
- Visual: bar
- Query ID: f2b3c4d5-1003-4a8b-9c0d-1e2f3a4b5c6d

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' | array_length(bag_keys(TagBag)) > 0
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2) by TagLabel = strcat(TagKey, '=', TagValue)
- Shapes output columns with project operations. Examples: TagLabel, EffectiveCost
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
// Cost by Tag Value - Explode tags into key-value pairs and show top values
CostsByMonth
| where ChargeCategory == 'Usage'
| extend TagBag = iff(isnotempty(Tags), todynamic(tostring(Tags)), dynamic({}))
| where array_length(bag_keys(TagBag)) > 0
| mv-apply TagKey = bag_keys(TagBag) to typeof(string) on (
    extend TagValue = tostring(TagBag[TagKey])
)
| where isnotempty(TagKey) and isnotempty(TagValue)
| summarize EffectiveCost = round(sum(EffectiveCost), 2) by TagLabel = strcat(TagKey, '=', TagValue)
| order by EffectiveCost desc
| take maxGroupCount
| project TagLabel, EffectiveCost
```

## Tile: Tag detail (last n months)

- Tile ID: f2b3c4d5-0005-4a8b-9c0d-1e2f3a4b5c6d
- Visual: table
- Query ID: f2b3c4d5-1004-4a8b-9c0d-1e2f3a4b5c6d

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' | array_length(bag_keys(TagBag)) > 0
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: TagKey, TagValue, EffectiveCost, BilledCost, Resources
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
// Tag Detail Table - All tag key-value pairs with cost and resource count
CostsByMonth
| where ChargeCategory == 'Usage'
| extend TagBag = iff(isnotempty(Tags), todynamic(tostring(Tags)), dynamic({}))
| where array_length(bag_keys(TagBag)) > 0
| mv-apply TagKey = bag_keys(TagBag) to typeof(string) on (
    extend TagValue = tostring(TagBag[TagKey])
)
| where isnotempty(TagKey)
| summarize
    EffectiveCost = round(sum(EffectiveCost), 2),
    BilledCost = round(sum(BilledCost), 2),
    Resources = dcount(ResourceId)
    by TagKey, TagValue
| order by EffectiveCost desc
| take 50
| project TagKey, TagValue, EffectiveCost, BilledCost, Resources
```

## Tile: Monthly tag coverage trend

- Tile ID: f2b3c4d5-0006-4a8b-9c0d-1e2f3a4b5c6d
- Visual: stackedcolumn
- Query ID: f2b3c4d5-1005-4a8b-9c0d-1e2f3a4b5c6d

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage'
- Aggregates data with summarize. Examples: TaggedCost = round(sumif(EffectiveCost, HasTags), 2),
- Shapes output columns with project operations. Examples: BillingPeriodStart, TaggedCost, UntaggedCost
- Orders or ranks output for visualization. Examples: BillingPeriodStart asc

### KQL

```kql
// Monthly Tag Coverage Trend - Tagged vs Untagged cost over time
CostsByMonth
| where ChargeCategory == 'Usage'
| extend TagBag = iff(isnotempty(Tags), todynamic(tostring(Tags)), dynamic({}))
| extend HasTags = array_length(bag_keys(TagBag)) > 0
| summarize
    TaggedCost = round(sumif(EffectiveCost, HasTags), 2),
    UntaggedCost = round(sumif(EffectiveCost, not(HasTags)), 2)
    by BillingPeriodStart
| order by BillingPeriodStart asc
| project BillingPeriodStart, TaggedCost, UntaggedCost
```

