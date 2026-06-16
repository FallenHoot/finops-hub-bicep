# Planning & Budgeting

- Page ID: 5c57f940-6f0f-4e39-930b-b6e89bb758ad
- Tile count: 22

## Tile: About this capability

- Tile ID: a66f0b2b-6bce-4bfb-ad3e-13f7eabcb586
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Running total - This month and last

- Tile ID: 1ac02a9f-3c12-4828-a4dd-60a0d411f60c
- Visual: area
- Query ID: 10300876-866a-40d7-836d-b3a8783ecece

### What this query does

- Reads from: CostsPlus.
- Consumes shared variables: CostsPlus.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(startofmonth(now()) - 1d)
- Aggregates data with summarize. Examples: EffectiveCost = sum(EffectiveCost) by ChargePeriodStart, Month = strcat(format_datetime(ChargePeriodStart, 'MM '), monthname[monthofyear(ChargePeriodStart)])
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCostRunningTotal, Month
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
CostsPlus
| where ChargePeriodStart >= startofmonth(startofmonth(now()) - 1d)
| summarize EffectiveCost = sum(EffectiveCost) by ChargePeriodStart, Month = strcat(format_datetime(ChargePeriodStart, 'MM '), monthname[monthofyear(ChargePeriodStart)])
| order by ChargePeriodStart asc
| extend EffectiveCostRunningTotal = row_cumsum(EffectiveCost, prev(Month) != Month)
| project ChargePeriodStart, EffectiveCostRunningTotal, Month
| render areachart  
```

## Tile: Summary

- Tile ID: 4faba5ce-4190-45f9-b41e-5d9c6a9c8098
- Visual: table
- Query ID: 9d6635cd-503a-49bc-80c8-ac8157c6e923

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

## Tile: Effective cost by subscription

- Tile ID: 890e0366-a9a5-4001-bc6e-f1b7f23fa8a7
- Visual: table
- Query ID: 3886b5cd-34a8-42d7-9e16-33ea4d236953

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
        ChargePeriodStart = startofmonth(ChargePeriodStart),
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

- Tile ID: ba01a000-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Budget vs actual

- Tile ID: ba01a001-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: multistat
- Query ID: ba010001-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: monthlyBudget, currencyFilter.
- Shapes output columns with project operations. Examples: Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let currentMonth = startofmonth(now());
let lastMonth = startofmonth(now(), -1);
let budget = todouble(monthlyBudget);
let actualMTD = toscalar(Costs | where ChargePeriodStart >= currentMonth | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', ''))) | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter) | summarize sum(EffectiveCost));
let actualSafe = iff(isnull(actualMTD), 0.0, actualMTD);
let actualLastMonth = toscalar(Costs | where ChargePeriodStart >= lastMonth and ChargePeriodStart < currentMonth | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', ''))) | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter) | summarize sum(EffectiveCost));
let lastSafe = iff(isnull(actualLastMonth), 0.0, actualLastMonth);
let daysInMonth = datetime_diff('day', endofmonth(now()), currentMonth) + 1;
let daysElapsed = max_of(1, datetime_diff('day', startofday(now()), currentMonth));
let projected = round(actualSafe / todouble(daysElapsed) * todouble(daysInMonth), 0);
let variance = iff(budget > 0, round((projected - budget) / budget * 100, 1), 0.0);
let status = iff(budget == 0, 'No budget set', iff(variance > 15, 'Over budget', iff(variance > 5, 'At risk', 'On track')));
print json = pack_array(
    pack('Label', 'Monthly Budget', 'Value', tostring(round(budget, 0))),
    pack('Label', 'Spent (MTD)', 'Value', tostring(round(actualSafe, 0))),
    pack('Label', 'Projected', 'Value', tostring(round(projected, 0))),
    pack('Label', 'Variance', 'Value', strcat(iff(variance >= 0, '+', ''), tostring(variance), '%')),
    pack('Label', 'Status', 'Value', status),
    pack('Label', 'Last Month Actual', 'Value', tostring(round(lastSafe, 0))))
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

## Tile: Budget burn rate (this month)

- Tile ID: ba01a002-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: area
- Query ID: ba010002-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: monthlyBudget, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= currentMonth and ChargePeriodStart < startofday(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: DailyCost = sum(EffectiveCost) by Day = startofday(ChargePeriodStart)
- Shapes output columns with project operations. Examples: Day, CumulativeCost = round(CumulativeCost, 0), BudgetLine = round(BudgetLine, 0)
- Orders or ranks output for visualization. Examples: Day asc

### KQL

```kql
let currentMonth = startofmonth(now());
let budget = todouble(monthlyBudget);
Costs
| where ChargePeriodStart >= currentMonth and ChargePeriodStart < startofday(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize DailyCost = sum(EffectiveCost) by Day = startofday(ChargePeriodStart)
| order by Day asc
| extend CumulativeCost = row_cumsum(DailyCost)
| extend BudgetLine = budget
| project Day, CumulativeCost = round(CumulativeCost, 0), BudgetLine = round(BudgetLine, 0)
```

## Tile: Budget variance by subscription

- Tile ID: ba01a003-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: table
- Query ID: ba010003-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: monthlyBudget, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= currentMonth | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: ActualCost = sum(EffectiveCost) by SubAccountName
- Shapes output columns with project operations. Examples: Status, SubAccountName, ActualCost = round(ActualCost, 0), EqualShareBudget, Variance, VariancePct
- Orders or ranks output for visualization. Examples: ActualCost desc

### KQL

```kql
let currentMonth = startofmonth(now());
let budget = todouble(monthlyBudget);
let subCount = toscalar(Costs | where ChargePeriodStart >= currentMonth | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', ''))) | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter) | summarize dcount(SubAccountId));
let subCountSafe = iff(isnull(subCount) or subCount < 1, 1, subCount);
let budgetPerSub = iff(budget > 0, budget / todouble(subCountSafe), 0.0);
Costs
| where ChargePeriodStart >= currentMonth
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize ActualCost = sum(EffectiveCost) by SubAccountName
| extend EqualShareBudget = round(budgetPerSub, 0)
| extend Variance = round(ActualCost - budgetPerSub, 0)
| extend VariancePct = iff(budgetPerSub > 0, round((ActualCost - budgetPerSub) / budgetPerSub * 100, 1), 0.0)
| extend Status = iff(budgetPerSub == 0, 'No Budget', iff(VariancePct > 15, 'At Risk', iff(VariancePct > 5, 'Watch', 'On Track')))
| project Status, SubAccountName, ActualCost = round(ActualCost, 0), EqualShareBudget, Variance, VariancePct
| order by ActualCost desc
```

## Tile: (untitled tile)

- Tile ID: 7220208c-847c-4579-adbf-a17d1e216f5e
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: fc01a000-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Current month projection

- Tile ID: fc01a001-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: multistat
- Query ID: fc010002-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: currencyFilter.
- Shapes output columns with project operations. Examples: Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let today = startofday(now());
let monthStart = startofmonth(today);
let monthEnd = endofmonth(today);
let daysInMonth = datetime_diff('day', monthEnd, monthStart) + 1;
let daysSoFar = datetime_diff('day', today, monthStart);
let spentSoFar = toscalar(Costs | where ChargePeriodStart >= monthStart and ChargePeriodStart < today | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', ''))) | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter) | summarize sum(EffectiveCost));
let spentSafe = iff(isnull(spentSoFar), 0.0, spentSoFar);
let dailyRate = iff(daysSoFar > 0, spentSafe / todouble(daysSoFar), 0.0);
let projected = dailyRate * todouble(daysInMonth);
let lastMonth = toscalar(Costs | where ChargePeriodStart >= startofmonth(today, -1) and ChargePeriodStart < monthStart | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', ''))) | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter) | summarize sum(EffectiveCost));
let lastSafe = iff(isnull(lastMonth), 0.0, lastMonth);
let change = iff(lastSafe > 0, round((projected - lastSafe) / lastSafe * 100, 1), 0.0);
print json = pack_array(
    pack('Label', 'Spent So Far', 'Value', tostring(round(spentSafe, 0))),
    pack('Label', 'Daily Run Rate', 'Value', tostring(round(dailyRate, 0))),
    pack('Label', 'Projected This Month', 'Value', tostring(round(projected, 0))),
    pack('Label', 'vs Last Month', 'Value', strcat(iff(change >= 0, '+', ''), tostring(change), '%')))
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

## Tile: 90-day cost forecast

- Tile ID: fc01a002-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: timechart
- Query ID: fc010001-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -numberOfMonths) and ChargePeriodStart < startofday(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
- Shapes output columns with project operations. Examples: Day = ChargePeriodStart,
- Builds a time series, commonly used for trend or forecast visuals.
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
// 90-day cost forecast using time-series decomposition
let costs = Costs
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths) and ChargePeriodStart < startofday(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
let startDate = toscalar(costs | summarize min(startofday(ChargePeriodStart)));
let endDate = toscalar(costs | summarize max(startofday(ChargePeriodStart)));
costs
| make-series DailyCost = sum(EffectiveCost) default=real(null) on ChargePeriodStart from startDate to endDate + 90d step 1d
| extend Forecast = series_decompose_forecast(DailyCost, 90)
| mv-expand ChargePeriodStart to typeof(datetime), DailyCost to typeof(real), Forecast to typeof(real)
| project Day = ChargePeriodStart,
    Actual = iff(ChargePeriodStart <= endDate and isnotnull(DailyCost), round(DailyCost, 2), real(null)),
    Forecast = iff(ChargePeriodStart > endDate and isnotnull(Forecast), round(max_of(0.0, Forecast), 2), real(null))
```

## Tile: Monthly forecast vs actual

- Tile ID: fc01a003-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: column
- Query ID: fc010003-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: history.
- Consumes shared variables: maxGroupCount, numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: Actual = sum(EffectiveCost) by Month = startofmonth(ChargePeriodStart);
- Shapes output columns with project operations. Examples: Month, Actual = round(Actual, 0), Forecast = real(null) | Month, Actual, Forecast
- Orders or ranks output for visualization. Examples: Month asc

### KQL

```kql
let history = Costs
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize Actual = sum(EffectiveCost) by Month = startofmonth(ChargePeriodStart);
let recentAvg = toscalar(history | top maxGroupCount by Month desc | summarize avg(Actual));
history
| project Month, Actual = round(Actual, 0), Forecast = real(null)
| union (print Month = startofmonth(datetime_add('month', 1, now())), Actual = real(null), Forecast = round(recentAvg, 0))
| union (print Month = startofmonth(datetime_add('month', 2, now())), Actual = real(null), Forecast = round(recentAvg * 1.02, 0))
| union (print Month = startofmonth(datetime_add('month', 3, now())), Actual = real(null), Forecast = round(recentAvg * 1.04, 0))
| order by Month asc
| project Month, Actual, Forecast
```

## Tile: Projected cost by subscription

- Tile ID: fc01a004-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: table
- Query ID: fc010004-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: maxGroupCount, numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -numberOfMonths) and ChargePeriodStart < startofday(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: DailyCost = sum(EffectiveCost) by Day = bin(ChargePeriodStart, 1d), SubAccountName | AvgDaily = avg(DailyCost) by SubAccountName
- Shapes output columns with project operations. Examples: SubAccountName, AvgDaily, ProjectedMonthly
- Orders or ranks output for visualization. Examples: maxGroupCount by AvgDaily desc | ProjectedMonthly desc

### KQL

```kql
Costs
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths) and ChargePeriodStart < startofday(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize DailyCost = sum(EffectiveCost) by Day = bin(ChargePeriodStart, 1d), SubAccountName
| summarize AvgDaily = avg(DailyCost) by SubAccountName
| top maxGroupCount by AvgDaily desc
| extend ProjectedMonthly = round(AvgDaily * 30, 0), AvgDaily = round(AvgDaily, 0)
| project SubAccountName, AvgDaily, ProjectedMonthly
| order by ProjectedMonthly desc
```

## Tile: Monthly cost trend

- Tile ID: fc01a005-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: table
- Query ID: fc010005-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: MonthlyCost = sum(EffectiveCost) by Month = startofmonth(ChargePeriodStart)
- Shapes output columns with project operations. Examples: Month, MonthlyCost = round(MonthlyCost, 0), MoMChange = strcat(iff(MoMChange >= 0, '+', ''), tostring(MoMChange), '%'), Trend = iff(MonthlyCost > PrevMonth, 'Up', iff(MonthlyCost < PrevMonth, 'Down', 'Flat'))
- Orders or ranks output for visualization. Examples: Month asc

### KQL

```kql
Costs
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize MonthlyCost = sum(EffectiveCost) by Month = startofmonth(ChargePeriodStart)
| order by Month asc
| extend PrevMonth = prev(MonthlyCost)
| extend MoMChange = iff(isnotnull(PrevMonth) and PrevMonth > 0, round((MonthlyCost - PrevMonth) / PrevMonth * 100, 1), 0.0)
| project Month, MonthlyCost = round(MonthlyCost, 0), MoMChange = strcat(iff(MoMChange >= 0, '+', ''), tostring(MoMChange), '%'), Trend = iff(MonthlyCost > PrevMonth, 'Up', iff(MonthlyCost < PrevMonth, 'Down', 'Flat'))
```

## Tile: (untitled tile)

- Tile ID: 09167d03-0a80-4d7c-8800-a58cb01f6318
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: 8e01a000-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Cost efficiency KPIs (last month)

- Tile ID: 8e01a001-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: multistat
- Query ID: 8e010001-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
- Shapes output columns with project operations. Examples: Label = tostring(json.Label), Value = tostring(json.Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
let totalCost = toscalar(data | summarize sum(EffectiveCost));
let resourceCount = toscalar(data | summarize dcount(ResourceId));
let subCount = toscalar(data | summarize dcount(SubAccountId));
let rgCount = toscalar(data | summarize dcount(x_ResourceGroupName));
let costPerResource = iff(resourceCount > 0, round(totalCost / todouble(resourceCount), 2), 0.0);
let costPerSub = iff(subCount > 0, round(totalCost / todouble(subCount), 0), 0.0);
let costPerRG = iff(rgCount > 0, round(totalCost / todouble(rgCount), 0), 0.0);
print json = pack_array(
    pack('Label', 'Cost / Resource', 'Value', tostring(costPerResource)),
    pack('Label', 'Cost / Subscription', 'Value', tostring(costPerSub)),
    pack('Label', 'Cost / Resource Group', 'Value', tostring(costPerRG)),
    pack('Label', 'Total Resources', 'Value', tostring(resourceCount)))
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

## Tile: Cost efficiency by subscription

- Tile ID: 8e01a002-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: bar
- Query ID: 8e010002-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: TotalCost = sum(EffectiveCost), Resources = dcount(ResourceId) by SubAccountName
- Shapes output columns with project operations. Examples: SubAccountName, TotalCost = round(TotalCost, 0), Resources, CostPerResource
- Orders or ranks output for visualization. Examples: TotalCost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize TotalCost = sum(EffectiveCost), Resources = dcount(ResourceId) by SubAccountName
| extend CostPerResource = iff(Resources > 0, round(TotalCost / todouble(Resources), 2), 0.0)
| project SubAccountName, TotalCost = round(TotalCost, 0), Resources, CostPerResource
| order by TotalCost desc
| take 15
```

## Tile: Monthly efficiency trend

- Tile ID: 8e01a003-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: timechart
- Query ID: 8e010005-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: numberOfMonths, currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -numberOfMonths) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: TotalCost = sum(EffectiveCost), Resources = dcount(ResourceId) by Month = startofmonth(ChargePeriodStart)
- Shapes output columns with project operations. Examples: Month, CostPerResource, TotalCost = round(TotalCost, 0), Resources
- Orders or ranks output for visualization. Examples: Month asc

### KQL

```kql
Costs
| where ChargePeriodStart >= startofmonth(now(), -numberOfMonths)
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize TotalCost = sum(EffectiveCost), Resources = dcount(ResourceId) by Month = startofmonth(ChargePeriodStart)
| extend CostPerResource = iff(Resources > 0, round(TotalCost / todouble(Resources), 2), 0.0)
| project Month, CostPerResource, TotalCost = round(TotalCost, 0), Resources
| order by Month asc
```

## Tile: Cost efficiency by resource group

- Tile ID: 8e01a004-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: bar
- Query ID: 8e010003-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: TotalCost = sum(EffectiveCost), Resources = dcount(ResourceId) by x_ResourceGroupName
- Shapes output columns with project operations. Examples: ResourceGroup = x_ResourceGroupName, TotalCost = round(TotalCost, 0), Resources, CostPerResource
- Orders or ranks output for visualization. Examples: TotalCost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize TotalCost = sum(EffectiveCost), Resources = dcount(ResourceId) by x_ResourceGroupName
| where isnotempty(x_ResourceGroupName)
| extend CostPerResource = iff(Resources > 0, round(TotalCost / todouble(Resources), 2), 0.0)
| project ResourceGroup = x_ResourceGroupName, TotalCost = round(TotalCost, 0), Resources, CostPerResource
| order by TotalCost desc
| take 15
```

## Tile: Unit cost by resource type

- Tile ID: 8e01a005-c4d5-4e6f-7a8b-9c0d1e2f3a4b
- Visual: table
- Query ID: 8e010004-c4d5-4e6f-7a8b-9c0d1e2f3a4b

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now()) | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: TotalCost = sum(EffectiveCost), ResourceCount = dcount(ResourceId) by ResourceType
- Shapes output columns with project operations. Examples: ResourceType, TotalCost = round(TotalCost, 0), ResourceCount, CostPerResource
- Orders or ranks output for visualization. Examples: TotalCost desc

### KQL

```kql
Costs
| where ChargePeriodStart >= startofmonth(now(), -1) and ChargePeriodStart < startofmonth(now())
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize TotalCost = sum(EffectiveCost), ResourceCount = dcount(ResourceId) by ResourceType
| where isnotempty(ResourceType) and ResourceCount > 0
| extend CostPerResource = round(TotalCost / todouble(ResourceCount), 2)
| project ResourceType, TotalCost = round(TotalCost, 0), ResourceCount, CostPerResource
| order by TotalCost desc
| take 20
```

