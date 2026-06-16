# Rightsizing (Preview)

- Page ID: e2b6c7d5-9a0f-4e1b-f1d4-5b6c7d8e9f0a
- Tile count: 4

## Tile: About Rightsizing

- Tile ID: f3c7d8e6-0b1a-4f2c-a2e5-6c7d8e9f0a1b
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Rightsizing recommendations summary

- Tile ID: a4d8e9f7-1c2b-4a3d-b3f6-7d8e9f0a1b2c
- Visual: multistat
- Query ID: b5e9f0a8-2d3c-4b4e-c4a7-8e9f0a1b2c3d

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Shapes output columns with project operations. Examples: Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
// Rightsizing - Summary KPIs
let recs = Recommendations
| extend ResourceIdSafe = tostring(coalesce(column_ifexists('ResourceId', ''), column_ifexists('x_ResourceId', '')));
let total = toscalar(recs | summarize count());
let totalSavings = toscalar(recs | summarize sum(x_EffectiveCostSavings));
let totalSafe = iff(isnull(totalSavings), 0.0, totalSavings);
let totalRecs = iff(isnull(total), 0, total);
let resources = toscalar(recs | summarize dcountif(ResourceIdSafe, isnotempty(ResourceIdSafe)));
print json = pack_array(
    pack('Label', 'Recommendations', 'Value', tostring(totalRecs)),
    pack('Label', 'Est. annual savings', 'Value', tostring(round(totalSafe, 2))),
    pack('Label', 'Resources affected', 'Value', tostring(iff(isnull(resources), 0, resources))))
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

## Tile: Top rightsizing recommendations

- Tile ID: c6f0a1b9-3e4d-4c5f-d5b8-9f0a1b2c3d4e
- Visual: table
- Query ID: d7a1b2c0-4f5e-4d6a-e6c9-0a1b2c3d4e5f

### What this query does

- Reads from: Recommendations.
- Aggregates data with summarize. Examples: EstSavings = round(sum(x_EffectiveCostSavings), 2),
- Shapes output columns with project operations. Examples: x_RecommendationCategory = RecommendationCategory, x_RecommendationDescription = RecommendationDescription, ResourceType, ResourceCount, EstSavings, LastSeen
- Orders or ranks output for visualization. Examples: EstSavings desc

### KQL

```kql
// Rightsizing - Top recommendations
Recommendations
| extend ResourceTypeSafe = tostring(coalesce(column_ifexists('ResourceType', ''), column_ifexists('x_ResourceType', ''), 'Unknown'))
| extend ResourceIdSafe = tostring(coalesce(column_ifexists('ResourceId', ''), column_ifexists('x_ResourceId', '')))
| extend RecommendationDescription = tostring(coalesce(column_ifexists('x_RecommendationDescription', ''), column_ifexists('RecommendationDescription', ''), 'No description'))
| extend RecommendationCategory = tostring(coalesce(column_ifexists('x_RecommendationCategory', ''), column_ifexists('RecommendationCategory', ''), 'Uncategorized'))
| summarize
    EstSavings = round(sum(x_EffectiveCostSavings), 2),
    ResourceCount = dcountif(ResourceIdSafe, isnotempty(ResourceIdSafe)),
    LastSeen = max(x_RecommendationDate)
    by ResourceType = iff(isnotempty(ResourceTypeSafe), ResourceTypeSafe, 'Unknown'), RecommendationDescription, RecommendationCategory
| order by EstSavings desc
| take 20
| project x_RecommendationCategory = RecommendationCategory, x_RecommendationDescription = RecommendationDescription, ResourceType, ResourceCount, EstSavings, LastSeen
```

## Tile: Est. savings by resource type

- Tile ID: e8b2c3d1-5a6f-4e7b-f7d0-1b2c3d4e5f6a
- Visual: bar
- Query ID: f9c3d4e2-6b7a-4f8c-a8e1-2c3d4e5f6a7b

### What this query does

- Reads from: Recommendations.
- Applies filters to narrow scope. Examples: x_EffectiveCostSavings > 0
- Aggregates data with summarize. Examples: EstSavings = round(sum(x_EffectiveCostSavings), 2) by ResourceType = iff(isnotempty(ResourceTypeSafe), ResourceTypeSafe, 'Unknown')
- Shapes output columns with project operations. Examples: ResourceType, EstSavings
- Orders or ranks output for visualization. Examples: EstSavings desc

### KQL

```kql
// Rightsizing - Est. savings by resource type
Recommendations
| where x_EffectiveCostSavings > 0
| extend ResourceTypeSafe = tostring(coalesce(column_ifexists('ResourceType', ''), column_ifexists('x_ResourceType', ''), 'Unknown'))
| summarize EstSavings = round(sum(x_EffectiveCostSavings), 2) by ResourceType = iff(isnotempty(ResourceTypeSafe), ResourceTypeSafe, 'Unknown')
| order by EstSavings desc
| take 15
| project ResourceType, EstSavings
```

