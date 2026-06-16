# Cost Analysis

- Page ID: 38170d90-36d5-4978-8e75-d3a6112384e5
- Tile count: 42

## Tile: (untitled tile)

- Tile ID: d9960334-1cff-4686-9d4a-e6afc5574aa7
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Monthly trend by service category

- Tile ID: 700f736d-56b1-4194-8282-891683f63134
- Visual: stackedcolumn
- Query ID: 4c7a7614-9b8c-415b-a4e1-d2d53c023d31

### What this query does

- Reads from: ServiceCategory.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2)
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Category = ServiceCategory
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByMonth;
let all = costs | where isnotempty(ServiceCategory) | summarize sum(EffectiveCost) by ServiceCategory;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
//
// Group rows after max count
| extend inTopX = ServiceCategory in (topX)
| extend ServiceCategory = iff(inTopX, ServiceCategory, otherId)
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2)
    by
    ChargePeriodStart,
    ServiceCategory
| project ChargePeriodStart, EffectiveCost, Category = ServiceCategory
| order by EffectiveCost desc
| render columnchart
```

## Tile: Monthly trend by service category

- Tile ID: 97872267-01c6-44f9-ad0d-34940d4b58fa
- Visual: table
- Query ID: 1d273b55-d2ea-427c-8a5f-01f6c240e98a

### What this query does

- Reads from: CostsByMonth, data, per, ServiceName.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: EffectiveCost  = sum(EffectiveCost) | EffectiveCost  = sum(EffectiveCost)
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc | column_ifexists('Total', 0.0) desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let data = (
    CostsByMonth
    | summarize 
        EffectiveCost  = sum(EffectiveCost)
        by
        ChargePeriodStart,
        ServiceCategory,
        ServiceName
    | as per
    | union (
        per
        | summarize 
            EffectiveCost  = sum(EffectiveCost)
            by
            ServiceCategory,
            ServiceName
    )
    | order by ChargePeriodStart asc
    | extend EffectiveCost = todouble(round(EffectiveCost, 2))
    | extend ChargePeriod = iff(isempty(ChargePeriodStart), strcat('Total'), strcat(format_datetime(ChargePeriodStart, 'yyyy-MM - '), monthname[monthofyear(ChargePeriodStart)]))
);
data | evaluate pivot(ChargePeriod, sum(EffectiveCost), ServiceCategory)
| order by column_ifexists('Total', 0.0) desc
```

## Tile: Monthly trend by service name

- Tile ID: b2916ba0-cb54-433d-89a1-8905b8d8618a
- Visual: stackedcolumn
- Query ID: 30644718-defd-4c6c-9ffa-a9c2cd1f871f

### What this query does

- Reads from: ServiceName.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2)
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Category = ServiceName
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByMonth;
let all = costs | where isnotempty(ServiceName) | summarize sum(EffectiveCost) by ServiceName;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
//
// Group rows after max count
| extend inTopX = ServiceName in (topX)
| extend ServiceName = iff(inTopX, ServiceName, otherId)
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2)
    by
    ChargePeriodStart,
    ServiceName
| project ChargePeriodStart, EffectiveCost, Category = ServiceName
| order by EffectiveCost desc
| render columnchart
```

## Tile: Monthly trend by service name

- Tile ID: 6208961b-6249-4fd4-a2d6-16b5e58b9baa
- Visual: table
- Query ID: 6259f773-593c-4953-898c-15aa5ff6e53a

### What this query does

- Reads from: CostsByMonth, data, per, ServiceName.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: EffectiveCost  = sum(EffectiveCost) | EffectiveCost  = sum(EffectiveCost)
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc | column_ifexists('Total', 0.0) desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let data = (
    CostsByMonth
    | summarize 
        EffectiveCost  = sum(EffectiveCost)
        by
        ChargePeriodStart,
        ServiceCategory,
        ServiceName
    | as per
    | union (
        per
        | summarize 
            EffectiveCost  = sum(EffectiveCost)
            by
            ServiceCategory,
            ServiceName
    )
    | order by ChargePeriodStart asc
    | extend EffectiveCost = todouble(round(EffectiveCost, 2))
    | extend ChargePeriod = iff(isempty(ChargePeriodStart), strcat('Total'), strcat(format_datetime(ChargePeriodStart, 'yyyy-MM - '), monthname[monthofyear(ChargePeriodStart)]))
);
data | evaluate pivot(ChargePeriod, sum(EffectiveCost), ServiceName, ServiceCategory)
| order by column_ifexists('Total', 0.0) desc
```

## Tile: (untitled tile)

- Tile ID: e47767ba-1884-4ca7-8458-24025b92464a
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Monthly trend by region

- Tile ID: d3e265ff-2c5a-4a03-a8b8-e0b4e10cf362
- Visual: stackedcolumn
- Query ID: d5224d06-c8e7-4dd9-afec-595b39712f5a

### What this query does

- Reads from: RegionName.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2)
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Region = RegionName
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByMonth;
let all = costs | where isnotempty(RegionName) | summarize sum(EffectiveCost) by RegionName;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit iff(count - maxGroupCount > 1, maxGroupCount, count);
let otherId = '(others)';
costs
//
// Group rows after max count
| extend inTopX = RegionName in (topX)
| extend RegionName = iff(inTopX, RegionName, strcat('(', count - maxGroupCount, ' others)'))
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2)
    by
    ChargePeriodStart = startofmonth(ChargePeriodStart),
    RegionName
| project ChargePeriodStart, EffectiveCost, Region = RegionName
| order by EffectiveCost desc
```

## Tile: Monthly trend by region

- Tile ID: c54de4ff-e793-49b7-b33d-db22fccd0290
- Visual: table
- Query ID: 0dcf2c54-7f1d-45e9-a53b-d598a24493a4

### What this query does

- Reads from: CostsByMonth, data, per, RegionName.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: EffectiveCost  = sum(EffectiveCost) | EffectiveCost  = sum(EffectiveCost)
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc | column_ifexists('Total', 0.0) desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let data = (
    CostsByMonth
    | summarize 
        EffectiveCost  = sum(EffectiveCost)
        by
        ChargePeriodStart = startofmonth(ChargePeriodStart),
        RegionName
    | as per
    | union (
        per
        | summarize 
            EffectiveCost  = sum(EffectiveCost)
            by
            RegionName
    )
    | order by ChargePeriodStart asc
    | extend EffectiveCost = todouble(round(EffectiveCost, 2))
    | extend ChargePeriod = iff(isempty(ChargePeriodStart), strcat('Total'), strcat(format_datetime(ChargePeriodStart, 'yyyy-MM - '), monthname[monthofyear(ChargePeriodStart)]))
);
data | evaluate pivot(ChargePeriod, sum(EffectiveCost), RegionName)
| order by column_ifexists('Total', 0.0) desc
```

## Tile: (untitled tile)

- Tile ID: 4956ec68-b338-4926-bd72-ae6ca9e886d6
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Monthly trend by subscription

- Tile ID: b28897e5-0606-4112-a13a-0cd814055ea7
- Visual: stackedcolumn
- Query ID: 21a87abe-19e2-44ec-8298-ba872e66c162

### What this query does

- Reads from: SubAccountId.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Sub = iff(SubAccountId == otherId, SubAccountName, strcat(SubAccountName, ' (', split(SubAccountId, '/')[2], ')'))
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByMonth;
let all = costs | where isnotempty(SubAccountId) | summarize sum(EffectiveCost) by SubAccountId;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
//
// Group rows after max count
| extend inTopX = SubAccountId in (topX)
| extend SubAccountId = iff(inTopX, SubAccountId, otherId)
| extend SubAccountName = iff(inTopX, SubAccountName, strcat('(', (count - maxGroupCount), ' others)'))
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2),
    SubAccountName = take_any(SubAccountName)
    by
    ChargePeriodStart = startofmonth(ChargePeriodStart),
    SubAccountId
| project ChargePeriodStart, EffectiveCost, Sub = iff(SubAccountId == otherId, SubAccountName, strcat(SubAccountName, ' (', split(SubAccountId, '/')[2], ')'))
| order by EffectiveCost desc
| render columnchart
```

## Tile: Monthly trend by subscription

- Tile ID: 7b24b810-3cd3-4b7c-92cc-6b40f071b24d
- Visual: table
- Query ID: 90502e9a-2d0d-4ae4-8d9d-cc21f9b72d5d

### What this query does

- Reads from: CostsByMonth, data, per, SubAccountId.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: BilledCost     = sum(BilledCost), | BilledCost     = sum(BilledCost),
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc | column_ifexists('Total', 0.0) desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let data = (
    CostsByMonth
    | summarize 
        BilledCost     = sum(BilledCost),
        EffectiveCost  = sum(EffectiveCost),
        ContractedCost = sum(ContractedCost),
        ListCost       = sum(ListCost),
        SubAccountName = take_any(SubAccountName)
        by
        ChargePeriodStart,
        SubAccountId
    | as per
    | union (
        per
        | summarize 
            BilledCost     = sum(BilledCost),
            EffectiveCost  = sum(EffectiveCost),
            ContractedCost = sum(ContractedCost),
            ListCost       = sum(ListCost),
            SubAccountName = take_any(SubAccountName)
            by
            SubAccountId
    )
    | order by ChargePeriodStart asc
    | extend BilledCost                = todouble(round(BilledCost, 2))
    | extend EffectiveCost             = todouble(round(EffectiveCost, 2))
    | extend ContractedCost            = todouble(round(ContractedCost, 2))
    | extend ListCost                  = todouble(round(ListCost, 2))
    | extend ContractedCostNormalized  = min_of(ContractedCost, ListCost)
    | extend EffectiveCostNormalized   = min_of(EffectiveCost, ContractedCostNormalized)
    | extend CommitmentDiscountSavings = todouble(round(ContractedCostNormalized - EffectiveCostNormalized, 2))
    | extend NegotiatedDiscountSavings = todouble(round(ListCost - ContractedCostNormalized, 2))
    | extend ChargePeriod = iff(isempty(ChargePeriodStart), strcat('Total'), strcat(format_datetime(ChargePeriodStart, 'yyyy-MM - '), monthname[monthofyear(ChargePeriodStart)]))
);
data | evaluate pivot(ChargePeriod, sum(EffectiveCost), SubAccountName)
| order by column_ifexists('Total', 0.0) desc
```

## Tile: (untitled tile)

- Tile ID: 6750ce15-ec4e-4c60-8079-b00a4b462d63
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Monthly trend by resource group

- Tile ID: d2672640-0e48-47e5-a253-de927a77a637
- Visual: stackedcolumn
- Query ID: 61b26784-6a73-4e80-85b2-9c5cfbd2dd06

### What this query does

- Reads from: x_ResourceGroupId.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, RG = iff(x_ResourceGroupId == otherId, x_ResourceGroupName, strcat(x_ResourceGroupName, ' (', SubAccountName, ')'))
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByMonth | extend x_ResourceGroupId = strcat(SubAccountId, '/resourcegroups/', x_ResourceGroupName);
let all = costs | where isnotempty(x_ResourceGroupId) | summarize sum(EffectiveCost) by x_ResourceGroupId;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
//
// Group rows after max count
| extend inTopX = x_ResourceGroupId in (topX)
| extend x_ResourceGroupId = iff(inTopX, x_ResourceGroupId, otherId)
| extend x_ResourceGroupName = iff(inTopX, x_ResourceGroupName, strcat('(', (count - maxGroupCount), ' others)'))
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2),
    SubAccountName = take_any(SubAccountName),
    x_ResourceGroupName = take_any(x_ResourceGroupName)
    by
    ChargePeriodStart,
    x_ResourceGroupId
| project ChargePeriodStart, EffectiveCost, RG = iff(x_ResourceGroupId == otherId, x_ResourceGroupName, strcat(x_ResourceGroupName, ' (', SubAccountName, ')'))
| order by EffectiveCost desc
| render columnchart
```

## Tile: Monthly trend by resource group

- Tile ID: f56a2d38-7d69-4dfd-8cc8-6b7a292758b1
- Visual: table
- Query ID: c2c65ec0-e57d-4834-8a6b-b5975afeb9a0

### What this query does

- Reads from: CostsByMonth, data, per, x_ResourceGroupId.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: EffectiveCost  = sum(EffectiveCost), | EffectiveCost  = sum(EffectiveCost),
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc | column_ifexists('Total', 0.0) desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let data = (
    CostsByMonth
    | extend x_ResourceGroupId = strcat(SubAccountId, '/resourcegroups/', x_ResourceGroupName)
    | summarize 
        EffectiveCost  = sum(EffectiveCost),
        SubAccountName = take_any(SubAccountName),
        x_ResourceGroupName = take_any(x_ResourceGroupName)
        by
        ChargePeriodStart,
        x_ResourceGroupId
    | as per
    | union (
        per
        | summarize 
            EffectiveCost  = sum(EffectiveCost),
            SubAccountName = take_any(SubAccountName),
            x_ResourceGroupName = take_any(x_ResourceGroupName)
            by
            x_ResourceGroupId
    )
    | order by ChargePeriodStart asc
    | extend EffectiveCost = todouble(round(EffectiveCost, 2))
    | extend ChargePeriod = iff(isempty(ChargePeriodStart), strcat('Total'), strcat(format_datetime(ChargePeriodStart, 'yyyy-MM - '), monthname[monthofyear(ChargePeriodStart)]))
);
data | evaluate pivot(ChargePeriod, sum(EffectiveCost), x_ResourceGroupName, SubAccountName)
| order by column_ifexists('Total', 0.0) desc
```

## Tile: (untitled tile)

- Tile ID: 52055726-2788-4216-b813-9d91714c5953
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Monthly trend by resource

- Tile ID: d84a014f-0b68-490b-a522-fba66fee1e0f
- Visual: stackedcolumn
- Query ID: 3924981c-23e4-464d-a872-045df1752750

### What this query does

- Reads from: ResourceId.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, RG = iff(ResourceId == otherId, ResourceName, strcat(ResourceName, ' (', ResourceType, ')'))
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByMonth;
let all = costs | where isnotempty(ResourceId) | summarize sum(EffectiveCost) by ResourceId;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
//
// Group rows after max count
| extend inTopX = ResourceId in (topX)
| extend ResourceId = iff(inTopX, ResourceId, otherId)
| extend ResourceName = iff(inTopX, ResourceName, strcat('(', (count - maxGroupCount), ' others)'))
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2),
    ResourceType = take_any(ResourceType),
    ResourceName = take_any(ResourceName)
    by
    ChargePeriodStart,
    ResourceId
| project ChargePeriodStart, EffectiveCost, RG = iff(ResourceId == otherId, ResourceName, strcat(ResourceName, ' (', ResourceType, ')'))
| order by EffectiveCost desc
| render columnchart
```

## Tile: Daily trend by resource

- Tile ID: c03c1e57-5e66-4eb1-a20b-10c887eb2140
- Visual: stackedcolumn
- Query ID: 49e24ee0-91de-4b1c-973f-036a3c060aca

### What this query does

- Reads from: ResourceId.
- Consumes shared variables: CostsByDay, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, RG = iff(ResourceId == otherId, ResourceName, strcat(ResourceName, ' (', ResourceType, ')'))
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByDay;
let all = costs | summarize sum(EffectiveCost) by ResourceId;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
//
// Group rows after max count
| extend inTopX = ResourceId in (topX)
| extend ResourceId = iff(inTopX, ResourceId, otherId)
| extend ResourceName = iff(inTopX, ResourceName, strcat('(', (count - maxGroupCount), ' others)'))
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2),
    ResourceType = take_any(ResourceType),
    ResourceName = take_any(ResourceName)
    by
    ChargePeriodStart,
    ResourceId
| project ChargePeriodStart, EffectiveCost, RG = iff(ResourceId == otherId, ResourceName, strcat(ResourceName, ' (', ResourceType, ')'))
| order by EffectiveCost desc
| render columnchart
```

## Tile: Monthly trend by resource

- Tile ID: 586ebe0b-ff5c-4794-91a1-a8ec845cad3a
- Visual: table
- Query ID: c7be613e-deb4-4779-ad75-4445e8d5e01f

### What this query does

- Reads from: CostsByMonth, data, per, ResourceId.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: EffectiveCost  = sum(EffectiveCost), | EffectiveCost  = sum(EffectiveCost)
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc | column_ifexists('Total', 0.0) desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let data = (
    CostsByMonth
    | summarize 
        EffectiveCost  = sum(EffectiveCost),
        ResourceName = take_any(ResourceName),
        ResourceType = take_any(ResourceType),
        RegionName = take_any(RegionName),
        x_ResourceGroupName = take_any(x_ResourceGroupName),
        SubAccountName = take_any(SubAccountName)
        by
        ChargePeriodStart,
        ResourceId
    | as per
    | union (
        per
        | summarize 
            EffectiveCost  = sum(EffectiveCost)
            by
            ResourceId,
            ResourceName,
            ResourceType,
            RegionName,
            x_ResourceGroupName,
            SubAccountName
    )
    | order by ChargePeriodStart asc
    | extend EffectiveCost = todouble(round(EffectiveCost, 2))
    | extend ChargePeriod = iff(isempty(ChargePeriodStart), strcat('Total'), strcat(format_datetime(ChargePeriodStart, 'yyyy-MM - '), monthname[monthofyear(ChargePeriodStart)]))
);
data | evaluate pivot(ChargePeriod, sum(EffectiveCost), ResourceName, ResourceType, RegionName, x_ResourceGroupName, SubAccountName)
| order by column_ifexists('Total', 0.0) desc
```

## Tile: (untitled tile)

- Tile ID: a8edc317-353b-4648-9d32-e73e0d0a2894
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Resource inventory summary (last n days)

- Tile ID: a83872cb-44ef-402a-8512-b9d5ba04744e
- Visual: multistat
- Query ID: f062533b-8c94-412f-bf83-0eb5cd06063d

### What this query does

- Reads from: costs.
- Consumes shared variables: CostsByDay, CostsPlus, numberOfDays.
- Applies filters to narrow scope. Examples: isnotempty(ResourceType);
- Orders or ranks output for visualization. Examples: Order asc

### KQL

```kql
let costs = CostsByDay
| where isnotempty(ResourceType);
costs | summarize Value = tostring(dcount(ResourceId)) by Label = "Resources", Order = 10
| union (costs | summarize Value = tostring(dcount(ResourceType)) by Label = "Resource types", Order = 11)
| union (costs | summarize Count = dcount(ResourceId) by Value = ResourceType | order by Count desc | limit 1 | extend Label = "Most used", Order = 21)
| union (costs | summarize sum(EffectiveCost) by Value = ResourceType | order by sum_EffectiveCost desc | limit 1 | extend Label = "Most cost", Order = 22)
| union (costs | summarize AllTypes = dcount(ResourceType), CommittedTypes = dcountif(ResourceType, isnotempty(CommitmentDiscountType)) by Label = "Covered by commitment discounts", Order = 31 | extend Value = strcat(round(1.0 * CommittedTypes / AllTypes * 100, 1), '%'))
| union (costs | summarize Savings = sum(ListCost - EffectiveCost) by Value = ResourceType | order by Savings desc | limit 1 | extend Label = "Most savings", Order = 32)
| union (costs | summarize CostPerResource = sum(EffectiveCost) / dcount(ResourceId) by Value = ResourceType | order by CostPerResource desc | limit 1 | extend Label = "Most expensive (cost / resource)", Order = 41)
| union (costs | where ResourceType !in (CostsPlus | where ChargePeriodStart < ago(numberOfDays * 1d) - 1d | distinct ResourceType) | summarize Count = dcount(ResourceId) by ResourceType | order by Count desc | as d | count | extend Label = "New in last n days", Value = case(Count == 0, '(none)', Count == 1, toscalar(d | project ResourceType), strcat(toscalar(d | limit 1 | project ResourceType), ' and ', (Count - 1), ' more')), Order = 42)
| order by Order asc

```

## Tile: Daily trend by resource type (last n days)

- Tile ID: 8d63f5d3-b1d8-4117-a358-bce7939a13ae
- Visual: stackedcolumn
- Query ID: ebe41e27-e9f9-478e-ab90-fd1f87906766

### What this query does

- Reads from: costs, ResourceType.
- Consumes shared variables: CostsByDay, maxGroupCount.
- Applies filters to narrow scope. Examples: isnotempty(ResourceType)
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2)
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Type = ResourceType
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByDay;
let all = costs | where isnotempty(ResourceType) | summarize sum(EffectiveCost) by ResourceType;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
| where isnotempty(ResourceType)
//
// Group rows after max count
| extend inTopX = ResourceType in (topX)
| extend ResourceType = iff(inTopX, ResourceType, strcat('(', (count - maxGroupCount), ' others)'))
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2)
    by
    ChargePeriodStart = startofday(ChargePeriodStart),
    ResourceType
| project ChargePeriodStart, EffectiveCost, Type = ResourceType
| order by EffectiveCost desc
| render columnchart
```

## Tile: Resource type summary (last n days)

- Tile ID: 38ffb57b-4646-4944-a92b-6966a3a6a807
- Visual: table
- Query ID: 2d7b6447-2769-40b8-958a-f252dab68b1e

### What this query does

- Reads from: CostsByDay.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: isnotempty(ResourceType)
- Aggregates data with summarize. Examples: Count = dcount(ResourceId),
- Shapes output columns with project operations. Examples: Type = ResourceType,
- Orders or ranks output for visualization. Examples: Count desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
CostsByDay
| where isnotempty(ResourceType)
| summarize 
    Count = dcount(ResourceId),
    EffectiveCost  = sum(EffectiveCost),
    ListCost  = sum(ListCost),
    ContractedCost  = sum(ContractedCost)
    by
    ResourceType
| order by Count desc
| project 
    Type = ResourceType,
    Count,
    Cost = round(EffectiveCost, 2),
    // NegotiatedSavings = round(ListCost - ContractedCost, 2),
    // CommitmentSavings = round(ContractedCost - EffectiveCost, 2),
    Savings = round(ListCost - EffectiveCost, 2),
    ["Cost / Resource"] = round(EffectiveCost / Count, 2)

```

## Tile: Most used (last n days)

- Tile ID: 4495e71e-1005-4224-91f4-8103f06981da
- Visual: bar
- Query ID: 9c5d3cf0-b6cb-45a2-acfd-b19df425bddf

### What this query does

- Reads from: costs.
- Consumes shared variables: CostsByDay, maxGroupCount.
- Applies filters to narrow scope. Examples: isnotempty(ResourceType)
- Aggregates data with summarize. Examples: ResourceCount = dcountif(ResourceId, isnotempty(ResourceId))
- Orders or ranks output for visualization. Examples: ResourceCount desc

### KQL

```kql
let costs = CostsByDay | where isnotempty(ResourceType);
let all = costs | summarize ResourceCount = dcount(ResourceId) by ResourceType;
let count = toscalar(all | order by ResourceCount desc | count);
let topX = all | order by ResourceCount desc | limit maxGroupCount;
let otherId = '(others)';
costs
| where isnotempty(ResourceType)
//
// Group rows after max count
| extend inTopX = ResourceType in (topX)
| extend ResourceType = iff(inTopX, ResourceType, strcat('(', (count - maxGroupCount), ' others)'))
//
| summarize 
    ResourceCount = dcountif(ResourceId, isnotempty(ResourceId))
    by
    ResourceType
| order by ResourceCount desc
| render columnchart
```

## Tile: Most cost (last n days)

- Tile ID: 011c2b2c-a232-4459-acf4-8db4055f4f70
- Visual: bar
- Query ID: a35b4c05-8ecb-4c51-9aaf-980af3d7923e

### What this query does

- Reads from: costs.
- Consumes shared variables: CostsByDay, maxGroupCount.
- Applies filters to narrow scope. Examples: isnotempty(ResourceType)
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2)
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByDay | where isnotempty(ResourceType);
let all = costs | summarize sum(EffectiveCost) by ResourceType;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
| where isnotempty(ResourceType)
//
// Group rows after max count
| extend inTopX = ResourceType in (topX)
| extend ResourceType = iff(inTopX, ResourceType, strcat('(', (count - maxGroupCount), ' others)'))
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2)
    by
    ResourceType
| order by EffectiveCost desc
| render columnchart
```

## Tile: Monthly trend by resource type

- Tile ID: e26eb29d-8021-406c-a84e-5568ddd234f4
- Visual: stackedcolumn
- Query ID: 90e30901-a931-4a1d-b81e-0a1821032c3c

### What this query does

- Reads from: ResourceType.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2)
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Type = ResourceType
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByMonth;
let all = costs | where isnotempty(ResourceType) | summarize sum(EffectiveCost) by ResourceType;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
//
// Group rows after max count
| extend inTopX = ResourceType in (topX)
| extend ResourceType = iff(inTopX, ResourceType, strcat('(', (count - maxGroupCount), ' others)'))
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2)
    by
    ChargePeriodStart,
    ResourceType
| project ChargePeriodStart, EffectiveCost, Type = ResourceType
| order by EffectiveCost desc
| render columnchart
```

## Tile: (untitled tile)

- Tile ID: 18517864-8a43-4f0c-80e3-863554f1b189
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Purchases

- Tile ID: 4383c893-8839-4678-88c6-9a6393595d0a
- Visual: table
- Query ID: 98c9b9b5-bebf-41f8-8319-5fa2523f9dd0

### What this query does

- Reads from: BillingCurrency, CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Purchase'
- Shapes output columns with project operations. Examples: ChargePeriodStart = substring(ChargePeriodStart, 0, 10),
- Orders or ranks output for visualization. Examples: ChargePeriodStart desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
CostsByMonth
| where ChargeCategory == 'Purchase'
| project
    ChargePeriodStart = substring(ChargePeriodStart, 0, 10),
    x_SkuDescription,
    CommitmentDiscountType,
    Term = case(isempty(x_SkuTerm) or x_SkuTerm <= 0, '', x_SkuTerm < 12, strcat(x_SkuTerm, ' month', iff(x_SkuTerm != 1, 's', '')), strcat(x_SkuTerm / 12, ' year', iff(x_SkuTerm != 12, 's', ''))),
    PricingQuantity,
    BilledCost,
    BillingCurrency
| order by ChargePeriodStart desc

```

## Tile: (untitled tile)

- Tile ID: e2784720-f86f-415b-8c22-c4ad8a399513
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: a3b4c5d6-0001-4a9b-0c1d-2e3f4a5b6c7d
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Subscription summary (last n months)

- Tile ID: a3b4c5d6-0002-4a9b-0c1d-2e3f4a5b6c7d
- Visual: multistat
- Query ID: a3b4c5d6-1001-4a9b-0c1d-2e3f4a5b6c7d

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: Subscriptions = dcount(SubAccountId),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[', | Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
// Subscription Summary - Counts and total cost
let data = materialize(
    CostsByMonth
    | summarize
        Subscriptions = dcount(SubAccountId),
        ResourceGroups = dcount(strcat(SubAccountId, x_ResourceGroupName)),
        Resources = dcount(ResourceId),
        TotalCost = round(sum(EffectiveCost), 0)
    | project json = todynamic(strcat('[',
        '{"Label":"Subscriptions","Value":"', Subscriptions, '"},',
        '{"Label":"Resource Groups","Value":"', ResourceGroups, '"},',
        '{"Label":"Resources","Value":"', Resources, '"},',
        '{"Label":"Total Cost","Value":"', TotalCost, '"}',
    ']'))
    | mv-expand json
    | project Label = tostring(json.Label), Value = tostring(json.Value)
);
data
```

## Tile: Cost by subscription (last n months)

- Tile ID: a3b4c5d6-0003-4a9b-0c1d-2e3f4a5b6c7d
- Visual: stackedcolumn
- Query ID: a3b4c5d6-1002-4a9b-0c1d-2e3f4a5b6c7d

### What this query does

- Reads from: costs, SubAccountId.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Sub = iff(SubAccountId == otherId, SubAccountName, strcat(SubAccountName, ' (', split(SubAccountId, '/')[2], ')'))
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
// Cost by Subscription - Monthly trend with top N
let costs = CostsByMonth;
let all = costs | where isnotempty(SubAccountId) | summarize sum(EffectiveCost) by SubAccountId;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
| extend inTopX = SubAccountId in (topX)
| extend SubAccountId = iff(inTopX, SubAccountId, otherId)
| extend SubAccountName = iff(inTopX, SubAccountName, strcat('(', (count - maxGroupCount), ' others)'))
| summarize
    EffectiveCost = round(sum(EffectiveCost), 2),
    SubAccountName = take_any(SubAccountName)
    by
    ChargePeriodStart = startofmonth(ChargePeriodStart),
    SubAccountId
| project ChargePeriodStart, EffectiveCost, Sub = iff(SubAccountId == otherId, SubAccountName, strcat(SubAccountName, ' (', split(SubAccountId, '/')[2], ')'))
| order by EffectiveCost desc
| render columnchart
```

## Tile: Top resources by subscription (last n months)

- Tile ID: a3b4c5d6-0004-4a9b-0c1d-2e3f4a5b6c7d
- Visual: table
- Query ID: a3b4c5d6-1003-4a9b-0c1d-2e3f4a5b6c7d

### What this query does

- Reads from: BilledCost, CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: isnotempty(ResourceId)
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: Subscription = strcat(SubAccountName, ' (', split(SubAccountId, '/')[2], ')'),
- Orders or ranks output for visualization. Examples: Subscription asc, EffectiveCost desc

### KQL

```kql
// Top Resources by Subscription - Nested drilldown table
CostsByMonth
| where isnotempty(ResourceId)
| summarize
    EffectiveCost = round(sum(EffectiveCost), 2),
    BilledCost = round(sum(BilledCost), 2),
    ResourceName = take_any(ResourceName),
    ServiceName = take_any(ServiceName),
    x_ResourceType = take_any(x_ResourceType),
    x_ResourceGroupName = take_any(x_ResourceGroupName),
    SubAccountName = take_any(SubAccountName)
    by SubAccountId, ResourceId
| project
    Subscription = strcat(SubAccountName, ' (', split(SubAccountId, '/')[2], ')'),
    ResourceGroup = x_ResourceGroupName,
    ResourceName,
    ServiceName,
    ResourceType = x_ResourceType,
    EffectiveCost,
    BilledCost
| order by Subscription asc, EffectiveCost desc
```

## Tile: Resource cost by service (last n months)

- Tile ID: a3b4c5d6-0005-4a9b-0c1d-2e3f4a5b6c7d
- Visual: bar
- Query ID: a3b4c5d6-1004-4a9b-0c1d-2e3f4a5b6c7d

### What this query does

- Reads from: costs.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2) by ServiceName
- Shapes output columns with project operations. Examples: ServiceName, EffectiveCost
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
// Resource Cost by Service - Top services by cost
let costs = CostsByMonth;
let all = costs | where isnotempty(ServiceName) | summarize sum(EffectiveCost) by ServiceName;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
costs
| extend inTopX = ServiceName in (topX)
| extend ServiceName = iff(inTopX, ServiceName, strcat('(', (count - maxGroupCount), ' others)'))
| summarize EffectiveCost = round(sum(EffectiveCost), 2) by ServiceName
| order by EffectiveCost desc
| project ServiceName, EffectiveCost
```

## Tile: Resource cost by resource group (last n months)

- Tile ID: a3b4c5d6-0006-4a9b-0c1d-2e3f4a5b6c7d
- Visual: bar
- Query ID: a3b4c5d6-1005-4a9b-0c1d-2e3f4a5b6c7d

### What this query does

- Reads from: costs.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2) by x_ResourceGroupName
- Shapes output columns with project operations. Examples: ResourceGroup = x_ResourceGroupName, EffectiveCost
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
// Resource Cost by Resource Group - Top resource groups by cost
let costs = CostsByMonth;
let all = costs | where isnotempty(x_ResourceGroupName) | summarize sum(EffectiveCost) by x_ResourceGroupName;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
costs
| extend inTopX = x_ResourceGroupName in (topX)
| extend x_ResourceGroupName = iff(inTopX, x_ResourceGroupName, strcat('(', (count - maxGroupCount), ' others)'))
| summarize EffectiveCost = round(sum(EffectiveCost), 2) by x_ResourceGroupName
| order by EffectiveCost desc
| project ResourceGroup = x_ResourceGroupName, EffectiveCost
```

## Tile: Top resources by provider (last n months)

- Tile ID: 0c040002-5d01-4f5a-6b7c-8d9e0f1a2b3c
- Visual: table
- Query ID: 0c040001-5d01-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= monthsago(numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by
- Shapes output columns with project operations. Examples: Provider, SubAccountName, ServiceName, ResourceName, Cost
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= monthsago(numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2) by
    Provider = coalesce(ProviderName, 'Unknown'),
    SubAccountName,
    ServiceName,
    ResourceName = coalesce(ResourceName, '(unnamed)')
| order by Cost desc
| take 100
| project Provider, SubAccountName, ServiceName, ResourceName, Cost
```

## Tile: (untitled tile)

- Tile ID: 114be936-94ce-4ed5-8ec9-2b39c963a882
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: 0c090010-c203-4f5a-6b7c-8d9e0f1a2b3c
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Monthly cost by provider

- Tile ID: 0c090011-c203-4f5a-6b7c-8d9e0f1a2b3c
- Visual: stackedcolumn
- Query ID: 0c090001-c203-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= monthsago(numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2)
- Orders or ranks output for visualization. Examples: Month asc, Provider asc

### KQL

```kql
Costs
| where ChargePeriodStart >= monthsago(numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2)
    by Month = startofmonth(ChargePeriodStart),
       Provider = coalesce(ProviderName, 'Unknown')
| order by Month asc, Provider asc
```

## Tile: Daily cost by provider (last n days)

- Tile ID: 0c090012-c203-4f5a-6b7c-8d9e0f1a2b3c
- Visual: stackedarea
- Query ID: 0c090002-c203-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfDays, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= ago(numberOfDays * 1d) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2)
- Orders or ranks output for visualization. Examples: Day asc

### KQL

```kql
Costs
| where ChargePeriodStart >= ago(numberOfDays * 1d)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2)
    by Day = bin(ChargePeriodStart, 1d),
       Provider = coalesce(ProviderName, 'Unknown')
| order by Day asc
```

## Tile: Top services across providers

- Tile ID: 0c090013-c203-4f5a-6b7c-8d9e0f1a2b3c
- Visual: table
- Query ID: 0c090003-c203-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= monthsago(numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2)
- Shapes output columns with project operations. Examples: Provider, ServiceCategory, ServiceName, Cost
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= monthsago(numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize Cost = round(sum(EffectiveCost), 2)
    by Provider = coalesce(ProviderName, 'Unknown'),
       ServiceCategory = coalesce(ServiceCategory, 'Other'),
       ServiceName = coalesce(ServiceName, 'Unknown')
| order by Cost desc
| take 50
| project Provider, ServiceCategory, ServiceName, Cost
```

## Tile: Sub accounts by provider

- Tile ID: 0c090014-c203-4f5a-6b7c-8d9e0f1a2b3c
- Visual: table
- Query ID: 0c090004-c203-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= monthsago(numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: Provider, SubAccount, Cost, Services, Resources
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= monthsago(numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize
    Cost = round(sum(EffectiveCost), 2),
    Services = dcount(ServiceName),
    Resources = dcount(ResourceId)
    by Provider = coalesce(ProviderName, 'Unknown'),
       SubAccount = coalesce(SubAccountName, 'Unknown')
| order by Cost desc
| take 25
| project Provider, SubAccount, Cost, Services, Resources
```

## Tile: Savings rate by provider

- Tile ID: 0c090015-c203-4f5a-6b7c-8d9e0f1a2b3c
- Visual: table
- Query ID: 0c090005-c203-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' | ChargePeriodStart >= monthsago(numberOfMonths)
- Aggregates data with summarize. Examples: ListCostTotal = round(sum(ListCost), 2),
- Shapes output columns with project operations. Examples: Provider, ListCostTotal, EffectiveCostTotal, Savings, SavingsRate
- Orders or ranks output for visualization. Examples: ListCostTotal desc

### KQL

```kql
Costs
| where ChargeCategory == 'Usage'
| where ChargePeriodStart >= monthsago(numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize
    ListCostTotal = round(sum(ListCost), 2),
    EffectiveCostTotal = round(sum(EffectiveCost), 2)
    by Provider = coalesce(ProviderName, 'Unknown')
| extend
    Savings = round(ListCostTotal - EffectiveCostTotal, 2),
    SavingsRate = iff(ListCostTotal > 0, round((ListCostTotal - EffectiveCostTotal) / ListCostTotal * 100, 1), 0.0)
| order by ListCostTotal desc
| project Provider, ListCostTotal, EffectiveCostTotal, Savings, SavingsRate
```

