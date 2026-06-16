# Summary

- Page ID: f8ee3008-df7e-442f-825e-2e3b46e4c185
- Tile count: 17

## Tile: On this page

- Tile ID: e3ac3bbc-a9ef-44dd-828f-226afbcfda33
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Summary

- Tile ID: 66dcd731-a141-47b2-b36a-53a138cb75f2
- Visual: multistat
- Query ID: e8b343dc-7430-4487-8d44-ef48ac454f2d

### What this query does

- Reads from: allCosts.
- Consumes shared variables: CostsByMonth, CostsThisMonth.
- Applies filters to narrow scope. Examples: BillingPeriodStart >= startofmonth(now(), -1) | x_AmortizationClass != 'Principal'
- Aggregates data with summarize. Examples: BilledCost = sum(BilledCost),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[{ "Type":"Billed cost", "Count":', BilledCost, ' }, { "Type":"Effective cost", "Count":', EffectiveCost, ' }, { "Type":"Commitment savings", "Count":', CommitmentDiscountSavings, ' }, { "Type":"Negotiated savings", "Count":', NegotiatedDiscountSavings, ' }]')), Month, IsThisMonth = BillingPeriodStart >= startofmonth(now()) | Label = strcat(json.Type, ' (', Month, ')'), Count = tolong(json.Count), IsThisMonth
- Orders or ranks output for visualization. Examples: BillingPeriodStart asc
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let allCosts = CostsByMonth | union CostsThisMonth;
let data = materialize(
    allCosts
    | where BillingPeriodStart >= startofmonth(now(), -1)
    | where x_AmortizationClass != 'Principal'
    | summarize 
        BilledCost = sum(BilledCost),
        EffectiveCost = sum(EffectiveCost),
        ContractedCost = sum(ContractedCost),
        ListCost = sum(ListCost)
        by
        BillingPeriodStart
    | order by BillingPeriodStart asc
    | extend CommitmentDiscountSavings = iff(ContractedCost == 0, real(0), ContractedCost - EffectiveCost)
    | extend NegotiatedDiscountSavings = iff(ListCost == 0, real(0), ListCost - ContractedCost)
    | extend Month = monthname[monthofyear(BillingPeriodStart)]
    | project json = todynamic(strcat('[{ "Type":"Billed cost", "Count":', BilledCost, ' }, { "Type":"Effective cost", "Count":', EffectiveCost, ' }, { "Type":"Commitment savings", "Count":', CommitmentDiscountSavings, ' }, { "Type":"Negotiated savings", "Count":', NegotiatedDiscountSavings, ' }]')), Month, IsThisMonth = BillingPeriodStart >= startofmonth(now())
    | mv-expand json
    | project Label = strcat(json.Type, ' (', Month, ')'), Count = tolong(json.Count), IsThisMonth
);
data
```

## Tile: Effective cost

- Tile ID: 49534f2e-97ea-4b41-87c2-5e0f4bc26db8
- Visual: column
- Query ID: 290e7eab-8159-4338-8531-85e2718cedb1

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: EffectiveCost = sum(EffectiveCost) by BillingPeriodStart
- Shapes output columns with project operations. Examples: BillingPeriodStart, EffectiveCost, Change = iif(isempty(PreviousEffectiveCost), todouble(0), todouble((EffectiveCost - PreviousEffectiveCost) / PreviousEffectiveCost)) * 100
- Orders or ranks output for visualization. Examples: BillingPeriodStart asc

### KQL

```kql
CostsByMonth
| summarize EffectiveCost = sum(EffectiveCost) by BillingPeriodStart
| order by BillingPeriodStart asc
| extend PreviousEffectiveCost = prev(EffectiveCost)
| project BillingPeriodStart, EffectiveCost, Change = iif(isempty(PreviousEffectiveCost), todouble(0), todouble((EffectiveCost - PreviousEffectiveCost) / PreviousEffectiveCost)) * 100

```

## Tile: Cost + savings running total (this month and last)

- Tile ID: dad96fbb-750c-47a3-bd2e-e2bee74ebd22
- Visual: stackedarea
- Query ID: dcc1f533-e5f9-4855-9e4c-21e21fcdf943

### What this query does

- Reads from: CostsPlus.
- Consumes shared variables: CostsPlus.
- Applies filters to narrow scope. Examples: startofmonth(ChargePeriodStart) >= startofmonth(now(), -1) | x_AmortizationClass != 'Principal'
- Aggregates data with summarize. Examples: EffectiveCost = sum(EffectiveCost),
- Shapes output columns with project operations. Examples: ChargePeriodStart, CommitmentDiscountSavingsRunningTotal, NegotiatedDiscountSavingsRunningTotal, EffectiveCostRunningTotal, Month
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
CostsPlus
| where startofmonth(ChargePeriodStart) >= startofmonth(now(), -1)
| where x_AmortizationClass != 'Principal'
| summarize 
    EffectiveCost = sum(EffectiveCost),
    ContractedCost = sum(ContractedCost),
    ListCost = sum(ListCost)
    by
    ChargePeriodStart,
    Month = strcat(format_datetime(ChargePeriodStart, 'MM '), monthname[monthofyear(ChargePeriodStart)])
| extend CommitmentDiscountSavings = iff(ContractedCost == 0, real(0), ContractedCost - EffectiveCost)
| extend NegotiatedDiscountSavings = iff(ListCost == 0, real(0), ListCost - ContractedCost)
| order by ChargePeriodStart asc
| extend EffectiveCostRunningTotal = row_cumsum(EffectiveCost, prev(Month) != Month)
| extend CommitmentDiscountSavingsRunningTotal = row_cumsum(CommitmentDiscountSavings, prev(Month) != Month)
| extend NegotiatedDiscountSavingsRunningTotal = row_cumsum(NegotiatedDiscountSavings, prev(Month) != Month)
| project ChargePeriodStart, CommitmentDiscountSavingsRunningTotal, NegotiatedDiscountSavingsRunningTotal, EffectiveCostRunningTotal, Month
| render areachart  
```

## Tile: Counts (last n days)

- Tile ID: 2a1ee947-f1e3-447e-9388-91e318068608
- Visual: multistat
- Query ID: 5d63e04d-1a11-4307-96f1-ebbf68e09be0

### What this query does

- Reads from: CostsByDay.
- Consumes shared variables: CostsByDay.
- Aggregates data with summarize. Examples: Subscriptions = dcount(SubAccountId),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[{ "Type":"Subscriptions", "Count":', Subscriptions, ' }, { "Type":"Resource groups", "Count":', ResourceGroups, ' }, { "Type":"Resources", "Count":', Resources, ' }, { "Type":"Services", "Count":', Services, ' }]')) | Label = tostring(json.Type), Count = tolong(json.Count)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = materialize(
    CostsByDay
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

## Tile: Cost summary

- Tile ID: ea97e18e-5253-4a9d-9eed-0f2fc45b3c5b
- Visual: bar
- Query ID: 5ff29428-de83-4a2c-8f86-d8beebe68750

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByDay, CostsByMonth.
- Aggregates data with summarize. Examples: ListCost = round(sum(ListCost), 2),
- Shapes output columns with project operations. Examples: Period, json = todynamic(strcat('[{ "Label":"List", "Value":', ListCost, ' }, { "Label":"Contracted", "Value":', ContractedCost, ' }, { "Label":"Effective", "Value":', EffectiveCost, ' }]')) | Label = tostring(json.Label), Value = tolong(json.Value), Period
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = materialize(
    CostsByMonth | extend Period = 'Last n months'
    | union (CostsByDay | extend Period = 'Last n days')
    | summarize 
        ListCost = round(sum(ListCost), 2),
        ContractedCost = round(sum(ContractedCost), 2),
        EffectiveCost = round(sum(EffectiveCost), 2)
        by
        Period
    | project Period, json = todynamic(strcat('[{ "Label":"List", "Value":', ListCost, ' }, { "Label":"Contracted", "Value":', ContractedCost, ' }, { "Label":"Effective", "Value":', EffectiveCost, ' }]'))
    | mv-expand json
    | project Label = tostring(json.Label), Value = tolong(json.Value), Period
);
data
```

## Tile: Savings summary

- Tile ID: d9959281-dc89-44fc-a2b3-b4f5227e0179
- Visual: bar
- Query ID: f5f240a8-a818-4f27-bdfb-e96fcfe433bd

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByDay, CostsByMonth.
- Aggregates data with summarize. Examples: ListCost = round(sum(ListCost), 2),
- Shapes output columns with project operations. Examples: Period, json = todynamic(strcat('[{ "Label":"Total delta", "Value":', ListCost - EffectiveCost, ' }, { "Label":"Negotiated delta", "Value":', ListCost - ContractedCost, ' }, { "Label":"Commitment delta", "Value":', ContractedCost - EffectiveCost, ' }]')) | Label = tostring(json.Label), Value = tolong(json.Value), Period
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = materialize(
    CostsByMonth | extend Period = 'Last n months'
    | union (CostsByDay | extend Period = 'Last n days')
    | summarize
        ListCost = round(sum(ListCost), 2),
        ContractedCost = round(sum(ContractedCost), 2),
        EffectiveCost = round(sum(EffectiveCost), 2)
        by
        Period
    | project Period, json = todynamic(strcat('[{ "Label":"Total delta", "Value":', ListCost - EffectiveCost, ' }, { "Label":"Negotiated delta", "Value":', ListCost - ContractedCost, ' }, { "Label":"Commitment delta", "Value":', ContractedCost - EffectiveCost, ' }]'))
    | mv-expand json
    | project Label = tostring(json.Label), Value = tolong(json.Value), Period
);
data

```

## Tile: Summary

- Tile ID: 04cb63d9-0a92-488f-b863-815466d6725c
- Visual: table
- Query ID: c077a6d4-719f-42fe-b39b-36f77dc68976

### What this query does

- Reads from: CostsByMonth, data.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: x_AmortizationClass != 'Principal'
- Aggregates data with summarize. Examples: BilledCost     = todouble(round(sum(BilledCost), 2)),
- Orders or ranks output for visualization. Examples: BillingPeriodStart asc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let data = (
    CostsByMonth
    | where x_AmortizationClass != 'Principal'
    | summarize 
        BilledCost     = todouble(round(sum(BilledCost), 2)),
        EffectiveCost  = todouble(round(sum(EffectiveCost), 2)),
        ContractedCost = todouble(round(sum(ContractedCost), 2)),
        ListCost       = todouble(round(sum(ListCost), 2))
        by
        BillingPeriodStart
    | order by BillingPeriodStart asc
    | extend CommitmentDiscountSavings = todouble(round(iff(ContractedCost == 0, real(0), ContractedCost - EffectiveCost), 2))
    | extend NegotiatedDiscountSavings = todouble(round(iff(ListCost == 0, real(0), ListCost - ContractedCost), 2))
    | extend TotalSavings = todouble(round(iff(ListCost == 0, real(0), ListCost - EffectiveCost), 2))
    | extend BillingPeriod = strcat(format_datetime(BillingPeriodStart, 'yyyy-MM - '), monthname[monthofyear(BillingPeriodStart)])
);
data | extend Data = 'Billed cost'            | evaluate pivot(BillingPeriod, first(BilledCost), Data)
| union (data | extend Data = 'Effective cost'          | evaluate pivot(BillingPeriod, first(EffectiveCost), Data))
| union (data | extend Data = 'Contracted cost'         | evaluate pivot(BillingPeriod, first(ContractedCost), Data))
| union (data | extend Data = 'List cost'               | evaluate pivot(BillingPeriod, first(ListCost), Data))
| union (data | extend Data = 'Negotiated savings'      | evaluate pivot(BillingPeriod, first(NegotiatedDiscountSavings), Data))
| union (data | extend Data = 'Commitment savings'      | evaluate pivot(BillingPeriod, first(CommitmentDiscountSavings), Data))
| union (data | extend Data = 'Total savings'           | evaluate pivot(BillingPeriod, first(TotalSavings), Data))

```

## Tile: (untitled tile)

- Tile ID: c381a000-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Cost by CPU architecture (last month)

- Tile ID: c381a001-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: pie
- Query ID: c3810001-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: TotalCost = round(sum(EffectiveCost), 0), VMs = dcount(ResourceId) by Architecture
- Orders or ranks output for visualization. Examples: TotalCost desc

### KQL

```kql
// CPU architecture cost breakdown (community request #1594)
// Heuristic based on Azure VM SKU naming conventions
// Excludes N-series GPU VMs (shown in separate GPU tile)
Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| where ServiceCategory == 'Compute' or ServiceName has 'Virtual Machines' or ResourceType =~ 'Virtual machine'
| extend SkuRaw = tostring(coalesce(column_ifexists('SkuMeter', ''), column_ifexists('SkuPriceId', ''), column_ifexists('x_SkuName', ''), column_ifexists('SkuId', ''), column_ifexists('ChargeDescription', ''), column_ifexists('ServiceName', '')))
| where isnotempty(SkuRaw)
| extend NormalizedSku = tolower(SkuRaw)
| where not(NormalizedSku matches regex @'(^|[^a-z0-9])n[cdv][0-9]')
| extend Architecture = case(
    NormalizedSku matches regex @'(^|[^a-z0-9])[a-z]{1,3}[0-9]+p(s|d|v)?(_|[^a-z0-9]|$)', 'Arm64 (Cobalt/Ampere)',
    NormalizedSku matches regex @'(^|[^a-z0-9])[a-z]{1,3}[0-9]+a(s|d|v)?(_|[^a-z0-9]|$)', 'AMD',
    NormalizedSku matches regex @'(^|[^a-z0-9])[a-z]{1,3}[0-9]+(s|d|v)?(_|[^a-z0-9]|$)', 'Intel',
    'Unknown')
| summarize TotalCost = round(sum(EffectiveCost), 0), VMs = dcount(ResourceId) by Architecture
| order by TotalCost desc
```

## Tile: Cost by GPU family (last month)

- Tile ID: aed52a69-b686-4da8-9073-e53827eb4d8a
- Visual: pie
- Query ID: 5c84ca05-0265-4b47-ab19-4fa1cd79b542

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: TotalCost = round(sum(EffectiveCost), 0), VMs = dcount(ResourceId) by GpuFamily
- Orders or ranks output for visualization. Examples: TotalCost desc

### KQL

```kql
// GPU compute cost breakdown by N-series VM family
// NC = Training/inference, ND = Distributed training, NV = Visualization
Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| where ServiceCategory == 'Compute' or ServiceName has 'Virtual Machines' or ResourceType =~ 'Virtual machine'
| where isnotempty(SkuMeter)
| extend NormalizedSku = tolower(SkuMeter)
| where NormalizedSku matches regex @'n[cdv][0-9]'
| extend GpuFamily = case(
    NormalizedSku has 'h100', 'H100',
    NormalizedSku has 'a100', 'A100',
    NormalizedSku has 'a10', 'A10',
    NormalizedSku has 't4', 'T4',
    NormalizedSku matches regex @'^nc', 'NC (Other)',
    NormalizedSku matches regex @'^nd', 'ND (Other)',
    NormalizedSku matches regex @'^nv', 'NV (Other)',
    'Other GPU')
| summarize TotalCost = round(sum(EffectiveCost), 0), VMs = dcount(ResourceId) by GpuFamily
| order by TotalCost desc
```

## Tile: (untitled tile)

- Tile ID: 0c030000-6800-4f5a-6b7c-8d9e0f1a2b3c
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Cost by provider

- Tile ID: 0c030003-6800-4f5a-6b7c-8d9e0f1a2b3c
- Visual: pie
- Query ID: 0c030001-6800-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= monthsago(numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by Provider = coalesce(ProviderName, 'Unknown')
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= monthsago(numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2) by Provider = coalesce(ProviderName, 'Unknown')
| order by Cost desc
```

## Tile: Monthly trend by provider

- Tile ID: 0c030004-6800-4f5a-6b7c-8d9e0f1a2b3c
- Visual: stackedcolumn
- Query ID: 0c030002-6800-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= monthsago(numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart), Provider = coalesce(ProviderName, 'Unknown')
- Orders or ranks output for visualization. Examples: Month asc

### KQL

```kql
Costs
| where ChargePeriodStart >= monthsago(numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart), Provider = coalesce(ProviderName, 'Unknown')
| order by Month asc
```

## Tile: (untitled tile)

- Tile ID: 54ce2296-c894-475f-a604-53996ba81610
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Cost by cloud region

- Tile ID: f655d7b0-3274-4bf6-93c2-0d88ac21202e
- Visual: map
- Query ID: 8baecfdf-eedc-4ae1-9a4c-8d6a599ed539

### What this query does

- Reads from: costs, ResourceCount.
- Consumes shared variables: CostsByMonth, currencyFilter.
- Applies filters to narrow scope. Examples: isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter) | isnotempty(RegionName) and RegionName !in ('', 'Unknown', 'Global', 'global')
- Aggregates data with summarize. Examples: TotalCost     = round(sum(EffectiveCost), 2),
- Combines datasets with join operations. Examples: kind=inner AzureRegionGeo on RegionName
- Shapes output columns with project operations. Examples: RegionName,
- Orders or ranks output for visualization. Examples: ResourceCount desc, TotalCost desc

### KQL

```kql
// Cost by cloud region with geo coordinates for interactive map visualization
// Azure region name -> lat/lon lookup (covers all generally-available Azure regions)
let AzureRegionGeo = datatable(RegionName:string, Latitude:real, Longitude:real) [
    // Americas
    'East US',             37.3719,   -79.8164,
    'East US 2',           36.6681,   -78.3889,
    'West US',             37.7833,  -122.4167,
    'West US 2',           47.2330,  -119.8520,
    'West US 3',           33.4484,  -112.0740,
    'Central US',          41.5908,   -93.6208,
    'North Central US',    41.8819,   -87.6278,
    'South Central US',    29.4167,   -98.5000,
    'West Central US',     40.8900,  -110.2340,
    'Canada Central',      43.6532,   -79.3832,
    'Canada East',         46.8170,   -71.2170,
    'Brazil South',       -23.5505,   -46.6333,
    'Brazil Southeast',   -22.9068,   -43.1729,
    'Mexico Central',      20.5888,  -100.3899,
    // Europe
    'North Europe',        53.3478,    -6.2597,
    'West Europe',         52.3667,     4.9000,
    'UK South',            50.9413,    -0.7990,
    'UK West',             53.4269,    -3.0840,
    'France Central',      46.3772,     2.3730,
    'France South',        43.8345,     2.1972,
    'Germany West Central',50.1109,     8.6821,
    'Germany North',       53.0736,     8.8064,
    'Norway East',         59.9139,    10.7522,
    'Norway West',         58.9700,     5.7330,
    'Switzerland North',   47.4515,     8.5646,
    'Switzerland West',    46.2044,     6.1432,
    'Sweden Central',      60.6749,    17.1413,
    'Poland Central',      52.2318,    21.0062,
    'Italy North',         45.4688,     9.1813,
    'Spain Central',       40.4163,    -3.6998,
    // Asia Pacific
    'East Asia',           22.2670,   114.1880,
    'Southeast Asia',       1.2830,   103.8330,
    'Japan East',          35.6812,   139.7671,
    'Japan West',          34.6939,   135.5022,
    'Australia East',     -33.8688,   151.2093,
    'Australia Southeast', -37.8136,   144.9631,
    'Australia Central',  -35.3075,   149.1244,
    'Australia Central 2',-35.3075,   149.1345,
    'Central India',       18.5822,    73.9197,
    'West India',          19.0885,    72.8682,
    'South India',         12.9845,    80.1637,
    'Korea South',         35.1796,   129.0756,
    'Korea Central',       37.5665,   126.9780,
    // Middle East & Africa
    'South Africa North', -25.7312,    28.2184,
    'South Africa West',  -34.0757,    18.8430,
    'UAE North',           25.2667,    55.3167,
    'UAE Central',         24.4667,    54.3667,
    'Israel Central',      31.5313,    34.8677,
    'Qatar Central',       25.5514,    51.4232,
    // Other
    'New Zealand North',  -36.8485,   174.7633,
    'Taiwan North',        25.0478,   121.5318,
    'Malaysia West',        3.1478,   101.6953,
    'Chile Central',      -33.4489,   -70.6693
];
let costs = CostsByMonth;
costs
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| where isnotempty(RegionName) and RegionName !in ('', 'Unknown', 'Global', 'global')
| summarize
    TotalCost     = round(sum(EffectiveCost), 2),
    ResourceCount = dcountif(ResourceId, isnotempty(ResourceId))
    by RegionName
| join kind=inner AzureRegionGeo on RegionName
| project
    RegionName,
    Longitude,
    Latitude,
    TotalCost,
    ResourceCount
| order by ResourceCount desc, TotalCost desc
```

## Tile: Data quality warning (last month)

- Tile ID: ab3c272a-19d0-4e65-9e31-1853b9d69dda
- Visual: table
- Query ID: 06c6b306-2f3d-4550-b1fb-b1b02cc86059

### What this query does

- Reads from: CostsByMonth, totals.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: BillingPeriodStart >= periodStart and BillingPeriodStart < periodEnd | x_AmortizationClass != 'Principal'
- Aggregates data with summarize. Examples: Rows = count(),
- Shapes output columns with project operations. Examples: ListCost = todouble(ListCost), | DataQualityStatus,

### KQL

```kql
let periodStart = startofmonth(now(), -1);
let periodEnd = startofmonth(now());
let scoped =
    CostsByMonth
    | where BillingPeriodStart >= periodStart and BillingPeriodStart < periodEnd
    | where x_AmortizationClass != 'Principal'
    | project
        ListCost = todouble(ListCost),
        ContractedCost = todouble(ContractedCost),
        EffectiveCost = todouble(EffectiveCost),
        EffectiveCostAbs = abs(todouble(EffectiveCost));
let totals = scoped
| summarize
    Rows = count(),
    ListLtContracted = countif(ListCost < ContractedCost),
    ContractedLtEffective = countif(ContractedCost < EffectiveCost),
    InvertedRows = countif(ListCost < ContractedCost or ContractedCost < EffectiveCost),
    InvertedEffectiveCost = sumif(EffectiveCostAbs, ListCost < ContractedCost or ContractedCost < EffectiveCost),
    TotalEffectiveCost = sum(EffectiveCostAbs);
totals
| extend DataQualityStatus = iff(InvertedRows == 0, 'OK', 'Warning')
| extend InvertedRowPercent = iff(Rows > 0, round(100.0 * todouble(InvertedRows) / todouble(Rows), 2), 0.0)
| extend InvertedCostPercent = iff(TotalEffectiveCost > 0, round(100.0 * InvertedEffectiveCost / TotalEffectiveCost, 2), 0.0)
| project
    DataQualityStatus,
    Rows,
    InvertedRows,
    InvertedRowPercent,
    ListLtContracted,
    ContractedLtEffective,
    InvertedEffectiveCost = round(InvertedEffectiveCost, 2),
    TotalEffectiveCost = round(TotalEffectiveCost, 2),
    InvertedCostPercent
```

