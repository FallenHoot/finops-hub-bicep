# Data Ingestion

- Page ID: 9e099251-9658-48da-b416-80422a2a47c7
- Tile count: 20

## Tile: On this page

- Tile ID: ab300a6a-3bbd-450b-942c-7f30113cba15
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: About this domain

- Tile ID: e29123b0-320a-4d36-a5bd-14c1757af8b8
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: 1e089e2c-d94a-4bfa-95e7-5f8b1249c982
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Ingested months

- Tile ID: fc2e27cf-57be-486f-afa5-6a93d6e9c6a7
- Visual: multistat
- Query ID: 8de47213-8327-44da-9d1b-8ba5de74c44a

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Shapes output columns with project operations. Examples: Label = tostring(temp.Label), Value = tostring(temp.Value)

### KQL

```kql
database('Ingestion').HubSettings
| extend temp = todynamic(strcat('[',
    '{"Label":"Version","Value":', version, '},',
    '{"Label":"Managed scopes","Value":', array_length(scopes), '},',
    '{"Label":"Data retention","Value":"', toint(retention.final.months), 'mo"}',
']'))
| mvexpand temp
| project Label = tostring(temp.Label), Value = tostring(temp.Value)

```

## Tile: Monthly trend by hub instance

- Tile ID: 05764729-51e4-4048-8cf8-2ac56eb3e643
- Visual: stackedcolumn
- Query ID: d7a9ff96-da17-4826-9fb5-b23f4c7b938d

### What this query does

- Reads from: x_ResourceParentId.
- Consumes shared variables: CostsByMonth, maxGroupCount.
- Applies filters to narrow scope. Examples: x_ToolkitTool == 'FinOps hubs'
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Hub = iff(x_ResourceParentId == otherId, x_ResourceParentName, strcat(x_ResourceParentName, ' (', x_ResourceGroupName, ' / ', SubAccountName, ')'))
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByMonth
| extend x_ToolkitTool = tostring(Tags['ftk-tool'])
| where x_ToolkitTool == 'FinOps hubs'
| extend x_ToolkitVersion = tostring(Tags['ftk-version'])
| extend x_ResourceParentId = tostring(Tags['cm-resource-parent'])
| extend x_ResourceParentName = database('Ingestion').parse_resourceid(x_ResourceParentId).ResourceName
;
let all = costs | summarize sum(EffectiveCost) by x_ResourceParentId;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
//
// Group rows after max count
| extend inTopX = x_ResourceParentId in (topX)
| extend x_ResourceParentId = iff(inTopX, x_ResourceParentId, otherId)
| extend x_ResourceParentName = iff(inTopX, x_ResourceParentName, strcat('(', (count - maxGroupCount), ' others)'))
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2),
    ResourceType = take_any(ResourceType),
    x_ResourceParentName = take_any(x_ResourceParentName),
    x_ResourceGroupName = take_any(x_ResourceGroupName),
    SubAccountName = take_any(SubAccountName)
    by
    ChargePeriodStart,
    x_ResourceParentId
| project ChargePeriodStart, EffectiveCost, Hub = iff(x_ResourceParentId == otherId, x_ResourceParentName, strcat(x_ResourceParentName, ' (', x_ResourceGroupName, ' / ', SubAccountName, ')'))
| order by EffectiveCost desc

```

## Tile: Daily trend by hub instance

- Tile ID: 37a8bef0-7dfb-42b9-aeab-55f8c9c178b8
- Visual: stackedcolumn
- Query ID: 13813a00-e634-4428-9eac-ea255fd1eaca

### What this query does

- Reads from: x_ResourceParentId.
- Consumes shared variables: CostsByDay, maxGroupCount.
- Applies filters to narrow scope. Examples: x_ToolkitTool == 'FinOps hubs'
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Hub = iff(x_ResourceParentId == otherId, x_ResourceParentName, strcat(x_ResourceParentName, ' (', x_ResourceGroupName, ' / ', SubAccountName, ')'))
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsByDay
| extend x_ToolkitTool = tostring(Tags['ftk-tool'])
| where x_ToolkitTool == 'FinOps hubs'
| extend x_ToolkitVersion = tostring(Tags['ftk-version'])
| extend x_ResourceParentId = tostring(Tags['cm-resource-parent'])
| extend x_ResourceParentName = database('Ingestion').parse_resourceid(x_ResourceParentId).ResourceName
;
let all = costs | summarize sum(EffectiveCost) by x_ResourceParentId;
let count = toscalar(all | order by sum_EffectiveCost desc | count);
let topX = all | order by sum_EffectiveCost desc | limit maxGroupCount;
let otherId = '(others)';
costs
//
// Group rows after max count
| extend inTopX = x_ResourceParentId in (topX)
| extend x_ResourceParentId = iff(inTopX, x_ResourceParentId, otherId)
| extend x_ResourceParentName = iff(inTopX, x_ResourceParentName, strcat('(', (count - maxGroupCount), ' others)'))
//
| summarize 
    EffectiveCost = round(sum(EffectiveCost), 2),
    ResourceType = take_any(ResourceType),
    x_ResourceParentName = take_any(x_ResourceParentName),
    x_ResourceGroupName = take_any(x_ResourceGroupName),
    SubAccountName = take_any(SubAccountName)
    by
    ChargePeriodStart,
    x_ResourceParentId
| project ChargePeriodStart, EffectiveCost, Hub = iff(x_ResourceParentId == otherId, x_ResourceParentName, strcat(x_ResourceParentName, ' (', x_ResourceGroupName, ' / ', SubAccountName, ')'))
| order by EffectiveCost desc

```

## Tile: Monthly trend by hub instance

- Tile ID: c48e07c5-f0a5-43e2-8a13-ee43ed1b92f9
- Visual: table
- Query ID: 62bbceee-c089-45db-822c-0b4745358aa4

### What this query does

- Reads from: costs, data, per, x_ResourceParentId.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: x_ToolkitTool == 'FinOps hubs'
- Aggregates data with summarize. Examples: EffectiveCost  = sum(EffectiveCost), | EffectiveCost  = sum(EffectiveCost)
- Shapes output columns with project operations. Examples: Name = x_ResourceParentName, Version = x_ToolkitVersion
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc | column_ifexists('Total', 0.0) desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let costs = CostsByMonth
| extend x_ToolkitTool = tostring(Tags['ftk-tool'])
| where x_ToolkitTool == 'FinOps hubs'
| extend x_ToolkitVersion = tostring(Tags['ftk-version'])
| extend x_ResourceParentId = tostring(Tags['cm-resource-parent'])
| extend x_ResourceParentName = tostring(database('Ingestion').parse_resourceid(x_ResourceParentId).ResourceName)
;
let data = (
    costs
    | summarize 
        EffectiveCost  = sum(EffectiveCost),
        x_ResourceParentName = take_any(x_ResourceParentName),
        RegionName = take_any(RegionName),
        x_ResourceGroupName = take_any(x_ResourceGroupName),
        SubAccountName = take_any(SubAccountName),
        x_ToolkitVersion = take_any(x_ToolkitVersion)
        by
        ChargePeriodStart,
        x_ResourceParentId
    | as per
    //
    // Append total
    | union (
        per
        | summarize 
            EffectiveCost  = sum(EffectiveCost)
            by
            x_ResourceParentId,
            x_ResourceParentName,
            x_ToolkitVersion,
            RegionName,
            x_ResourceGroupName,
            SubAccountName
    )
    | order by ChargePeriodStart asc
    | extend EffectiveCost = todouble(round(EffectiveCost, 2))
    | extend ChargePeriod = iff(isempty(ChargePeriodStart), strcat('Total'), strcat(format_datetime(ChargePeriodStart, 'yyyy-MM - '), monthname[monthofyear(ChargePeriodStart)]))
);
data | evaluate pivot(ChargePeriod, sum(EffectiveCost), x_ResourceParentName, x_ToolkitVersion, RegionName, x_ResourceGroupName, SubAccountName)
| project-rename Name = x_ResourceParentName, Version = x_ToolkitVersion
| order by column_ifexists('Total', 0.0) desc

```

## Tile: (untitled tile)

- Tile ID: 10d7d4d3-0201-4cdf-977b-4814152fda24
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Ingested scopes

- Tile ID: c636ea6c-8356-4a69-a4d6-61e6596a3c4e
- Visual: card
- Query ID: d2c522dc-ef4b-4714-a473-09350e275557

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Applies filters to narrow scope. Examples: TableName contains '_final_v' | Dataset == 'Costs'
- Aggregates data with summarize. Examples: dcount(Scope)
- Shapes output columns with project operations. Examples: Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount

### KQL

```kql
.show cluster extents
| where TableName contains '_final_v'
| extend Dataset = tostring(split(TableName, '_final_v')[0])
| where Dataset == 'Costs'
| extend FocusVersion = replace_string(tostring(split(TableName, '_final_v')[1]), '_', '.')
| extend ToolkitVersion = tostring(extract(@'drop-by:ftk-version-([^\s]+)', 1, Tags))
// | extend Table = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 1, Tags))
| extend Date  = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 2, Tags))
| extend Scope = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 5, Tags))
| extend Date  = todatetime(strcat(replace_string(trim(@'/', Date), '/', '-'), '-01'))
| extend Scope = replace_regex(Scope, @'/[^/]+$', '')
| project Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount
| extend ScopeId = tostring(database('Ingestion').parse_resourceid(Scope).ResourceName)
// TODO: Look up the name from cost data
| extend ScopeResourceType = database('Ingestion').parse_resourceid(Scope).x_ResourceType
// TODO: Clean up scope resource type display names -- | extend ScopeType = resource_type(ScopeResourceType).SingularDisplayName
| summarize dcount(Scope)
```

## Tile: Ingested months

- Tile ID: 379b25b8-7188-4657-b82f-dee14b344bec
- Visual: card
- Query ID: 6fe11b78-82ef-4e9a-8411-a65e5b0d8bba

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Applies filters to narrow scope. Examples: TableName contains '_final_v' | Dataset == 'Costs'
- Aggregates data with summarize. Examples: dcount(startofmonth(Date))
- Shapes output columns with project operations. Examples: Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount

### KQL

```kql
.show cluster extents
| where TableName contains '_final_v'
| extend Dataset = tostring(split(TableName, '_final_v')[0])
| where Dataset == 'Costs'
| extend FocusVersion = replace_string(tostring(split(TableName, '_final_v')[1]), '_', '.')
| extend ToolkitVersion = tostring(extract(@'drop-by:ftk-version-([^\s]+)', 1, Tags))
// | extend Table = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 1, Tags))
| extend Date  = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 2, Tags))
| extend Scope = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 5, Tags))
| extend Date  = todatetime(strcat(replace_string(trim(@'/', Date), '/', '-'), '-01'))
| extend Scope = replace_regex(Scope, @'/[^/]+$', '')
| project Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount
| extend ScopeId = tostring(database('Ingestion').parse_resourceid(Scope).ResourceName)
// TODO: Look up the name from cost data
| extend ScopeResourceType = database('Ingestion').parse_resourceid(Scope).x_ResourceType
// TODO: Clean up scope resource type display names -- | extend ScopeType = resource_type(ScopeResourceType).SingularDisplayName
| summarize dcount(startofmonth(Date))
```

## Tile: Ingested data by table

- Tile ID: 0b192258-9639-4bd1-bffb-f0fbdcd14d1f
- Visual: stackedcolumn
- Query ID: b98c9ed7-47b3-41c1-a596-fd9d32725b33

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Applies filters to narrow scope. Examples: TableName contains '_final_v'
- Aggregates data with summarize. Examples: Rows = sum(RowCount) by Date, Dataset
- Shapes output columns with project operations. Examples: Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount

### KQL

```kql
.show cluster extents
| where TableName contains '_final_v'
| extend Dataset = tostring(split(TableName, '_final_v')[0])
| extend FocusVersion = replace_string(tostring(split(TableName, '_final_v')[1]), '_', '.')
| extend ToolkitVersion = tostring(extract(@'drop-by:ftk-version-([^\s]+)', 1, Tags))
// | extend Table = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 1, Tags))
| extend Date  = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 2, Tags))
| extend Scope = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 5, Tags))
| extend Date  = todatetime(strcat(replace_string(trim(@'/', Date), '/', '-'), '-01'))
| extend Scope = replace_regex(Scope, @'/[^/]+$', '')
| project Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount
| extend ScopeId = database('Ingestion').parse_resourceid(Scope).ResourceName
// TODO: Look up the name from cost data
| extend ScopeResourceType = database('Ingestion').parse_resourceid(Scope).x_ResourceType
// TODO: Clean up scope resource type display names -- | extend ScopeType = resource_type(ScopeResourceType).SingularDisplayName
| summarize Rows = sum(RowCount) by Date, Dataset
```

## Tile: Ingested cost data by scope

- Tile ID: db78922e-5215-4b93-9762-212eb0e32bf3
- Visual: stackedcolumn
- Query ID: 187e22fe-3d78-45a2-a2bf-090ece144fd1

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Applies filters to narrow scope. Examples: TableName contains '_final_v' | Dataset == 'Costs'
- Aggregates data with summarize. Examples: Rows = sum(RowCount) by Date, ScopeId
- Shapes output columns with project operations. Examples: Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount

### KQL

```kql
.show cluster extents
| where TableName contains '_final_v'
| extend Dataset = tostring(split(TableName, '_final_v')[0])
| where Dataset == 'Costs'
| extend FocusVersion = replace_string(tostring(split(TableName, '_final_v')[1]), '_', '.')
| extend ToolkitVersion = tostring(extract(@'drop-by:ftk-version-([^\s]+)', 1, Tags))
// | extend Table = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 1, Tags))
| extend Date  = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 2, Tags))
| extend Scope = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 5, Tags))
| extend Date  = todatetime(strcat(replace_string(trim(@'/', Date), '/', '-'), '-01'))
| extend Scope = replace_regex(Scope, @'/[^/]+$', '')
| project Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount
| extend ScopeId = tostring(database('Ingestion').parse_resourceid(Scope).ResourceName)
| extend ScopeResourceType = database('Ingestion').parse_resourceid(Scope).x_ResourceType
// TODO: Clean up scope resource type display names -- | extend ScopeType = resource_type(ScopeResourceType).SingularDisplayName
| summarize Rows = sum(RowCount) by Date, ScopeId
```

## Tile: Ingested price data by scope

- Tile ID: 71b29fd4-2999-45dc-9e4b-14152c48a4f4
- Visual: stackedcolumn
- Query ID: b3621977-59be-4f98-a034-a94479612115

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Applies filters to narrow scope. Examples: TableName contains '_final_v' | Dataset == 'Prices'
- Aggregates data with summarize. Examples: Rows = sum(RowCount) by Date, ScopeId
- Shapes output columns with project operations. Examples: Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount

### KQL

```kql
.show cluster extents
| where TableName contains '_final_v'
| extend Dataset = tostring(split(TableName, '_final_v')[0])
| where Dataset == 'Prices'
| extend FocusVersion = replace_string(tostring(split(TableName, '_final_v')[1]), '_', '.')
| extend ToolkitVersion = tostring(extract(@'drop-by:ftk-version-([^\s]+)', 1, Tags))
// | extend Table = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 1, Tags))
| extend Date  = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 2, Tags))
| extend Scope = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 5, Tags))
| extend Date  = todatetime(strcat(replace_string(trim(@'/', Date), '/', '-'), '-01'))
| extend Scope = replace_regex(Scope, @'/[^/]+$', '')
| project Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount
| extend ScopeId = tostring(database('Ingestion').parse_resourceid(Scope).ResourceName)
// TODO: Look up the name from cost data
| extend ScopeResourceType = database('Ingestion').parse_resourceid(Scope).x_ResourceType
// TODO: Clean up scope resource type display names -- | extend ScopeType = resource_type(ScopeResourceType).SingularDisplayName
| summarize Rows = sum(RowCount) by Date, ScopeId
```

## Tile: Ingested recommendation data by scope

- Tile ID: 29f1c705-131d-44b9-9bd6-368c93aedcdf
- Visual: stackedcolumn
- Query ID: 4a2a77fe-e819-4059-b027-dab0a1770a0a

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Applies filters to narrow scope. Examples: TableName contains '_final_v' | Dataset == 'Recommendations'
- Aggregates data with summarize. Examples: Rows = sum(RowCount) by Date, ScopeId
- Shapes output columns with project operations. Examples: Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount

### KQL

```kql
.show cluster extents
| where TableName contains '_final_v'
| extend Dataset = tostring(split(TableName, '_final_v')[0])
| where Dataset == 'Recommendations'
| extend FocusVersion = replace_string(tostring(split(TableName, '_final_v')[1]), '_', '.')
| extend ToolkitVersion = tostring(extract(@'drop-by:ftk-version-([^\s]+)', 1, Tags))
// | extend Table = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 1, Tags))
| extend Date  = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 2, Tags))
| extend Scope = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 5, Tags))
| extend Date  = todatetime(strcat(replace_string(trim(@'/', Date), '/', '-'), '-01'))
| extend Scope = replace_regex(Scope, @'/[^/]+$', '')
| project Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount
| extend ScopeId = tostring(database('Ingestion').parse_resourceid(Scope).ResourceName)
// TODO: Look up the name from cost data
| extend ScopeResourceType = database('Ingestion').parse_resourceid(Scope).x_ResourceType
// TODO: Clean up scope resource type display names -- | extend ScopeType = resource_type(ScopeResourceType).SingularDisplayName
| summarize Rows = sum(RowCount) by Date, ScopeId
```

## Tile: Ingested transaction data by scope

- Tile ID: 47471816-9569-4ff3-816b-98fbc47b5c17
- Visual: stackedcolumn
- Query ID: 8f1ad1ef-6f5e-4f20-a1c4-3941e871d0cd

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Applies filters to narrow scope. Examples: TableName contains '_final_v' | Dataset == 'Transactions'
- Aggregates data with summarize. Examples: Rows = sum(RowCount) by Date, ScopeId
- Shapes output columns with project operations. Examples: Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount

### KQL

```kql
.show cluster extents
| where TableName contains '_final_v'
| extend Dataset = tostring(split(TableName, '_final_v')[0])
| where Dataset == 'Transactions'
| extend FocusVersion = replace_string(tostring(split(TableName, '_final_v')[1]), '_', '.')
| extend ToolkitVersion = tostring(extract(@'drop-by:ftk-version-([^\s]+)', 1, Tags))
// | extend Table = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 1, Tags))
| extend Date  = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 2, Tags))
| extend Scope = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 5, Tags))
| extend Date  = todatetime(strcat(replace_string(trim(@'/', Date), '/', '-'), '-01'))
| extend Scope = replace_regex(Scope, @'/[^/]+$', '')
| project Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount
| extend ScopeId = tostring(database('Ingestion').parse_resourceid(Scope).ResourceName)
// TODO: Look up the name from cost data
| extend ScopeResourceType = database('Ingestion').parse_resourceid(Scope).x_ResourceType
// TODO: Clean up scope resource type display names -- | extend ScopeType = resource_type(ScopeResourceType).SingularDisplayName
| summarize Rows = sum(RowCount) by Date, ScopeId
```

## Tile: Ingested commitment discount usage data by scope

- Tile ID: fcedcd3b-cd11-42ab-8363-de9619fc2018
- Visual: stackedcolumn
- Query ID: e9a9a135-6a74-4463-b69f-eac6930ff1f2

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Applies filters to narrow scope. Examples: TableName contains '_final_v' | Dataset == 'CommitmentDiscountUsage'
- Aggregates data with summarize. Examples: Rows = sum(RowCount) by Date, ScopeId
- Shapes output columns with project operations. Examples: Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount

### KQL

```kql
.show cluster extents
| where TableName contains '_final_v'
| extend Dataset = tostring(split(TableName, '_final_v')[0])
| where Dataset == 'CommitmentDiscountUsage'
| extend FocusVersion = replace_string(tostring(split(TableName, '_final_v')[1]), '_', '.')
| extend ToolkitVersion = tostring(extract(@'drop-by:ftk-version-([^\s]+)', 1, Tags))
// | extend Table = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 1, Tags))
| extend Date  = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 2, Tags))
| extend Scope = tostring(extract(@'drop-by:([^/\s]+)(/[0-9]{4}(/[0-9]{2}(/[0-9]{2})?)?)?(/[^\s]+)', 5, Tags))
| extend Date  = todatetime(strcat(replace_string(trim(@'/', Date), '/', '-'), '-01'))
| extend Scope = replace_regex(Scope, @'/[^/]+$', '')
| project Dataset, FocusVersion, ToolkitVersion, Date, Scope, LastUpdate = MaxCreatedOn, OriginalSize, RowCount
| extend ScopeId = tostring(database('Ingestion').parse_resourceid(Scope).ResourceName)
// TODO: Look up the name from cost data
| extend ScopeResourceType = database('Ingestion').parse_resourceid(Scope).x_ResourceType
// TODO: Clean up scope resource type display names -- | extend ScopeType = resource_type(ScopeResourceType).SingularDisplayName
| summarize Rows = sum(RowCount) by Date, ScopeId
```

## Tile: (untitled tile)

- Tile ID: daa1b2bd-0ccd-43ff-ad2c-1337d247805a
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Summary of list, contracted, and effective cost alignment

- Tile ID: d5ea61ef-d4f5-423e-bfa4-d1ab473867c2
- Visual: table
- Query ID: 56fd8707-bbb3-4f7e-8e37-8dd90ada3baa

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Rows = count(), EffectiveCost = round(sum(EffectiveCost), 2), EffectiveOverContracted = abs(sum(EffectiveOverContracted)), ContractedOverList = abs(sum(ContractedOverList)), EffectiveOverList = abs(sum(EffectiveOverList)), Agreement = arraystring(make_set(x_BillingAccountAgreement)) by Scenario | order by Rows desc

### KQL

```kql
Costs
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| extend EffectiveOverContracted = iff(ContractedCost < EffectiveCost, ContractedCost - EffectiveCost, real(0))
| extend ContractedOverList      = iff(ListCost < ContractedCost,      ListCost - ContractedCost,      real(0))
| extend EffectiveOverList       = iff(ListCost < EffectiveCost,       ListCost - EffectiveCost,       real(0))
| extend Scenario = case(
    ListCost == 0 and CommitmentDiscountCategory == 'Usage' and ChargeCategory == 'Usage', 'Reservation usage missing list',
    ListCost == 0 and CommitmentDiscountCategory == 'Usage' and ChargeCategory == 'Purchase', 'Reservation purchase missing list',
    ListCost == 0 and CommitmentDiscountCategory == 'Spend' and ChargeCategory == 'Usage', 'Savings plan usage missing list',
    ListCost == 0 and CommitmentDiscountCategory == 'Spend' and ChargeCategory == 'Purchase', 'Savings plan purchase missing list',
    ListCost == 0 and ChargeCategory == 'Purchase', 'Other purchase missing list',
    isnotempty(CommitmentDiscountStatus) and ContractedOverList == 0 and EffectiveOverContracted < 0, 'Commitment cost over contracted',
    ListCost == 0 and BilledCost == 0 and EffectiveCost == 0 and ContractedCost > 0 and x_SourceChanges !contains 'MissingContractedCost', 'ContractedCost should be 0',
    ListCost == 0 and ContractedCost == 0 and BilledCost > 0 and EffectiveCost > 0 and x_PublisherCategory == 'Marketplace' and ChargeCategory == 'Usage', 'Marketplace usage missing list/contracted',
    ContractedOverList < 0 and EffectiveOverContracted == 0 and x_SourceChanges !contains 'MissingListCost', 'ListCost too low',
    ContractedUnitPrice == x_EffectiveUnitPrice and EffectiveOverContracted < 0 and x_SourceChanges !contains 'MissingContractedCost', 'ContractedCost doesn\'t match price',
    EffectiveOverContracted != 0 and abs(EffectiveOverContracted) < 0.00000001, 'Rounding error',
    ContractedOverList != 0 and abs(ContractedOverList) < 0.00000001, 'Rounding error',
    EffectiveOverList != 0 and abs(EffectiveOverList) < 0.00000001, 'Rounding error',
    ContractedCost < EffectiveCost or ListCost < ContractedCost or ListCost < EffectiveCost, '',
    EffectiveCost <= ContractedCost and ContractedCost <= ListCost, 'Good',
    '')
| project-reorder ListCost, ContractedCost, BilledCost, EffectiveCost, EffectiveOverList, EffectiveOverContracted, ContractedOverList, x_SourceChanges, ListUnitPrice, ContractedUnitPrice, x_BilledUnitPrice, x_EffectiveUnitPrice, CommitmentDiscountStatus, PricingQuantity, PricingUnit, x_PricingBlockSize, x_PricingUnitDescription
// DEBUG -- | where isempty(scenario) | limit 1000
// Summarize -- 
| summarize Rows = count(), EffectiveCost = round(sum(EffectiveCost), 2), EffectiveOverContracted = abs(sum(EffectiveOverContracted)), ContractedOverList = abs(sum(ContractedOverList)), EffectiveOverList = abs(sum(EffectiveOverList)), Agreement = arraystring(make_set(x_BillingAccountAgreement)) by Scenario | order by Rows desc

```

## Tile: (untitled tile)

- Tile ID: d401a000-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Data quality warnings (last month)

- Tile ID: d401a001-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: table
- Query ID: d4010001-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: AffectedRows = count(), TotalDifference = round(sum(EffectiveCost - ListCost), 2) by ServiceName, SubAccountName
- Shapes output columns with project operations. Examples: Warning = 'Warning: EffectiveCost > ListCost', ServiceName, SubAccountName, AffectedRows, TotalDifference
- Orders or ranks output for visualization. Examples: TotalDifference desc

### KQL

```kql
// Data quality warnings - flag rows where EffectiveCost > ListCost (known MCA issue #1424)
Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| where EffectiveCost > ListCost and ListCost > 0
| summarize AffectedRows = count(), TotalDifference = round(sum(EffectiveCost - ListCost), 2) by ServiceName, SubAccountName
| project Warning = 'Warning: EffectiveCost > ListCost', ServiceName, SubAccountName, AffectedRows, TotalDifference
| order by TotalDifference desc
| take 20
```

