# Bug Report: AHB Eligibility Query Labels Linux-priced VMs as Windows

- Date: 2026-06-22
- Area: Dashboard query logic
- Dashboard file: dashboards/dashboard-FinOps-hub_2.json
- Tile: Eligible resources (last n days)
- Query ID: 99d44f1f-c53a-40ee-b749-8e5557ec58c7
- Page: Licensing & SaaS (Preview)

## Summary
The Eligible resources query can present VMs as Windows licensing candidates even when the VM compute line is effectively Linux-priced. This causes wording confusion in customer-facing output and can overstate potential AHB opportunity.

## Customer Impact
- False-positive interpretation of AHB candidates.
- Customer confusion when VM naming or SKU metadata implies Windows, but unit price behavior aligns to Linux baseline.
- Reduced trust in the eligibility table for DevTest and mixed licensing scenarios.

## Reproduction Pattern
1. Use a subscription with DevTest or mixed VM licensing records.
2. Open tile Eligible resources (last n days).
3. Observe rows where Windows-associated metadata appears, but effective contracted unit price aligns with Linux price baseline.
4. Result: row appears as Windows AHB candidate despite Linux-rate charging behavior.

## Root Cause
Previous query path selected rows primarily from x_SkuLicenseStatus == 'Not Enabled' and projected license-oriented fields directly, without a robust Linux-price baseline comparison and meter-path cross-checking.

## Fix Implemented
Updated query 99d44f1f-c53a-40ee-b749-8e5557ec58c7 in dashboards/dashboard-FinOps-hub_2.json to:
- Build LinuxPrices baseline from Ingestion.Prices_final_v1_2 for VM consumption SKUs excluding Windows subcategory.
- Keep explicit Not Enabled path, but require compute contracted price (USD-normalized) to be above Linux baseline.
- Add VM License meter path for records where status is empty but license meter evidence exists.
- Exclude currently enabled resources via leftanti join on enabledVMs.
- Derive packs/cores and present wording as licensing usage guidance rather than hard Windows labeling.

## Validation
- Dashboard JSON parse: OK (ConvertFrom-Json)
- File diagnostics: no errors

## Recommended Product-Team Follow-up
1. Confirm whether additional filters are needed for non-Azure providers in this query.
2. Add unit/integration test coverage for:
   - DevTest mixed license scenarios
   - Linux-rate compute with Windows-like metadata
   - License meter present + empty status scenarios
3. Consider adding a confidence column to eligibility output (for explicit status path vs inferred meter path).

## Notes
This update is a logic and wording hardening change to reduce false positives and improve explainability.
