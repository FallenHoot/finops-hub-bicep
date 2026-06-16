# About

- Page ID: 969ddf4c-8f2a-4ec4-9588-bb2f39473c9f
- Tile count: 6

## Tile: (untitled tile)

- Tile ID: 8e17c9f7-c513-4b93-bab8-44d3b0e48e9c
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: About the FinOps toolkit

- Tile ID: f5fc42ae-fb77-4df7-9407-5c9c3588dd84
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: 80dea1b1-3160-44f3-a6fa-8f1ee42ef867
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Overall Maturity Score

- Tile ID: 94ebe664-a687-4309-b0ce-d52a73fa85f0
- Visual: multistat
- Query ID: 35a9f1d0-3dd1-4ca5-b40b-47a104f48386

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);

### KQL

```kql
// FinOps Maturity Scorecard - Auto-scored from live data
let lastMonth = Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
let totalRows = toscalar(lastMonth | summarize count());
let taggedRows = toscalar(lastMonth | summarize countif(isnotempty(Tags) and Tags != '{}'));
let tagPct = iif(totalRows > 0, round(100.0 * taggedRows / totalRows, 0), 0.0);
let totalList = toscalar(lastMonth | where ListCost > 0 | summarize sum(ListCost));
let totalEffective = toscalar(lastMonth | where ListCost > 0 | summarize sum(EffectiveCost));
let esr = iif(totalList > 0, round(100.0 * (totalList - totalEffective) / totalList, 0), 0.0);
let commitTotal = toscalar(lastMonth | where isnotempty(CommitmentDiscountId) | summarize sum(EffectiveCost));
let commitUsed = toscalar(lastMonth | where isnotempty(CommitmentDiscountId) | summarize sumif(EffectiveCost, CommitmentDiscountStatus == 'Used'));
let commitUtil = iif(commitTotal > 0, round(100.0 * commitUsed / commitTotal, 0), 0.0);
let providerCount = toscalar(lastMonth | summarize dcount(column_ifexists('ProviderName', '')));
let subCount = toscalar(lastMonth | summarize dcount(SubAccountId));
print
  OverallMaturity = case(
    tagPct > 70 and esr > 15 and commitUtil > 70, 'Run',
    tagPct > 40 or esr > 5 or commitUtil > 40, 'Walk',
    'Crawl'),
  TagCoverage = strcat(tagPct, '%'),
  EffectiveSavingsRate = strcat(esr, '%'),
  CommitmentUtilization = strcat(commitUtil, '%'),
  CloudProviders = providerCount,
  Subscriptions = subCount
```

## Tile: Capability Maturity Detail

- Tile ID: 7bdc738f-24af-4732-8c6f-8ced6b068959
- Visual: table
- Query ID: 782dcff0-e4bd-4279-8af0-c7e22bc2f02d

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
- Shapes output columns with project operations. Examples: Level, Domain, Capability, Metric, Value=round(Value, 0), WalkThreshold=round(WalkThreshold, 0), RunThreshold=round(RunThreshold, 0)
- Orders or ranks output for visualization. Examples: Domain asc, Capability asc

### KQL

```kql
// FinOps Capability Maturity Detail
let lastMonth = Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
let totalRows = toscalar(lastMonth | summarize count());
let taggedRows = toscalar(lastMonth | summarize countif(isnotempty(Tags) and Tags != '{}'));
let tagPct = iif(totalRows > 0, round(100.0 * taggedRows / totalRows, 0), 0.0);
let totalList = toscalar(lastMonth | where ListCost > 0 | summarize sum(ListCost));
let totalEffective = toscalar(lastMonth | where ListCost > 0 | summarize sum(EffectiveCost));
let esr = iif(totalList > 0, round(100.0 * (totalList - totalEffective) / totalList, 0), 0.0);
let commitTotal = toscalar(lastMonth | where isnotempty(CommitmentDiscountId) | summarize sum(EffectiveCost));
let commitUsed = toscalar(lastMonth | where isnotempty(CommitmentDiscountId) | summarize sumif(EffectiveCost, CommitmentDiscountStatus == 'Used'));
let commitUtil = iif(commitTotal > 0, round(100.0 * commitUsed / commitTotal, 0), 0.0);
let subCount = toreal(toscalar(lastMonth | summarize dcount(SubAccountId)));
let rgCount = toreal(toscalar(lastMonth | summarize dcount(column_ifexists('x_ResourceGroupName', ''))));
union
(print Domain='Understand', Capability='Cost Visibility', Metric='Subscriptions tracked', Value=subCount, WalkThreshold=3.0, RunThreshold=10.0),
(print Domain='Manage', Capability='Cost Allocation', Metric='Tag coverage %', Value=tagPct, WalkThreshold=50.0, RunThreshold=80.0),
(print Domain='Optimize', Capability='Rate Optimization', Metric='Effective savings rate %', Value=esr, WalkThreshold=10.0, RunThreshold=20.0),
(print Domain='Optimize', Capability='Commitment Discounts', Metric='Utilization %', Value=commitUtil, WalkThreshold=50.0, RunThreshold=80.0),
(print Domain='Manage', Capability='Resource Groups', Metric='Resource groups tracked', Value=rgCount, WalkThreshold=10.0, RunThreshold=50.0)
| extend Level = case(Value >= RunThreshold, 'Run', Value >= WalkThreshold, 'Walk', 'Crawl')
| project Level, Domain, Capability, Metric, Value=round(Value, 0), WalkThreshold=round(WalkThreshold, 0), RunThreshold=round(RunThreshold, 0)
| order by Domain asc, Capability asc
```

## Tile: Improvement Recommendations

- Tile ID: a76e5d07-b38d-4b1a-992a-f1ed1b7e1c0e
- Visual: table
- Query ID: af60214c-a4d9-4d9f-8b61-a5ac3ed42960

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
- Shapes output columns with project operations. Examples: Priority, Area, Recommendation, Current, Target, Impact
- Orders or ranks output for visualization. Examples: Priority asc

### KQL

```kql
// FinOps Improvement Recommendations
let lastMonth = Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
let totalRows = toscalar(lastMonth | summarize count());
let taggedRows = toscalar(lastMonth | summarize countif(isnotempty(Tags) and Tags != '{}'));
let tagPct = iif(totalRows > 0, round(100.0 * taggedRows / totalRows, 0), 0.0);
let totalList = toscalar(lastMonth | where ListCost > 0 | summarize sum(ListCost));
let totalEffective = toscalar(lastMonth | where ListCost > 0 | summarize sum(EffectiveCost));
let esr = iif(totalList > 0, round(100.0 * (totalList - totalEffective) / totalList, 0), 0.0);
let commitTotal = toscalar(lastMonth | where isnotempty(CommitmentDiscountId) | summarize sum(EffectiveCost));
let commitUsed = toscalar(lastMonth | where isnotempty(CommitmentDiscountId) | summarize sumif(EffectiveCost, CommitmentDiscountStatus == 'Used'));
let commitUtil = iif(commitTotal > 0, round(100.0 * commitUsed / commitTotal, 0), 0.0);
range i from 1 to 3 step 1
| extend Priority = case(i == 1 and tagPct < 50, 1, i == 1 and tagPct < 80, 2, i == 1, 3, i == 2 and esr < 10, 1, i == 2 and esr < 20, 2, i == 2, 3, commitUtil < 50, 1, commitUtil < 80, 2, 3)
| extend Area = case(i == 1, 'Cost Allocation', i == 2, 'Rate Optimization', 'Commitment Utilization')
| extend Recommendation = case(i == 1 and tagPct < 50, 'Warning: Implement mandatory tagging policy for all resources', i == 1 and tagPct < 80, 'Increase tag coverage to 80%+ for accurate chargeback', i == 1, 'Tag coverage is excellent', i == 2 and esr < 10, 'Warning: Evaluate commitment discounts (reservations, savings plans)', i == 2 and esr < 20, 'Expand commitment coverage for higher savings', i == 2, 'Savings rate is strong', commitUtil < 50, 'Warning: Review and reallocate underutilized commitments', commitUtil < 80, 'Optimize commitment allocation across subscriptions', 'Commitment utilization is excellent')
| extend Current = case(i == 1, strcat(tagPct, '%'), i == 2, strcat(esr, '%'), strcat(commitUtil, '%'))
| extend Target = case(i == 2, '20%+', '80%+')
| extend Impact = case(i == 1 and tagPct < 50, 'High', i == 1 and tagPct < 80, 'Medium', i == 1, 'Low', i == 2 and esr < 10, 'High', i == 2 and esr < 20, 'Medium', i == 2, 'Low', commitUtil < 50, 'High', commitUtil < 80, 'Medium', 'Low')
| project Priority, Area, Recommendation, Current, Target, Impact
| order by Priority asc
```

