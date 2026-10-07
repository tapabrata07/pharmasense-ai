# PharmaSense AI – Data Quality Report (Step 1)

Database: `pharmasense.db` (SQLite). 7 tables loaded from the provided CSVs. Row counts match the guide (compounds 150, clinical_trials 110, trial_sites 375, lab_results 2000, adverse_events 500, research_documents 250, agent_interaction_logs 400).

## 1. Passed checks
| Check | Result |
|---|---|
| Duplicate rows in any table | 0 |
| Duplicate primary keys (compound, trial, site, AE) | 0 |
| Orphan foreign keys (trials→compounds, sites→trials, labs→compounds, AEs→trials, AEs→sites, docs→compounds, docs→trials) | 0 |
| AE's site belongs to the AE's trial | 0 mismatches |
| Trial therapeutic area = its compound's area | 0 mismatches |
| Trial end date before start date | 0 |
| Completed trials missing actual_end_date | 0 |
| Toxicity score outside 0–1; negative lab values | 0 |
| Trials with no sites | 0 |
| Severity/seriousness logic | Every "Serious" AE is "Severe" (43); 24 Severe AEs are Non-serious |

## 2. Issues found (to document and handle, not silently fix)
| # | Issue | Count | Suggested handling |
|---|---|---|---|
| 1 | Expected nulls: `clinical_trials.actual_end_date` (62 – trials still open), `research_documents.trial_id` (101 – docs tied only to a compound) | 62 / 101 | Keep NULL; use LEFT JOINs |
| 2 | Actual enrollment above target enrollment | 6 trials (TRL-0009, 0015, 0044, 0048, 0075, 0079) | Cap % enrolled at 100 in dashboards, flag as over-enrolled |
| 3 | Non-completed trial with an actual_end_date | 9 (all Terminated) | Valid: terminated trials have an end date |
| 4 | Sum of site `enrollment_count` differs from trial `actual_enrollment` | 105 of 110 trials (avg gap 13.7%) | Do not add site counts to reconcile to trial totals; use the trial table for trial-level enrollment and site table for site/country views |
| 5 | Adverse event dated before its trial's start date | 182 AEs across 66 trials | Flag as date-quality issue; exclude from time-based AE analysis or report separately |
| 6 | AEs recorded at sites with status "Pending Activation" | 179 | Same: business-logic inconsistency to flag |
| 7 | Trials still Recruiting / Active but past planned end date | 39 | Report as "overdue" rather than dropping |
| 8 | Trials marked Completed with a planned end date in the future | 4 | Flag |
| 9 | Same patient_code appears in more than one trial | 3 codes | Flag for the PII/redaction step (Step 7) |
| 10 | Lab results dated before the compound's synthesis_date | 664 of 2000 | Flag; do not use lab dates for time-trend claims without caveat |
| 11 | Research documents dated before the compound's synthesis_date | 59 of 250 | Same |
| 12 | `lab_results` has no trial_id | – | A compound's labs can be joined to trials only through compound_id |

Items 5, 6, 10, 11 are typical of synthetic data (randomly generated dates), but a real analyst should still report them.

## 3. Notes for the later steps
- "Phase II oncology trials below 60% enrollment" returns 1 trial (TRL-0037, 40.5%) if limited to in-progress trials (Recruiting, Active not recruiting). Decide and state whether Suspended/Terminated count.
- Golden-set answers should be computed from `queries.sql` so every expected answer is reproducible.
