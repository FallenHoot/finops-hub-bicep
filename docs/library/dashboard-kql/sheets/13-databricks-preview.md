# Databricks (Preview)

- Page ID: ba68a8d7-df68-4c33-b17d-4e9e67596337
- Tile count: 5

## Tile: (untitled tile)

- Tile ID: 27826bae-edc3-4560-99b9-05a046e2eafe
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Databricks Spend Summary

- Tile ID: e2b4b158-b8ab-4687-b5b7-d34a44f01364
- Visual: multistat
- Query ID: cf120001-3529-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: x_PublisherCategory == 'Marketplace' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Shapes output columns with project operations. Examples: Label=tostring(json.Label), Value=tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let mkt = Costs
| where x_PublisherCategory == 'Marketplace'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| where tolower(strcat(PublisherName, ' ', ServiceName, ' ', ChargeDescription)) has 'databricks'
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
let total = toscalar(mkt | summarize round(sum(EffectiveCost), 2));
let subs = toscalar(mkt | summarize dcount(SubAccountName));
let products = toscalar(mkt | summarize dcount(ServiceName));
print json = pack_array(pack('Label', 'Databricks spend', 'Value', tostring(total)), pack('Label', 'Subscriptions', 'Value', tostring(subs)), pack('Label', 'Products', 'Value', tostring(products)))
| mv-expand json
| project Label=tostring(json.Label), Value=tostring(json.Value)
```

## Tile: Databricks Spend by Month

- Tile ID: 03b9a6d8-31af-46c1-b3e9-c36e0dba3aef
- Visual: column
- Query ID: 5d9101af-c2b0-4acf-abfa-be16bed80a69

### What this query does

- Reads from: databricks.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: x_PublisherCategory == 'Marketplace' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart)
- Orders or ranks output for visualization. Examples: Month asc

### KQL

```kql
let databricks = Costs
| where x_PublisherCategory == 'Marketplace'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| where tolower(strcat(PublisherName, ' ', ServiceName, ' ', ChargeDescription)) has 'databricks'
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
databricks
| summarize Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart)
| order by Month asc
```

## Tile: Top Databricks Products

- Tile ID: e9d5bfa0-e1e3-482b-831b-2f837f47639d
- Visual: table
- Query ID: cd6c86fa-ea12-4b8a-a094-44963282cc8f

### What this query does

- Reads from: databricks.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: x_PublisherCategory == 'Marketplace' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by ServiceName, PublisherName
- Shapes output columns with project operations. Examples: Product = ServiceName, Publisher = PublisherName, Cost
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
let databricks = Costs
| where x_PublisherCategory == 'Marketplace'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| where tolower(strcat(PublisherName, ' ', ServiceName, ' ', ChargeDescription)) has 'databricks'
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
databricks
| summarize Cost = round(sum(EffectiveCost), 2) by ServiceName, PublisherName
| order by Cost desc
| take 15
| project Product = ServiceName, Publisher = PublisherName, Cost
```

## Tile: Databricks Spend by Subscription

- Tile ID: 070d494d-2a4e-4b24-a4ff-c77c3e4e94bc
- Visual: table
- Query ID: 9bbe203f-434e-472d-bc70-12707f5b9386

### What this query does

- Reads from: databricks.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: x_PublisherCategory == 'Marketplace' | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2), Products = dcount(ServiceName) by SubAccountName
- Shapes output columns with project operations. Examples: SubAccountName, Cost, Products
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
let databricks = Costs
| where x_PublisherCategory == 'Marketplace'
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| where tolower(strcat(PublisherName, ' ', ServiceName, ' ', ChargeDescription)) has 'databricks'
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
databricks
| summarize Cost = round(sum(EffectiveCost), 2), Products = dcount(ServiceName) by SubAccountName
| order by Cost desc
| project SubAccountName, Cost, Products
```

