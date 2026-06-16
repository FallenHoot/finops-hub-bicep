# Dashboard KQL Query Library

This library extracts every query in dashboards/dashboard-FinOps-hub_2.json into its own folder and compares referenced columns to the local FOCUS-style schema (Costs_final_v1_2).

## Files

- summary.json
- focus-comparison-summary.json
- queries/<nnn-...>/query.kql
- queries/<nnn-...>/metadata.json
- queries/<nnn-...>/README.md
- sheets/README.md (sheet-organized KQL with explanations)

## Query index

| # | Query ID | Primary tile | Assessment | Folder |
|---:|---|---|---|---|
| 1 | 152f2041-bbc1-41e4-b155-271b2e0cf6e9 | Cost last month | focus-aligned | [queries/001-cost-last-month-152f2041](queries/001-cost-last-month-152f2041/README.md) |
| 2 | bc24e050-f2b9-4b4a-a08d-69fc4a4bb95e | Cost over time | focus-aligned | [queries/002-cost-over-time-bc24e050](queries/002-cost-over-time-bc24e050/README.md) |
| 3 | 0d91ea4a-c81d-4a21-b708-b6af37be1eec | Change over time | focus-aligned | [queries/003-change-over-time-0d91ea4a](queries/003-change-over-time-0d91ea4a/README.md) |
| 4 | f2cecbb0-13f8-4642-afa4-bbcc0558f777 | Counts | focus-aligned | [queries/004-counts-f2cecbb0](queries/004-counts-f2cecbb0/README.md) |
| 5 | 5d63e04d-1a11-4307-96f1-ebbf68e09be0 | Counts (last n days) | focus-aligned | [queries/005-counts-last-n-days-5d63e04d](queries/005-counts-last-n-days-5d63e04d/README.md) |
| 6 | 290e7eab-8159-4338-8531-85e2718cedb1 | Effective cost | focus-aligned | [queries/006-effective-cost-290e7eab](queries/006-effective-cost-290e7eab/README.md) |
| 7 | d5ed469a-45ea-49a2-b305-b841050213cf | 3-month running total trend | focus-aligned | [queries/007-3-month-running-total-trend-d5ed469a](queries/007-3-month-running-total-trend-d5ed469a/README.md) |
| 8 | 10300876-866a-40d7-836d-b3a8783ecece | Running total - This month and last | focus-aligned | [queries/008-running-total-this-month-and-last-10300876](queries/008-running-total-this-month-and-last-10300876/README.md) |
| 9 | 9e41a624-d5f9-40c6-b47f-fef4b50ec3dd | 3-month daily trend | focus-aligned | [queries/009-3-month-daily-trend-9e41a624](queries/009-3-month-daily-trend-9e41a624/README.md) |
| 10 | f26e2204-270e-4219-8f68-5acef1c9393f | 3-month daily trend by subscription | focus-aligned | [queries/010-3-month-daily-trend-by-subscription-f26e2204](queries/010-3-month-daily-trend-by-subscription-f26e2204/README.md) |
| 11 | dcc1f533-e5f9-4855-9e4c-21e21fcdf943 | Cost + savings running total (this month and last) | focus-aligned | [queries/011-cost-savings-running-total-this-month-and-last-dcc1f533](queries/011-cost-savings-running-total-this-month-and-last-dcc1f533/README.md) |
| 12 | e8b343dc-7430-4487-8d44-ef48ac454f2d | Summary | focus-aligned | [queries/012-summary-e8b343dc](queries/012-summary-e8b343dc/README.md) |
| 13 | c077a6d4-719f-42fe-b39b-36f77dc68976 | Summary | focus-aligned | [queries/013-summary-c077a6d4](queries/013-summary-c077a6d4/README.md) |
| 14 | 9d6635cd-503a-49bc-80c8-ac8157c6e923 | Summary | focus-aligned | [queries/014-summary-9d6635cd](queries/014-summary-9d6635cd/README.md) |
| 15 | 3886b5cd-34a8-42d7-9e16-33ea4d236953 | Effective cost by subscription | focus-aligned | [queries/015-effective-cost-by-subscription-3886b5cd](queries/015-effective-cost-by-subscription-3886b5cd/README.md) |
| 16 | d5224d06-c8e7-4dd9-afec-595b39712f5a | Monthly trend by region | focus-aligned | [queries/016-monthly-trend-by-region-d5224d06](queries/016-monthly-trend-by-region-d5224d06/README.md) |
| 17 | 0dcf2c54-7f1d-45e9-a53b-d598a24493a4 | Monthly trend by region | focus-aligned | [queries/017-monthly-trend-by-region-0dcf2c54](queries/017-monthly-trend-by-region-0dcf2c54/README.md) |
| 18 | 30644718-defd-4c6c-9ffa-a9c2cd1f871f | Monthly trend by service name | focus-aligned | [queries/018-monthly-trend-by-service-name-30644718](queries/018-monthly-trend-by-service-name-30644718/README.md) |
| 19 | 6259f773-593c-4953-898c-15aa5ff6e53a | Monthly trend by service name | focus-aligned | [queries/019-monthly-trend-by-service-name-6259f773](queries/019-monthly-trend-by-service-name-6259f773/README.md) |
| 20 | 21a87abe-19e2-44ec-8298-ba872e66c162 | Monthly trend by subscription | focus-aligned | [queries/020-monthly-trend-by-subscription-21a87abe](queries/020-monthly-trend-by-subscription-21a87abe/README.md) |
| 21 | 90502e9a-2d0d-4ae4-8d9d-cc21f9b72d5d | Monthly trend by subscription | focus-aligned | [queries/021-monthly-trend-by-subscription-90502e9a](queries/021-monthly-trend-by-subscription-90502e9a/README.md) |
| 22 | c2c65ec0-e57d-4834-8a6b-b5975afeb9a0 | Monthly trend by resource group | focus-aligned | [queries/022-monthly-trend-by-resource-group-c2c65ec0](queries/022-monthly-trend-by-resource-group-c2c65ec0/README.md) |
| 23 | 61b26784-6a73-4e80-85b2-9c5cfbd2dd06 | Monthly trend by resource group | focus-aligned | [queries/023-monthly-trend-by-resource-group-61b26784](queries/023-monthly-trend-by-resource-group-61b26784/README.md) |
| 24 | 3924981c-23e4-464d-a872-045df1752750 | Monthly trend by resource | focus-aligned | [queries/024-monthly-trend-by-resource-3924981c](queries/024-monthly-trend-by-resource-3924981c/README.md) |
| 25 | c7be613e-deb4-4779-ad75-4445e8d5e01f | Monthly trend by resource | focus-aligned | [queries/025-monthly-trend-by-resource-c7be613e](queries/025-monthly-trend-by-resource-c7be613e/README.md) |
| 26 | 49e24ee0-91de-4b1c-973f-036a3c060aca | Daily trend by resource | focus-aligned | [queries/026-daily-trend-by-resource-49e24ee0](queries/026-daily-trend-by-resource-49e24ee0/README.md) |
| 27 | 4c7a7614-9b8c-415b-a4e1-d2d53c023d31 | Monthly trend by service category | focus-aligned | [queries/027-monthly-trend-by-service-category-4c7a7614](queries/027-monthly-trend-by-service-category-4c7a7614/README.md) |
| 28 | 1d273b55-d2ea-427c-8a5f-01f6c240e98a | Monthly trend by service category | focus-aligned | [queries/028-monthly-trend-by-service-category-1d273b55](queries/028-monthly-trend-by-service-category-1d273b55/README.md) |
| 29 | 90e30901-a931-4a1d-b81e-0a1821032c3c | Monthly trend by resource type | focus-aligned | [queries/029-monthly-trend-by-resource-type-90e30901](queries/029-monthly-trend-by-resource-type-90e30901/README.md) |
| 30 | ebe41e27-e9f9-478e-ab90-fd1f87906766 | Daily trend by resource type (last n days) | focus-aligned | [queries/030-daily-trend-by-resource-type-last-n-days-ebe41e27](queries/030-daily-trend-by-resource-type-last-n-days-ebe41e27/README.md) |
| 31 | a35b4c05-8ecb-4c51-9aaf-980af3d7923e | Most cost (last n days) | focus-aligned | [queries/031-most-cost-last-n-days-a35b4c05](queries/031-most-cost-last-n-days-a35b4c05/README.md) |
| 32 | 9c5d3cf0-b6cb-45a2-acfd-b19df425bddf | Most used (last n days) | focus-aligned | [queries/032-most-used-last-n-days-9c5d3cf0](queries/032-most-used-last-n-days-9c5d3cf0/README.md) |
| 33 | 2d7b6447-2769-40b8-958a-f252dab68b1e | Resource type summary (last n days) | focus-aligned | [queries/033-resource-type-summary-last-n-days-2d7b6447](queries/033-resource-type-summary-last-n-days-2d7b6447/README.md) |
| 34 | f062533b-8c94-412f-bf83-0eb5cd06063d | Resource inventory summary (last n days) | focus-aligned | [queries/034-resource-inventory-summary-last-n-days-f062533b](queries/034-resource-inventory-summary-last-n-days-f062533b/README.md) |
| 35 | 1d9c166d-22b6-48fd-9a90-9f983083ecc7 | Daily trend | focus-aligned | [queries/035-daily-trend-1d9c166d](queries/035-daily-trend-1d9c166d/README.md) |
| 36 | af6424d4-8f73-4b81-bfdd-f0287ebcaaca | SKUs with negotiated discounts (last n days) | focus-aligned | [queries/036-skus-with-negotiated-discounts-last-n-days-af6424d4](queries/036-skus-with-negotiated-discounts-last-n-days-af6424d4/README.md) |
| 37 | c4f6542d-a9cb-4284-bd4e-b9f94ad02192 | SKUs with commitment discounts (last n days) | focus-aligned | [queries/037-skus-with-commitment-discounts-last-n-days-c4f6542d](queries/037-skus-with-commitment-discounts-last-n-days-c4f6542d/README.md) |
| 38 | 00ae3917-c783-45f6-a04e-9113e4c5d445 | SKUs with no discounts (last n days) | focus-aligned | [queries/038-skus-with-no-discounts-last-n-days-00ae3917](queries/038-skus-with-no-discounts-last-n-days-00ae3917/README.md) |
| 39 | d8a4634e-7ebe-47ce-83b5-ff7f50f6bee6 | Most used SKUs (last n days) | focus-aligned | [queries/039-most-used-skus-last-n-days-d8a4634e](queries/039-most-used-skus-last-n-days-d8a4634e/README.md) |
| 40 | 98c9b9b5-bebf-41f8-8319-5fa2523f9dd0 | Purchases | focus-aligned | [queries/040-purchases-98c9b9b5](queries/040-purchases-98c9b9b5/README.md) |
| 41 | 35a3a2b3-4ab0-4449-96f7-c78db789089e | Purchases | focus-aligned | [queries/041-purchases-35a3a2b3](queries/041-purchases-35a3a2b3/README.md) |
| 42 | 5ff29428-de83-4a2c-8f86-d8beebe68750 | Cost summary | focus-aligned | [queries/042-cost-summary-5ff29428](queries/042-cost-summary-5ff29428/README.md) |
| 43 | f5f240a8-a818-4f27-bdfb-e96fcfe433bd | Savings summary | focus-aligned | [queries/043-savings-summary-f5f240a8](queries/043-savings-summary-f5f240a8/README.md) |
| 44 | d7f31381-ba44-46a1-ad3e-dc6b8826706d | Commitment discount usage (last n days) | focus-aligned | [queries/044-commitment-discount-usage-last-n-days-d7f31381](queries/044-commitment-discount-usage-last-n-days-d7f31381/README.md) |
| 45 | e17346d1-0227-4aa4-8765-f9b4bf43bed5 | Savings summary (last n months) | focus-aligned | [queries/045-savings-summary-last-n-months-e17346d1](queries/045-savings-summary-last-n-months-e17346d1/README.md) |
| 46 | f1ef29df-7a1d-4dd0-8619-0c0164707b31 | Savings summary (last n days) | focus-aligned | [queries/046-savings-summary-last-n-days-f1ef29df](queries/046-savings-summary-last-n-days-f1ef29df/README.md) |
| 47 | 7d0c2c1f-338b-4534-b173-36b284779131 | Commitment discount breakdown (last n months) | focus-aligned | [queries/047-commitment-discount-breakdown-last-n-months-7d0c2c1f](queries/047-commitment-discount-breakdown-last-n-months-7d0c2c1f/README.md) |
| 48 | 84ecad69-79ac-45b9-a8af-60be28dcc748 | Commitment discount breakdown (last n days) | focus-aligned | [queries/048-commitment-discount-breakdown-last-n-days-84ecad69](queries/048-commitment-discount-breakdown-last-n-days-84ecad69/README.md) |
| 49 | a7843e1d-7c76-4e4d-9a92-bc642d2f8506 | Monthly trend by service category | focus-aligned | [queries/049-monthly-trend-by-service-category-a7843e1d](queries/049-monthly-trend-by-service-category-a7843e1d/README.md) |
| 50 | 5bbb5369-ac95-45fc-853c-a6a2ce6a9e7b | Monthly savings trend | focus-aligned | [queries/050-monthly-savings-trend-5bbb5369](queries/050-monthly-savings-trend-5bbb5369/README.md) |
| 51 | 93f0eb9f-fa4d-4c54-96c2-8c1d3387d13a | Total savings (last n months) | focus-aligned | [queries/051-total-savings-last-n-months-93f0eb9f](queries/051-total-savings-last-n-months-93f0eb9f/README.md) |
| 52 | 5c442903-65b0-4b53-9e7c-3ea9c1af7be5 | Daily savings trend | focus-aligned | [queries/052-daily-savings-trend-5c442903](queries/052-daily-savings-trend-5c442903/README.md) |
| 53 | 9a9ee4b0-a37d-475f-bf1d-f51573243491 | Total savings (last n days) | focus-aligned | [queries/053-total-savings-last-n-days-9a9ee4b0](queries/053-total-savings-last-n-days-9a9ee4b0/README.md) |
| 54 | 377e3693-0738-45d7-97d9-4b6e71ec5b36 | Commitment discount chargeback by resource group | focus-aligned | [queries/054-commitment-discount-chargeback-by-resource-group-377e3693](queries/054-commitment-discount-chargeback-by-resource-group-377e3693/README.md) |
| 55 | 13cad52d-91e7-4ab4-aad5-4aae21c1019a | Commitment discount chargeback by subscription | focus-aligned | [queries/055-commitment-discount-chargeback-by-subscription-13cad52d](queries/055-commitment-discount-chargeback-by-subscription-13cad52d/README.md) |
| 56 | dcf69b47-233e-4bc4-b914-3f6f09f4cb82 | Commitment discount usage by resource (last n days) | focus-aligned | [queries/056-commitment-discount-usage-by-resource-last-n-day-dcf69b47](queries/056-commitment-discount-usage-by-resource-last-n-day-dcf69b47/README.md) |
| 57 | d7a9ff96-da17-4826-9fb5-b23f4c7b938d | Monthly trend by hub instance | focus-aligned | [queries/057-monthly-trend-by-hub-instance-d7a9ff96](queries/057-monthly-trend-by-hub-instance-d7a9ff96/README.md) |
| 58 | 13813a00-e634-4428-9eac-ea255fd1eaca | Daily trend by hub instance | focus-aligned | [queries/058-daily-trend-by-hub-instance-13813a00](queries/058-daily-trend-by-hub-instance-13813a00/README.md) |
| 59 | 62bbceee-c089-45db-822c-0b4745358aa4 | Monthly trend by hub instance | focus-aligned | [queries/059-monthly-trend-by-hub-instance-62bbceee](queries/059-monthly-trend-by-hub-instance-62bbceee/README.md) |
| 60 | b98c9ed7-47b3-41c1-a596-fd9d32725b33 | Ingested data by table | metadata-query | [queries/060-ingested-data-by-table-b98c9ed7](queries/060-ingested-data-by-table-b98c9ed7/README.md) |
| 61 | 187e22fe-3d78-45a2-a2bf-090ece144fd1 | Ingested cost data by scope | metadata-query | [queries/061-ingested-cost-data-by-scope-187e22fe](queries/061-ingested-cost-data-by-scope-187e22fe/README.md) |
| 62 | d2c522dc-ef4b-4714-a473-09350e275557 | Ingested scopes | metadata-query | [queries/062-ingested-scopes-d2c522dc](queries/062-ingested-scopes-d2c522dc/README.md) |
| 63 | 6fe11b78-82ef-4e9a-8411-a65e5b0d8bba | Ingested months | metadata-query | [queries/063-ingested-months-6fe11b78](queries/063-ingested-months-6fe11b78/README.md) |
| 64 | b3621977-59be-4f98-a034-a94479612115 | Ingested price data by scope | metadata-query | [queries/064-ingested-price-data-by-scope-b3621977](queries/064-ingested-price-data-by-scope-b3621977/README.md) |
| 65 | 4a2a77fe-e819-4059-b027-dab0a1770a0a | Ingested recommendation data by scope | metadata-query | [queries/065-ingested-recommendation-data-by-scope-4a2a77fe](queries/065-ingested-recommendation-data-by-scope-4a2a77fe/README.md) |
| 66 | 8f1ad1ef-6f5e-4f20-a1c4-3941e871d0cd | Ingested transaction data by scope | metadata-query | [queries/066-ingested-transaction-data-by-scope-8f1ad1ef](queries/066-ingested-transaction-data-by-scope-8f1ad1ef/README.md) |
| 67 | e9a9a135-6a74-4463-b69f-eac6930ff1f2 | Ingested commitment discount usage data by scope | metadata-query | [queries/067-ingested-commitment-discount-usage-data-by-scope-e9a9a135](queries/067-ingested-commitment-discount-usage-data-by-scope-e9a9a135/README.md) |
| 68 | 1a400b6c-9204-434d-88ff-2dc5260a95bf | Hybrid Benefit summary (last n days) | focus-aligned | [queries/068-hybrid-benefit-summary-last-n-days-1a400b6c](queries/068-hybrid-benefit-summary-last-n-days-1a400b6c/README.md) |
| 69 | c2ad5370-f4df-4a13-ac31-2c095f88754d | Underutilized vCPU capacity (last n days) | focus-aligned | [queries/069-underutilized-vcpu-capacity-last-n-days-c2ad5370](queries/069-underutilized-vcpu-capacity-last-n-days-c2ad5370/README.md) |
| 70 | 4614acfb-2288-4a71-97f7-32845a9ddcb2 | Fully utilized vCPU capacity (last n days) | focus-aligned | [queries/070-fully-utilized-vcpu-capacity-last-n-days-4614acfb](queries/070-fully-utilized-vcpu-capacity-last-n-days-4614acfb/README.md) |
| 71 | 99d44f1f-c53a-40ee-b749-8e5557ec58c7 | Eligible resources (last n days) | focus-aligned | [queries/071-eligible-resources-last-n-days-99d44f1f](queries/071-eligible-resources-last-n-days-99d44f1f/README.md) |
| 72 | 5fd3ea2a-8882-4438-9103-fa3945240604 | Forecast (next n days) | focus-aligned | [queries/072-forecast-next-n-days-5fd3ea2a](queries/072-forecast-next-n-days-5fd3ea2a/README.md) |
| 73 | e1bc2d51-44af-4dd9-8b0d-a71088b551f5 | Effective Savings Rate (last n months) | focus-aligned | [queries/073-effective-savings-rate-last-n-months-e1bc2d51](queries/073-effective-savings-rate-last-n-months-e1bc2d51/README.md) |
| 74 | 3b3f0a58-2d84-4e3e-bebc-3e747a7d5ede | Savings breakdown by month | focus-aligned | [queries/074-savings-breakdown-by-month-3b3f0a58](queries/074-savings-breakdown-by-month-3b3f0a58/README.md) |
| 75 | cb34f22b-9370-460c-9658-3e73d220bbc7 | Effective Savings Rate (last n days) | focus-aligned | [queries/075-effective-savings-rate-last-n-days-cb34f22b](queries/075-effective-savings-rate-last-n-days-cb34f22b/README.md) |
| 76 | 8de47213-8327-44da-9d1b-8ba5de74c44a | Ingested months | metadata-query | [queries/076-ingested-months-8de47213](queries/076-ingested-months-8de47213/README.md) |
| 77 | 0341b3e4-eccc-4924-9555-9835b128c543 | Effective cost breakdown by month | focus-aligned | [queries/077-effective-cost-breakdown-by-month-0341b3e4](queries/077-effective-cost-breakdown-by-month-0341b3e4/README.md) |
| 78 | 56fd8707-bbb3-4f7e-8e37-8dd90ada3baa | Summary of list, contracted, and effective cost alignment | focus-aligned | [queries/078-summary-of-list-contracted-and-effective-cost-al-56fd8707](queries/078-summary-of-list-contracted-and-effective-cost-al-56fd8707/README.md) |
| 79 | ed34de1f-3e00-467f-bc70-304e2c25262a | SaaS Spend Summary | focus-aligned | [queries/079-saas-spend-summary-ed34de1f](queries/079-saas-spend-summary-ed34de1f/README.md) |
| 80 | 891f3114-1466-42d7-8c3d-6f329ba9b816 | SaaS Spend by Month | focus-aligned | [queries/080-saas-spend-by-month-891f3114](queries/080-saas-spend-by-month-891f3114/README.md) |
| 81 | 61be1ce6-fd98-4961-bc00-ee23c5ade3eb | Top Publishers | focus-aligned | [queries/081-top-publishers-61be1ce6](queries/081-top-publishers-61be1ce6/README.md) |
| 82 | e2be6de9-ae28-46ca-a974-be2d014d4542 | Top Products | focus-aligned | [queries/082-top-products-e2be6de9](queries/082-top-products-e2be6de9/README.md) |
| 83 | 3159144e-e894-4fd3-9320-eeeaa5fabd0c | SaaS Spend by Subscription | focus-aligned | [queries/083-saas-spend-by-subscription-3159144e](queries/083-saas-spend-by-subscription-3159144e/README.md) |
| 84 | cf020001-3529-4e5f-6a7b-8c9d0e1f2a3b | Databricks Spend Summary (Preview) | focus-aligned | [queries/084-databricks-spend-summary-preview-cf020001](queries/084-databricks-spend-summary-preview-cf020001/README.md) |
| 85 | cf120001-3529-4e5f-6a7b-8c9d0e1f2a3b | Databricks Spend Summary | focus-aligned | [queries/085-databricks-spend-summary-cf120001](queries/085-databricks-spend-summary-cf120001/README.md) |
| 86 | cf020002-3529-4e5f-6a7b-8c9d0e1f2a3b | Fabric Spend Summary (Preview) | focus-aligned | [queries/086-fabric-spend-summary-preview-cf020002](queries/086-fabric-spend-summary-preview-cf020002/README.md) |
| 87 | cf120002-3529-4e5f-6a7b-8c9d0e1f2a3b | Fabric Spend Summary | focus-aligned | [queries/087-fabric-spend-summary-cf120002](queries/087-fabric-spend-summary-cf120002/README.md) |
| 88 | 886ef328-6a85-4f47-8a52-4261281a0c4f | Spot Summary | focus-aligned | [queries/088-spot-summary-886ef328](queries/088-spot-summary-886ef328/README.md) |
| 89 | 647bfaef-4a54-42c0-aaeb-186b8dea47ee | Pricing Category Breakdown | focus-aligned | [queries/089-pricing-category-breakdown-647bfaef](queries/089-pricing-category-breakdown-647bfaef/README.md) |
| 90 | e60a2844-d918-481a-81bc-ebf9bef4fd2c | Spot vs On-Demand Trend | focus-aligned | [queries/090-spot-vs-on-demand-trend-e60a2844](queries/090-spot-vs-on-demand-trend-e60a2844/README.md) |
| 91 | cf56343c-7597-43b7-bebe-4e86ea7d3da7 | Top Spot Resources | focus-aligned | [queries/091-top-spot-resources-cf56343c](queries/091-top-spot-resources-cf56343c/README.md) |
| 92 | d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a | MACC Current Status (Preview) | focus-aligned | [queries/092-macc-current-status-preview-d4e5f6a7](queries/092-macc-current-status-preview-d4e5f6a7/README.md) |
| 93 | f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c | Monthly Consumption Trend (Preview) | focus-aligned | [queries/093-monthly-consumption-trend-preview-f6a7b8c9](queries/093-monthly-consumption-trend-preview-f6a7b8c9/README.md) |
| 94 | b8c9d0e1-f2a3-4b4c-5d6e-7f8a9b0c1d2e | MACC Forecast (Preview) | focus-aligned | [queries/094-macc-forecast-preview-b8c9d0e1](queries/094-macc-forecast-preview-b8c9d0e1/README.md) |
| 95 | f2b3c4d5-1001-4a8b-9c0d-1e2f3a4b5c6d | Tag Coverage | focus-aligned | [queries/095-tag-coverage-f2b3c4d5](queries/095-tag-coverage-f2b3c4d5/README.md) |
| 96 | f2b3c4d5-1002-4a8b-9c0d-1e2f3a4b5c6d | Cost by tag key (last n months) | focus-aligned | [queries/096-cost-by-tag-key-last-n-months-f2b3c4d5](queries/096-cost-by-tag-key-last-n-months-f2b3c4d5/README.md) |
| 97 | f2b3c4d5-1003-4a8b-9c0d-1e2f3a4b5c6d | Cost by tag value (last n months) | focus-aligned | [queries/097-cost-by-tag-value-last-n-months-f2b3c4d5](queries/097-cost-by-tag-value-last-n-months-f2b3c4d5/README.md) |
| 98 | f2b3c4d5-1004-4a8b-9c0d-1e2f3a4b5c6d | Tag detail (last n months) | focus-aligned | [queries/098-tag-detail-last-n-months-f2b3c4d5](queries/098-tag-detail-last-n-months-f2b3c4d5/README.md) |
| 99 | f2b3c4d5-1005-4a8b-9c0d-1e2f3a4b5c6d | Monthly tag coverage trend | focus-aligned | [queries/099-monthly-tag-coverage-trend-f2b3c4d5](queries/099-monthly-tag-coverage-trend-f2b3c4d5/README.md) |
| 100 | a3b4c5d6-1001-4a9b-0c1d-2e3f4a5b6c7d | Subscription summary (last n months) | focus-aligned | [queries/100-subscription-summary-last-n-months-a3b4c5d6](queries/100-subscription-summary-last-n-months-a3b4c5d6/README.md) |
| 101 | a3b4c5d6-1002-4a9b-0c1d-2e3f4a5b6c7d | Cost by subscription (last n months) | focus-aligned | [queries/101-cost-by-subscription-last-n-months-a3b4c5d6](queries/101-cost-by-subscription-last-n-months-a3b4c5d6/README.md) |
| 102 | a3b4c5d6-1003-4a9b-0c1d-2e3f4a5b6c7d | Top resources by subscription (last n months) | focus-aligned | [queries/102-top-resources-by-subscription-last-n-months-a3b4c5d6](queries/102-top-resources-by-subscription-last-n-months-a3b4c5d6/README.md) |
| 103 | a3b4c5d6-1004-4a9b-0c1d-2e3f4a5b6c7d | Resource cost by service (last n months) | focus-aligned | [queries/103-resource-cost-by-service-last-n-months-a3b4c5d6](queries/103-resource-cost-by-service-last-n-months-a3b4c5d6/README.md) |
| 104 | a3b4c5d6-1005-4a9b-0c1d-2e3f4a5b6c7d | Resource cost by resource group (last n months) | focus-aligned | [queries/104-resource-cost-by-resource-group-last-n-months-a3b4c5d6](queries/104-resource-cost-by-resource-group-last-n-months-a3b4c5d6/README.md) |
| 105 | fc010002-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Current month projection | focus-aligned | [queries/105-current-month-projection-fc010002](queries/105-current-month-projection-fc010002/README.md) |
| 106 | fc010001-c4d5-4e6f-7a8b-9c0d1e2f3a4b | 90-day cost forecast | focus-aligned | [queries/106-90-day-cost-forecast-fc010001](queries/106-90-day-cost-forecast-fc010001/README.md) |
| 107 | fc010003-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Monthly forecast vs actual | focus-aligned | [queries/107-monthly-forecast-vs-actual-fc010003](queries/107-monthly-forecast-vs-actual-fc010003/README.md) |
| 108 | fc010004-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Projected cost by subscription | focus-aligned | [queries/108-projected-cost-by-subscription-fc010004](queries/108-projected-cost-by-subscription-fc010004/README.md) |
| 109 | fc010005-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Monthly cost trend | focus-aligned | [queries/109-monthly-cost-trend-fc010005](queries/109-monthly-cost-trend-fc010005/README.md) |
| 110 | 8e010001-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Cost efficiency KPIs (last month) | focus-aligned | [queries/110-cost-efficiency-kpis-last-month-8e010001](queries/110-cost-efficiency-kpis-last-month-8e010001/README.md) |
| 111 | 8e010002-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Cost efficiency by subscription | focus-aligned | [queries/111-cost-efficiency-by-subscription-8e010002](queries/111-cost-efficiency-by-subscription-8e010002/README.md) |
| 112 | 8e010005-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Monthly efficiency trend | focus-aligned | [queries/112-monthly-efficiency-trend-8e010005](queries/112-monthly-efficiency-trend-8e010005/README.md) |
| 113 | 8e010003-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Cost efficiency by resource group | focus-aligned | [queries/113-cost-efficiency-by-resource-group-8e010003](queries/113-cost-efficiency-by-resource-group-8e010003/README.md) |
| 114 | 8e010004-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Unit cost by resource type | focus-aligned | [queries/114-unit-cost-by-resource-type-8e010004](queries/114-unit-cost-by-resource-type-8e010004/README.md) |
| 115 | ba010001-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Budget vs actual | focus-aligned | [queries/115-budget-vs-actual-ba010001](queries/115-budget-vs-actual-ba010001/README.md) |
| 116 | ba010002-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Budget burn rate (this month) | focus-aligned | [queries/116-budget-burn-rate-this-month-ba010002](queries/116-budget-burn-rate-this-month-ba010002/README.md) |
| 117 | ba010003-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Budget variance by subscription | focus-aligned | [queries/117-budget-variance-by-subscription-ba010003](queries/117-budget-variance-by-subscription-ba010003/README.md) |
| 118 | c1910001-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Chargeback by tag value (last month) | focus-aligned | [queries/118-chargeback-by-tag-value-last-month-c1910001](queries/118-chargeback-by-tag-value-last-month-c1910001/README.md) |
| 119 | c1910002-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Showback by department (last 3 months) | focus-aligned | [queries/119-showback-by-department-last-3-months-c1910002](queries/119-showback-by-department-last-3-months-c1910002/README.md) |
| 120 | c3810001-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Cost by CPU architecture (last month) | focus-aligned | [queries/120-cost-by-cpu-architecture-last-month-c3810001](queries/120-cost-by-cpu-architecture-last-month-c3810001/README.md) |
| 121 | d4010001-c4d5-4e6f-7a8b-9c0d1e2f3a4b | Data quality warnings (last month) | focus-aligned | [queries/121-data-quality-warnings-last-month-d4010001](queries/121-data-quality-warnings-last-month-d4010001/README.md) |
| 122 | 0c030001-6800-4e5f-6a7b-8c9d0e1f2a3b | Cost by provider | focus-aligned | [queries/122-cost-by-provider-0c030001](queries/122-cost-by-provider-0c030001/README.md) |
| 123 | 0c030002-6800-4e5f-6a7b-8c9d0e1f2a3b | Monthly trend by provider | focus-aligned | [queries/123-monthly-trend-by-provider-0c030002](queries/123-monthly-trend-by-provider-0c030002/README.md) |
| 124 | 0c040001-5d01-4e5f-6a7b-8c9d0e1f2a3b | Top resources by provider (last n months) | focus-aligned | [queries/124-top-resources-by-provider-last-n-months-0c040001](queries/124-top-resources-by-provider-last-n-months-0c040001/README.md) |
| 125 | 0c040003-c191-4e5f-6a7b-8c9d0e1f2a3b | Cost by provider and invoice issuer | focus-aligned | [queries/125-cost-by-provider-and-invoice-issuer-0c040003](queries/125-cost-by-provider-and-invoice-issuer-0c040003/README.md) |
| 126 | 0c090001-c203-4e5f-6a7b-8c9d0e1f2a3b | Monthly cost by provider | focus-aligned | [queries/126-monthly-cost-by-provider-0c090001](queries/126-monthly-cost-by-provider-0c090001/README.md) |
| 127 | 0c090002-c203-4e5f-6a7b-8c9d0e1f2a3b | Daily cost by provider (last n days) | focus-aligned | [queries/127-daily-cost-by-provider-last-n-days-0c090002](queries/127-daily-cost-by-provider-last-n-days-0c090002/README.md) |
| 128 | 0c090003-c203-4e5f-6a7b-8c9d0e1f2a3b | Top services across providers | focus-aligned | [queries/128-top-services-across-providers-0c090003](queries/128-top-services-across-providers-0c090003/README.md) |
| 129 | 0c090004-c203-4e5f-6a7b-8c9d0e1f2a3b | Sub accounts by provider | focus-aligned | [queries/129-sub-accounts-by-provider-0c090004](queries/129-sub-accounts-by-provider-0c090004/README.md) |
| 130 | 0c090005-c203-4e5f-6a7b-8c9d0e1f2a3b | Savings rate by provider | focus-aligned | [queries/130-savings-rate-by-provider-0c090005](queries/130-savings-rate-by-provider-0c090005/README.md) |
| 131 | 35a9f1d0-3dd1-4ca5-b40b-47a104f48386 | Overall Maturity Score | focus-aligned | [queries/131-overall-maturity-score-35a9f1d0](queries/131-overall-maturity-score-35a9f1d0/README.md) |
| 132 | 782dcff0-e4bd-4279-8af0-c7e22bc2f02d | Capability Maturity Detail | focus-aligned | [queries/132-capability-maturity-detail-782dcff0](queries/132-capability-maturity-detail-782dcff0/README.md) |
| 133 | af60214c-a4d9-4d9f-8b61-a5ac3ed42960 | Improvement Recommendations | focus-aligned | [queries/133-improvement-recommendations-af60214c](queries/133-improvement-recommendations-af60214c/README.md) |
| 134 | e50149e0-aa35-4666-ac62-178904d8c719 | Cost by subscription (last month) | focus-aligned | [queries/134-cost-by-subscription-last-month-e50149e0](queries/134-cost-by-subscription-last-month-e50149e0/README.md) |
| 135 | 582a801f-88e7-4005-95bc-2d750473bdf5 | Monthly cost trend by subscription | focus-aligned | [queries/135-monthly-cost-trend-by-subscription-582a801f](queries/135-monthly-cost-trend-by-subscription-582a801f/README.md) |
| 136 | e975f824-6c9e-44ce-a539-083dadae47fd | Waste summary (last 30 days) | focus-aligned | [queries/136-waste-summary-last-30-days-e975f824](queries/136-waste-summary-last-30-days-e975f824/README.md) |
| 137 | 119e09db-a213-4ff2-95a9-da3894623da6 | Waste by detection rule | focus-aligned | [queries/137-waste-by-detection-rule-119e09db](queries/137-waste-by-detection-rule-119e09db/README.md) |
| 138 | a4e65583-94aa-498c-96cc-1155248a167e | Projected annual waste | focus-aligned | [queries/138-projected-annual-waste-a4e65583](queries/138-projected-annual-waste-a4e65583/README.md) |
| 139 | 69fedb94-871f-4cac-a171-56156c9ad7d0 | Orphaned resources detail | focus-aligned | [queries/139-orphaned-resources-detail-69fedb94](queries/139-orphaned-resources-detail-69fedb94/README.md) |
| 140 | ace6d8d9-df64-4a64-9b1c-55fcc7481eef | Monthly waste trend | focus-aligned | [queries/140-monthly-waste-trend-ace6d8d9](queries/140-monthly-waste-trend-ace6d8d9/README.md) |
| 141 | 5c84ca05-0265-4b47-ab19-4fa1cd79b542 | Cost by GPU family (last month) | focus-aligned | [queries/141-cost-by-gpu-family-last-month-5c84ca05](queries/141-cost-by-gpu-family-last-month-5c84ca05/README.md) |
| 142 | 43612ae4-c475-4f22-bb50-ce9d995abb8f | unbound-query | focus-aligned | [queries/142-unbound-query-43612ae4](queries/142-unbound-query-43612ae4/README.md) |
| 143 | cb1f5404-c0b1-42fd-99fb-3cff7b08daaa | unbound-query | focus-aligned | [queries/143-unbound-query-cb1f5404](queries/143-unbound-query-cb1f5404/README.md) |
| 144 | 4ce0f587-2d45-436c-8f79-102c6b382439 | unbound-query | focus-aligned | [queries/144-unbound-query-4ce0f587](queries/144-unbound-query-4ce0f587/README.md) |
| 145 | 6b598467-8c31-4693-b1eb-7ed683fcfc3a | unbound-query | focus-aligned | [queries/145-unbound-query-6b598467](queries/145-unbound-query-6b598467/README.md) |
| 146 | 4a1973bf-08e9-4e82-b8e6-6edff81cf0a5 | unbound-query | focus-aligned | [queries/146-unbound-query-4a1973bf](queries/146-unbound-query-4a1973bf/README.md) |
| 147 | eb9259cc-05b7-4441-a66d-a29026fe371b | unbound-query | focus-aligned | [queries/147-unbound-query-eb9259cc](queries/147-unbound-query-eb9259cc/README.md) |
| 148 | a0b1c2d3-68b1-4e5f-6a7b-8c9d0e1f2a3b | unbound-query | focus-aligned | [queries/148-unbound-query-a0b1c2d3](queries/148-unbound-query-a0b1c2d3/README.md) |
| 149 | a0b1c2d3-5a11-4e5f-6a7b-8c9d0e1f2a3b | unbound-query | focus-aligned | [queries/149-unbound-query-a0b1c2d3](queries/149-unbound-query-a0b1c2d3/README.md) |
| 150 | 7e010001-c4d5-4e6f-7a8b-9c0d1e2f3a4b | unbound-query | focus-aligned | [queries/150-unbound-query-7e010001](queries/150-unbound-query-7e010001/README.md) |
| 151 | 0c010001-3529-4e5f-6a7b-8c9d0e1f2a3b | unbound-query | focus-aligned | [queries/151-unbound-query-0c010001](queries/151-unbound-query-0c010001/README.md) |
| 152 | cf010001-3529-4e5f-6a7b-8c9d0e1f2a3b | unbound-query | focus-aligned | [queries/152-unbound-query-cf010001](queries/152-unbound-query-cf010001/README.md) |
| 153 | b5e9f0a8-2d3c-4b4e-c4a7-8e9f0a1b2c3d | Rightsizing recommendations summary | focus-aligned | [queries/153-rightsizing-recommendations-summary-b5e9f0a8](queries/153-rightsizing-recommendations-summary-b5e9f0a8/README.md) |
| 154 | d7a1b2c0-4f5e-4d6a-e6c9-0a1b2c3d4e5f | Top rightsizing recommendations | focus-aligned | [queries/154-top-rightsizing-recommendations-d7a1b2c0](queries/154-top-rightsizing-recommendations-d7a1b2c0/README.md) |
| 155 | f9c3d4e2-6b7a-4f8c-a8e1-2c3d4e5f6a7b | Est. savings by resource type | focus-aligned | [queries/155-est-savings-by-resource-type-f9c3d4e2](queries/155-est-savings-by-resource-type-f9c3d4e2/README.md) |
| 156 | 5d9101af-c2b0-4acf-abfa-be16bed80a69 | Databricks Spend by Month | focus-aligned | [queries/156-databricks-spend-by-month-5d9101af](queries/156-databricks-spend-by-month-5d9101af/README.md) |
| 157 | cd6c86fa-ea12-4b8a-a094-44963282cc8f | Top Databricks Products | focus-aligned | [queries/157-top-databricks-products-cd6c86fa](queries/157-top-databricks-products-cd6c86fa/README.md) |
| 158 | 9bbe203f-434e-472d-bc70-12707f5b9386 | Databricks Spend by Subscription | focus-aligned | [queries/158-databricks-spend-by-subscription-9bbe203f](queries/158-databricks-spend-by-subscription-9bbe203f/README.md) |
| 159 | 32c8d1ab-d976-4a57-a57c-57562d180897 | Fabric Spend by Month | focus-aligned | [queries/159-fabric-spend-by-month-32c8d1ab](queries/159-fabric-spend-by-month-32c8d1ab/README.md) |
| 160 | ccda6751-82d9-4854-963d-5e6af90ced41 | Top Fabric Products | focus-aligned | [queries/160-top-fabric-products-ccda6751](queries/160-top-fabric-products-ccda6751/README.md) |
| 161 | 109f2279-bec3-4f5b-b6ea-5575f412b868 | Fabric Spend by Subscription | focus-aligned | [queries/161-fabric-spend-by-subscription-109f2279](queries/161-fabric-spend-by-subscription-109f2279/README.md) |
| 162 | 8baecfdf-eedc-4ae1-9a4c-8d6a599ed539 | Cost by cloud region | focus-aligned | [queries/162-cost-by-cloud-region-8baecfdf](queries/162-cost-by-cloud-region-8baecfdf/README.md) |
