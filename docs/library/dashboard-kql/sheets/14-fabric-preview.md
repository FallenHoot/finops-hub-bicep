# Fabric (Preview)

- Page ID: ba13a209-ce7d-4169-a098-e29d4972c664
- Tile count: 5

## Tile: (untitled tile)

- Tile ID: 4e545504-6478-4301-bf56-7ce8987ae567
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Fabric Spend Summary

- Tile ID: e209f24d-f8c8-414c-aca9-5d9ebffac040
- Visual: multistat
- Query ID: cf120002-3529-4e5f-6a7b-8c9d0e1f2a3b

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: (x_PublisherCategory == 'Marketplace' or (ProviderName == 'Microsoft' and ServiceName has_cs 'Fabric')) | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Shapes output columns with project operations. Examples: Label=tostring(json.Label), Value=tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let mkt = Costs
| where (x_PublisherCategory == 'Marketplace' or (ProviderName == 'Microsoft' and ServiceName has_cs 'Fabric'))
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| where tolower(strcat(PublisherName, ' ', ServiceName, ' ', ChargeDescription)) has 'fabric'
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
let total = toscalar(mkt | summarize round(sum(EffectiveCost), 2));
let subs = toscalar(mkt | summarize dcount(SubAccountName));
let products = toscalar(mkt | summarize dcount(ServiceName));
print json = pack_array(pack('Label', 'Fabric spend', 'Value', tostring(total)), pack('Label', 'Subscriptions', 'Value', tostring(subs)), pack('Label', 'Products', 'Value', tostring(products)))
| mv-expand json
| project Label=tostring(json.Label), Value=tostring(json.Value)
```

## Tile: Fabric Spend by Month

- Tile ID: 79163359-cef1-41b2-9bf0-012b4e4a993d
- Visual: column
- Query ID: 32c8d1ab-d976-4a57-a57c-57562d180897

### What this query does

- Reads from: fabric.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: (x_PublisherCategory == 'Marketplace' or (ProviderName == 'Microsoft' and ServiceName has_cs 'Fabric')) | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart)
- Orders or ranks output for visualization. Examples: Month asc

### KQL

```kql
let fabric = Costs
| where (x_PublisherCategory == 'Marketplace' or (ProviderName == 'Microsoft' and ServiceName has_cs 'Fabric'))
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| where tolower(strcat(PublisherName, ' ', ServiceName, ' ', ChargeDescription)) has 'fabric'
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
fabric
| summarize Cost = round(sum(EffectiveCost), 2) by Month = startofmonth(ChargePeriodStart)
| order by Month asc
```

## Tile: Top Fabric Products

- Tile ID: 2910db06-1f5d-4c7d-8b15-2f59642aa9e3
- Visual: table
- Query ID: ccda6751-82d9-4854-963d-5e6af90ced41

### What this query does

- Reads from: fabric.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: (x_PublisherCategory == 'Marketplace' or (ProviderName == 'Microsoft' and ServiceName has_cs 'Fabric')) | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2) by ServiceName, PublisherName
- Shapes output columns with project operations. Examples: Product = ServiceName, Publisher = PublisherName, Cost
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
let fabric = Costs
| where (x_PublisherCategory == 'Marketplace' or (ProviderName == 'Microsoft' and ServiceName has_cs 'Fabric'))
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| where tolower(strcat(PublisherName, ' ', ServiceName, ' ', ChargeDescription)) has 'fabric'
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
fabric
| summarize Cost = round(sum(EffectiveCost), 2) by ServiceName, PublisherName
| order by Cost desc
| take 15
| project Product = ServiceName, Publisher = PublisherName, Cost
```

## Tile: Fabric Spend by Subscription

- Tile ID: 035e4853-4520-48ca-9748-0f8ced4863c0
- Visual: table
- Query ID: 109f2279-bec3-4f5b-b6ea-5575f412b868

### What this query does

- Reads from: fabric.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: (x_PublisherCategory == 'Marketplace' or (ProviderName == 'Microsoft' and ServiceName has_cs 'Fabric')) | ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
- Aggregates data with summarize. Examples: Cost = round(sum(EffectiveCost), 2), Products = dcount(ServiceName) by SubAccountName
- Shapes output columns with project operations. Examples: SubAccountName, Cost, Products
- Orders or ranks output for visualization. Examples: Cost desc

### KQL

```kql
let fabric = Costs
| where (x_PublisherCategory == 'Marketplace' or (ProviderName == 'Microsoft' and ServiceName has_cs 'Fabric'))
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| where tolower(strcat(PublisherName, ' ', ServiceName, ' ', ChargeDescription)) has 'fabric'
| extend Currency = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or Currency == tostring(currencyFilter);
fabric
| summarize Cost = round(sum(EffectiveCost), 2), Products = dcount(ServiceName) by SubAccountName
| order by Cost desc
| project SubAccountName, Cost, Products
```

