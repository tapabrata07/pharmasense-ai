# PharmaSense AI — Data & Dashboards Project

A data analysis project built on a synthetic pharma R&D / clinical operations dataset (7 linked tables, 3,700+ records). Scope: data loading, data quality validation, SQL analysis, and evaluation dashboards.

## Contents

| File | Description |
|---|---|
| `pharmasense.db` | SQLite database with all 7 source tables loaded |
| `queries.sql` | 10 core SQL queries answering key business questions (enrollment, adverse events, compound profiles, lab results, site/country breakdowns, agent log analysis) |
| `data_quality_report.md` | Full data quality findings: integrity checks passed, issues found, and how each was handled |
| `PharmaSense_Dashboards.xlsx` | Excel dashboards — agent performance/observability and clinical trial/adverse-event summaries, with formula-driven pivot-style tables and charts |
| `PharmaSense_Architecture_Findings.pdf` | One-stop write-up: architecture, data quality summary, key SQL findings, dashboard overview, limitations & next steps |

## How to explore

1. **Start with** `PharmaSense_Architecture_Findings.pdf` for the full picture.
2. **Open** `pharmasense.db` in DB Browser for SQLite (or any SQLite client) and run the queries in `queries.sql`.
3. **Open** `PharmaSense_Dashboards.xlsx` in Excel to see the dashboards and underlying data tables.
4. **Read** `data_quality_report.md` for the detailed validation checks.

## Summary

- 7 tables loaded and validated: no duplicate keys, no orphan foreign keys.
- Several data-quality issues identified and documented (enrollment mismatches, date inconsistencies, site-status inconsistencies) rather than silently fixed.
- 10 SQL queries answer the core business questions from the project brief.
- Two Excel dashboards cover agent observability (latency, tokens, escalation rate) and clinical trial / adverse-event summaries.

## Scope note

The source project guide describes a full multi-agent GenAI system (RAG, tool-calling agents, orchestration). This submission covers the **data + dashboards** portion only, as confirmed with my internship supervisor.

**Author:** Tapabrata Maity — Data Analyst Intern
