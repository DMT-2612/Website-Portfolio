# Portfolio Case Study: ICMRA Fundraising Analytics Dashboard

## 1. Project Overview

The ICMRA Fundraising Analytics Dashboard is a strategic Business Intelligence project developed for the International Consortium for Medical Research Advancement, a medical research fundraising organisation with activity across contributors, campaigns, regions, referral sources, and research areas.

The project used fundraising data from 2019 to 2025 to create a Power BI decision-support solution for senior management. The main objective was to move beyond descriptive reporting and provide actionable insight into fundraising performance, contributor value, campaign efficiency, retention risk, and forward planning.

The final output included a strategic analytics report, Power BI dashboard, executive infographic, data quality documentation, semantic model design, and advanced analytics logic.

## 2. Business Context

ICMRA's leadership needed a clearer understanding of how fundraising performance was changing and where future growth should be managed. The organisation had multiple contributor types, campaign structures, research areas, and referral channels, but needed one consolidated view of performance and strategic risk.

The core business challenge was not simply to report total donations. The real challenge was to identify:

- Which funding patterns were sustainable.
- Which contributor groups were most valuable or at risk.
- Which campaigns delivered efficient return.
- Where dormant contributors represented recoverable value.
- What combination of growth levers could support future revenue targets.

This made the project highly relevant to business analysis and data analytics because the dashboard had to connect operational data with executive-level decisions.

## 3. Dataset and Preparation

The source dataset contained fundraising activity from 2019 to 2025, structured across a pledge-payment fact table and supporting dimension tables for accounts, campaigns, and contribution types.

The raw fact table contained 45,000 pledge-payment records. Data preparation was completed in Power Query to ensure transparency and reproducibility. Key cleaning steps included:

- Removing 7 exact duplicate pledge-payment records, leaving 44,993 cleaned fact rows.
- Correcting 5 malformed account ID values so fact records could match the account dimension.
- Removing 21 trailing blank records from the contribution lookup table.
- Standardising inconsistent account categories, including `Househld` to `Household`.
- Standardising `USA` to `United States`.
- Imputing 92 missing payment dates using campaign-level median payment lag.
- Retaining a `Payment Date Imputed` flag so imputed records remained auditable.

This data preparation step was important because downstream measures such as revenue, pledge count, RFM frequency, campaign ROI, retention, and CLV proxy would be unreliable if duplicate records, missing dates, or broken relationships remained unresolved.

## 4. Analytical Approach

The dashboard was designed around a Power BI star schema, with the pledge-payment table as the central fact table and account, campaign, contribution, and date tables as dimensions.

The analytical approach included several layers:

| Analysis Area | Purpose |
|---|---|
| Executive KPI monitoring | Track total pledges, contributors, average pledge, campaign achievement, and ROI. |
| Campaign performance | Compare revenue, target achievement, budget pressure, and return efficiency. |
| Contributor segmentation | Understand value by account type, segment, region, and funding capacity. |
| RFM analytics | Segment contributors by recency, frequency, and monetary value. |
| Cohort retention | Analyse whether contributors remained active after their first observed payment period. |
| CLV proxy | Compare historical contributor value using observed revenue, frequency, and lifetime. |
| Scenario planning | Test how changes in pledge value, giving frequency, and retention could affect revenue targets. |

Some techniques were intentionally scoped. CLV was treated as a historical proxy rather than a predictive lifetime value model because the dataset did not contain margin, discount rate, or formal churn probability. Market basket analysis was rejected because the dataset did not contain a valid basket or multi-item transaction structure.

## 5. Dashboard Structure

The final Power BI dashboard was organised into eight pages:

1. **Executive Overview**: Board-level KPI summary and fundraising trend.
2. **Campaign Performance**: Campaign achievement, budget, ROI, and funding drivers.
3. **Contributor Overview**: Contributor composition by account type, segment, capacity, and region.
4. **RFM Analytics**: Contributor value and behavioural segmentation.
5. **Cohort Analytics**: Retention by cohort and activity offset.
6. **CLV Analysis**: Historical contributor value and churn/inactivity indicators.
7. **Scenario Analysis**: What-if revenue modelling and goal-seeking logic.
8. **Executive Infographic**: One-page synthesis for senior leadership.

This structure separated each analytical technique into a dedicated page, reducing dashboard clutter and making the business purpose of each view clearer for non-technical stakeholders.

## 6. Key Insights

### Insight 1: Revenue Growth Was Strong but Not Stable

Annual pledge revenue increased from $1.36M in 2019 and $1.31M in 2020 to $8.50M in 2022 and $12.81M in 2023. However, revenue then fell by 78.3% to $2.79M in 2024 and remained almost flat at $2.76M in 2025.

This showed that 2023 should be treated as an exceptional peak rather than a reliable planning baseline. For senior management, the implication was that future targets should be rebased around sustainable capacity instead of assuming peak-year performance would repeat.

### Insight 2: Contributor Value Was Concentrated in Key Segments

RFM segmentation showed that Champions generated $6.9M, while Needs Attention and Loyal Donors generated approximately $11.0M combined.

This indicated that ICMRA's contributor portfolio contained both high-value secure segments and high-value vulnerable segments. The business issue was not only to identify top contributors, but to understand which valuable contributors were drifting and required intervention.

### Insight 3: Campaign Performance Was Uneven

Campaign analysis showed a strong imbalance in campaign return. General Oncology Research generated approximately $17M, while the next leading campaigns were materially lower.

The key management implication was that campaign performance should not be judged by revenue alone. Campaigns also consume budget, staff effort, and donor attention, so ICMRA should compare revenue, target achievement, and budget efficiency before scaling future campaign investment.

### Insight 4: Reactivation Was a Significant Growth Opportunity

The dashboard identified 1,353 contributors who returned after more than 365 days of inactivity. These reactivated contributors generated approximately $19.03M in revenue.

This reframed dormant contributors as a recoverable value pool, not only a retention problem. The strongest reactivation value came from segments such as Champions and Loyal Donors, showing that valuable relationships could lapse and later return.

### Insight 5: Dormant Contributors Still Represented Revenue Exposure

The analysis identified approximately $6.3M in dormant contributor value still tied to inactive contributors. The largest exposure was found in At Risk, General Contributors, Lost, and Needs Attention segments.

This converted retention risk into a measurable financial exposure. For management, the dashboard made it possible to prioritise recovery activity based on revenue value, not only contributor count.

### Insight 6: Balanced Growth Levers Reduced Target Risk

The scenario model showed that a +20% revenue target would require a full +20% uplift if management relied on only one driver: average pledge, giving frequency, or retention. However, the same target required approximately +6.27% improvement in each driver when growth was balanced across all three.

This supported a more realistic planning approach. Instead of depending on one large behavioural shift, ICMRA could distribute growth pressure across donation value, engagement frequency, and relationship retention.

## 7. Recommendations

Based on the dashboard findings, ICMRA should manage fundraising as an integrated value-risk portfolio.

First, revenue planning should be rebased around sustainable performance rather than the exceptional 2023 peak. This would reduce the risk of setting unrealistic targets that are not supported by repeatable contributor behaviour.

Second, contributor management should use segmentation as an operating framework. Champions and Loyal Donors should be protected, while Needs Attention, At Risk, Lost, and dormant high-value contributors should be monitored for recovery and retention action.

Third, campaign investment should be assessed through return efficiency. Campaigns should be compared using revenue, target achievement, budget allocation, and ROI rather than gross revenue alone.

Finally, future growth planning should use balanced scenario modelling. Management should test combined improvements across average pledge, giving frequency, and retention instead of relying on a single revenue lever.

## 8. Business Value

The project created business value by turning fragmented fundraising records into a structured decision-support system. It helped senior management understand not only what happened, but where action should be focused.

Key business value included:

- Clearer visibility of fundraising performance and volatility.
- Better prioritisation of high-value and at-risk contributors.
- More disciplined campaign investment review.
- Quantified dormant and reactivation revenue opportunities.
- Scenario-based planning for future revenue targets.
- A board-facing infographic that translated analytics into an executive narrative.

## 9. Skills Demonstrated

This project demonstrates capabilities relevant to Business Analyst, Data Business Analyst, and BI/Data Analyst roles:

- Translating ambiguous business needs into analytical questions.
- Designing a dashboard around stakeholder decisions.
- Performing transparent data quality assessment using Power Query.
- Building a semantic model to support reliable KPI reporting.
- Defining metric contracts before implementation.
- Applying advanced analytics techniques appropriately based on dataset structure.
- Communicating insights in business language.
- Producing strategic recommendations from evidence.
- Balancing technical analytics with stakeholder-ready storytelling.

## 10. Reflection

The most important learning from this project was that advanced analytics should be selected based on business relevance and dataset structure, not because the technique sounds impressive.

RFM, cohort retention, campaign ROI, CLV proxy, and scenario planning were appropriate because the dataset supported the required entities, dates, amounts, and relationships. Market basket analysis was rejected because the data did not contain a valid basket structure.

This project also reinforced the importance of metric governance. Measures such as campaign ROI, churn, retention, and CLV can be technically valid but misleading if the business definition is unclear. Creating metric contracts before building the dashboard helped keep the analysis aligned with decision-making rather than only visual presentation.
