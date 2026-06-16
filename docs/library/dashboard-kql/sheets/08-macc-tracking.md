# MACC Tracking

- Page ID: a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d
- Tile count: 8

## Tile: (untitled tile)

- Tile ID: b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: MACC Current Status (Preview)

- Tile ID: c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f
- Visual: table
- Query ID: d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a

### What this query does

- Reads from: MACCData.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
- Shapes output columns with project operations. Examples: Description, Currency, DataSource, CommitmentAmount = round(Commitment, 0), TotalConsumed = round(TotalConsumed2, 0), RemainingBalance = round(Commitment - TotalConsumed2, 0), PercentConsumed = strcat(PercentConsumed, '%'), PercentTimeElapsed = strcat(PercentTimeElapsed, '%'), DaysRemaining, ExpirationDate = format_datetime(EndDate, 'yyyy-MM-dd'), HealthStatus
- Orders or ranks output for visualization. Examples: 1 by SourcePriority desc, IsActive desc, StartDate desc;

### KQL

```kql
// MACC Status - Supports API-backed lots and manual entry
let MACCData = union isfuzzy=true
    (MACC_Lots | extend DataSource = 'API', SourcePriority = 2),
    (MACC_Lots_raw | extend DataSource = 'API', SourcePriority = 2),
    (MACC_ManualEntry | extend DataSource = 'Manual', SourcePriority = 1),
    (print Description='No MACC data configured', Currency='', StartDate=datetime(null), ExpirationDate=datetime(null), CommitmentAmount=0.0, DataSource='Fallback', SourcePriority=0)
| extend Description = tostring(coalesce(column_ifexists('Description', ''), column_ifexists('LotId', ''), 'MACC commitment'))
| extend Currency = tostring(coalesce(column_ifexists('Currency', ''), column_ifexists('OriginalCurrency', ''), column_ifexists('ClosedBalanceCurrency', '')))
| extend StartDate = todatetime(coalesce(column_ifexists('StartDate', datetime(null)), column_ifexists('PurchasedDate', datetime(null)), startofmonth(now())))
| extend ExpirationDate = todatetime(coalesce(column_ifexists('ExpirationDate', datetime(null)), endofmonth(now())))
| extend CommitmentAmount = todouble(coalesce(column_ifexists('CommitmentAmount', real(null)), column_ifexists('OriginalAmount', real(null))))
| extend IsActive = iff(isnotnull(ExpirationDate) and ExpirationDate >= now(), 1, 0)
| top 1 by SourcePriority desc, IsActive desc, StartDate desc;
let StartDate = toscalar(MACCData | project StartDate);
let EndDate = toscalar(MACCData | project ExpirationDate);
let Commitment = toscalar(MACCData | project CommitmentAmount);
let ConsumedCosts = Costs
| where ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
let TotalConsumed = toscalar(ConsumedCosts | summarize sum(EffectiveCost));
let TotalConsumed2 = iff(isnull(TotalConsumed), 0.0, TotalConsumed);
let DaysTotalRaw = datetime_diff('day', EndDate, StartDate);
let DaysTotal = iff(isnull(DaysTotalRaw) or DaysTotalRaw < 1, 1, DaysTotalRaw);
let DaysElapsedRaw = datetime_diff('day', now(), StartDate);
let DaysElapsed = iff(DaysElapsedRaw < 0, 0, iff(DaysElapsedRaw > DaysTotal, DaysTotal, DaysElapsedRaw));
let DaysRemainingRaw = datetime_diff('day', EndDate, now());
let DaysRemaining = iff(DaysRemainingRaw < 0, 0, DaysRemainingRaw);
let PercentConsumed = iff(Commitment > 0, round(100.0 * TotalConsumed2 / Commitment, 1), 0.0);
let PercentTimeElapsed = round(100.0 * todouble(DaysElapsed) / todouble(DaysTotal), 1);
let HealthStatus = case(PercentConsumed >= PercentTimeElapsed - 5 and PercentConsumed <= PercentTimeElapsed + 10, 'On Track', PercentConsumed > PercentTimeElapsed + 10, 'Ahead', PercentConsumed >= PercentTimeElapsed - 15, 'Slightly Behind', PercentConsumed >= PercentTimeElapsed - 25, 'Behind', 'At Risk');
MACCData
| project Description, Currency, DataSource, CommitmentAmount = round(Commitment, 0), TotalConsumed = round(TotalConsumed2, 0), RemainingBalance = round(Commitment - TotalConsumed2, 0), PercentConsumed = strcat(PercentConsumed, '%'), PercentTimeElapsed = strcat(PercentTimeElapsed, '%'), DaysRemaining, ExpirationDate = format_datetime(EndDate, 'yyyy-MM-dd'), HealthStatus
```

## Tile: Monthly Consumption Trend (Preview)

- Tile ID: e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b
- Visual: column
- Query ID: f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: MonthlyConsumption = sum(EffectiveCost) by Month = startofmonth(ChargePeriodStart)
- Shapes output columns with project operations. Examples: Month, MonthlyConsumption = round(MonthlyConsumption, 0), RunningTotal = round(RunningTotal, 0), RemainingBalance = round(RemainingBalance, 0)
- Orders or ranks output for visualization. Examples: 1 by SourcePriority desc, IsActive desc, StartDate desc; | Month asc

### KQL

```kql
// MACC Monthly Consumption Trend from FOCUS data
let MACCData = union isfuzzy=true
    (MACC_Lots | extend DataSource = 'API', SourcePriority = 2),
    (MACC_Lots_raw | extend DataSource = 'API', SourcePriority = 2),
    (MACC_ManualEntry | extend DataSource = 'Manual', SourcePriority = 1),
    (print Description='No MACC data configured', Currency='', StartDate=datetime(null), ExpirationDate=datetime(null), CommitmentAmount=0.0, DataSource='Fallback', SourcePriority=0)
| extend StartDate = todatetime(coalesce(column_ifexists('StartDate', datetime(null)), column_ifexists('PurchasedDate', datetime(null)), startofmonth(now())))
| extend ExpirationDate = todatetime(coalesce(column_ifexists('ExpirationDate', datetime(null)), endofmonth(now())))
| extend CommitmentAmount = todouble(coalesce(column_ifexists('CommitmentAmount', real(null)), column_ifexists('OriginalAmount', real(null))))
| extend IsActive = iff(isnotnull(ExpirationDate) and ExpirationDate >= now(), 1, 0)
| top 1 by SourcePriority desc, IsActive desc, StartDate desc;
let StartDate = toscalar(MACCData | project StartDate);
let EndDate = toscalar(MACCData | project ExpirationDate);
let Commitment = toscalar(MACCData | project CommitmentAmount);
Costs
| where ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize MonthlyConsumption = sum(EffectiveCost) by Month = startofmonth(ChargePeriodStart)
| order by Month asc
| extend RunningTotal = row_cumsum(MonthlyConsumption)
| extend CommitmentLine = Commitment
| extend RemainingBalance = Commitment - RunningTotal
| project Month, MonthlyConsumption = round(MonthlyConsumption, 0), RunningTotal = round(RunningTotal, 0), RemainingBalance = round(RemainingBalance, 0)
```

## Tile: MACC Forecast (Preview)

- Tile ID: a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d
- Visual: multistat
- Query ID: b8c9d0e1-f2a3-4b4c-5d6e-7f8a9b0c1d2e

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
- Shapes output columns with project operations. Examples: json = pack_array(pack('Label', 'Remaining Balance', 'Value', tostring(Remaining)), pack('Label', 'Avg Monthly Burn', 'Value', tostring(AvgMonthly)), pack('Label', 'Required Monthly', 'Value', tostring(Required)), pack('Label', 'Spend Gap', 'Value', tostring(Gap))) | Label = tostring(json.Label), Value = tostring(json.Value)
- Orders or ranks output for visualization. Examples: 1 by SourcePriority desc, IsActive desc, StartDate desc;
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
// MACC Forecast from FOCUS cost data
let MACCData = union isfuzzy=true
    (MACC_Lots | extend DataSource = 'API', SourcePriority = 2),
    (MACC_Lots_raw | extend DataSource = 'API', SourcePriority = 2),
    (MACC_ManualEntry | extend DataSource = 'Manual', SourcePriority = 1),
    (print Description='No MACC data configured', Currency='', StartDate=datetime(null), ExpirationDate=datetime(null), CommitmentAmount=0.0, DataSource='Fallback', SourcePriority=0)
| extend StartDate = todatetime(coalesce(column_ifexists('StartDate', datetime(null)), column_ifexists('PurchasedDate', datetime(null)), startofmonth(now())))
| extend ExpirationDate = todatetime(coalesce(column_ifexists('ExpirationDate', datetime(null)), endofmonth(now())))
| extend CommitmentAmount = todouble(coalesce(column_ifexists('CommitmentAmount', real(null)), column_ifexists('OriginalAmount', real(null))))
| extend IsActive = iff(isnotnull(ExpirationDate) and ExpirationDate >= now(), 1, 0)
| top 1 by SourcePriority desc, IsActive desc, StartDate desc;
let StartDate = toscalar(MACCData | project StartDate);
let EndDate = toscalar(MACCData | project ExpirationDate);
let Commitment = toscalar(MACCData | project CommitmentAmount);
let FilteredCosts = Costs
| where ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter);
let TotalConsumed = toscalar(FilteredCosts | summarize sum(EffectiveCost));
let TotalConsumed2 = iff(isnull(TotalConsumed), 0.0, TotalConsumed);
let MonthsOfData = toscalar(FilteredCosts | summarize dcount(startofmonth(ChargePeriodStart)));
let MonthsOfData2 = iff(isnull(MonthsOfData) or MonthsOfData < 1, 1, MonthsOfData);
let AvgMonthlyBurn = TotalConsumed2 / todouble(MonthsOfData2);
let RemainingBalance = iff(Commitment > TotalConsumed2, Commitment - TotalConsumed2, 0.0);
let MonthsUntilExpiration = datetime_diff('month', EndDate, now());
let MonthsUntilExp2 = iff(MonthsUntilExpiration < 1, 1, MonthsUntilExpiration);
let RequiredMonthlySpend = iff(RemainingBalance > 0, RemainingBalance / todouble(MonthsUntilExp2), 0.0);
let SpendGap = RequiredMonthlySpend - AvgMonthlyBurn;
print Remaining=round(RemainingBalance, 0), AvgMonthly=round(AvgMonthlyBurn, 0), Required=round(RequiredMonthlySpend, 0), Gap=round(SpendGap, 0)
| project json = pack_array(pack('Label', 'Remaining Balance', 'Value', tostring(Remaining)), pack('Label', 'Avg Monthly Burn', 'Value', tostring(AvgMonthly)), pack('Label', 'Required Monthly', 'Value', tostring(Required)), pack('Label', 'Spend Gap', 'Value', tostring(Gap)))
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

## Tile: MACC Pacing vs Linear Target (Preview)

- Tile ID: mc01e2f3-a4b5-4c6d-7e8f-9a0b1c2d3e4f
- Visual: line
- Query ID: mc01e2f3-a4b5-4c6d-7e8f-9a0b1c2d3e4f

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: MonthlyConsumption = sum(EffectiveCost) by Month = startofmonth(ChargePeriodStart)
- Shapes output columns with project operations. Examples: Month, ActualCumulative = round(ActualCumulative, 0), LinearTarget = round(LinearTarget, 0)
- Orders or ranks output for visualization. Examples: 1 by SourcePriority desc, IsActive desc, StartDate desc; | Month asc

### KQL

```kql
// MACC Pacing vs Linear Target - Actual cumulative vs straight-line commitment target
let MACCData = union isfuzzy=true
    (MACC_Lots | extend DataSource = 'API', SourcePriority = 2),
    (MACC_Lots_raw | extend DataSource = 'API', SourcePriority = 2),
    (MACC_ManualEntry | extend DataSource = 'Manual', SourcePriority = 1),
    (print Description='No MACC data configured', Currency='', StartDate=datetime(null), ExpirationDate=datetime(null), CommitmentAmount=0.0, DataSource='Fallback', SourcePriority=0)
| extend StartDate = todatetime(coalesce(column_ifexists('StartDate', datetime(null)), column_ifexists('PurchasedDate', datetime(null)), startofmonth(now())))
| extend ExpirationDate = todatetime(coalesce(column_ifexists('ExpirationDate', datetime(null)), endofmonth(now())))
| extend CommitmentAmount = todouble(coalesce(column_ifexists('CommitmentAmount', real(null)), column_ifexists('OriginalAmount', real(null))))
| extend IsActive = iff(isnotnull(ExpirationDate) and ExpirationDate >= now(), 1, 0)
| top 1 by SourcePriority desc, IsActive desc, StartDate desc;
let StartDate = toscalar(MACCData | project StartDate);
let EndDate = toscalar(MACCData | project ExpirationDate);
let Commitment = toscalar(MACCData | project CommitmentAmount);
let TotalMonths = max_of(datetime_diff('month', EndDate, StartDate), 1);
let MonthlyTarget = Commitment / todouble(TotalMonths);
Costs
| where ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| summarize MonthlyConsumption = sum(EffectiveCost) by Month = startofmonth(ChargePeriodStart)
| order by Month asc
| extend ActualCumulative = row_cumsum(MonthlyConsumption)
| extend MonthIndex = row_number()
| extend LinearTarget = MonthlyTarget * todouble(MonthIndex)
| project Month, ActualCumulative = round(ActualCumulative, 0), LinearTarget = round(LinearTarget, 0)
```

## Tile: MACC Decrement by Subscription (Preview)

- Tile ID: mc02f3a4-b5c6-4d7e-8f9a-0b1c2d3e4f5a
- Visual: table
- Query ID: mc02f3a4-b5c6-4d7e-8f9a-0b1c2d3e4f5a

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: sum(EffectiveCost) | EffectiveCost = sum(EffectiveCost) by SubscriptionName
- Shapes output columns with project operations. Examples: SubscriptionName, EffectiveCost = round(EffectiveCost, 0), PercentOfTotal = strcat(PercentOfTotal, '%'), PercentOfCommitment = strcat(PercentOfCommitment, '%')
- Orders or ranks output for visualization. Examples: 1 by SourcePriority desc, IsActive desc, StartDate desc; | EffectiveCost desc

### KQL

```kql
// MACC Decrement by Subscription - Top subscriptions contributing to MACC consumption
let MACCData = union isfuzzy=true
    (MACC_Lots | extend DataSource = 'API', SourcePriority = 2),
    (MACC_Lots_raw | extend DataSource = 'API', SourcePriority = 2),
    (MACC_ManualEntry | extend DataSource = 'Manual', SourcePriority = 1),
    (print Description='No MACC data configured', Currency='', StartDate=datetime(null), ExpirationDate=datetime(null), CommitmentAmount=0.0, DataSource='Fallback', SourcePriority=0)
| extend StartDate = todatetime(coalesce(column_ifexists('StartDate', datetime(null)), column_ifexists('PurchasedDate', datetime(null)), startofmonth(now())))
| extend ExpirationDate = todatetime(coalesce(column_ifexists('ExpirationDate', datetime(null)), endofmonth(now())))
| extend CommitmentAmount = todouble(coalesce(column_ifexists('CommitmentAmount', real(null)), column_ifexists('OriginalAmount', real(null))))
| extend IsActive = iff(isnotnull(ExpirationDate) and ExpirationDate >= now(), 1, 0)
| top 1 by SourcePriority desc, IsActive desc, StartDate desc;
let StartDate = toscalar(MACCData | project StartDate);
let EndDate = toscalar(MACCData | project ExpirationDate);
let Commitment = toscalar(MACCData | project CommitmentAmount);
let TotalConsumed = toscalar(
    Costs
    | where ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate
    | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
    | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
    | summarize sum(EffectiveCost)
);
let TotalConsumed2 = iff(isnull(TotalConsumed), 0.0, TotalConsumed);
Costs
| where ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| extend SubscriptionName = coalesce(column_ifexists('SubAccountName', ''), 'Unknown')
| summarize EffectiveCost = sum(EffectiveCost) by SubscriptionName
| extend PercentOfTotal = round(100.0 * EffectiveCost / TotalConsumed2, 1)
| extend PercentOfCommitment = round(100.0 * EffectiveCost / Commitment, 1)
| order by EffectiveCost desc
| take 20
| project SubscriptionName, EffectiveCost = round(EffectiveCost, 0), PercentOfTotal = strcat(PercentOfTotal, '%'), PercentOfCommitment = strcat(PercentOfCommitment, '%')
```

## Tile: MACC Burn by Confidence Layer (Preview)

- Tile ID: mc03a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6b
- Visual: table
- Query ID: mc03a4b5-c6d7-4e8f-9a0b-1c2d3e4f5a6b

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 0),
- Shapes output columns with project operations. Examples: ConfidenceLayer, EffectiveCost, BilledCost, LineItems
- Orders or ranks output for visualization. Examples: 1 by SourcePriority desc, IsActive desc, StartDate desc; | ConfidenceLayer asc

### KQL

```kql
// MACC Burn by Confidence Layer - Classifies costs by MACC eligibility confidence
let MACCData = union isfuzzy=true
    (MACC_Lots | extend DataSource = 'API', SourcePriority = 2),
    (MACC_Lots_raw | extend DataSource = 'API', SourcePriority = 2),
    (MACC_ManualEntry | extend DataSource = 'Manual', SourcePriority = 1),
    (print Description='No MACC data configured', Currency='', StartDate=datetime(null), ExpirationDate=datetime(null), CommitmentAmount=0.0, DataSource='Fallback', SourcePriority=0)
| extend StartDate = todatetime(coalesce(column_ifexists('StartDate', datetime(null)), column_ifexists('PurchasedDate', datetime(null)), startofmonth(now())))
| extend ExpirationDate = todatetime(coalesce(column_ifexists('ExpirationDate', datetime(null)), endofmonth(now())))
| extend CommitmentAmount = todouble(coalesce(column_ifexists('CommitmentAmount', real(null)), column_ifexists('OriginalAmount', real(null))))
| extend IsActive = iff(isnotnull(ExpirationDate) and ExpirationDate >= now(), 1, 0)
| top 1 by SourcePriority desc, IsActive desc, StartDate desc;
let StartDate = toscalar(MACCData | project StartDate);
let EndDate = toscalar(MACCData | project ExpirationDate);
Costs
| where ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate
| extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
| where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
| extend ConfidenceLayer = case(
    ProviderName == 'Microsoft' and ChargeCategory == 'Usage'
        and not(tolower(ServiceName) has_any ('microsoft 365', 'dynamics 365', 'power bi', 'power apps', 'power automate', 'github')),
    'Layer 1: Native Azure (95%+)',
    ChargeCategory == 'Purchase' and isnotempty(column_ifexists('CommitmentDiscountId', '')),
    'Layer 2: Commitments (90%+)',
    ProviderName != 'Microsoft' and InvoiceIssuerName == 'Microsoft'
        and EffectiveCost > 0,
    'Layer 3: Marketplace (70-75%)',
    'Layer 4: Unclassified (review)')
| summarize
    EffectiveCost = round(sum(EffectiveCost), 0),
    BilledCost = round(sum(BilledCost), 0),
    LineItems = count()
    by ConfidenceLayer
| order by ConfidenceLayer asc
| project ConfidenceLayer, EffectiveCost, BilledCost, LineItems
```

## Tile: Presumed vs Actual Reconciliation (Preview)

- Tile ID: mc04b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7c
- Visual: multistat
- Query ID: mc04b5c6-d7e8-4f9a-0b1c-2d3e4f5a6b7c

### What this query does

- Reads from: Costs.
- Consumes shared variables: currencyFilter.
- Applies filters to narrow scope. Examples: ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate | isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
- Aggregates data with summarize. Examples: sum(EffectiveCost)
- Shapes output columns with project operations. Examples: json = pack_array( | Label = tostring(json.Label), Value = tostring(json.Value)
- Orders or ranks output for visualization. Examples: 1 by SourcePriority desc, IsActive desc, StartDate desc;
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
// Presumed vs Actual MACC Reconciliation
let MACCData = union isfuzzy=true
    (MACC_Lots | extend DataSource = 'API', SourcePriority = 2),
    (MACC_Lots_raw | extend DataSource = 'API', SourcePriority = 2),
    (MACC_ManualEntry | extend DataSource = 'Manual', SourcePriority = 1),
    (print Description='No MACC data configured', Currency='', StartDate=datetime(null), ExpirationDate=datetime(null), CommitmentAmount=0.0, DataSource='Fallback', SourcePriority=0)
| extend StartDate = todatetime(coalesce(column_ifexists('StartDate', datetime(null)), column_ifexists('PurchasedDate', datetime(null)), startofmonth(now())))
| extend ExpirationDate = todatetime(coalesce(column_ifexists('ExpirationDate', datetime(null)), endofmonth(now())))
| extend CommitmentAmount = todouble(coalesce(column_ifexists('CommitmentAmount', real(null)), column_ifexists('OriginalAmount', real(null))))
| extend ClosedBalance = todouble(coalesce(column_ifexists('ClosedBalance', real(null)), real(null)))
| extend IsActive = iff(isnotnull(ExpirationDate) and ExpirationDate >= now(), 1, 0)
| top 1 by SourcePriority desc, IsActive desc, StartDate desc;
let StartDate = toscalar(MACCData | project StartDate);
let EndDate = toscalar(MACCData | project ExpirationDate);
let Commitment = toscalar(MACCData | project CommitmentAmount);
let APIBalance = toscalar(MACCData | project ClosedBalance);
let APIConsumed = iff(isnotnull(APIBalance) and isnotnull(Commitment), Commitment - APIBalance, real(null));
let PresumedBurn = toscalar(
    Costs
    | where ChargePeriodStart >= StartDate and ChargePeriodStart < EndDate
    | extend CurrencyCode = tostring(coalesce(column_ifexists('BillingCurrency', ''), column_ifexists('PricingCurrency', '')))
    | where isnull(currencyFilter) or tostring(currencyFilter) in ('', '*', 'All', 'all') or CurrencyCode == tostring(currencyFilter)
    | summarize sum(EffectiveCost)
);
let PresumedBurn2 = iff(isnull(PresumedBurn), 0.0, PresumedBurn);
let GapAmount = iff(isnotnull(APIConsumed), PresumedBurn2 - APIConsumed, real(null));
let GapPercent = iff(isnotnull(APIConsumed) and APIConsumed > 0, round(100.0 * GapAmount / APIConsumed, 1), real(null));
let GapStatus = case(
    isnull(GapPercent), 'No API data',
    abs(GapPercent) <= 5.0, 'Normal (<= 5%)',
    abs(GapPercent) <= 10.0, 'Review (5-10%)',
    'Escalate (> 10%)');
print
    PresumedBurn = round(PresumedBurn2, 0),
    ActualDecrement = iff(isnotnull(APIConsumed), round(APIConsumed, 0), real(null)),
    Gap = iff(isnotnull(GapAmount), round(GapAmount, 0), real(null)),
    GapPct = iff(isnotnull(GapPercent), strcat(tostring(GapPercent), '%'), 'N/A'),
    GapStatus = GapStatus
| project json = pack_array(
    pack('Label', 'Presumed Burn (FOCUS)', 'Value', tostring(PresumedBurn)),
    pack('Label', 'Actual Decrement (API)', 'Value', iff(isnotnull(ActualDecrement), tostring(ActualDecrement), 'No API data')),
    pack('Label', 'Gap', 'Value', iff(isnotnull(Gap), tostring(Gap), 'N/A')),
    pack('Label', 'Gap %', 'Value', GapPct),
    pack('Label', 'Gap Status', 'Value', GapStatus))
| mv-expand json
| project Label = tostring(json.Label), Value = tostring(json.Value)
```

