# Dashboard View Library

This library documents what each dashboard area is for, how to explain it to customers, and where confusion usually happens.

## AI provider onboarding

- AI provider FOCUS setup and ingestion guide: [AI-PROVIDER-FOCUS-SETUP.md](./AI-PROVIDER-FOCUS-SETUP.md)

## Current dashboard baseline

Last synced: **2026-09-21**

- Dashboard file: [dashboards/dashboard-FinOps-hub_2.json](../../../dashboards/dashboard-FinOps-hub_2.json)
- Pages: **17**
- Tiles: **235**
- Queries: **182**

## Page inventory

| Page | Tiles | Main intent |
|---|---:|---|
| About | 6 | Orientation and context |
| Summary | 17 | High-level FinOps health and trend signals |
| Cost Analysis | 42 | Cost drill-down by scope and dimensions |
| Rate Optimization | 40 | Commitment discounts, savings, ODCR financial waste and persistence, and efficiency |
| Planning & Budgeting | 22 | Forecasting, budget variance, and unit economics |
| Invoicing & Allocation | 17 | Showback/chargeback and tag coverage |
| Data Ingestion | 20 | Data freshness, coverage, and quality |
| MACC Tracking | 8 | Commitment tracking experiments |
| Project Budgets (Preview) | 3 | Budget experimentation by subscription/project |
| Orphaned Resources (Preview) | 6 | Waste and cleanup opportunities |
| Anomaly Management (Preview) | 7 | Spend anomaly detection, trend checks, and forecast monitoring |
| Licensing & SaaS (Preview) | 24 | Hybrid Benefit, SaaS marketplace, Databricks/Fabric preview coverage, and Spot optimization |
| Databricks (Preview) | 5 | Databricks marketplace and service cost coverage |
| Fabric (Preview) | 5 | Fabric marketplace and service cost coverage |
| Rightsizing (Preview) | 4 | Rightsizing opportunities and estimated savings |
| Forecast Enrichment (Preview) | 4 | Forecast gaps and commitment burn explainability |
| AI Billing (Preview) | 5 | AI service spend tracking and resource-level review |

## Top query variables that drive customer questions

| Variable | Query references | Why questions happen |
|---|---:|---|
| `currencyFilter` | 72 | Monetary visuals can switch between USD-normalized and billing-currency filtered views |
| `CostsByMonth` | 54 | Used across many pages with different grouping logic |
| `numberOfMonths` | 42 | Time-window assumptions are not always obvious |
| `CostsByDay` | 30 | Day-level granularity can conflict with billing period views |
| `maxGroupCount` | 23 | Top-N truncation can hide tail cost |
| `numberOfDays` | 13 | Short windows can distort trend interpretation |

## Standard customer explanation pattern

For every tile, document:

1. **What it shows** (plain-English definition)
2. **Why it matters** (decision impact)
3. **How to read it** (axes, filters, windows)
4. **Common misunderstandings**
5. **Next action when value is high/low/anomalous**

Use [dashboard-view.template.md](../templates/dashboard-view.template.md).

## ODCR financial optimization

The Rate Optimization ODCR section is the billing-backed financial view. It uses
FOCUS 1.2 fields derived by FinOps hub to show used and unused `EffectiveCost`,
unused cost share, daily cost trend, billed reservation resources, CRG ranking,
and isolated/recurring/persistent waste within the selected dashboard window.

Do not describe `UsedCost / TotalCost` as CRG utilization. The dashboard labels
that ratio `UsedCostShare`; operational utilization requires current allocation
from Capacity Reservation Group Instance View.

Use the standalone ODCR operations workbook for:

- reservation inventory, SKU, region, and zone from Azure Resource Graph;
- provider subscription, ownership tags, and sharing authorization;
- VM and VMSS references to the full CRG resource ID;
- current allocated units, available SLA-backed units, and overallocation from
	ARM Instance View for the selected CRG;
- direct Azure Cost Management actual cost for one selected subscription when
	FinOps hub is not used;
- governance findings such as missing ownership, sharing-limit pressure,
	provisioning failures, and empty CRGs.

Shared CRGs are Preview. Dashboard cost data can lag current resource state, and
currency values must not be combined unless they have already been normalized by
the selected dashboard currency mode. This repository is community-maintained
and is not officially supported by Microsoft.