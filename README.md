# CredResolve Data Analyst Assignment

## Collections Recovery Forensics, Performance Reconstruction & Decision Analysis

**Analyst:** Tanush  
**Repository:** CredResolve Data Analyst Assignment  
**Objective:** Independently reconstruct collections performance, test the business claim **“Recovery has improved by 11% month-on-month”**, investigate data-quality and attribution issues, and translate the findings into an executive decision framework.

---

## 1. Executive Summary

The business reported that **recovery improved by 11% month-on-month**. The analysis did **not** reproduce this claim consistently from the validated recovery population.

Using the cleaned/golden analytical layer:

- **30,000 accounts** were analysed.
- Total outstanding exposure is **₹10.489 billion**.
- Validated recovery is **₹1.316 billion**.
- There are **17,534 validated recovery transactions**.
- **13,284 accounts** have validated recovery.
- Overall recovery rate is approximately **12.54%**.
- The 11% month-on-month improvement claim is **not validated**.
- Only **March 2026 (+11.03%)** reached the reported 11% level.
- February was **−9.13%**, April **−7.29%**, May **+5.20%**, June **−4.72%**, July **+6.65%**, and August **−74.84%**.
- August recovery was **₹47.11M** with only **616 successful recovery transactions** in the available data; therefore, the August decline is reported as an observation and **not attributed to a specific cause without further evidence**.

### Bottom-line conclusion

**The reported 11% month-on-month improvement should not be used as a validated performance trend.** The independently reconstructed series shows volatility rather than a sustained +11% monthly improvement.

---

# 2. Assignment Questions Addressed

The assignment requires answers to four central questions:

1. **What happened?**
2. **Why did it happen?**
3. **Is the reported 11% improvement real?**
4. **Where should the ₹10 Cr investment be deployed?**

The submission is structured around these questions rather than around the number of queries or charts.

---

# 3. Analytical Approach

The analysis was built as:

```text
Raw Operational Data
        |
        v
     Staging
        |
        v
      Clean
        |
        v
      Golden
        |
        v
 Features / Metrics
        |
        v
   Python Analysis
        |
        v
    Power BI
        |
        v
 Executive Decision
```

The analytical layer separates **operational source data**, **cleaned data**, **validated recovery**, and **business reporting** so that the recovery claim can be tested independently.

---

# 4. Golden Dataset & Source-of-Truth Decisions

## Accounts

`clean.accounts` is used as the account-level analytical source for:

- account population
- principal amount
- outstanding amount
- DPD
- risk segment
- account status
- loan type

## Payments

`clean.payments` is used for payment-status and payment-quality analysis.

## Validated Recovery

`gold.recovery_payments` is used as the **authoritative recovery transaction population** for recovery reporting.

The golden recovery logic uses successful payments and validates the account relationship before producing the recovery layer.

## Payment identity

**`payment_id`** is retained as the operational transaction identifier after exact duplicate copies are removed.

`payment_reference` is retained as a descriptive/reconciliation field and is **not** used as the primary deduplication key.

## Borrower attribution

The Golden attribution rule is:

```text
payment.account_id
        ->
accounts.account_id
        ->
accounts.borrower_id
```

rather than trusting `payments.borrower_id` directly.

This decision was made because **25,499 borrower/account mismatches** were identified during the forensic investigation.

---

# 5. Data Quality & Forensic Findings

## 5.1 Payment duplication

Payment cleaning reduced the payment population from:

```text
Raw payment rows       = 25,500
Clean payment rows     = 25,000
Rows removed           = 500
```

The removed rows were treated as duplicate copies rather than legitimate independent recoveries.

The duplicate-payment investigation also showed a **₹25,901,961.05 reduction in successful-payment amount**, equivalent to approximately **1.93%** of the unclean successful-payment amount.

### Business impact

Without payment deduplication, recovery could be overstated.

---

## 5.2 Payment reference completeness

In the cleaned payment population:

```text
Clean payment rows              = 25,000
Missing/blank payment_reference = 382
Missing percentage              = 1.53%
```

The missing references were **not imputed** because no reliable matching reference could be recovered from the gold recovery population.

### Treatment

The 382 values remain `NULL`.

### Business impact

Payment records are retained without inventing reconciliation identifiers.

---

## 5.3 Borrower identity issue

The borrower investigation found:

```text
Borrower IDs appearing multiple times = 8,566
Excess records                        = 19,585
```

The duplicate borrower records are **not exact duplicates** and contain changes across borrower attributes.

The records were therefore **not automatically deleted** or reduced to the latest row.

### Classification

**Fact / Strong Evidence**

### Business implication

`borrower_id` should not automatically be treated as a stable unique person-level identifier until temporal/history and identity resolution are completed.

---

## 5.4 Agent identity corruption

The agent investigation found:

```text
Duplicated agent IDs = 1,000
Excess rows          = 29,000
```

The same `agent_id` can appear with multiple:

- employee codes
- names
- vendors
- teams
- statuses
- dates

The issue affects:

```text
88,241 calls
28,305 accounts
15,000 agent sessions
```

Therefore:

- `agent_id` is **not** treated as a stable employee-level identifier.
- `employee_code` is also not assumed to uniquely identify one person.

### Classification

**Fact / Strong Evidence**

### Business implication

Aggregate operational activity can still be analysed, but agent-level attribution should be treated as unreliable until identity resolution is fixed.

---

## 5.5 Call / attempt key integrity

Cross-checks between `calls` and `call_attempts` showed that the same `call_id` can correspond to different:

- accounts
- borrowers
- timestamps
- agents
- telephony vendors

Therefore, `call_id` should **not** automatically be treated as a unique collection event key.

### Golden event design

The preferred design is:

```text
attempt_id = Golden call-attempt event key
call_id    = source/reference field
```

provided the final attempt-level integrity checks continue to support that structure.

### Classification

**Fact / Strong Evidence**

---

## 5.6 WhatsApp data quality

WhatsApp cleaning produced:

```text
Source events                 = 60,600
Staging events                = 60,600
Clean events                  = 60,000
Duplicate rows removed       = 600
Removed percentage           = 0.99%
Orphan WhatsApp events       = 0
Remaining duplicate event IDs = 0
```

The 600 duplicated event IDs represented exact duplicate copies and were removed in the clean layer.

### Classification

**Fact / Strong Evidence**

### Business impact

WhatsApp event volume is no longer inflated by these exact duplicate records.

---

# 6. Recovery Performance Reconstruction

## Portfolio

```text
Accounts             = 30,000
Outstanding exposure = ₹10,489,035,366.33
Principal             = ₹12,103,665,678.04
Average DPD           = 56.51 days
```

## Validated recovery

```text
Recovery transactions = 17,534
Recovered accounts    = 13,284
Validated recovery    = ₹1,315,583,965.60
Overall recovery rate ≈ 12.54%
```

Recovery is measured as:

```text
Validated Recovery
------------------
Outstanding Exposure
```

This definition is preferred because it separates **actual validated successful payment value** from the broader payment-event population.

---

# 7. Independent Test of the 11% Claim

The month-on-month calculation is:

```text
(Current Month Recovery - Previous Month Recovery)
------------------------------------------------- × 100
             Previous Month Recovery
```

## Results

| Month | Validated Recovery | MoM Change |
|---|---:|---:|
| Jan 2026 | ₹187.23M | — |
| Feb 2026 | ₹170.14M | **−9.13%** |
| Mar 2026 | ₹188.91M | **+11.03%** |
| Apr 2026 | ₹175.14M | **−7.29%** |
| May 2026 | ₹184.25M | **+5.20%** |
| Jun 2026 | ₹175.56M | **−4.72%** |
| Jul 2026 | ₹187.24M | **+6.65%** |
| Aug 2026 | ₹47.11M | **−74.84%** |

### Claim decision

**Claim: “Recovery has improved by 11% month-on-month.”**

**Result: NOT VALIDATED**

Only March 2026 reached the reported level at **+11.03%**.

The observed series does not show a sustained month-on-month +11% improvement.

### Confidence

**High confidence** for rejecting the claim as a consistent monthly trend, because the independent validated series directly contradicts the reported pattern across most observed month transitions.

---

# 8. DPD Analysis

The DPD buckets used are:

```text
CURRENT
1-30
31-60
61-90
90+
```

## Results

| DPD Bucket | Accounts | Outstanding | Recovered | Recovery Rate |
|---|---:|---:|---:|---:|
| 1-30 | 10,880 | ₹3,834.10M | ₹471.54M | **12.30%** |
| 31-60 | 5,514 | ₹1,914.49M | ₹252.78M | **13.20%** |
| 90+ | 5,453 | ₹1,896.36M | ₹235.07M | **12.40%** |
| 61-90 | 5,468 | ₹1,895.87M | ₹238.74M | **12.59%** |
| CURRENT | 2,685 | ₹948.22M | ₹117.46M | **12.39%** |

### Key finding

The **1-30 DPD bucket** has the largest outstanding exposure:

**₹3.834 billion / 36.55% of total outstanding exposure.**

The **31-60 DPD bucket** has the highest recovery rate at **13.20%**.

### Business implication

The 1-30 bucket represents the largest collection opportunity by absolute exposure, while 31-60 shows the strongest observed recovery efficiency.

---

# 9. Risk Segment Analysis

| Risk Segment | Accounts | Outstanding | Recovered | Recovery Rate |
|---|---:|---:|---:|---:|
| HIGH | 7,552 | ₹2,646.18M | ₹331.60M | **12.53%** |
| LOW | 7,513 | ₹2,633.31M | ₹330.86M | **12.56%** |
| MEDIUM | 7,533 | ₹2,628.18M | ₹330.51M | **12.58%** |
| NPA | 7,402 | ₹2,581.36M | ₹322.62M | **12.50%** |

### Key finding

Recovery rates range only from **12.50% to 12.58%**, indicating that recovery performance is highly similar across the four risk segments.

**MEDIUM = highest recovery rate (12.58%)**  
**NPA = lowest recovery rate (12.50%)**

### Interpretation

Risk segment alone does not explain a large portion of observed recovery variation.

### Classification

**Fact / Correlation, not causation**

---

# 10. Risk × DPD Analysis

The analysis covers:

```text
4 risk segments × 5 DPD buckets = 20 combinations
```

### Key findings

- Highest recovery rate: **13.40% — NPA / 31-60 DPD**
- Lowest recovery rate: **11.13% — NPA / CURRENT**
- Highest account count: **2,819 — MEDIUM / 1-30 DPD**
- Largest individual risk-DPD outstanding: **₹992.79M — MEDIUM / 1-30 DPD**
- Recovery rates across the 20 combinations range from **11.13% to 13.40%**
- Spread across these combinations = **2.27 percentage points**

### Business implication

The **1-30 DPD bucket dominates exposure across risk segments**, suggesting that early-stage delinquency is a major collection opportunity by amount.

---

# 11. Payment Status Analysis

Clean payment population:

```text
Total payment records = 25,000
```

| Status | Records | Amount |
|---|---:|---:|
| SUCCESS | **17,534** | **₹1,315.58M** |
| FAILED | 3,677 | ₹278.42M |
| PENDING | 2,535 | ₹190.22M |
| REVERSED | 1,254 | ₹94.67M |

### Key implication

Only validated successful payments are treated as recovery in the Golden recovery layer.

This prevents failed, pending and reversed payment events from being interpreted as successful collections.

---

# 12. What the Evidence Supports

## FACT

- 11% month-on-month recovery improvement is **not consistently reproduced** by validated recovery data.
- 500 payment rows were removed during duplicate cleaning.
- 382 clean payment records have missing payment references.
- 600 exact duplicate WhatsApp rows were removed.
- 8,566 borrower IDs appear multiple times.
- 1,000 agent IDs appear multiple times, with identity conflicts.
- `call_id` has integrity issues when linked across call and attempt systems.
- 1-30 DPD contains the largest outstanding exposure.
- Risk-segment recovery rates are closely grouped around 12.5%.

## STRONG EVIDENCE

- Agent-level performance attribution is unreliable under the current identifiers.
- Payment deduplication is necessary to prevent recovery overstatement.
- Early-stage delinquency is the largest exposure opportunity by amount.

## CORRELATION

- Differences in recovery across risk and DPD segments exist, but the observed differences are not evidence of causality by themselves.

## HYPOTHESIS / REQUIRES FURTHER TESTING

- The reason for August's sharp decline.
- Whether targeting changes caused a change in recovery.
- Whether channel, vendor, campaign or agent operational changes caused the monthly volatility.

---

# 13. Statistical Investigation — What Is and Is Not Established

A transparent descriptive analysis was completed for:

- monthly time-series movement
- risk-segment mix
- DPD mix
- Risk × DPD exposure
- payment quality

The current submission **does not claim causal attribution** from these descriptive comparisons.

The assignment also asks for investigation of:

- mix effects
- cohort effects
- selection bias
- survivorship bias
- Simpson's paradox
- attribution-window bias
- time-series effects

These require additional controlled comparisons and/or cohort-level operational data analysis before making a causal claim.

Therefore, this repository deliberately distinguishes **observed fact** from **causal inference**.

---

# 14. Counterfactual Methodology

The assignment asks us to assume that targeting changed midway through the year and estimate:

> What would recovery have looked like without the targeting change?

A practical identification strategy would be:

### Treatment group
Accounts targeted under the new targeting strategy after the change.

### Control group
Comparable accounts remaining under the previous targeting policy, where available.

### Recommended method
**Difference-in-differences with matching**:

1. Match treatment and control accounts on pre-treatment:
   - DPD
   - risk segment
   - outstanding amount
   - loan type
   - borrower/portfolio characteristics available in the data
2. Compare pre/post recovery changes.
3. Estimate the treatment effect on recovery.
4. Test whether pre-treatment trends were sufficiently parallel.

### Confounders
Potential confounders include:

- portfolio composition
- DPD mix
- borrower segment
- loan type
- campaign differences
- channel exposure
- agent/vendor differences
- calendar/time effects
- payment timing

### Limitation

A credible causal estimate requires the actual targeting-policy change point and sufficiently comparable treatment/control observations. These are not established by the descriptive analysis alone.

**Therefore, no unsupported causal uplift estimate is reported in this repository.**

---

# 15. ₹10 Cr Investment Decision

The available validated analysis establishes that the reported **11% monthly improvement is not reliable**, but the current evidence does **not** isolate a causal ROI for one of the six investment choices.

Therefore, the responsible recommendation is:

## **Do not commit the full ₹10 Cr based only on the current descriptive evidence.**

### Recommended next investment mechanism

Run a controlled **targeting experiment** before committing the full budget.

This is consistent with the assignment's allowance to state that the data is insufficient for a reliable recommendation and specify the additional experiment/data required.

### Experiment design

- Randomize comparable eligible accounts into old-vs-new targeting strategies.
- Stratify by DPD and risk segment.
- Measure incremental validated recovery.
- Measure recovery per targeted account.
- Measure cost per ₹ recovered.
- Estimate confidence intervals.
- Scale only the strategy that demonstrates positive incremental recovery.

### Why this recommendation

The observed recovery rates across risk/DPD segments are relatively close, while the month-to-month recovery series is volatile. A controlled targeting experiment therefore provides a clearer route to establishing **incremental recovery caused by an operational change** before allocating the full ₹10 Cr.

### ROI fields to populate after the experiment

```text
Investment                       = ₹10 Cr
Incremental recovery             = [Experiment estimate]
Expected ROI                     = [(Incremental recovery - investment) / investment]
Break-even                        = [Months until cumulative incremental recovery = investment]
Downside scenario                 = [Lower confidence-bound incremental recovery]
Confidence range                  = [Experiment confidence interval]
```

No financial uplift number is fabricated in this repository without causal evidence.

---

# 16. Power BI Dashboard

The Power BI report contains three complementary views:

### Page 1 — Loan Recovery & Collections Performance Dashboard

Executive view showing:

- Total Recovery
- Recovery Transactions
- Recovered Accounts
- Recovered Borrowers
- Recovery Rate
- Monthly Recovery Trend
- Outstanding by DPD
- Accounts by Risk Segment
- Recovery by Risk Segment
- Payment Status Distribution

### Page 2 — Collections Risk & DPD Analysis

Analytical drill-down showing:

- Total Outstanding
- 31+ DPD Exposure %
- 90+ DPD Exposure %
- Average DPD
- Recovery Rate
- Recovery Rate by Risk Segment
- Outstanding Exposure by Collection Priority
- Recovery Rate by DPD
- Risk × DPD Exposure Matrix

### Page 3 — Payment & Recovery Reconciliation

Payment-quality and financial reconciliation view showing:

- payment volumes by status
- payment amounts by status
- payment method analysis
- validated recovery
- payment/recovery reconciliation

The Executive Dashboard is designed so that the first page can be understood quickly, while additional pages support investigation.

---

# 17. Production Analytics Architecture

```text
                   RAW SOURCES
                       |
                       v
                  STAGING LAYER
                       |
              Data Contracts / PK Checks
                       |
                       v
                   CLEAN LAYER
        +--------------+--------------+
        |              |              |
     Accounts       Payments        Events
        |              |              |
        +--------------+--------------+
                       |
             Data Quality / Forensics
        Deduplication / Identity / Timestamps
                       |
                       v
                  GOLDEN LAYER
             Validated Recovery Events
                       |
                       v
              FEATURE / METRICS LAYER
       Recovery / DPD / Risk / Collections KPIs
                       |
                       v
                   POWER BI
                       |
                       v
                  LEADERSHIP
```

### Production controls

Recommended production controls include:

- primary-key uniqueness checks
- schema/data contracts
- incremental loads
- late-arriving-event handling
- backfill process
- duplicate detection
- referential-integrity checks
- timestamp/timezone validation
- payment reconciliation
- monitoring
- anomaly detection
- metric-definition versioning
- data lineage

---

# 18. Repository Files

## SQL Repository

Purpose:
- cleaning
- transformations
- data-quality checks
- payment validation
- recovery metrics
- DPD/risk analysis
- claim validation

## Python Analysis Notebook

Purpose:
- independent validation
- descriptive analysis
- monthly recovery reconstruction
- risk/DPD analysis
- reproducible reasoning

## Power BI Dashboard

Purpose:
- executive dashboard
- risk and DPD analysis
- payment/recovery reconciliation

## Golden Dataset / Pipeline

The Golden Dataset provides the trusted analytical layer for the collections
analysis. The pipeline follows **Raw → Staging → Clean → Golden → Feature /
Metrics → Dashboard** and applies data-type standardization, deduplication,
referential-integrity checks, timestamp validation, payment attribution and
source-of-truth rules.

### Key Results

- **30,000 accounts** in the cleaned account population.
- **25,500 → 25,000 payment rows** after duplicate handling; **500 rows removed**.
- **60,600 → 60,000 WhatsApp events** after removing **600 exact duplicates**.
- **17,534 validated recovery transactions**.
- **13,284 recovered accounts** and **7,987 recovered borrowers**.
- **₹1.316B validated recovery**.
- Payment attribution uses `account_id → accounts.account_id → accounts.borrower_id`.
- `payment_id` is used as the operational payment identifier after duplicate handling.
- Agent and borrower identifiers are treated cautiously where identity conflicts were found.

---

## Data Quality Report

The data-forensics analysis identified several issues that could affect
collections reporting and attribution.

### Major Findings

- **500 duplicate payment rows** were removed from 25,500 raw payment records.
- Approximately **₹25.90M** of successful-payment amount was associated with
  removed duplicate records.
- **382 of 25,000 clean payment records (1.53%)** have missing
  `payment_reference`; these were retained as NULL because they could not be
  reliably imputed.
- **8,566 borrower IDs** appear multiple times, creating **19,585 excess records**.
- **1,000 agent IDs** appear multiple times, creating **29,000 excess rows**.
- The agent identity issue affects **88,241 calls, 28,305 accounts and 15,000
  agent sessions**.
- `call_id` showed cross-system inconsistencies and is therefore not assumed
  to uniquely identify one collection event.
- **600 duplicate WhatsApp events** were removed from 60,600 source events.
- **0 orphan WhatsApp events** remained after cleaning.

These findings are classified as **Fact / Strong Evidence** where directly
established by the data. Observed relationships are not treated as causal
without controlled evidence.

---

## Executive Memo

The independent analysis was designed to determine whether the business claim
**“Recovery has improved by 11% month-on-month”** is supported by the data.

### What Happened?

The claim is **not validated as a sustained trend**.

| Month | Validated Recovery | MoM Change |
|---|---:|---:|
| Jan 2026 | ₹187.23M | — |
| Feb 2026 | ₹170.14M | **-9.13%** |
| Mar 2026 | ₹188.91M | **+11.03%** |
| Apr 2026 | ₹175.14M | **-7.29%** |
| May 2026 | ₹184.25M | **+5.20%** |
| Jun 2026 | ₹175.56M | **-4.72%** |
| Jul 2026 | ₹187.24M | **+6.65%** |
| Aug 2026 | ₹47.11M | **-74.84%** |

Only **March 2026 (+11.03%)** reached the reported 11% level. The remaining
monthly movements do not support a consistent +11% improvement.

### Why?

- Data-quality issues create risk of overstated or misattributed operational
  metrics.
- The **1–30 DPD bucket contains ₹3.834B**, approximately **36.55%** of total
  outstanding exposure.
- **31–60 DPD has the highest observed recovery rate at 13.20%**.
- Recovery rates across HIGH, LOW, MEDIUM and NPA segments are closely grouped
  between **12.50% and 12.58%**.
- The largest Risk × DPD exposure is **MEDIUM / 1–30 DPD at approximately
  ₹992.79M**.
- These are descriptive findings; they do not establish that any single
  operational channel or targeting strategy caused the changes.

### Investment Decision

The current evidence is **not sufficient to claim a reliable causal ROI or
incremental recovery from a ₹10 Cr investment**.

The recommended next step is a controlled **better borrower targeting
experiment** with matched treatment and control groups, using DPD, risk,
outstanding amount, loan type and other pre-treatment characteristics.

The full ₹10 Cr should not be committed solely on the reported 11% KPI.
Incremental recovery, ROI, break-even and downside should be estimated from the
controlled experiment before scaling.

---

## Architecture Diagram

The proposed production analytics architecture is:

**Raw Sources**  
↓  
**Staging Layer**  
↓  
**Clean Layer**  
↓  
**Data Forensics & Quality Controls**  
↓  
**Golden Dataset**  
↓  
**Feature / Metrics Layer**  
↓  
**Power BI Dashboard**  
↓  
**Leadership Decision**

### Production Controls

- Data contracts and schema validation
- Primary-key and duplicate checks
- Referential-integrity validation
- Timestamp and timezone checks
- Payment reconciliation
- Entity-resolution controls
- Incremental processing
- Late-arriving-data handling
- Historical backfills
- Data-quality monitoring
- KPI anomaly detection
- Data lineage and metric-definition versioning

---

# 19. Reproducibility

### SQL

Database: `CollectionsAnalytics`

Core analytical schemas/tables:

```text
clean.accounts
clean.payments
clean.calls
clean.whatsapp_events
gold.recovery_payments
```

### Python

Python notebook connects to SQL Server and reproduces the main analytical outputs.

### Power BI

The dashboard is connected to the cleaned/golden SQL analytical layer rather than relying on the original raw operational tables for core recovery reporting.

---

# 20. Limitations

1. The available descriptive analysis does not establish causal effects for channel, campaign, vendor, agent or targeting changes.
2. Agent identity collisions prevent reliable person-level agent attribution.
3. Borrower ID reuse/collision issues require further identity and temporal investigation.
4. The August recovery decline is an observed result but its cause is not established.
5. A causal ₹10 Cr ROI cannot responsibly be estimated without a controlled experiment or stronger identification strategy.
6. The assignment requests several statistical diagnostics and operational drivers; any item not directly supported by observed evidence is explicitly left as an open hypothesis rather than presented as fact.

---

# 21. Final Conclusion

The central business claim was tested independently using validated recovery data.

**The evidence does not support a sustained 11% month-on-month recovery improvement.**

The strongest findings are:

- recovery is volatile rather than consistently improving by 11%;
- payment duplication can materially distort reported recovery;
- agent identity quality is poor enough to undermine person-level attribution;
- the 1-30 DPD bucket contains the largest outstanding exposure;
- recovery rates across major risk segments are broadly similar;
- the current evidence is sufficient to challenge the reported KPI, but not sufficient to claim a causal reason for every monthly movement or to manufacture an unsupported ₹10 Cr ROI.

The recommended decision is therefore to **protect the ₹10 Cr investment decision with a controlled targeting experiment**, establish incremental validated recovery, and scale only after causal evidence is obtained.

---



