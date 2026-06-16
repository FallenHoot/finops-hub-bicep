# Anomaly Management (Preview)

- Page ID: a8f2e3d1-5c6b-4a9e-b7f0-1d2e3f4a5b6c
- Tile count: 7

## Tile: About Anomaly Management

- Tile ID: b9e3f4a2-6d7c-4b8f-c8a1-2e3f4a5b6c7d
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: 4b1622e6-474f-4438-a544-4c504432edde
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Daily trend

- Tile ID: 00b9ea3a-3902-4234-806f-1a7bf87b3992
- Visual: column
- Query ID: 1d9c166d-22b6-48fd-9a90-9f983083ecc7

### What this query does

- Reads from: CostsByDay.
- Consumes shared variables: CostsByDay.
- Aggregates data with summarize. Examples: EffectiveCost = sum(EffectiveCost) by ChargePeriodStart = startofday(ChargePeriodStart)
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Change = iif(isempty(PreviousEffectiveCost), todouble(0), todouble((EffectiveCost - PreviousEffectiveCost) / PreviousEffectiveCost)) * 100
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc

### KQL

```kql
CostsByDay
| summarize EffectiveCost = sum(EffectiveCost) by ChargePeriodStart = startofday(ChargePeriodStart)
| order by ChargePeriodStart asc
| extend PreviousEffectiveCost = prev(EffectiveCost)
| project ChargePeriodStart, EffectiveCost, Change = iif(isempty(PreviousEffectiveCost), todouble(0), todouble((EffectiveCost - PreviousEffectiveCost) / PreviousEffectiveCost)) * 100

```

## Tile: 3-month running total trend

- Tile ID: 570e40a5-f67a-4c4b-84f6-c207ed021812
- Visual: column
- Query ID: d5ed469a-45ea-49a2-b305-b841050213cf

### What this query does

- Reads from: CostsPlus.
- Consumes shared variables: CostsPlus, numberOfDays.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(ago(numberOfDays * 1d))
- Aggregates data with summarize. Examples: EffectiveCost = sum(EffectiveCost) by ChargePeriodStart, Day = dayofmonth(ChargePeriodStart), Month = strcat(format_datetime(ChargePeriodStart, 'MM '), monthname[monthofyear(ChargePeriodStart)])
- Shapes output columns with project operations. Examples: Day, EffectiveCostRunningTotal, Month
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
CostsPlus
| where ChargePeriodStart >= startofmonth(ago(numberOfDays * 1d))
| summarize EffectiveCost = sum(EffectiveCost) by ChargePeriodStart, Day = dayofmonth(ChargePeriodStart), Month = strcat(format_datetime(ChargePeriodStart, 'MM '), monthname[monthofyear(ChargePeriodStart)])
| order by ChargePeriodStart asc
| extend EffectiveCostRunningTotal = row_cumsum(EffectiveCost, prev(Month) != Month)
| project Day, EffectiveCostRunningTotal, Month
| render areachart  
```

## Tile: 3-month daily trend

- Tile ID: 27ff6f92-2e6f-431f-bf3b-f36aad59b5f5
- Visual: column
- Query ID: 9e41a624-d5f9-40c6-b47f-fef4b50ec3dd

### What this query does

- Reads from: CostsPlus.
- Consumes shared variables: CostsPlus, numberOfDays.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= startofmonth(ago(numberOfDays * 1d))
- Aggregates data with summarize. Examples: EffectiveCost = sum(EffectiveCost) by ChargePeriodStart, Day = dayofmonth(ChargePeriodStart), Month = strcat(format_datetime(ChargePeriodStart, 'MM '), monthname[monthofyear(ChargePeriodStart)])
- Shapes output columns with project operations. Examples: Day, EffectiveCost, Month
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
CostsPlus
| where ChargePeriodStart >= startofmonth(ago(numberOfDays * 1d))
| summarize EffectiveCost = sum(EffectiveCost) by ChargePeriodStart, Day = dayofmonth(ChargePeriodStart), Month = strcat(format_datetime(ChargePeriodStart, 'MM '), monthname[monthofyear(ChargePeriodStart)])
| order by ChargePeriodStart asc
| project Day, EffectiveCost, Month
| render columnchart
```

## Tile: 3-month daily trend by subscription

- Tile ID: 97df5060-929c-4457-a7e9-47005c845f16
- Visual: stackedcolumn
- Query ID: f26e2204-270e-4219-8f68-5acef1c9393f

### What this query does

- Reads from: SubAccountId.
- Consumes shared variables: CostsPlus, maxGroupCount, numberOfDays.
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2),
- Shapes output columns with project operations. Examples: ChargePeriodStart, EffectiveCost, Sub = iff(SubAccountId == otherId, SubAccountName, strcat(SubAccountName, ' (', split(SubAccountId, '/')[2], ')'))
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let costs = CostsPlus | where ChargePeriodStart >= startofmonth(ago(numberOfDays * 1d));
let all = costs | summarize sum(EffectiveCost) by SubAccountId;
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
    ChargePeriodStart,
    SubAccountId
| project ChargePeriodStart, EffectiveCost, Sub = iff(SubAccountId == otherId, SubAccountName, strcat(SubAccountName, ' (', split(SubAccountId, '/')[2], ')'))
| order by EffectiveCost desc
| render columnchart
```

## Tile: Forecast (next n days)

- Tile ID: 6fb4c25e-ae84-495b-88ae-6dd2035500d1
- Visual: timechart
- Query ID: 5fd3ea2a-8882-4438-9103-fa3945240604

### What this query does

- Reads from: costs.
- Consumes shared variables: CostsPlus, numberOfDays, numberOfMonths.
- Builds a time series, commonly used for trend or forecast visuals.

### KQL

```kql
let costs = CostsPlus | where ChargePeriodStart >= startofmonth(now(), -numberOfMonths) and ChargePeriodStart < startofday(ago(-1d));
let startOfPeriod = toscalar(costs | summarize min(startofday(ChargePeriodStart)));
let endOfPeriod = toscalar(costs | summarize max(startofday(ChargePeriodStart)));
let forecastHorizon = numberOfDays * 1d;
costs
| make-series
    EffectiveCost = sum(EffectiveCost) default=real(null)
    on ChargePeriodStart
    from startOfPeriod to endOfPeriod + forecastHorizon step 1d
    // by SubAccountId
| extend Forecast = series_decompose_forecast(EffectiveCost, numberOfDays)

```

