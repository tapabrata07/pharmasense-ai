-- ============================================================
-- PharmaSense AI - core SQL queries (SQLite/DuckDB compatible)
-- ============================================================

-- Q1. Phase II oncology trials below 60% enrollment (still in progress)
SELECT trial_id, compound_id, status, target_enrollment, actual_enrollment,
       ROUND(100.0*actual_enrollment/target_enrollment,1) AS pct_enrolled
FROM clinical_trials
WHERE trial_phase='Phase II' AND therapeutic_area='Oncology'
  AND status IN ('Recruiting','Active, not recruiting')
  AND 1.0*actual_enrollment/target_enrollment < 0.60
ORDER BY pct_enrolled;

-- Q2. Enrollment rate by phase and status
SELECT trial_phase, status, COUNT(*) AS trials,
       SUM(actual_enrollment) AS enrolled, SUM(target_enrollment) AS target,
       ROUND(100.0*SUM(actual_enrollment)/SUM(target_enrollment),1) AS pct
FROM clinical_trials GROUP BY 1,2 ORDER BY 1,2;

-- Q3. Adverse events by trial with serious-event count and rate per enrolled patient
SELECT a.trial_id, t.trial_phase, t.therapeutic_area,
       COUNT(*) AS total_ae,
       SUM(a.seriousness='Serious') AS serious_ae,
       ROUND(1.0*COUNT(*)/t.actual_enrollment,3) AS ae_per_patient
FROM adverse_events a JOIN clinical_trials t USING(trial_id)
GROUP BY a.trial_id ORDER BY serious_ae DESC, total_ae DESC LIMIT 10;

-- Q4. All Serious AEs, newest first (escalation candidates for the triage agent)
SELECT event_id, trial_id, site_id, event_date, adverse_event_term, causality_assessment, outcome
FROM adverse_events
WHERE seriousness='Serious'
ORDER BY event_date DESC;

-- Q5. Full picture for one compound (change the id)
WITH p AS (SELECT 'CMP-0002' AS cid)
SELECT 'compound' AS section, c.compound_name AS a, c.therapeutic_area AS b, c.discovery_phase AS c, c.toxicity_score AS d
FROM compounds c, p WHERE c.compound_id=p.cid
UNION ALL
SELECT 'labs', experiment_type, COUNT(*), SUM(pass_fail='Pass'), ROUND(AVG(result_value),2)
FROM lab_results, p WHERE compound_id=p.cid GROUP BY experiment_type
UNION ALL
SELECT 'trial', t.trial_id, t.trial_phase, t.status, ROUND(100.0*t.actual_enrollment/t.target_enrollment,1)
FROM clinical_trials t, p WHERE t.compound_id=p.cid
UNION ALL
SELECT 'adverse_events', a.severity, a.seriousness, COUNT(*), NULL
FROM adverse_events a JOIN clinical_trials t USING(trial_id), p
WHERE t.compound_id=p.cid GROUP BY a.severity,a.seriousness;

-- Q6. Lab pass rate by experiment type
SELECT experiment_type, COUNT(*) AS runs,
       ROUND(100.0*SUM(pass_fail='Pass')/COUNT(*),1) AS pass_rate
FROM lab_results GROUP BY 1 ORDER BY pass_rate;

-- Q7. Compounds with hERG failures and their trial status (cardiotoxicity signal)
SELECT c.compound_id, c.compound_name, c.target_protein,
       SUM(l.pass_fail='Fail') AS herg_fails, COUNT(*) AS herg_runs
FROM lab_results l JOIN compounds c USING(compound_id)
WHERE l.experiment_type='hERG Cardiotoxicity Screen'
GROUP BY 1 HAVING herg_fails>=1 ORDER BY herg_fails DESC LIMIT 10;

-- Q8. Sites by country with enrollment
SELECT country, COUNT(*) AS sites, SUM(enrollment_count) AS enrolled,
       SUM(site_status='Active') AS active_sites
FROM trial_sites GROUP BY 1 ORDER BY enrolled DESC;

-- Q9. Agent observability: latency / tokens / escalation by agent
SELECT agent_invoked, COUNT(*) AS calls,
       ROUND(AVG(latency_ms)) AS avg_latency_ms,
       ROUND(AVG(tokens_used)) AS avg_tokens,
       ROUND(AVG(feedback_rating),2) AS avg_rating,
       ROUND(100.0*SUM(escalated_flag)/COUNT(*),1) AS escalation_pct
FROM agent_interaction_logs GROUP BY 1 ORDER BY calls DESC;

-- Q10. Tool usage and slow calls
SELECT tool_called, COUNT(*) AS calls, ROUND(AVG(latency_ms)) AS avg_ms, MAX(latency_ms) AS max_ms
FROM agent_interaction_logs GROUP BY 1 ORDER BY calls DESC;
