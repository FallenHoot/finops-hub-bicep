# Rate Optimization

- Page ID: 306fef9a-c760-4559-a326-7c25d196b616
- Tile count: 35

## Tile: On this page

- Tile ID: c0bd4bc4-a910-4a74-89a9-d4ae0f995563
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: fa177e0f-9a74-4475-b64d-a399224e96e0
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: (untitled tile)

- Tile ID: bd461109-e42e-4329-a4b9-16a83c1ad9b3
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Savings summary (last n months)

- Tile ID: 9513d9d7-be4a-468c-aed0-f0076c9bf3c4
- Visual: multistat
- Query ID: e17346d1-0227-4aa4-8765-f9b4bf43bed5

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: x_AmortizationClass != 'Principal'
- Aggregates data with summarize. Examples: ListCost = sum(ListCost),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[', | Label = tostring(json.label), Value = tostring(json.value), Type = tostring(json.type)
- Orders or ranks output for visualization. Examples: toint(json.order) asc
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = materialize(
    CostsByMonth
    //
    // Don't double-count commitment discount purchases
    | where x_AmortizationClass != 'Principal'
    //
    | summarize 
        ListCost = sum(ListCost),
        ContractedCost = sum(ContractedCost),
        EffectiveCost = sum(EffectiveCost)
    | extend NegotiatedDiscountDelta = iff(ListCost == 0, real(0), ListCost - ContractedCost)
    | extend CommitmentDiscountDelta = iff(ContractedCost == 0, real(0), ContractedCost - EffectiveCost)
    | extend TotalDiscountDelta = iff(ListCost == 0, real(0), ListCost - EffectiveCost)
    | project json = todynamic(strcat('[',
        '{ "order":11, "type":"List", "label":"Cost without discounts", "value":"', numberstring(round(ListCost, 2)), '" },',
        '{ "order":12, "type":"", "label":"", "value":"-" },',
        '{ "order":13, "type":"Contracted", "label":"After negotiated discounts", "value":"', numberstring(round(ContractedCost, 2)), '" },',
        '{ "order":14, "type":"", "label":"", "value":"=" },',
        '{ "order":15, "type":"PartialSavings", "label":"Negotiated discount delta", "value":"', numberstring(round(NegotiatedDiscountDelta, 2)), '" },',
        //
        '{ "order":21, "type":"Contracted", "label":"After negotiated discounts", "value":"', numberstring(round(ContractedCost, 2)), '" },',
        '{ "order":22, "type":"", "label":"", "value":"-" },',
        '{ "order":23, "type":"Effective", "label":"After commitment discounts", "value":"', numberstring(round(EffectiveCost, 2)), '" },',
        '{ "order":24, "type":"", "label":"", "value":"=" },',
        '{ "order":25, "type":"PartialSavings", "label":"Commitment discount delta", "value":"', numberstring(round(CommitmentDiscountDelta, 2)), '" },',
        //
        '{ "order":31, "type":"List", "label":"Cost without discounts", "value":"', numberstring(round(ListCost, 2)), '" },',
        '{ "order":32, "type":"", "label":"", "value":"-" },',
        '{ "order":33, "type":"Effective", "label":"After commitment discounts", "value":"', numberstring(round(EffectiveCost, 2)), '" },',
        '{ "order":34, "type":"", "label":"", "value":"=" },',
        '{ "order":35, "type":"TotalSavings", "label":"Total discount delta", "value":"', numberstring(round(TotalDiscountDelta, 2)), '" }',
    ']'))
    | mv-expand json
    | order by toint(json.order) asc
    | project Label = tostring(json.label), Value = tostring(json.value), Type = tostring(json.type)
);
data
```

## Tile: Commitment discount breakdown (last n months)

- Tile ID: e8018da4-7269-4e91-9f32-4bcf390746af
- Visual: multistat
- Query ID: 7d0c2c1f-338b-4534-b173-36b284779131

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: isnotempty(CommitmentDiscountStatus)
- Aggregates data with summarize. Examples: Value = sum(EffectiveCost), order = sum(order) by CommitmentDiscountStatus, CommitmentDiscountType
- Shapes output columns with project operations. Examples: Label = strcat(CommitmentDiscountStatus, ' ', tolower(CommitmentDiscountType), 's'), Value
- Orders or ranks output for visualization. Examples: order asc
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = materialize(
    CostsByMonth
    //
    | where isnotempty(CommitmentDiscountStatus)
    //
    // Guarantee there's a row for every combination
    | union (
        print json = dynamic([
            {"order": 11, "CommitmentDiscountType": "Reservation", "CommitmentDiscountStatus": "Used"},
            {"order": 12, "CommitmentDiscountType": "Reservation", "CommitmentDiscountStatus": "Unused"},
            {"order": 21, "CommitmentDiscountType": "Savings Plan", "CommitmentDiscountStatus": "Used"},
            {"order": 22, "CommitmentDiscountType": "Savings Plan", "CommitmentDiscountStatus": "Unused"}
        ])
        | mv-expand json
        | evaluate bag_unpack(json)
        | extend EffectiveCost = toreal(0)
    )
    //
    | summarize Value = sum(EffectiveCost), order = sum(order) by CommitmentDiscountStatus, CommitmentDiscountType
    | order by order asc
    | project Label = strcat(CommitmentDiscountStatus, ' ', tolower(CommitmentDiscountType), 's'), Value
);
data
```

## Tile: Effective Savings Rate (last n months)

- Tile ID: 961b8980-213f-4bc7-9512-8a08614229e0
- Visual: multistat
- Query ID: e1bc2d51-44af-4dd9-8b0d-a71088b551f5

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: x_AmortizationClass != 'Principal'
- Aggregates data with summarize. Examples: ListCost = sum(ListCost),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[', | Label = tostring(json.label), Value = tostring(json.value), Type = tostring(json.type)
- Orders or ranks output for visualization. Examples: toint(json.order) asc
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = materialize(
    CostsByMonth
    //
    // Don't double-count commitment discount purchases
    | where x_AmortizationClass != 'Principal'
    //
    | summarize 
        ListCost = sum(ListCost),
        ContractedCost = sum(ContractedCost),
        EffectiveCost = sum(EffectiveCost)
    | extend TotalSavings = ListCost - EffectiveCost
    | extend EffectiveSavingsRate = TotalSavings / ListCost
    | project json = todynamic(strcat('[',
        '{ "order":11, "type":"TotalSavings", "label":"Total savings", "value":"', numberstring(round(TotalSavings, 2)), '" },',
        '{ "order":12, "type":"", "label":"", "value":"/" },',
        '{ "order":13, "type":"List", "label":"Cost without discounts", "value":"', numberstring(round(ListCost, 2)), '" },',
        '{ "order":14, "type":"", "label":"", "value":"=" },',
        '{ "order":15, "type":"EffectiveSavingsRate", "label":"Effective savings rate", "value":"', percentstring(EffectiveSavingsRate), '" }',
    ']'))
    | mv-expand json
    | order by toint(json.order) asc
    | project Label = tostring(json.label), Value = tostring(json.value), Type = tostring(json.type)
);
data
```

## Tile: Total savings (last n months)

- Tile ID: 8f92a18b-9000-48f8-952a-5f21c535105c
- Visual: pie
- Query ID: 93f0eb9f-fa4d-4c54-96c2-8c1d3387d13a

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' or isempty(CommitmentDiscountId)
- Aggregates data with summarize. Examples: Savings = round(sum(ListCost - EffectiveCost), 2)

### KQL

```kql
CostsByMonth
//
// Filter out commitment discount purchases
| where ChargeCategory == 'Usage' or isempty(CommitmentDiscountId)
//
| summarize 
    Savings = round(sum(ListCost - EffectiveCost), 2)
    by
    Type = case(
        isnotempty(CommitmentDiscountType), CommitmentDiscountType,
        'Negotiated'
    )
```

## Tile: Monthly savings trend

- Tile ID: df06246e-5feb-4fd1-bcb0-c04448ac4c80
- Visual: stackedcolumn
- Query ID: 5bbb5369-ac95-45fc-853c-a6a2ce6a9e7b

### What this query does

- Reads from: CommitmentDiscountType.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' or isempty(CommitmentDiscountId)
- Aggregates data with summarize. Examples: ListCost = sum(ListCost),
- Shapes output columns with project operations. Examples: ChargePeriodStart,

### KQL

```kql
CostsByMonth
//
// Filter out commitment discount purchases
| where ChargeCategory == 'Usage' or isempty(CommitmentDiscountId)
//
| summarize 
    ListCost = sum(ListCost),
    ContractedCost = sum(ContractedCost),
    EffectiveCost = sum(EffectiveCost)
    by
    ChargePeriodStart = startofmonth(ChargePeriodStart),
    CommitmentDiscountType
| project
    ChargePeriodStart,
    Savings = round(ListCost - EffectiveCost, 2),
    Type = case(
        isnotempty(CommitmentDiscountType), CommitmentDiscountType,
        'Negotiated'
    )
```

## Tile: Savings breakdown by month

- Tile ID: 6367a5d7-99ca-4afc-b9d4-4c77ec259a07
- Visual: table
- Query ID: 3b3f0a58-2d84-4e3e-bebc-3e747a7d5ede

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: ['List cost']      = round(sumif(ListCost, x_AmortizationClass != 'Principal'), 2),
- Orders or ranks output for visualization. Examples: Month desc

### KQL

```kql
CostsByMonth
| extend x_AmortizationClass = case(
    ChargeCategory == 'Purchase' and isnotempty(CommitmentDiscountCategory), 'Principal',
    isnotempty(CommitmentDiscountCategory), 'Amortized Charge',
    ''
)
| extend x_CommitmentDiscountSavings = iff(ContractedCost == 0,      real(0), ContractedCost - EffectiveCost)
| extend x_NegotiatedDiscountSavings = iff(ListCost == 0,            real(0), ListCost - ContractedCost)
| extend x_TotalSavings              = iff(ListCost == 0,            real(0), ListCost - EffectiveCost)
| summarize
    ['List cost']      = round(sumif(ListCost, x_AmortizationClass != 'Principal'), 2),
    ['Effective cost'] = round(sum(EffectiveCost), 2),
    Savings            = round(sum(x_TotalSavings), 2)
    by
    Account = x_BillingProfileId,
    Month   = substring(startofmonth(ChargePeriodStart), 0, 7)
| extend ESR = percentstring(Savings/ ['List cost'])
| order by Month desc
```

## Tile: Effective cost breakdown by month

- Tile ID: 2e9d6a7f-6393-41ad-83df-51faddbe3b8e
- Visual: table
- Query ID: 0341b3e4-eccc-4924-9555-9835b128c543

### What this query does

- Reads from: CostsByMonth.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: ['On-demand']    = round(sumif(EffectiveCost, PricingCategory == 'Standard'), 2),
- Orders or ranks output for visualization. Examples: Month desc

### KQL

```kql
CostsByMonth
| extend x_AmortizationClass = case(
    ChargeCategory == 'Purchase' and isnotempty(CommitmentDiscountCategory), 'Principal',
    isnotempty(CommitmentDiscountCategory), 'Amortized Charge',
    ''
)
| extend x_CommitmentDiscountSavings = iff(ContractedCost == 0,      real(0), ContractedCost - EffectiveCost)
| extend x_NegotiatedDiscountSavings = iff(ListCost == 0,            real(0), ListCost - ContractedCost)
| extend x_TotalSavings              = iff(ListCost == 0,            real(0), ListCost - EffectiveCost)
| summarize
    ['On-demand']    = round(sumif(EffectiveCost, PricingCategory == 'Standard'), 2),
    Spot             = round(sumif(EffectiveCost, PricingCategory == 'Dynamic'), 2),
    Reservation      = round(sumif(EffectiveCost, CommitmentDiscountType == 'Reservation'), 2),
    ['Savings Plan'] = round(sumif(EffectiveCost, CommitmentDiscountType == 'Savings Plan'), 2),
    ['Other']        = round(sumif(EffectiveCost, PricingCategory !in ('Standard', 'Dynamic') and isempty(CommitmentDiscountType)), 2)
    by
    Account = x_BillingProfileId,
    Month   = substring(startofmonth(ChargePeriodStart), 0, 7)
| order by Month desc
```

## Tile: Monthly trend by service category

- Tile ID: e69fe03b-606c-4b93-b9b5-6f1048b24deb
- Visual: table
- Query ID: a7843e1d-7c76-4e4d-9a92-bc642d2f8506

### What this query does

- Reads from: CostsByMonth, data, per, ServiceName.
- Consumes shared variables: CostsByMonth.
- Aggregates data with summarize. Examples: EffectiveCost  = sum(EffectiveCost) | EffectiveCost  = sum(EffectiveCost)
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc | column_ifexists('Total', 0.0) desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let data = (
    CostsByMonth
    | summarize 
        EffectiveCost  = sum(EffectiveCost)
        by
        ChargePeriodStart,
        ServiceCategory,
        ServiceName
    | as per
    | union (
        per
        | summarize 
            EffectiveCost  = sum(EffectiveCost)
            by
            ServiceCategory,
            ServiceName
    )
    | order by ChargePeriodStart asc
    | extend EffectiveCost = todouble(round(EffectiveCost, 2))
    | extend ChargePeriod = iff(isempty(ChargePeriodStart), strcat('Total'), strcat(format_datetime(ChargePeriodStart, 'yyyy-MM - '), monthname[monthofyear(ChargePeriodStart)]))
);
data | evaluate pivot(ChargePeriod, sum(EffectiveCost), ServiceCategory)
| order by column_ifexists('Total', 0.0) desc
```

## Tile: (untitled tile)

- Tile ID: 40a4e89e-e521-4fb1-bdca-95166b7c9267
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Savings summary (last n days)

- Tile ID: 9aec9f5c-f7cc-48da-8f0d-303137623945
- Visual: multistat
- Query ID: f1ef29df-7a1d-4dd0-8619-0c0164707b31

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' or isempty(CommitmentDiscountId)
- Aggregates data with summarize. Examples: ListCost = sum(ListCost),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[', | Label = tostring(json.label), Value = tostring(json.value), Type = tostring(json.type)
- Orders or ranks output for visualization. Examples: toint(json.order) asc
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = materialize(
    CostsByDay
    //
    // Don't double-count commitment discount purchases
    | where ChargeCategory == 'Usage' or isempty(CommitmentDiscountId)
    //
    | summarize 
        ListCost = sum(ListCost),
        ContractedCost = sum(ContractedCost),
        EffectiveCost = sum(EffectiveCost)
    | extend NegotiatedDiscountDelta = iff(ListCost == 0, real(0), ListCost - ContractedCost)
    | extend CommitmentDiscountDelta = iff(ContractedCost == 0, real(0), ContractedCost - EffectiveCost)
    | extend TotalDiscountDelta = iff(ListCost == 0, real(0), ListCost - EffectiveCost)
    | project json = todynamic(strcat('[',
        '{ "order":11, "type":"List", "label":"Cost without discounts", "value":"', numberstring(round(ListCost, 2)), '" },',
        '{ "order":12, "type":"", "label":"", "value":"-" },',
        '{ "order":13, "type":"Contracted", "label":"After negotiated discounts", "value":"', numberstring(round(ContractedCost, 2)), '" },',
        '{ "order":14, "type":"", "label":"", "value":"=" },',
        '{ "order":15, "type":"PartialSavings", "label":"Negotiated discount delta", "value":"', numberstring(round(NegotiatedDiscountDelta, 2)), '" },',
        //
        '{ "order":21, "type":"Contracted", "label":"After negotiated discounts", "value":"', numberstring(round(ContractedCost, 2)), '" },',
        '{ "order":22, "type":"", "label":"", "value":"-" },',
        '{ "order":23, "type":"Effective", "label":"After commitment discounts", "value":"', numberstring(round(EffectiveCost, 2)), '" },',
        '{ "order":24, "type":"", "label":"", "value":"=" },',
        '{ "order":25, "type":"PartialSavings", "label":"Commitment discount delta", "value":"', numberstring(round(CommitmentDiscountDelta, 2)), '" },',
        //
        '{ "order":31, "type":"List", "label":"Cost without discounts", "value":"', numberstring(round(ListCost, 2)), '" },',
        '{ "order":32, "type":"", "label":"", "value":"-" },',
        '{ "order":33, "type":"Effective", "label":"After commitment discounts", "value":"', numberstring(round(EffectiveCost, 2)), '" },',
        '{ "order":34, "type":"", "label":"", "value":"=" },',
        '{ "order":35, "type":"TotalSavings", "label":"Total discount delta", "value":"', numberstring(round(TotalDiscountDelta, 2)), '" }',
    ']'))
    | mv-expand json
    | order by toint(json.order) asc
    | project Label = tostring(json.label), Value = tostring(json.value), Type = tostring(json.type)
);
data
```

## Tile: Commitment discount breakdown (last n days)

- Tile ID: 8dd83ee9-6692-4b94-a8c3-68caa7adbb64
- Visual: multistat
- Query ID: 84ecad69-79ac-45b9-a8af-60be28dcc748

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: isnotempty(CommitmentDiscountStatus)
- Aggregates data with summarize. Examples: Value = sum(EffectiveCost), order = sum(order) by CommitmentDiscountStatus, CommitmentDiscountType
- Shapes output columns with project operations. Examples: Label = strcat(CommitmentDiscountStatus, ' ', tolower(CommitmentDiscountType), 's'), Value
- Orders or ranks output for visualization. Examples: order asc
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = materialize(
    CostsByDay
    //
    // Don't double-count commitment discount purchases
    | where isnotempty(CommitmentDiscountStatus)
    //
    // Guarantee there's a row for every combination
    | union (
        print json = dynamic([
            {"order": 11, "CommitmentDiscountType": "Reservation", "CommitmentDiscountStatus": "Used"},
            {"order": 12, "CommitmentDiscountType": "Reservation", "CommitmentDiscountStatus": "Unused"},
            {"order": 21, "CommitmentDiscountType": "Savings Plan", "CommitmentDiscountStatus": "Used"},
            {"order": 22, "CommitmentDiscountType": "Savings Plan", "CommitmentDiscountStatus": "Unused"}
        ])
        | mv-expand json
        | evaluate bag_unpack(json)
        | extend EffectiveCost = toreal(0)
    )
    //
    | summarize Value = sum(EffectiveCost), order = sum(order) by CommitmentDiscountStatus, CommitmentDiscountType
    | order by order asc
    | project Label = strcat(CommitmentDiscountStatus, ' ', tolower(CommitmentDiscountType), 's'), Value
);
data
```

## Tile: Effective Savings Rate (last n days)

- Tile ID: 69e3a7e2-9477-4b63-8c86-9d66a782501b
- Visual: multistat
- Query ID: cb34f22b-9370-460c-9658-3e73d220bbc7

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: x_AmortizationClass != 'Principal'
- Aggregates data with summarize. Examples: ListCost = sum(ListCost),
- Shapes output columns with project operations. Examples: json = todynamic(strcat('[', | Label = tostring(json.label), Value = tostring(json.value), Type = tostring(json.type)
- Orders or ranks output for visualization. Examples: toint(json.order) asc
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
let data = materialize(
    CostsByDay
    //
    // Don't double-count commitment discount purchases
    | where x_AmortizationClass != 'Principal'
    //
    | summarize 
        ListCost = sum(ListCost),
        ContractedCost = sum(ContractedCost),
        EffectiveCost = sum(EffectiveCost)
    | extend TotalSavings = ListCost - EffectiveCost
    | extend EffectiveSavingsRate = TotalSavings / ListCost
    | project json = todynamic(strcat('[',
        '{ "order":11, "type":"TotalSavings", "label":"Total savings", "value":"', numberstring(round(TotalSavings, 2)), '" },',
        '{ "order":12, "type":"", "label":"", "value":"/" },',
        '{ "order":13, "type":"List", "label":"Cost without discounts", "value":"', numberstring(round(ListCost, 2)), '" },',
        '{ "order":14, "type":"", "label":"", "value":"=" },',
        '{ "order":15, "type":"EffectiveSavingsRate", "label":"Effective savings rate", "value":"', percentstring(EffectiveSavingsRate), '" }',
    ']'))
    | mv-expand json
    | order by toint(json.order) asc
    | project Label = tostring(json.label), Value = tostring(json.value), Type = tostring(json.type)
);
data
```

## Tile: Total savings (last n days)

- Tile ID: 088944a4-6cc6-4320-a8eb-82d35ee5b5d6
- Visual: pie
- Query ID: 9a9ee4b0-a37d-475f-bf1d-f51573243491

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' or isempty(CommitmentDiscountId)
- Aggregates data with summarize. Examples: Savings = round(sum(ListCost - EffectiveCost), 2)

### KQL

```kql
CostsByDay
//
// Filter out commitment discount purchases
| where ChargeCategory == 'Usage' or isempty(CommitmentDiscountId)
//
| summarize 
    Savings = round(sum(ListCost - EffectiveCost), 2)
    by
    Type = case(
        isnotempty(CommitmentDiscountType), CommitmentDiscountType,
        'Negotiated'
    )
```

## Tile: Daily savings trend

- Tile ID: b28fdb79-8d7a-414a-9da4-75ab9bffe134
- Visual: stackedcolumn
- Query ID: 5c442903-65b0-4b53-9e7c-3ea9c1af7be5

### What this query does

- Reads from: CommitmentDiscountType.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' or isempty(CommitmentDiscountId)
- Aggregates data with summarize. Examples: ListCost = sum(ListCost),
- Shapes output columns with project operations. Examples: ChargePeriodStart,

### KQL

```kql
CostsByDay
//
// Filter out commitment discount purchases
| where ChargeCategory == 'Usage' or isempty(CommitmentDiscountId)
//
| summarize 
    ListCost = sum(ListCost),
    ContractedCost = sum(ContractedCost),
    EffectiveCost = sum(EffectiveCost)
    by
    ChargePeriodStart = startofday(ChargePeriodStart),
    CommitmentDiscountType
| project
    ChargePeriodStart,
    Savings = round(ListCost - EffectiveCost, 2),
    Type = case(
        isnotempty(CommitmentDiscountType), CommitmentDiscountType,
        'Negotiated'
    )
```

## Tile: (untitled tile)

- Tile ID: cad5d666-02e8-4319-bbad-1bdf46ca2961
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Commitment discount usage (last n days)

- Tile ID: 36c1dede-49c9-4ae3-a19a-a230f87e9197
- Visual: table
- Query ID: d7f31381-ba44-46a1-ad3e-dc6b8826706d

### What this query does

- Reads from: CostsByDay.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' | isnotempty(CommitmentDiscountId)
- Aggregates data with summarize. Examples: CommitmentDiscountName = take_any(CommitmentDiscountName),
- Shapes output columns with project operations. Examples: CommitmentDiscountName,
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
CostsByDay
| where ChargeCategory == 'Usage'
| where isnotempty(CommitmentDiscountId)
//
| extend x_CommitmentDiscountUtilizationPotential = case(
    ProviderName == 'Microsoft' and isnotempty(CommitmentDiscountCategory), EffectiveCost,
    CommitmentDiscountCategory == 'Usage', ConsumedQuantity,
    CommitmentDiscountCategory == 'Spend', EffectiveCost,
    real(0)
)
| extend x_CommitmentDiscountUtilizationAmount = iff(CommitmentDiscountStatus == 'Used', x_CommitmentDiscountUtilizationPotential, real(0))
//
| summarize
    CommitmentDiscountName = take_any(CommitmentDiscountName),
    CommitmentDiscountType = take_any(CommitmentDiscountType),
    x_SkuTerm = take_any(x_SkuTerm),
    ListCost = sum(ListCost),
    ContractedCost = sum(ContractedCost),
    EffectiveCost = sum(EffectiveCost),
    x_CommitmentDiscountUtilizationAmount    = sum(x_CommitmentDiscountUtilizationAmount),
    x_CommitmentDiscountUtilizationPotential = sum(x_CommitmentDiscountUtilizationPotential)
    by
    CommitmentDiscountId
| order by EffectiveCost desc
| project
    CommitmentDiscountName,
    CommitmentDiscountType,
    Term = case(isempty(x_SkuTerm) or x_SkuTerm <= 0, '', x_SkuTerm < 12, strcat(x_SkuTerm, ' month', iff(x_SkuTerm != 1, 's', '')), strcat(x_SkuTerm / 12, ' year', iff(x_SkuTerm != 12, 's', ''))),
    Utilization = round(x_CommitmentDiscountUtilizationAmount / x_CommitmentDiscountUtilizationPotential * 100, 1),
    Cost = round(EffectiveCost, 2),
    Savings = round(ListCost - EffectiveCost, 2)

```

## Tile: (untitled tile)

- Tile ID: cee8e33c-bb08-4f48-9c8e-c785985d16e5
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Commitment discount chargeback by subscription

- Tile ID: e22f49e5-766c-4b35-8b4c-b99bef142d42
- Visual: table
- Query ID: 13cad52d-91e7-4ab4-aad5-4aae21c1019a

### What this query does

- Reads from: CommitmentDiscountStatus, CostsByMonth, data, per.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' | isnotempty(CommitmentDiscountId)
- Aggregates data with summarize. Examples: BilledCost     = sum(BilledCost), | BilledCost     = sum(BilledCost),
- Shapes output columns with project operations. Examples: Count
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc | SubAccountName asc, column_ifexists('Total', 0.0) desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let data = (
    CostsByMonth
    | where ChargeCategory == 'Usage'
    | where isnotempty(CommitmentDiscountId)
    | where EffectiveCost != 0
    | summarize 
        BilledCost     = sum(BilledCost),
        EffectiveCost  = sum(EffectiveCost),
        ContractedCost = sum(ContractedCost),
        ListCost       = sum(ListCost),
        SubAccountName = take_anyif(SubAccountName, isnotempty(SubAccountId)),
        CommitmentDiscountName = take_any(CommitmentDiscountName),
        CommitmentDiscountType = take_any(CommitmentDiscountType)
        by
        ChargePeriodStart,
        SubAccountId,
        CommitmentDiscountId,
        CommitmentDiscountStatus
    | as per
    | union (
        per
        | summarize 
            BilledCost     = sum(BilledCost),
            EffectiveCost  = sum(EffectiveCost),
            ContractedCost = sum(ContractedCost),
            ListCost       = sum(ListCost),
            SubAccountName = take_anyif(SubAccountName, isnotempty(SubAccountId)),
            CommitmentDiscountName = take_any(CommitmentDiscountName),
            CommitmentDiscountType = take_any(CommitmentDiscountType)
            by
            SubAccountId,
            CommitmentDiscountId,
            CommitmentDiscountStatus
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
    | extend SubAccountName = iff(isempty(SubAccountName) and CommitmentDiscountStatus == 'Unused', '(Unused)', SubAccountName)
);
percent((
    data | evaluate pivot(ChargePeriod, sum(EffectiveCost), SubAccountName, CommitmentDiscountName, CommitmentDiscountType)
    | extend Count = tolong(column_ifexists('Total', 0.0) * 1000)
))
| project-away Count
| order by SubAccountName asc, column_ifexists('Total', 0.0) desc
```

## Tile: (untitled tile)

- Tile ID: fad3f76a-1c81-4c4f-8787-99da226100d1
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Commitment discount chargeback by resource group

- Tile ID: b2c319c7-0ef0-477b-a80f-9b6e022b7e5e
- Visual: table
- Query ID: 377e3693-0738-45d7-97d9-4b6e71ec5b36

### What this query does

- Reads from: CommitmentDiscountStatus, CostsByMonth, data, per.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' | isnotempty(CommitmentDiscountId)
- Aggregates data with summarize. Examples: EffectiveCost  = sum(EffectiveCost), | EffectiveCost  = sum(EffectiveCost),
- Shapes output columns with project operations. Examples: Count
- Orders or ranks output for visualization. Examples: ChargePeriodStart asc | x_ResourceGroupName asc, SubAccountName asc, column_ifexists('Total', 0.0) desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
let data = (
    CostsByMonth
    | where ChargeCategory == 'Usage'
    | where isnotempty(CommitmentDiscountId)
    | where EffectiveCost != 0
    | extend x_ResourceGroupId = strcat(SubAccountId, '/resourcegroups/', x_ResourceGroupName)
    | summarize 
        EffectiveCost  = sum(EffectiveCost),
        SubAccountName = take_anyif(SubAccountName, isnotempty(SubAccountId)),
        x_ResourceGroupName = take_any(x_ResourceGroupName),
        CommitmentDiscountName = take_any(CommitmentDiscountName),
        CommitmentDiscountType = take_any(CommitmentDiscountType)
        by
        ChargePeriodStart,
        SubAccountId,
        x_ResourceGroupId,
        CommitmentDiscountId,
        CommitmentDiscountStatus
    | as per
    | union (
        per
        | summarize 
            EffectiveCost  = sum(EffectiveCost),
            SubAccountName = take_anyif(SubAccountName, isnotempty(SubAccountId)),
            x_ResourceGroupName = take_any(x_ResourceGroupName),
            CommitmentDiscountName = take_any(CommitmentDiscountName),
            CommitmentDiscountType = take_any(CommitmentDiscountType)
            by
            x_ResourceGroupId,
            CommitmentDiscountId,
            CommitmentDiscountStatus
    )
    | order by ChargePeriodStart asc
    | extend EffectiveCost = todouble(round(EffectiveCost, 2))
    | extend ChargePeriod = iff(isempty(ChargePeriodStart), strcat('Total'), strcat(format_datetime(ChargePeriodStart, 'yyyy-MM - '), monthname[monthofyear(ChargePeriodStart)]))
    | extend x_ResourceGroupName = iff(isempty(x_ResourceGroupName) and CommitmentDiscountStatus == 'Unused', '(Unused)', x_ResourceGroupName)
    | extend SubAccountName = iff(isempty(SubAccountName) and CommitmentDiscountStatus == 'Unused', '(Unused)', SubAccountName)
);
percent((
    data | evaluate pivot(ChargePeriod, sum(EffectiveCost), x_ResourceGroupName, SubAccountName, CommitmentDiscountName, CommitmentDiscountType)
    | extend Count = tolong(column_ifexists('Total', 0.0) * 1000)
))
| project-away Count
| order by x_ResourceGroupName asc, SubAccountName asc, column_ifexists('Total', 0.0) desc
```

## Tile: (untitled tile)

- Tile ID: 6e4a3743-e023-4fbc-a34d-43c08f201c6e
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Commitment discount usage by resource (last n days)

- Tile ID: c7e80308-bbb1-4aa8-a3d7-ce9eb0145f92
- Visual: table
- Query ID: dcf69b47-233e-4bc4-b914-3f6f09f4cb82

### What this query does

- Reads from: CommitmentDiscountId, CostsByDay.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Usage' | isnotempty(CommitmentDiscountId)
- Aggregates data with summarize. Examples: EffectiveCost  = sum(EffectiveCost),
- Shapes output columns with project operations. Examples: CommitmentDiscountType,
- Orders or ranks output for visualization. Examples: CommitmentDiscountType asc, CommitmentDiscountName asc, ResourceName asc, ResourceType asc, x_ResourceGroupName asc, SubAccountName asc, EffectiveCost desc

### KQL

```kql
CostsByDay
| where ChargeCategory == 'Usage'
| where isnotempty(CommitmentDiscountId)
| where EffectiveCost != 0
| summarize 
    EffectiveCost  = sum(EffectiveCost),
    ResourceName = take_any(ResourceName),
    ResourceType = take_any(ResourceType),
    RegionName = take_any(RegionName),
    x_ResourceGroupName = take_any(x_ResourceGroupName),
    SubAccountName = take_any(SubAccountName),
    CommitmentDiscountName = take_any(CommitmentDiscountName),
    CommitmentDiscountType = take_any(CommitmentDiscountType)
    by
    ResourceId,
    CommitmentDiscountId
| project 
    CommitmentDiscountType,
    CommitmentDiscountName,
    ResourceName,
    ResourceType,
    RegionName,
    x_ResourceGroupName,
    SubAccountName,
    EffectiveCost = round(EffectiveCost, 2)
| order by CommitmentDiscountType asc, CommitmentDiscountName asc, ResourceName asc, ResourceType asc, x_ResourceGroupName asc, SubAccountName asc, EffectiveCost desc
```

## Tile: (untitled tile)

- Tile ID: 6ea8b37d-617b-47dd-add0-8e3c0f708540
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Purchases

- Tile ID: 84da605b-6a0d-4a2a-aac3-a4160f9de10d
- Visual: table
- Query ID: 35a3a2b3-4ab0-4449-96f7-c78db789089e

### What this query does

- Reads from: costs, CostsByMonth, x_SkuOrderId.
- Consumes shared variables: CostsByMonth.
- Applies filters to narrow scope. Examples: ChargeCategory == 'Purchase' | isnotempty(CommitmentDiscountType)
- Aggregates data with summarize. Examples: x_CommitmentDiscountUtilizationAmount    = sum(x_CommitmentDiscountUtilizationAmount),
- Combines datasets with join operations. Examples: kind=leftouter (
- Shapes output columns with project operations. Examples: ChargePeriodStart = substring(ChargePeriodStart, 0, 10), | x_SkuOrderId,
- Orders or ranks output for visualization. Examples: ChargePeriodStart desc

### KQL

```kql
let monthname = dynamic(['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']);
CostsByMonth
| as costs
| where ChargeCategory == 'Purchase'
| where isnotempty(CommitmentDiscountType)
| project
    ChargePeriodStart = substring(ChargePeriodStart, 0, 10),
    x_SkuDescription,
    CommitmentDiscountType,
    Term = case(isempty(x_SkuTerm) or x_SkuTerm <= 0, '', x_SkuTerm < 12, strcat(x_SkuTerm, ' month', iff(x_SkuTerm != 1, 's', '')), strcat(x_SkuTerm / 12, ' year', iff(x_SkuTerm != 12, 's', ''))),
    ChargeFrequency,
    ChargeClass,
    PricingQuantity,
    Utilization = real(0),
    BilledCost,
    x_SkuOrderId
| join kind=leftouter (
    costs
    | where ChargeCategory == 'Usage'
    | where isnotempty(CommitmentDiscountId)
    //
    | extend x_CommitmentDiscountUtilizationPotential = case(
        ProviderName == 'Microsoft' and isnotempty(CommitmentDiscountCategory), EffectiveCost,
        CommitmentDiscountCategory == 'Usage', ConsumedQuantity,
        CommitmentDiscountCategory == 'Spend', EffectiveCost,
        real(0)
    )
    | extend x_CommitmentDiscountUtilizationAmount = iff(CommitmentDiscountStatus == 'Used', x_CommitmentDiscountUtilizationPotential, real(0))
    //
    | summarize
        x_CommitmentDiscountUtilizationAmount    = sum(x_CommitmentDiscountUtilizationAmount),
        x_CommitmentDiscountUtilizationPotential = sum(x_CommitmentDiscountUtilizationPotential)
        by
        x_SkuOrderId
    | project
        x_SkuOrderId,
        Utilization = round(x_CommitmentDiscountUtilizationAmount / x_CommitmentDiscountUtilizationPotential * 100, 1)
) on x_SkuOrderId
| extend Utilization = coalesce(Utilization1, real(0))
| project-away x_SkuOrderId, x_SkuOrderId1, Utilization1
| order by ChargePeriodStart desc



```

## Tile: (untitled tile)

- Tile ID: 5bd3258c-034c-4e23-b543-7cdf87bd153d
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: SKUs with negotiated discounts (last n days)

- Tile ID: 72aa5a62-e129-4ffa-be62-82c833282d27
- Visual: table
- Query ID: af6424d4-8f73-4b81-bfdd-f0287ebcaaca

### What this query does

- Reads from: CostsByDay, x_SkuTerm.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: isnotempty(x_SkuDescription) | x_EffectiveUnitPrice != 0 and isnotempty(x_EffectiveUnitPrice)
- Aggregates data with summarize. Examples: x_ResourceCount = dcount(ResourceId),
- Shapes output columns with project operations. Examples: x_SkuDescription,
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
CostsByDay
| where isnotempty(x_SkuDescription)
//
// Only include SKUs with effective prices
| where x_EffectiveUnitPrice != 0 and isnotempty(x_EffectiveUnitPrice)
//
// Only include SKUs with negotiated discounts and not commitment discounts
| where ListUnitPrice > x_EffectiveUnitPrice
| where isempty(CommitmentDiscountStatus)
//
| summarize 
    x_ResourceCount = dcount(ResourceId),
    EffectiveCost = round(sum(EffectiveCost), 2),
    BilledCost = round(sum(BilledCost), 2),
    ListUnitPrice = round(take_any(ListUnitPrice), 4),
    ContractedUnitPrice = round(take_any(ContractedUnitPrice), 4),
    x_EffectiveUnitPrice = round(take_any(x_EffectiveUnitPrice), 4),
    PricingQuantity = sum(PricingQuantity)
    by
    x_SkuDescription,
    PricingUnit,
    CommitmentDiscountType,
    x_SkuTerm
| order by EffectiveCost desc
| project 
    x_SkuDescription,
    // CommitmentDiscountType,
    // x_SkuTerm,
    Quantity = round(PricingQuantity, 4),
    Unit = PricingUnit,
    // Resources = x_ResourceCount,
    List = ListUnitPrice,
    // ContractedUnitPrice,
    // x_EffectiveUnitPrice,
    Discount = round(ListUnitPrice - x_EffectiveUnitPrice, 4),
    // BilledCost,
    Cost = EffectiveCost
| where Discount > 0

```

## Tile: Most used SKUs (last n days)

- Tile ID: a3d814b8-ff20-4919-ae2a-f1caec997edf
- Visual: bar
- Query ID: d8a4634e-7ebe-47ce-83b5-ff7f50f6bee6

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByDay, maxGroupCount.
- Applies filters to narrow scope. Examples: isnotempty(x_SkuDescription)
- Aggregates data with summarize. Examples: EffectiveCost = round(sum(EffectiveCost), 2) by SKU = x_SkuDescription
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
let doubleGroupCount = maxGroupCount * 2;
let costs = CostsByDay
| where isnotempty(x_SkuDescription)
;
let all = costs | summarize EffectiveCost = round(sum(EffectiveCost), 2) by x_SkuDescription;
let count = toscalar(all | count);
let topX = all | order by EffectiveCost desc | limit doubleGroupCount;
costs
//
// Group rows after max count
| extend inTopX = x_SkuDescription in (topX)
| extend x_SkuDescription = iff(inTopX, x_SkuDescription, strcat('(', (count - doubleGroupCount), ' others)'))
//
| summarize EffectiveCost = round(sum(EffectiveCost), 2) by SKU = x_SkuDescription
| order by EffectiveCost desc

```

## Tile: SKUs with commitment discounts (last n days)

- Tile ID: 3d7688f7-0a1c-4564-b851-f380a22817bf
- Visual: table
- Query ID: c4f6542d-a9cb-4284-bd4e-b9f94ad02192

### What this query does

- Reads from: CostsByDay, x_SkuTerm.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: isnotempty(x_SkuDescription) | x_EffectiveUnitPrice != 0 and isnotempty(x_EffectiveUnitPrice)
- Aggregates data with summarize. Examples: x_ResourceCount = dcount(ResourceId),
- Shapes output columns with project operations. Examples: x_SkuDescription,
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
CostsByDay
| where isnotempty(x_SkuDescription)
//
// Only include SKUs with effective prices
| where x_EffectiveUnitPrice != 0 and isnotempty(x_EffectiveUnitPrice)
//
// Only include SKUs with commitment discounts
| where isnotempty(CommitmentDiscountStatus)
// Guard: exclude rows where ListUnitPrice is missing (FOCUS gap for reservation usage)
| where ListUnitPrice > 0
//
| summarize 
    x_ResourceCount = dcount(ResourceId),
    EffectiveCost = round(sum(EffectiveCost), 2),
    BilledCost = round(sum(BilledCost), 2),
    ListUnitPrice = round(take_any(ListUnitPrice), 4),
    ContractedUnitPrice = round(take_any(ContractedUnitPrice), 4),
    x_EffectiveUnitPrice = round(take_any(x_EffectiveUnitPrice), 4),
    PricingQuantity = sum(PricingQuantity)
    by
    x_SkuDescription,
    PricingUnit,
    CommitmentDiscountType,
    x_SkuTerm
| order by EffectiveCost desc
| project 
    x_SkuDescription,
    CommitmentDiscountType,
    Term = case(
        isempty(x_SkuTerm) or x_SkuTerm <= 0, '',
        x_SkuTerm < 12, strcat(x_SkuTerm, ' month', iff(x_SkuTerm != 1, 's', '')),
        strcat(x_SkuTerm / 12, ' year', iff(x_SkuTerm != 12, 's', ''))
    ),
    Quantity = round(PricingQuantity, 4),
    Unit = PricingUnit,
    // Resources = x_ResourceCount,
    List = ListUnitPrice,
    // ContractedUnitPrice,
    // x_EffectiveUnitPrice,
    Discount = round(ListUnitPrice - x_EffectiveUnitPrice, 4),
    // BilledCost,
    Cost = EffectiveCost
//| where Discount > 0

```

## Tile: SKUs with no discounts (last n days)

- Tile ID: b2c9dcef-b40d-4dad-a0a3-cb5fe2c77156
- Visual: table
- Query ID: 00ae3917-c783-45f6-a04e-9113e4c5d445

### What this query does

- Reads from: CostsByDay, x_SkuTerm.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: isnotempty(x_SkuDescription) | x_EffectiveUnitPrice != 0 and isnotempty(x_EffectiveUnitPrice)
- Aggregates data with summarize. Examples: x_ResourceCount = dcount(ResourceId),
- Shapes output columns with project operations. Examples: x_SkuDescription,
- Orders or ranks output for visualization. Examples: EffectiveCost desc

### KQL

```kql
CostsByDay
| where isnotempty(x_SkuDescription)
//
// Only include SKUs with effective prices
| where x_EffectiveUnitPrice != 0 and isnotempty(x_EffectiveUnitPrice)
//
// Only include SKUs without any discounts
| where ListUnitPrice == x_EffectiveUnitPrice
| where isempty(CommitmentDiscountStatus)
//
| summarize 
    x_ResourceCount = dcount(ResourceId),
    EffectiveCost = round(sum(EffectiveCost), 2),
    BilledCost = round(sum(BilledCost), 2),
    ListUnitPrice = round(take_any(ListUnitPrice), 4),
    ContractedUnitPrice = round(take_any(ContractedUnitPrice), 4),
    x_EffectiveUnitPrice = round(take_any(x_EffectiveUnitPrice), 4),
    PricingQuantity = sum(PricingQuantity)
    by
    x_SkuDescription,
    PricingUnit,
    CommitmentDiscountType,
    x_SkuTerm
| order by EffectiveCost desc
| project 
    x_SkuDescription,
    // CommitmentDiscountType,
    // x_SkuTerm,
    Quantity = round(PricingQuantity, 4),
    Unit = PricingUnit,
    // Resources = x_ResourceCount,
    List = ListUnitPrice,
    // ContractedUnitPrice,
    // x_EffectiveUnitPrice,
    Discount = round(ListUnitPrice - x_EffectiveUnitPrice, 4),
    // BilledCost,
    Cost = EffectiveCost
| where Discount == 0

```

## Tile: (untitled tile)

- Tile ID: b7e1f2a3-4c5d-6e7f-8a9b-0c1d2e3f4a5b
- Visual: markdownCard
- Query ID: (none)

### What this query does

This tile does not reference a query in the queries collection.

## Tile: Disk tier cost comparison (last n days)

- Tile ID: c8f2a3b4-5d6e-7f8a-9b0c-1d2e3f4a5b6c
- Visual: multistat
- Query ID: d9a3b4c5-6e7f-8a9b-0c1d-2e3f4a5b6c7d

### What this query does

- Uses previously defined variables or helper query blocks as its primary input.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: x_ResourceType =~ 'Microsoft.Compute/disks' | isnotempty(x_SkuDescription)
- Shapes output columns with project operations. Examples: Label = tostring(Label), Value = tostring(Value)
- Expands or parses nested JSON-like structures before aggregation.

### KQL

```kql
// Disk tier cost comparison: Premium SSD v1 vs v2
let disks = CostsByDay
| where x_ResourceType =~ 'Microsoft.Compute/disks'
| where isnotempty(x_SkuDescription)
| extend DiskTier = case(
    x_SkuDescription has 'Premium SSD v2' or x_SkuMeterSubcategory has 'Premium SSD v2', 'Premium SSD v2',
    x_SkuDescription has 'Premium SSD' or x_SkuMeterSubcategory has 'Premium SSD', 'Premium SSD v1',
    x_SkuDescription has 'Standard SSD' or x_SkuMeterSubcategory has 'Standard SSD', 'Standard SSD',
    x_SkuDescription has 'Ultra' or x_SkuMeterSubcategory has 'Ultra Disk', 'Ultra Disk',
    x_SkuDescription has 'Standard HDD' or x_SkuMeterSubcategory has 'Standard HDD', 'Standard HDD',
    'Other'
);
let v1Cost = toscalar(disks | where DiskTier == 'Premium SSD v1' | summarize round(sum(EffectiveCost), 2));
let v2Cost = toscalar(disks | where DiskTier == 'Premium SSD v2' | summarize round(sum(EffectiveCost), 2));
let v1Count = toscalar(disks | where DiskTier == 'Premium SSD v1' | summarize dcount(ResourceId));
let v2Count = toscalar(disks | where DiskTier == 'Premium SSD v2' | summarize dcount(ResourceId));
let totalDiskCost = toscalar(disks | summarize round(sum(EffectiveCost), 2));
print json = pack_array(
    pack('Label', 'Premium SSD v1 cost', 'Value', iff(isnull(v1Cost), '0', tostring(v1Cost))),
    pack('Label', 'Premium SSD v1 disks', 'Value', iff(isnull(v1Count), '0', tostring(v1Count))),
    pack('Label', 'Premium SSD v2 cost', 'Value', iff(isnull(v2Cost), '0', tostring(v2Cost))),
    pack('Label', 'Premium SSD v2 disks', 'Value', iff(isnull(v2Count), '0', tostring(v2Count))),
    pack('Label', 'Total disk cost', 'Value', iff(isnull(totalDiskCost), '0', tostring(totalDiskCost)))
)
| mv-expand json
| evaluate bag_unpack(json)
| project Label = tostring(Label), Value = tostring(Value)

```

## Tile: Disk tier detail by SKU (last n days)

- Tile ID: d9a4b5c6-7e8f-9a0b-1c2d-3e4f5a6b7c8d
- Visual: table
- Query ID: e0b4c5d6-7f8a-9b0c-1d2e-3f4a5b6c7d8e

### What this query does

- Reads from: CostsByDay.
- Consumes shared variables: CostsByDay.
- Applies filters to narrow scope. Examples: x_ResourceType =~ 'Microsoft.Compute/disks' | isnotempty(x_SkuDescription)
- Aggregates data with summarize. Examples: DiskCount = dcount(ResourceId),
- Shapes output columns with project operations. Examples: Tier = DiskTier,
- Orders or ranks output for visualization. Examples: TotalCost desc

### KQL

```kql
// Disk tier detail by SKU
CostsByDay
| where x_ResourceType =~ 'Microsoft.Compute/disks'
| where isnotempty(x_SkuDescription)
| extend DiskTier = case(
    x_SkuDescription has 'Premium SSD v2' or x_SkuMeterSubcategory has 'Premium SSD v2', 'Premium SSD v2',
    x_SkuDescription has 'Premium SSD' or x_SkuMeterSubcategory has 'Premium SSD', 'Premium SSD v1',
    x_SkuDescription has 'Standard SSD' or x_SkuMeterSubcategory has 'Standard SSD', 'Standard SSD',
    x_SkuDescription has 'Ultra' or x_SkuMeterSubcategory has 'Ultra Disk', 'Ultra Disk',
    x_SkuDescription has 'Standard HDD' or x_SkuMeterSubcategory has 'Standard HDD', 'Standard HDD',
    'Other'
)
| summarize 
    DiskCount = dcount(ResourceId),
    TotalCost = round(sum(EffectiveCost), 2),
    ListCost = round(sum(ListCost), 2)
    by DiskTier, x_SkuDescription
| extend CostPerDisk = round(TotalCost / DiskCount, 2)
| extend ListDelta = round(ListCost - TotalCost, 2)
| order by TotalCost desc
| project 
    Tier = DiskTier,
    SKU = x_SkuDescription,
    Disks = DiskCount,
    [\"Effective cost\"] = TotalCost,
    [\"Cost / disk\"] = CostPerDisk,
    [\"List delta\"] = ListDelta

```

