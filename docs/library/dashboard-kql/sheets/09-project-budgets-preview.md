# Project Budgets (Preview)

- Page ID: d9d88432-617f-445b-8f4b-d70c8a421507
- Tile count: 3

## Tile: (untitled tile)

- Tile ID: e448d5e8-2ea2-4b88-b76b-910bef0c429d
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Cost by subscription (last month)

- Tile ID: 6d349a8b-54b4-4117-a71f-b8ac49f84179
- Visual: table
- Query ID: e50149e0-aa35-4666-ac62-178904d8c719

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
// Project Budgets - Cost by subscription (last month)
Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize
    EffectiveCost = round(sum(EffectiveCost), 2),
    Resources = dcount(ResourceId),
    Services = dcount(ServiceName),
    ResourceGroups = dcount(column_ifexists('x_ResourceGroupName', ''))
    by SubAccountName, SubAccountId
| order by EffectiveCost desc
```

## Tile: Monthly cost trend by subscription

- Tile ID: c30b769c-22cb-4388-b9d5-ec40f0814349
- Visual: stackedcolumn
- Query ID: 582a801f-88e7-4005-95bc-2d750473bdf5

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart), SubAccountName
- Orders or ranks output for visualization. Examples: Month asc

### KQL

```kql
// Project Budgets - Monthly cost trend by subscription
Costs
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize EffectiveCost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart), SubAccountName
| order by Month asc
```

