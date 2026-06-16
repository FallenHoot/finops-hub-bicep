# Forecast Enrichment (Preview)

- Page ID: 979769b6-1072-422e-a7d3-3ae24ee70970
- Tile count: 4

## Tile: Commitment burn by type

- Tile ID: 93c19a0c-9055-4eee-bf18-b1a4d6dbb1ec
- Visual: table
- Query ID: 8fa76309-d610-40aa-95b5-4b6fcb246d4a

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: BillingPeriodStart >= analysisStart | ChargeCategory == 'Purchase'
- Aggregates data with summarize. Examples: TotalCommitmentCharge = round(sum(BilledCost), 2), MonthsWithCharges = dcount(startofmonth(BillingPeriodStart)) by CommitmentType = coalesce(CommitmentDiscountType, 'Other purchases')
- Orders or ranks output for visualization. Examples: AvgMonthlyCommitmentBurn desc

### KQL

```kql
let lookbackMonths = 6;
let analysisStart = startofmonth(now(), -lookbackMonths);
CostsByMonth
| where BillingPeriodStart >= analysisStart
| where ChargeCategory == 'Purchase'
| summarize TotalCommitmentCharge = round(sum(BilledCost), 2), MonthsWithCharges = dcount(startofmonth(BillingPeriodStart)) by CommitmentType = coalesce(CommitmentDiscountType, 'Other purchases')
| extend AvgMonthlyCommitmentBurn = round(TotalCommitmentCharge / toreal(lookbackMonths), 2)
| order by AvgMonthlyCommitmentBurn desc
```

## Tile: Commitment burn trend

- Tile ID: d8bbf356-f32a-42ed-8de9-0195ed199a40
- Visual: column
- Query ID: 1c675228-2420-4f27-b1ac-3ff4191bdf22

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: BillingPeriodStart >= analysisStart | ChargeCategory == 'Purchase'
- Aggregates data with summarize. Examples: CommitmentBurn = round(sum(BilledCost), 2) by BillingPeriodStart = startofmonth(BillingPeriodStart), CommitmentType = coalesce(CommitmentDiscountType, 'Other purchases')
- Orders or ranks output for visualization. Examples: BillingPeriodStart asc

### KQL

```kql
let lookbackMonths = 6;
let analysisStart = startofmonth(now(), -lookbackMonths);
CostsByMonth
| where BillingPeriodStart >= analysisStart
| where ChargeCategory == 'Purchase'
| summarize CommitmentBurn = round(sum(BilledCost), 2) by BillingPeriodStart = startofmonth(BillingPeriodStart), CommitmentType = coalesce(CommitmentDiscountType, 'Other purchases')
| order by BillingPeriodStart asc
```

## Tile: Usage vs commitment mix

- Tile ID: f91c3496-ae9d-456e-8bd0-efe14958cb17
- Visual: bar
- Query ID: 64a2fc85-7054-43df-8b8b-58e26af98e22

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: BillingPeriodStart >= analysisStart | BillingPeriodStart >= analysisStart
- Aggregates data with summarize. Examples: sum(iif(ChargeCategory == 'Usage', todouble(BilledCost), 0.0)) | sum(iif(ChargeCategory == 'Purchase', todouble(BilledCost), 0.0))

### KQL

```kql
let lookbackMonths = 6;
let analysisStart = startofmonth(now(), -lookbackMonths);
let usageCost = toscalar(
    CostsByMonth
    | where BillingPeriodStart >= analysisStart
    | summarize sum(iif(ChargeCategory == 'Usage', todouble(BilledCost), 0.0))
);
let commitmentCost = toscalar(
    CostsByMonth
    | where BillingPeriodStart >= analysisStart
    | summarize sum(iif(ChargeCategory == 'Purchase', todouble(BilledCost), 0.0))
);
print SpendType = 'Usage', Amount = round(todouble(coalesce(usageCost, 0.0)), 2)
| union (print SpendType = 'Commitment purchases', Amount = round(todouble(coalesce(commitmentCost, 0.0)), 2))
```

## Tile: Forecast gap analysis

- Tile ID: 52f99b4c-3190-4086-8057-656cf0e73e4b
- Visual: table
- Query ID: d5e3631a-345b-4310-ac9b-b1970d694929

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: BillingPeriodStart >= lastMonthStart and BillingPeriodStart < thisMonthStart | ChargeCategory == 'Usage'
- Aggregates data with summarize. Examples: round(sum(BilledCost), 2) | round(sum(BilledCost), 2)

### KQL

```kql
let lookbackMonths = 6;
let analysisStart = startofmonth(now(), -lookbackMonths);
let lastMonthStart = startofmonth(now(), -1);
let thisMonthStart = startofmonth(now());
let usageLastMonth = toscalar(
    CostsByMonth
    | where BillingPeriodStart >= lastMonthStart and BillingPeriodStart < thisMonthStart
    | where ChargeCategory == 'Usage'
    | summarize round(sum(BilledCost), 2)
);
let commitmentLastMonth = toscalar(
    CostsByMonth
    | where BillingPeriodStart >= lastMonthStart and BillingPeriodStart < thisMonthStart
    | where ChargeCategory == 'Purchase'
    | summarize round(sum(BilledCost), 2)
);
let avgCommitmentBurn = toscalar(
    CostsByMonth
    | where BillingPeriodStart >= analysisStart and BillingPeriodStart < thisMonthStart
    | where ChargeCategory == 'Purchase'
    | summarize round(sum(BilledCost) / toreal(lookbackMonths), 2)
);
print Metric = 'Azure mid-month forecast proxy (usage only)', Amount = todouble(coalesce(usageLastMonth, 0.0)), Note = 'Matches the common portal behavior described by customers'
| union (print Metric = 'Historical commitment add-on', Amount = todouble(coalesce(avgCommitmentBurn, 0.0)), Note = 'Average purchase charges from the historical lookback window')
| union (print Metric = 'Expected monthly total', Amount = todouble(coalesce(usageLastMonth, 0.0) + coalesce(avgCommitmentBurn, 0.0)), Note = 'Usage proxy plus historical commitment burn')
| union (print Metric = 'Last month posted commitments', Amount = todouble(coalesce(commitmentLastMonth, 0.0)), Note = 'Sanity check against the most recent closed month')
```

