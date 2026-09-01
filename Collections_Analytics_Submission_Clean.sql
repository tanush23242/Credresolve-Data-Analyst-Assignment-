-- COLLECTIONS ANALYTICS | SUBMISSION-READY SQL
-- Purpose: Data quality, duplicate/identity forensics, validated recovery, and collection analytics.
-- Notes: Original dbo tables are preserved. Clean/gold tables are derived outputs.
-- Exploratory duplicate queries that repeated the same test have been removed; one representative query is retained per analytical purpose.

USE CollectionsAnalytics;
GO

CREATE DATABASE CollectionsAnalytics;


USE CollectionsAnalytics;

CREATE SCHEMA raw;
GO

CREATE SCHEMA stg;
GO

CREATE SCHEMA clean;
GO

CREATE SCHEMA gold;
GO

CREATE SCHEMA feature;
GO

CREATE SCHEMA mart;
GO

CREATE SCHEMA audit;
GO

USE CollectionsAnalytics;


SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

SELECT COUNT(*) AS row_count FROM dbo.accounts;
SELECT COUNT(*) AS row_count FROM dbo.borrowers;
SELECT COUNT(*) AS row_count FROM dbo.agents;
SELECT COUNT(*) AS row_count FROM dbo.agent_sessions;
SELECT COUNT(*) AS row_count FROM dbo.call_attempts;
SELECT COUNT(*) AS row_count FROM dbo.call_dispositions;
SELECT COUNT(*) AS row_count FROM dbo.calls;
SELECT COUNT(*) AS row_count FROM dbo.campaigns;
SELECT COUNT(*) AS row_count FROM dbo.complaints;
SELECT COUNT(*) AS row_count FROM dbo.daily_targeting;
SELECT COUNT(*) AS row_count FROM dbo.field_visits;
SELECT COUNT(*) AS row_count FROM dbo.payments;
SELECT COUNT(*) AS row_count FROM dbo.promises_to_pay;
SELECT COUNT(*) AS row_count FROM dbo.sms_events;
SELECT COUNT(*) AS row_count FROM dbo.vendor_telephony;
SELECT COUNT(*) AS row_count FROM dbo.whatsapp_events;
SELECT COUNT(*) AS row_count FROM dbo.account_status_history;
SELECT COUNT(*) AS row_count FROM dbo.data_dictionary;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN
(
    'accounts',
    'borrowers',
    'agents',
    'agent_sessions',
    'calls',
    'call_attempts',
    'call_dispositions',
    'campaigns',
    'complaints',
    'daily_targeting',
    'field_visits',
    'payments',
    'promises_to_pay',
    'sms_events',
    'vendor_telephony',
    'whatsapp_events',
    'account_status_history'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;

----data_dictionary.csv

SELECT *
FROM dbo.data_dictionary
ORDER BY [dataset], [column];

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME, ORDINAL_POSITION;

--for account.csv 
SELECT
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    UPPER(TRIM(CAST(loan_type AS VARCHAR(100)))) AS loan_type,
    TRY_CONVERT(DECIMAL(18,2), principal_amount) AS principal_amount,
    TRY_CONVERT(DECIMAL(18,2), outstanding_amount) AS outstanding_amount,
    TRY_CONVERT(INT, dpd) AS dpd,
    UPPER(TRIM(CAST(risk_segment AS VARCHAR(100)))) AS risk_segment,
    UPPER(TRIM(CAST(status AS VARCHAR(100)))) AS status,
    TRY_CONVERT(DATETIME2, opened_at) AS opened_at,
    TRIM(CAST(timezone AS VARCHAR(100))) AS timezone,
    TRIM(CAST(schema_version AS VARCHAR(100))) AS schema_version
INTO stg.accounts
FROM dbo.accounts;


-- for borrowers
SELECT
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRIM(CAST(name AS VARCHAR(255))) AS name,
    TRIM(CAST(phone AS VARCHAR(50))) AS phone,
    TRIM(CAST(email AS VARCHAR(255))) AS email,
    TRIM(CAST(city AS VARCHAR(100))) AS city,
    TRY_CONVERT(DATETIME2, created_at) AS created_at,
    TRY_CONVERT(DATETIME2, updated_at) AS updated_at,
    UPPER(TRIM(CAST(state AS VARCHAR(100)))) AS state
INTO stg.borrowers
FROM dbo.borrowers;

-- for correcting some error used drop 

--for agents
SELECT
    TRIM(CAST(agent_id AS VARCHAR(100))) AS agent_id,
    TRIM(CAST(employee_code AS VARCHAR(100))) AS employee_code,
    TRIM(CAST(agent_name AS VARCHAR(255))) AS agent_name,
    TRIM(CAST(vendor_id AS VARCHAR(100))) AS vendor_id,
    TRIM(CAST(team AS VARCHAR(100))) AS team,
    UPPER(TRIM(CAST(status AS VARCHAR(50)))) AS status,
    TRY_CONVERT(DATETIME2, joined_at) AS joined_at,
    TRY_CONVERT(DATETIME2, updated_at) AS updated_at
INTO stg.agents
FROM dbo.agents;
GO

SELECT
    TRIM(CAST(session_id AS VARCHAR(100))) AS session_id,
    TRIM(CAST(agent_id AS VARCHAR(100))) AS agent_id,
    TRY_CONVERT(DATETIME2, login_at) AS login_at,
    UPPER(TRIM(CAST(channel AS VARCHAR(100)))) AS channel,
    TRIM(CAST(device_id AS VARCHAR(100))) AS device_id,
    TRIM(CAST(timezone AS VARCHAR(100))) AS timezone,
    TRY_CONVERT(DATETIME2, logout_at) AS logout_at
INTO stg.agent_sessions
FROM dbo.agent_sessions;

SELECT
    TRIM(CAST(call_id AS VARCHAR(100))) AS call_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRY_CONVERT(DATETIME2, event_at) AS event_at,
    TRIM(CAST(agent_id AS VARCHAR(100))) AS agent_id,
    TRIM(CAST(campaign_id AS VARCHAR(100))) AS campaign_id,
    UPPER(TRIM(CAST(direction AS VARCHAR(50)))) AS direction,
    TRIM(CAST(vendor_id AS VARCHAR(100))) AS vendor_id,
    UPPER(TRIM(CAST(call_status AS VARCHAR(100)))) AS call_status,
    TRY_CONVERT(INT, duration_sec) AS duration_sec,
    TRIM(CAST(timezone AS VARCHAR(100))) AS timezone
INTO stg.calls
FROM dbo.calls;

SELECT
    TRIM(CAST(attempt_id AS VARCHAR(100))) AS attempt_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRY_CONVERT(DATETIME2, event_at) AS event_at,
    TRIM(CAST(call_id AS VARCHAR(100))) AS call_id,
    TRIM(CAST(agent_id AS VARCHAR(100))) AS agent_id,
    TRY_CONVERT(INT, attempt_no) AS attempt_no,
    TRIM(CAST(vendor_id AS VARCHAR(100))) AS vendor_id,
    UPPER(TRIM(CAST(attempt_status AS VARCHAR(100)))) AS attempt_status
INTO stg.call_attempts
FROM dbo.call_attempts;

SELECT
    TRIM(CAST(disposition_id AS VARCHAR(100))) AS disposition_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRY_CONVERT(DATETIME2, event_at) AS event_at,
    TRIM(CAST(call_id AS VARCHAR(100))) AS call_id,
    TRIM(CAST(agent_id AS VARCHAR(100))) AS agent_id,
    UPPER(TRIM(CAST(disposition_code AS VARCHAR(100)))) AS disposition_code,
    TRIM(CAST(disposition_version AS VARCHAR(100))) AS disposition_version
INTO stg.call_dispositions
FROM dbo.call_dispositions;

SELECT
    TRIM(CAST(campaign_id AS VARCHAR(100))) AS campaign_id,
    TRIM(CAST(campaign_name AS VARCHAR(255))) AS campaign_name,
    UPPER(TRIM(CAST(channel AS VARCHAR(100)))) AS channel,
    TRIM(CAST(strategy_version AS VARCHAR(100))) AS strategy_version,
    TRY_CONVERT(DATETIME2, start_at) AS start_at,
    TRIM(CAST(target_definition AS VARCHAR(1000))) AS target_definition,
    TRY_CONVERT(DATETIME2, end_at) AS end_at
INTO stg.campaigns
FROM dbo.campaigns;

SELECT
    TRIM(CAST(complaint_id AS VARCHAR(100))) AS complaint_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRY_CONVERT(DATETIME2, event_at) AS event_at,
    UPPER(TRIM(CAST(complaint_type AS VARCHAR(100)))) AS complaint_type,
    UPPER(TRIM(CAST(severity AS VARCHAR(50)))) AS severity,
    UPPER(TRIM(CAST(status AS VARCHAR(50)))) AS status,
    UPPER(TRIM(CAST(source AS VARCHAR(100)))) AS source,
    TRY_CONVERT(DATETIME2, resolution_at) AS resolution_at
INTO stg.complaints
FROM dbo.complaints;

SELECT
    TRIM(CAST(target_id AS VARCHAR(100))) AS target_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(campaign_id AS VARCHAR(100))) AS campaign_id,
    TRY_CONVERT(DATE, target_date) AS target_date,
    TRY_CONVERT(INT, priority) AS priority,
    UPPER(TRIM(CAST(recommended_channel AS VARCHAR(100)))) AS recommended_channel,
    UPPER(TRIM(CAST(status AS VARCHAR(100)))) AS status
INTO stg.daily_targeting
FROM dbo.daily_targeting;

SELECT
    TRIM(CAST(visit_id AS VARCHAR(100))) AS visit_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRY_CONVERT(DATETIME2, event_at) AS event_at,
    TRIM(CAST(agent_id AS VARCHAR(100))) AS agent_id,
    UPPER(TRIM(CAST(visit_type AS VARCHAR(100)))) AS visit_type,
    UPPER(TRIM(CAST(outcome AS VARCHAR(100)))) AS outcome,
    TRY_CONVERT(DECIMAL(10,7), latitude) AS latitude,
    TRY_CONVERT(DECIMAL(10,7), longitude) AS longitude,
    TRY_CONVERT(DATETIME2, scheduled_at) AS scheduled_at
INTO stg.field_visits
FROM dbo.field_visits;

SELECT
    TRIM(CAST(payment_id AS VARCHAR(100))) AS payment_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRY_CONVERT(DATETIME2, event_at) AS event_at,
    TRIM(CAST(payment_reference AS VARCHAR(255))) AS payment_reference,
    TRY_CONVERT(DECIMAL(18,2), amount) AS amount,
    UPPER(TRIM(CAST(payment_status AS VARCHAR(100)))) AS payment_status,
    UPPER(TRIM(CAST(payment_method AS VARCHAR(100)))) AS payment_method,
    TRIM(CAST(provider_id AS VARCHAR(100))) AS provider_id
INTO stg.payments
FROM dbo.payments;

SELECT
    TRIM(CAST(ptp_id AS VARCHAR(100))) AS ptp_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRY_CONVERT(DATETIME2, event_at) AS event_at,
    TRIM(CAST(agent_id AS VARCHAR(100))) AS agent_id,
    TRY_CONVERT(DECIMAL(18,2), promised_amount) AS promised_amount,
    TRY_CONVERT(DATE, promised_date) AS promised_date,
    UPPER(TRIM(CAST(status AS VARCHAR(100)))) AS status,
    UPPER(TRIM(CAST(source AS VARCHAR(100)))) AS source
INTO stg.promises_to_pay
FROM dbo.promises_to_pay;

SELECT
    TRIM(CAST(sms_event_id AS VARCHAR(100))) AS sms_event_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRY_CONVERT(DATETIME2, event_at) AS event_at,
    TRIM(CAST(message_id AS VARCHAR(100))) AS message_id,
    UPPER(TRIM(CAST(event_type AS VARCHAR(100)))) AS event_type,
    TRIM(CAST(template_code AS VARCHAR(100))) AS template_code,
    TRIM(CAST(provider_id AS VARCHAR(100))) AS provider_id
INTO stg.sms_events
FROM dbo.sms_events;

SELECT
    TRIM(CAST(vendor_id AS VARCHAR(100))) AS vendor_id,
    TRIM(CAST(vendor_name AS VARCHAR(255))) AS vendor_name,
    TRIM(CAST(vendor_account_id AS VARCHAR(100))) AS vendor_account_id,
    TRIM(CAST(timezone AS VARCHAR(100))) AS timezone,
    UPPER(TRIM(CAST(status AS VARCHAR(50)))) AS status,
    TRIM(CAST(schema_version AS VARCHAR(100))) AS schema_version
INTO stg.vendor_telephony
FROM dbo.vendor_telephony;

SELECT
    TRIM(CAST(whatsapp_event_id AS VARCHAR(100))) AS whatsapp_event_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRY_CONVERT(DATETIME2, event_at) AS event_at,
    TRIM(CAST(message_id AS VARCHAR(100))) AS message_id,
    UPPER(TRIM(CAST(event_type AS VARCHAR(100)))) AS event_type,
    TRIM(CAST(template_code AS VARCHAR(100))) AS template_code,
    TRIM(CAST(provider_id AS VARCHAR(100))) AS provider_id
INTO stg.whatsapp_events
FROM dbo.whatsapp_events;

SELECT
    TRIM(CAST(history_id AS VARCHAR(100))) AS history_id,
    TRIM(CAST(account_id AS VARCHAR(100))) AS account_id,
    TRIM(CAST(borrower_id AS VARCHAR(100))) AS borrower_id,
    TRY_CONVERT(DATETIME2, event_at) AS event_at,
    UPPER(TRIM(CAST(status AS VARCHAR(100)))) AS status,
    TRIM(CAST(changed_by AS VARCHAR(100))) AS changed_by,
    UPPER(TRIM(CAST(source AS VARCHAR(100)))) AS source,
    TRY_CONVERT(DATETIME2, recorded_at) AS recorded_at
INTO stg.account_status_history
FROM dbo.account_status_history;

-- ============================================================

---Audit data type error 
--Date
SELECT *
FROM dbo.calls
WHERE TRY_CONVERT(DATETIME2, event_at) IS NULL
  AND event_at IS NOT NULL;

--Ammount
SELECT *
FROM dbo.payments
WHERE TRY_CONVERT(DECIMAL(18,2), amount) IS NULL
  AND amount IS NOT NULL;

--DPD
SELECT *
FROM dbo.accounts
WHERE TRY_CONVERT(INT, dpd) IS NULL
  AND dpd IS NOT NULL;


CREATE TABLE audit.data_quality_results
(
    run_id            UNIQUEIDENTIFIER,
    table_name        VARCHAR(100),
    check_name        VARCHAR(200),
    severity          VARCHAR(20),
    records_checked   BIGINT,
    records_failed    BIGINT,
    status             VARCHAR(20),
    run_at             DATETIME2 DEFAULT SYSDATETIME()
);
-- ============================================================
-- PRIMARY-KEY DUPLICATE CHECKS
-- ============================================================
-- Total operational tables checked = 17
--
-- Purpose:
-- Identify IDs that appear more than once in the original
-- imported dbo tables.
--
-- IMPORTANT:
-- DO NOT delete any duplicate records at this stage.
-- We will inspect them and determine whether they are:
-- 1. True duplicates
-- 2. Legitimate multiple events
-- 3. Retries
-- 4. Historical/versioned records
-- 5. Data-ingestion duplicates
-- ============================================================


-- 1. ACCOUNTS
SELECT
    account_id,
    COUNT(*) AS cnt
FROM dbo.accounts
GROUP BY account_id
HAVING COUNT(*) > 1;


-- 2. BORROWERS
SELECT
    borrower_id,
    COUNT(*) AS cnt
FROM dbo.borrowers
GROUP BY borrower_id
HAVING COUNT(*) > 1;


-- 3. AGENTS
SELECT
    agent_id,
    COUNT(*) AS cnt
FROM dbo.agents
GROUP BY agent_id
HAVING COUNT(*) > 1;


-- 4. AGENT SESSIONS
SELECT
    session_id,
    COUNT(*) AS cnt
FROM dbo.agent_sessions
GROUP BY session_id
HAVING COUNT(*) > 1;


-- 5. CALLS
SELECT
    call_id,
    COUNT(*) AS cnt
FROM dbo.calls
GROUP BY call_id
HAVING COUNT(*) > 1;


-- 6. CALL ATTEMPTS
SELECT
    attempt_id,
    COUNT(*) AS cnt
FROM dbo.call_attempts
GROUP BY attempt_id
HAVING COUNT(*) > 1;


-- 7. CALL DISPOSITIONS
SELECT
    disposition_id,
    COUNT(*) AS cnt
FROM dbo.call_dispositions
GROUP BY disposition_id
HAVING COUNT(*) > 1;


-- 8. CAMPAIGNS
SELECT
    campaign_id,
    COUNT(*) AS cnt
FROM dbo.campaigns
GROUP BY campaign_id
HAVING COUNT(*) > 1;


-- 9. COMPLAINTS
SELECT
    complaint_id,
    COUNT(*) AS cnt
FROM dbo.complaints
GROUP BY complaint_id
HAVING COUNT(*) > 1;


-- 10. DAILY TARGETING
SELECT
    target_id,
    COUNT(*) AS cnt
FROM dbo.daily_targeting
GROUP BY target_id
HAVING COUNT(*) > 1;


-- 11. FIELD VISITS
SELECT
    visit_id,
    COUNT(*) AS cnt
FROM dbo.field_visits
GROUP BY visit_id
HAVING COUNT(*) > 1;


-- 12. PAYMENTS(Found)
SELECT
    payment_id,
    COUNT(*) AS cnt
FROM dbo.payments
GROUP BY payment_id
HAVING COUNT(*) > 1;


-- 13. PROMISES TO PAY
SELECT
    ptp_id,
    COUNT(*) AS cnt
FROM dbo.promises_to_pay
GROUP BY ptp_id
HAVING COUNT(*) > 1;


-- 14. SMS EVENTS
SELECT
    sms_event_id,
    COUNT(*) AS cnt
FROM dbo.sms_events
GROUP BY sms_event_id
HAVING COUNT(*) > 1;


-- 15. VENDOR TELEPHONY
SELECT
    vendor_id,
    COUNT(*) AS cnt
FROM dbo.vendor_telephony
GROUP BY vendor_id
HAVING COUNT(*) > 1;


-- 16. WHATSAPP EVENTS(Found)
SELECT
    whatsapp_event_id,
    COUNT(*) AS cnt
FROM dbo.whatsapp_events
GROUP BY whatsapp_event_id
HAVING COUNT(*) > 1;


-- 17. ACCOUNT STATUS HISTORY
SELECT
    history_id,
    COUNT(*) AS cnt
FROM dbo.account_status_history
GROUP BY history_id
HAVING COUNT(*) > 1;

-- ============================================================

-- STEP 16.2: QUANTIFY DUPLICATE BORROWER IDS
-- ============================================================

SELECT
    COUNT(*) AS duplicated_borrower_ids,
    SUM(cnt - 1) AS excess_rows
FROM
(
    SELECT
        borrower_id,
        COUNT(*) AS cnt
    FROM dbo.borrowers
    GROUP BY borrower_id
    HAVING COUNT(*) > 1
) d;

-- ============================================================
-- MAXIMUM DUPLICATION PER BORROWER
-- ============================================================

SELECT
    MAX(cnt) AS maximum_records_for_one_borrower
FROM
(
    SELECT
        borrower_id,
        COUNT(*) AS cnt
    FROM dbo.borrowers
    GROUP BY borrower_id
) d;

-- ============================================================
-- STEP 16.3: IDENTIFY BORROWER IDS WITH MULTIPLE RECORDS
-- ============================================================

SELECT
    borrower_id,
    COUNT(*) AS record_count,
    COUNT(DISTINCT name) AS different_names,
    COUNT(DISTINCT phone) AS different_phones,
    COUNT(DISTINCT email) AS different_emails,
    COUNT(DISTINCT city) AS different_cities,
    COUNT(DISTINCT state) AS different_states
FROM dbo.borrowers
GROUP BY borrower_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

SELECT *
FROM dbo.borrowers
WHERE borrower_id = 'BRW0006302'
ORDER BY created_at, updated_at;

SELECT
    account_id,
    borrower_id,
    loan_type,
    principal_amount,
    outstanding_amount,
    dpd,
    risk_segment,
    status,
    opened_at
FROM dbo.accounts
WHERE borrower_id = 'BRW0006302'
ORDER BY opened_at, account_id;

-- ============================================================
-- STEP 16.8: CHECK WHETHER AN ACCOUNT HAS MULTIPLE BORROWER IDs
-- Purpose:
-- Determine whether the same account is associated with
-- more than one borrower_id.
--
-- Interpretation:
-- No rows = each account has one borrower_id
-- Rows returned = account-level identity inconsistency
-- ============================================================

SELECT
    account_id,
    COUNT(DISTINCT borrower_id) AS borrower_count
FROM dbo.accounts
GROUP BY account_id
HAVING COUNT(DISTINCT borrower_id) > 1
ORDER BY borrower_count DESC;

-- ============================================================
-- STEP 16.9: QUANTIFY ACCOUNTS AFFECTED BY DUPLICATE BORROWER IDs
-- Purpose:
-- Determine how many accounts use a borrower_id that appears
-- multiple times in the borrowers table.
-- ============================================================

SELECT
    COUNT(DISTINCT a.account_id) AS affected_accounts
FROM dbo.accounts a
INNER JOIN
(
    SELECT
        borrower_id
    FROM dbo.borrowers
    GROUP BY borrower_id
    HAVING COUNT(*) > 1
) d
    ON a.borrower_id = d.borrower_id;

-- ============================================================
-- STEP 16.9B: QUANTIFY OUTSTANDING BALANCE AFFECTED
-- Purpose:
-- Estimate the outstanding balance associated with accounts
-- linked to duplicate/conflicting borrower IDs.
-- ============================================================

SELECT
    COUNT(DISTINCT a.account_id) AS affected_accounts,
    SUM(a.outstanding_amount) AS affected_outstanding_amount
FROM dbo.accounts a
INNER JOIN
(
    SELECT
        borrower_id
    FROM dbo.borrowers
    GROUP BY borrower_id
    HAVING COUNT(*) > 1
) d
    ON a.borrower_id = d.borrower_id;

-- ============================================================
-- STEP 16.9C: PERCENTAGE OF PORTFOLIO AFFECTED
-- ============================================================

SELECT
    COUNT(DISTINCT CASE
        WHEN d.borrower_id IS NOT NULL
        THEN a.account_id
    END) AS affected_accounts,

    COUNT(DISTINCT a.account_id) AS total_accounts,

    CAST(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN d.borrower_id IS NOT NULL
            THEN a.account_id
        END)
        / NULLIF(COUNT(DISTINCT a.account_id), 0)
        AS DECIMAL(10,2)
    ) AS affected_account_pct
FROM dbo.accounts a
LEFT JOIN
(
    SELECT
        borrower_id
    FROM dbo.borrowers
    GROUP BY borrower_id
    HAVING COUNT(*) > 1
) d
    ON a.borrower_id = d.borrower_id;

    -- ============================================================

-- STEP 17.1: QUANTIFY DUPLICATE AGENT IDs
-- Purpose:
-- Determine how many agent IDs occur more than once
-- and how many excess records exist.
-- ============================================================

SELECT
    COUNT(*) AS duplicated_agent_ids,
    SUM(cnt - 1) AS excess_rows
FROM
(
    SELECT
        agent_id,
        COUNT(*) AS cnt
    FROM dbo.agents
    GROUP BY agent_id
    HAVING COUNT(*) > 1
) d;

-- ============================================================
-- STEP 17.2: IDENTIFY DIFFERENCES IN DUPLICATE AGENT RECORDS
-- Purpose:
-- Determine whether duplicated agent IDs represent:
-- 1. Historical updates
-- 2. Vendor/team changes
-- 3. Status changes
-- 4. Genuine identity conflicts
-- ============================================================

SELECT
    agent_id,
    COUNT(*) AS record_count,
    COUNT(DISTINCT employee_code) AS different_employee_codes,
    COUNT(DISTINCT agent_name) AS different_names,
    COUNT(DISTINCT vendor_id) AS different_vendors,
    COUNT(DISTINCT team) AS different_teams,
    COUNT(DISTINCT status) AS different_statuses,
    COUNT(DISTINCT joined_at) AS different_join_dates,
    COUNT(DISTINCT updated_at) AS different_update_dates
FROM dbo.agents
GROUP BY agent_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- ============================================================
-- STEP 17.3: INSPECT ONE DUPLICATE AGENT IN DETAIL
-- ============================================================

SELECT *
FROM dbo.agents
WHERE agent_id = 'AGT00125'
ORDER BY joined_at, updated_at;

-- ============================================================
-- STEP 17.4: CHECK EMPLOYEE CODE → AGENT ID CONSISTENCY
-- Purpose:
-- Determine whether one employee_code appears under multiple
-- agent_id values.
-- ============================================================

SELECT
    employee_code,
    COUNT(DISTINCT agent_id) AS agent_id_count
FROM dbo.agents
WHERE employee_code IS NOT NULL
GROUP BY employee_code
HAVING COUNT(DISTINCT agent_id) > 1
ORDER BY agent_id_count DESC;

-- ============================================================
-- STEP 17.5: CHECK DUPLICATE EMPLOYEE CODES
-- Purpose:
-- Determine whether employee_code itself is reused.
-- ============================================================

SELECT
    employee_code,
    COUNT(*) AS record_count,
    COUNT(DISTINCT agent_id) AS agent_id_count,
    COUNT(DISTINCT agent_name) AS name_count,
    COUNT(DISTINCT vendor_id) AS vendor_count
FROM dbo.agents
WHERE employee_code IS NOT NULL
GROUP BY employee_code
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- ============================================================

-- STEP 17.7: SAME EMPLOYEE UNDER MULTIPLE AGENT IDs
-- ============================================================

SELECT
    employee_code,
    COUNT(DISTINCT agent_id) AS agent_id_count
FROM dbo.agents
WHERE employee_code IS NOT NULL
GROUP BY employee_code
HAVING COUNT(DISTINCT agent_id) > 1
ORDER BY agent_id_count DESC;

-- ============================================================
-- STEP 17.8: DUPLICATE AGENT IDs USED IN CALLS
-- ============================================================

SELECT
    a.agent_id,
    COUNT(DISTINCT c.call_id) AS call_count,
    COUNT(DISTINCT c.account_id) AS account_count
FROM
(
    SELECT
        agent_id
    FROM dbo.agents
    GROUP BY agent_id
    HAVING COUNT(*) > 1
) a
INNER JOIN dbo.calls c
    ON a.agent_id = c.agent_id
GROUP BY a.agent_id
ORDER BY call_count DESC;

-- ============================================================
-- STEP 17.9: QUANTIFY IMPACT OF DUPLICATE AGENT IDs
-- ============================================================

SELECT
    COUNT(DISTINCT c.call_id) AS affected_calls,
    COUNT(DISTINCT c.account_id) AS affected_accounts,
    COUNT(DISTINCT c.agent_id) AS affected_agent_ids
FROM dbo.calls c
INNER JOIN
(
    SELECT
        agent_id
    FROM dbo.agents
    GROUP BY agent_id
    HAVING COUNT(*) > 1
) d
    ON c.agent_id = d.agent_id;

-- ============================================================
-- STEP 17.10: DUPLICATE AGENT IDs USED IN SESSIONS
-- ============================================================

SELECT
    COUNT(DISTINCT s.session_id) AS affected_sessions,
    COUNT(DISTINCT s.agent_id) AS affected_agent_ids
FROM dbo.agent_sessions s
INNER JOIN
(
    SELECT
        agent_id
    FROM dbo.agents
    GROUP BY agent_id
    HAVING COUNT(*) > 1
) d
    ON s.agent_id = d.agent_id;

-- ============================================================
-- STEP 17.11: CHECK INVALID AGENT TIMELINES
-- ============================================================

SELECT
    COUNT(*) AS invalid_timestamp_records
FROM dbo.agents
WHERE joined_at IS NOT NULL
  AND updated_at IS NOT NULL
  AND updated_at < joined_at;

SELECT *
FROM dbo.agents
WHERE joined_at IS NOT NULL
  AND updated_at IS NOT NULL
  AND updated_at < joined_at
ORDER BY agent_id, joined_at;


-- STEP 17.13: COUNT EMPLOYEE CODES ASSOCIATED WITH
-- DUPLICATED AGENT IDs
-- ============================================================

SELECT
    COUNT(DISTINCT a.employee_code) AS affected_employee_codes
FROM dbo.agents a
INNER JOIN
(
    SELECT
        agent_id
    FROM dbo.agents
    GROUP BY agent_id
    HAVING COUNT(*) > 1
) d
    ON a.agent_id = d.agent_id
WHERE a.employee_code IS NOT NULL;

-- ============================================================
-- STEP 17.14: SAME EMPLOYEE UNDER MULTIPLE AGENT IDs
-- ============================================================

SELECT
    employee_code,
    COUNT(DISTINCT agent_id) AS agent_id_count
FROM dbo.agents
WHERE employee_code IS NOT NULL
GROUP BY employee_code
HAVING COUNT(DISTINCT agent_id) > 1
ORDER BY agent_id_count DESC;


-- STEP 17.18: CHECK EMPLOYEE CODE IDENTITY CONSISTENCY
-- Purpose:
-- Determine whether an employee_code consistently represents
-- one person/name or is itself reused across different names.
-- ============================================================

SELECT
    employee_code,
    COUNT(DISTINCT agent_name) AS name_count,
    COUNT(DISTINCT agent_id) AS agent_id_count,
    COUNT(DISTINCT vendor_id) AS vendor_count,
    COUNT(DISTINCT team) AS team_count
FROM dbo.agents
WHERE employee_code IS NOT NULL
GROUP BY employee_code
HAVING COUNT(DISTINCT agent_name) > 1
    OR COUNT(DISTINCT agent_id) > 1
ORDER BY
    name_count DESC,
    agent_id_count DESC;

-- STEP 18.1: QUANTIFY EXACT DUPLICATE CALLS
-- ============================================================

SELECT
    COUNT(*) AS duplicate_call_ids,
    SUM(cnt - 1) AS excess_call_rows
FROM
(
    SELECT
        call_id,
        COUNT(*) AS cnt
    FROM dbo.calls
    GROUP BY call_id
    HAVING COUNT(*) > 1
) d;

-- ============================================================
-- STEP 18.2: DUPLICATE CALL PERCENTAGE
-- ============================================================

SELECT
    COUNT(*) AS total_call_rows,

    (
        SELECT SUM(cnt - 1)
        FROM
        (
            SELECT
                call_id,
                COUNT(*) AS cnt
            FROM dbo.calls
            GROUP BY call_id
            HAVING COUNT(*) > 1
        ) d
    ) AS duplicate_rows,

    CAST(
        100.0 *
        (
            SELECT SUM(cnt - 1)
            FROM
            (
                SELECT
                    call_id,
                    COUNT(*) AS cnt
                FROM dbo.calls
                GROUP BY call_id
                HAVING COUNT(*) > 1
            ) d
        )
        / NULLIF(COUNT(*),0)
        AS DECIMAL(10,2)
    ) AS duplicate_row_pct

FROM dbo.calls;

-- ============================================================
-- STEP 18.3: CREATE CLEAN CALLS
-- Purpose:
-- Remove confirmed exact duplicate call rows.
-- Original dbo.calls remains unchanged.
-- ============================================================

DROP TABLE IF EXISTS clean.calls;
GO

WITH ranked_calls AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                call_id,
                account_id,
                borrower_id,
                event_at,
                agent_id,
                campaign_id,
                direction,
                vendor_id,
                call_status,
                duration_sec,
                timezone
            ORDER BY call_id
        ) AS rn
    FROM stg.calls
)
SELECT
    call_id,
    account_id,
    borrower_id,
    event_at,
    agent_id,
    campaign_id,
    direction,
    vendor_id,
    call_status,
    duration_sec,
    timezone
INTO clean.calls
FROM ranked_calls
WHERE rn = 1;
GO

-- ============================================================
-- STEP 18.4: VERIFY CLEAN CALL UNIQUENESS
-- ============================================================

SELECT
    call_id,
    COUNT(*) AS cnt
FROM clean.calls
GROUP BY call_id
HAVING COUNT(*) > 1;

-- ============================================================
-- STEP 18.4A: INSPECT DUPLICATE CALL IDs STILL IN CLEAN
-- Purpose:
-- Find out why the same call_id still appears more than once.
-- DO NOT DELETE ANYTHING YET.
-- ============================================================

SELECT *
FROM clean.calls
WHERE call_id IN
(
    SELECT call_id
    FROM clean.calls
    GROUP BY call_id
    HAVING COUNT(*) > 1
)
ORDER BY call_id, event_at;

-- ============================================================
-- STEP 18.4B: COMPARE DUPLICATE CALL RECORDS
-- Purpose:
-- Determine whether duplicate call_ids have differences
-- in account, agent, campaign, vendor, status, duration, etc.
-- ============================================================

SELECT
    call_id,
    COUNT(*) AS record_count,
    COUNT(DISTINCT account_id) AS account_count,
    COUNT(DISTINCT borrower_id) AS borrower_count,
    COUNT(DISTINCT event_at) AS event_time_count,
    COUNT(DISTINCT agent_id) AS agent_count,
    COUNT(DISTINCT campaign_id) AS campaign_count,
    COUNT(DISTINCT vendor_id) AS vendor_count,
    COUNT(DISTINCT direction) AS direction_count,
    COUNT(DISTINCT call_status) AS status_count,
    COUNT(DISTINCT duration_sec) AS duration_count,
    COUNT(DISTINCT timezone) AS timezone_count
FROM clean.calls
GROUP BY call_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- ============================================================
-- STEP 18.5: CLASSIFY REMAINING DUPLICATE CALL IDs
--
-- Purpose:
-- Determine whether repeated call_ids are:
-- 1. Exact duplicates
-- 2. Agent attribution conflicts
-- 3. Timestamp conflicts
-- 4. Account conflicts
-- 5. Campaign/vendor conflicts
-- 6. Status/duration conflicts
--
-- IMPORTANT:
-- DO NOT DELETE ANYTHING YET.
-- ============================================================

SELECT
    call_id,
    COUNT(*) AS record_count,

    COUNT(DISTINCT account_id) AS account_count,
    COUNT(DISTINCT borrower_id) AS borrower_count,
    COUNT(DISTINCT event_at) AS event_time_count,
    COUNT(DISTINCT agent_id) AS agent_count,
    COUNT(DISTINCT campaign_id) AS campaign_count,
    COUNT(DISTINCT vendor_id) AS vendor_count,
    COUNT(DISTINCT direction) AS direction_count,
    COUNT(DISTINCT call_status) AS status_count,
    COUNT(DISTINCT duration_sec) AS duration_count,
    COUNT(DISTINCT timezone) AS timezone_count,

    SUM(CASE WHEN agent_id IS NULL THEN 1 ELSE 0 END) AS null_agent_rows,
    SUM(CASE WHEN event_at IS NULL THEN 1 ELSE 0 END) AS null_event_rows

FROM clean.calls

GROUP BY call_id

HAVING COUNT(*) > 1

ORDER BY
    record_count DESC,
    call_id;

-- ============================================================
-- STEP 18.6: FIND EXACT DUPLICATE CALL RECORDS
-- ============================================================

SELECT
    call_id,
    account_id,
    borrower_id,
    event_at,
    agent_id,
    campaign_id,
    direction,
    vendor_id,
    call_status,
    duration_sec,
    timezone,
    COUNT(*) AS duplicate_count
FROM clean.calls
GROUP BY
    call_id,
    account_id,
    borrower_id,
    event_at,
    agent_id,
    campaign_id,
    direction,
    vendor_id,
    call_status,
    duration_sec,
    timezone
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================
-- STEP 18.7: FIND CONFLICTING DUPLICATE CALL IDs
-- ============================================================

SELECT
    call_id,
    COUNT(*) AS record_count,

    COUNT(DISTINCT account_id) AS account_count,
    COUNT(DISTINCT borrower_id) AS borrower_count,
    COUNT(DISTINCT event_at) AS event_time_count,
    COUNT(DISTINCT agent_id) AS agent_count,
    COUNT(DISTINCT campaign_id) AS campaign_count,
    COUNT(DISTINCT vendor_id) AS vendor_count,
    COUNT(DISTINCT call_status) AS status_count,
    COUNT(DISTINCT duration_sec) AS duration_count,
    COUNT(DISTINCT timezone) AS timezone_count

FROM clean.calls

GROUP BY call_id

HAVING COUNT(*) > 1
   AND
   (
        COUNT(DISTINCT account_id) > 1
        OR COUNT(DISTINCT borrower_id) > 1
        OR COUNT(DISTINCT event_at) > 1
        OR COUNT(DISTINCT agent_id) > 1
        OR COUNT(DISTINCT campaign_id) > 1
        OR COUNT(DISTINCT vendor_id) > 1
        OR COUNT(DISTINCT call_status) > 1
        OR COUNT(DISTINCT duration_sec) > 1
        OR COUNT(DISTINCT timezone) > 1
   )

ORDER BY call_id;

-- ============================================================
-- STEP 18.8: INSPECT CONFLICTING DUPLICATE CALLS
-- ============================================================

SELECT *
FROM clean.calls
WHERE call_id IN
(
    SELECT call_id
    FROM clean.calls
    GROUP BY call_id
    HAVING COUNT(*) > 1
)
ORDER BY call_id, event_at;

-- ============================================================
-- STEP 18.9: INSPECT CALL0001606
-- ============================================================

SELECT *
FROM dbo.calls
WHERE call_id = 'CALL0001606'
ORDER BY event_at;

SELECT *
FROM clean.calls
WHERE call_id = 'CALL0001606'
ORDER BY event_at;

-- ============================================================
-- STEP 18.12: FIND DUPLICATE CALLS WHERE ONLY AGENT_ID DIFFERS
-- ============================================================
-- Purpose:
-- Identify duplicate call_ids where all business/event
-- attributes are identical except for agent_id.
--
-- If one row has a NULL agent_id and another has a populated
-- agent_id, the populated agent_id can be retained.
-- ============================================================

SELECT
    call_id,
    COUNT(*) AS record_count,
    COUNT(DISTINCT account_id) AS account_count,
    COUNT(DISTINCT borrower_id) AS borrower_count,
    COUNT(DISTINCT event_at) AS event_time_count,
    COUNT(DISTINCT campaign_id) AS campaign_count,
    COUNT(DISTINCT vendor_id) AS vendor_count,
    COUNT(DISTINCT direction) AS direction_count,
    COUNT(DISTINCT call_status) AS status_count,
    COUNT(DISTINCT duration_sec) AS duration_count,
    COUNT(DISTINCT timezone) AS timezone_count,
    COUNT(DISTINCT agent_id) AS agent_count,
    SUM(CASE WHEN agent_id IS NULL THEN 1 ELSE 0 END) AS null_agent_rows
FROM dbo.calls
GROUP BY call_id
HAVING COUNT(*) > 1
   AND COUNT(DISTINCT account_id) = 1
   AND COUNT(DISTINCT borrower_id) = 1
   AND COUNT(DISTINCT event_at) = 1
   AND COUNT(DISTINCT campaign_id) = 1
   AND COUNT(DISTINCT vendor_id) = 1
   AND COUNT(DISTINCT direction) = 1
   AND COUNT(DISTINCT call_status) = 1
   AND COUNT(DISTINCT duration_sec) = 1
   AND COUNT(DISTINCT timezone) = 1
   AND COUNT(DISTINCT agent_id) = 2
   AND SUM(CASE WHEN agent_id IS NULL THEN 1 ELSE 0 END) >= 1
ORDER BY call_id;

-- ============================================================
-- STEP 18.13: CHECK NULL-AGENT DUPLICATE PATTERN
-- ============================================================

SELECT
    call_id,
    MAX(agent_id) AS populated_agent_id,
    SUM(CASE WHEN agent_id IS NULL THEN 1 ELSE 0 END) AS null_agent_rows,
    COUNT(*) AS total_rows
FROM dbo.calls
GROUP BY call_id
HAVING COUNT(*) > 1
   AND SUM(CASE WHEN agent_id IS NULL THEN 1 ELSE 0 END) > 0
ORDER BY call_id;

-- ============================================================
-- STEP 18.14: FIND CALLS WITH MULTIPLE NON-NULL AGENTS
-- ============================================================
-- Purpose:
-- Detect calls where the same call_id is attributed to
-- two different actual agents.
-- ============================================================

SELECT
    call_id,
    COUNT(DISTINCT agent_id) AS non_null_agent_count
FROM dbo.calls
WHERE agent_id IS NOT NULL
GROUP BY call_id
HAVING COUNT(DISTINCT agent_id) > 1
ORDER BY non_null_agent_count DESC;

-- ============================================================
-- STEP 18.15: IDENTIFY OTHER CALL ATTRIBUTION CONFLICTS
-- ============================================================

SELECT
    call_id,
    COUNT(DISTINCT account_id) AS account_count,
    COUNT(DISTINCT borrower_id) AS borrower_count,
    COUNT(DISTINCT campaign_id) AS campaign_count,
    COUNT(DISTINCT vendor_id) AS vendor_count,
    COUNT(DISTINCT call_status) AS status_count,
    COUNT(DISTINCT event_at) AS event_time_count
FROM dbo.calls
GROUP BY call_id
HAVING COUNT(*) > 1
   AND
   (
        COUNT(DISTINCT account_id) > 1
        OR COUNT(DISTINCT borrower_id) > 1
        OR COUNT(DISTINCT campaign_id) > 1
        OR COUNT(DISTINCT vendor_id) > 1
        OR COUNT(DISTINCT call_status) > 1
        OR COUNT(DISTINCT event_at) > 1
   )
ORDER BY call_id;

-- STEP 18.16: INSPECT TIMESTAMP-CONFLICTING CALLS
--
-- Purpose:
-- Retrieve the complete source records for call_ids where
-- event_at is the only differing attribute.
-- ============================================================

SELECT *
FROM dbo.calls
WHERE call_id IN
(
    SELECT call_id
    FROM dbo.calls
    GROUP BY call_id
    HAVING COUNT(*) > 1
       AND COUNT(DISTINCT account_id) = 1
       AND COUNT(DISTINCT borrower_id) = 1
       AND COUNT(DISTINCT event_at) > 1
       AND COUNT(DISTINCT agent_id) = 1
       AND COUNT(DISTINCT campaign_id) = 1
       AND COUNT(DISTINCT vendor_id) = 1
       AND COUNT(DISTINCT call_status) = 1
       AND COUNT(DISTINCT duration_sec) = 1
       AND COUNT(DISTINCT timezone) = 1
)
ORDER BY call_id, event_at;

-- ============================================================
-- STEP 18.17: MEASURE TIMESTAMP DIFFERENCE
--
-- Purpose:
-- Determine how far apart the duplicate timestamps are.
-- ============================================================

WITH duplicate_calls AS
(
    SELECT
        call_id,
        MIN(event_at) AS first_event_at,
        MAX(event_at) AS second_event_at
    FROM dbo.calls
    GROUP BY call_id
    HAVING COUNT(*) > 1
       AND COUNT(DISTINCT account_id) = 1
       AND COUNT(DISTINCT borrower_id) = 1
       AND COUNT(DISTINCT event_at) > 1
       AND COUNT(DISTINCT agent_id) = 1
       AND COUNT(DISTINCT campaign_id) = 1
       AND COUNT(DISTINCT vendor_id) = 1
       AND COUNT(DISTINCT call_status) = 1
       AND COUNT(DISTINCT duration_sec) = 1
       AND COUNT(DISTINCT timezone) = 1
)
SELECT
    call_id,
    first_event_at,
    second_event_at,
    DATEDIFF(SECOND, first_event_at, second_event_at)
        AS difference_seconds,
    DATEDIFF(MINUTE, first_event_at, second_event_at)
        AS difference_minutes
FROM duplicate_calls
ORDER BY difference_seconds DESC;

-- ============================================================
-- STEP 18.18: DISTRIBUTION OF TIMESTAMP DIFFERENCES
-- ============================================================

WITH duplicate_calls AS
(
    SELECT
        call_id,
        MIN(event_at) AS first_event_at,
        MAX(event_at) AS second_event_at
    FROM dbo.calls
    GROUP BY call_id
    HAVING COUNT(*) > 1
       AND COUNT(DISTINCT account_id) = 1
       AND COUNT(DISTINCT borrower_id) = 1
       AND COUNT(DISTINCT event_at) > 1
       AND COUNT(DISTINCT agent_id) = 1
       AND COUNT(DISTINCT campaign_id) = 1
       AND COUNT(DISTINCT vendor_id) = 1
       AND COUNT(DISTINCT call_status) = 1
       AND COUNT(DISTINCT duration_sec) = 1
       AND COUNT(DISTINCT timezone) = 1
)
SELECT
    DATEDIFF(MINUTE, first_event_at, second_event_at)
        AS difference_minutes,
    COUNT(*) AS call_count
FROM duplicate_calls
GROUP BY
    DATEDIFF(MINUTE, first_event_at, second_event_at)
ORDER BY
    difference_minutes;

-- ============================================================
-- STEP 18.19: CHECK DATE SHIFT IN DUPLICATE CALLS
-- ============================================================

WITH duplicate_calls AS
(
    SELECT
        call_id,
        MIN(event_at) AS first_event_at,
        MAX(event_at) AS second_event_at
    FROM dbo.calls
    GROUP BY call_id
    HAVING COUNT(*) > 1
       AND COUNT(DISTINCT account_id) = 1
       AND COUNT(DISTINCT borrower_id) = 1
       AND COUNT(DISTINCT event_at) > 1
       AND COUNT(DISTINCT agent_id) = 1
       AND COUNT(DISTINCT campaign_id) = 1
       AND COUNT(DISTINCT vendor_id) = 1
       AND COUNT(DISTINCT call_status) = 1
       AND COUNT(DISTINCT duration_sec) = 1
       AND COUNT(DISTINCT timezone) = 1
)
SELECT
    call_id,
    first_event_at,
    second_event_at,
    CAST(first_event_at AS DATE) AS first_date,
    CAST(second_event_at AS DATE) AS second_date,
    CASE
        WHEN CAST(first_event_at AS DATE)
           <> CAST(second_event_at AS DATE)
        THEN 'DATE_SHIFT'
        ELSE 'SAME_DATE'
    END AS date_check
FROM duplicate_calls
ORDER BY call_id;

-- ============================================================
-- STEP 18.20: CROSS-CHECK CALL WITH CALL ATTEMPTS
-- Replace CALL0000226 with an actual duplicate call_id.
-- ============================================================

SELECT *
FROM dbo.call_attempts
WHERE call_id = 'CALL0000226'
ORDER BY event_at;

-- ============================================================
-- CROSS-CHECK CALL WITH DISPOSITIONS
-- ============================================================

SELECT *
FROM dbo.call_dispositions
WHERE call_id = 'CALL0000226'
ORDER BY event_at;

-- ============================================================
-- STEP 18.25: FIND ALL CALL IDs WITH ACCOUNT/ATTEMPT MISMATCH
-- ============================================================
-- Purpose:
-- Determine how many call_ids connect the calls table to
-- attempts belonging to different accounts.
--
-- If rows are returned, call_id is not a reliable account-level
-- event key.
-- ============================================================

SELECT
    c.call_id,
    c.account_id AS calls_account_id,
    a.account_id AS attempt_account_id,
    c.event_at AS calls_event_at,
    a.event_at AS attempt_event_at,
    c.agent_id AS calls_agent_id,
    a.agent_id AS attempt_agent_id,
    c.vendor_id AS calls_vendor_id,
    a.vendor_id AS attempt_vendor_id,
    a.attempt_id,
    a.attempt_no,
    a.attempt_status
FROM dbo.calls c
INNER JOIN dbo.call_attempts a
    ON c.call_id = a.call_id
WHERE c.account_id <> a.account_id
   OR (c.account_id IS NULL AND a.account_id IS NOT NULL)
   OR (c.account_id IS NOT NULL AND a.account_id IS NULL)
ORDER BY c.call_id, a.event_at;

-- ============================================================
-- STEP 18.26: QUANTIFY CALL → ATTEMPT ACCOUNT MISMATCH
-- ============================================================

SELECT
    COUNT(DISTINCT a.call_id) AS affected_call_ids,
    COUNT(DISTINCT a.attempt_id) AS affected_attempts,
    COUNT(DISTINCT a.account_id) AS affected_accounts
FROM dbo.call_attempts a
INNER JOIN dbo.calls c
    ON a.call_id = c.call_id
WHERE c.account_id <> a.account_id
   OR (c.account_id IS NULL AND a.account_id IS NOT NULL)
   OR (c.account_id IS NOT NULL AND a.account_id IS NULL);

-- ============================================================
-- STEP 18.27: QUANTIFY CALL → ATTEMPT BORROWER MISMATCH
-- ============================================================

SELECT
    COUNT(DISTINCT a.call_id) AS affected_call_ids,
    COUNT(DISTINCT a.attempt_id) AS affected_attempts,
    COUNT(DISTINCT a.borrower_id) AS affected_borrowers
FROM dbo.call_attempts a
INNER JOIN dbo.calls c
    ON a.call_id = c.call_id
WHERE c.borrower_id <> a.borrower_id
   OR (c.borrower_id IS NULL AND a.borrower_id IS NOT NULL)
   OR (c.borrower_id IS NOT NULL AND a.borrower_id IS NULL);

-- ============================================================
-- STEP 18.28: QUANTIFY CALL → ATTEMPT AGENT MISMATCH
-- ============================================================

SELECT
    COUNT(DISTINCT a.call_id) AS affected_call_ids,
    COUNT(DISTINCT a.attempt_id) AS affected_attempts
FROM dbo.call_attempts a
INNER JOIN dbo.calls c
    ON a.call_id = c.call_id
WHERE c.agent_id <> a.agent_id
   OR (c.agent_id IS NULL AND a.agent_id IS NOT NULL)
   OR (c.agent_id IS NOT NULL AND a.agent_id IS NULL);

-- ============================================================
-- STEP 18.29: QUANTIFY CALL → ATTEMPT VENDOR MISMATCH
-- ============================================================

SELECT
    COUNT(DISTINCT a.call_id) AS affected_call_ids,
    COUNT(DISTINCT a.attempt_id) AS affected_attempts
FROM dbo.call_attempts a
INNER JOIN dbo.calls c
    ON a.call_id = c.call_id
WHERE c.vendor_id <> a.vendor_id
   OR (c.vendor_id IS NULL AND a.vendor_id IS NOT NULL)
   OR (c.vendor_id IS NOT NULL AND a.vendor_id IS NULL);

-- ============================================================
-- STEP 18.30: QUANTIFY CALL → ATTEMPT TIMESTAMP MISMATCH
-- ============================================================

SELECT
    COUNT(DISTINCT a.call_id) AS affected_call_ids,
    COUNT(DISTINCT a.attempt_id) AS affected_attempts
FROM dbo.call_attempts a
INNER JOIN dbo.calls c
    ON a.call_id = c.call_id
WHERE c.event_at <> a.event_at
   OR (c.event_at IS NULL AND a.event_at IS NOT NULL)
   OR (c.event_at IS NOT NULL AND a.event_at IS NULL);

-- ============================================================
-- STEP 18.31: VALIDATE ATTEMPT_ID AS EVENT KEY
-- ============================================================

SELECT
    attempt_id,
    COUNT(*) AS cnt
FROM dbo.call_attempts
GROUP BY attempt_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

-- ============================================================
-- STEP 18.32: CHECK ATTEMPT_ID ATTRIBUTE CONSISTENCY
-- ============================================================

SELECT
    attempt_id,
    COUNT(DISTINCT account_id) AS account_count,
    COUNT(DISTINCT borrower_id) AS borrower_count,
    COUNT(DISTINCT event_at) AS event_count,
    COUNT(DISTINCT agent_id) AS agent_count,
    COUNT(DISTINCT call_id) AS call_id_count,
    COUNT(DISTINCT attempt_no) AS attempt_no_count,
    COUNT(DISTINCT vendor_id) AS vendor_count,
    COUNT(DISTINCT attempt_status) AS status_count
FROM dbo.call_attempts
GROUP BY attempt_id
HAVING
       COUNT(DISTINCT account_id) > 1
    OR COUNT(DISTINCT borrower_id) > 1
    OR COUNT(DISTINCT event_at) > 1
    OR COUNT(DISTINCT agent_id) > 1
    OR COUNT(DISTINCT call_id) > 1
    OR COUNT(DISTINCT attempt_no) > 1
    OR COUNT(DISTINCT vendor_id) > 1
    OR COUNT(DISTINCT attempt_status) > 1
ORDER BY attempt_id;

-- ============================================================

-- STEP 18.31: CHECK ATTEMPT_ID UNIQUENESS
-- Purpose:
-- Determine whether attempt_id itself is duplicated.(No Duplicates)
-- ============================================================

SELECT
    attempt_id,
    COUNT(*) AS cnt
FROM dbo.call_attempts
GROUP BY attempt_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

-- ============================================================
-- STEP 18.32: CHECK ATTEMPT_ID ATTRIBUTE CONSISTENCY
-- Purpose:
-- Verify that each attempt_id corresponds to one account,
-- borrower, call, timestamp, agent, vendor and status.(NO duplicate)
-- ============================================================

SELECT
    attempt_id,

    COUNT(DISTINCT account_id) AS account_count,
    COUNT(DISTINCT borrower_id) AS borrower_count,
    COUNT(DISTINCT call_id) AS call_id_count,
    COUNT(DISTINCT event_at) AS event_count,
    COUNT(DISTINCT agent_id) AS agent_count,
    COUNT(DISTINCT attempt_no) AS attempt_no_count,
    COUNT(DISTINCT vendor_id) AS vendor_count,
    COUNT(DISTINCT attempt_status) AS status_count

FROM dbo.call_attempts

GROUP BY attempt_id

HAVING
       COUNT(DISTINCT account_id) > 1
    OR COUNT(DISTINCT borrower_id) > 1
    OR COUNT(DISTINCT call_id) > 1
    OR COUNT(DISTINCT event_at) > 1
    OR COUNT(DISTINCT agent_id) > 1
    OR COUNT(DISTINCT attempt_no) > 1
    OR COUNT(DISTINCT vendor_id) > 1
    OR COUNT(DISTINCT attempt_status) > 1

ORDER BY attempt_id;

-- ============================================================
-- STEP 18.33: ATTEMPT_ID → ACCOUNT CONSISTENCY(No duplicates)
-- ============================================================

SELECT
    attempt_id,
    COUNT(DISTINCT account_id) AS account_count
FROM dbo.call_attempts
GROUP BY attempt_id
HAVING COUNT(DISTINCT account_id) > 1;

-- ============================================================
-- STEP 18.34: ATTEMPT_ID → BORROWER CONSISTENCY (No duplicates)
-- ============================================================

SELECT
    attempt_id,
    COUNT(DISTINCT borrower_id) AS borrower_count
FROM dbo.call_attempts
GROUP BY attempt_id
HAVING COUNT(DISTINCT borrower_id) > 1;

-- ============================================================
-- STEP 18.35: CALL_ID → ATTEMPT_ID RELATIONSHIP
-- Purpose:
-- Understand whether one call_id is grouping multiple attempts.
-- ============================================================

SELECT
    call_id,
    COUNT(DISTINCT attempt_id) AS attempt_count
FROM dbo.call_attempts
GROUP BY call_id
HAVING COUNT(DISTINCT attempt_id) > 1
ORDER BY attempt_count DESC;

-- ============================================================
-- STEP 18.36: QUANTIFY CALL_ID REUSE
-- ============================================================

SELECT
    COUNT(*) AS reused_call_ids,
    SUM(attempt_count - 1) AS excess_attempt_links
FROM
(
    SELECT
        call_id,
        COUNT(DISTINCT attempt_id) AS attempt_count
    FROM dbo.call_attempts
    GROUP BY call_id
    HAVING COUNT(DISTINCT attempt_id) > 1
) x;


-- STEP 19.1: QUANTIFY DUPLICATE WHATSAPP EVENT IDs
-- Purpose:
-- Identify how many whatsapp_event_ids are duplicated and
-- how many excess records they create.
-- ============================================================

SELECT
    COUNT(*) AS duplicated_whatsapp_ids,
    SUM(cnt - 1) AS excess_whatsapp_rows
FROM
(
    SELECT
        whatsapp_event_id,
        COUNT(*) AS cnt
    FROM dbo.whatsapp_events
    GROUP BY whatsapp_event_id
    HAVING COUNT(*) > 1
) d;

-- ============================================================
-- STEP 19.2: WHATSAPP DUPLICATE IMPACT
-- ============================================================

SELECT
    COUNT(*) AS total_whatsapp_rows,

    (
        SELECT SUM(cnt - 1)
        FROM
        (
            SELECT
                whatsapp_event_id,
                COUNT(*) AS cnt
            FROM dbo.whatsapp_events
            GROUP BY whatsapp_event_id
            HAVING COUNT(*) > 1
        ) d
    ) AS excess_duplicate_rows,

    CAST(
        100.0 *
        (
            SELECT SUM(cnt - 1)
            FROM
            (
                SELECT
                    whatsapp_event_id,
                    COUNT(*) AS cnt
                FROM dbo.whatsapp_events
                GROUP BY whatsapp_event_id
                HAVING COUNT(*) > 1
            ) d
        )
        / NULLIF(COUNT(*),0)
        AS DECIMAL(10,2)
    ) AS duplicate_row_pct

FROM dbo.whatsapp_events;

-- ============================================================
-- STEP 19.3: FIND EXACT DUPLICATE WHATSAPP RECORDS
-- ============================================================

SELECT
    whatsapp_event_id,
    account_id,
    borrower_id,
    event_at,
    message_id,
    event_type,
    template_code,
    provider_id,
    COUNT(*) AS duplicate_count
FROM dbo.whatsapp_events
GROUP BY
    whatsapp_event_id,
    account_id,
    borrower_id,
    event_at,
    message_id,
    event_type,
    template_code,
    provider_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================
-- STEP 19.4: CHECK MESSAGE_ID DUPLICATION
-- Purpose:
-- Determine how many events belong to the same WhatsApp message.
-- ============================================================

SELECT
    message_id,
    COUNT(*) AS event_count,
    COUNT(DISTINCT whatsapp_event_id) AS whatsapp_event_count,
    COUNT(DISTINCT event_type) AS event_type_count
FROM dbo.whatsapp_events
WHERE message_id IS NOT NULL
GROUP BY message_id
HAVING COUNT(*) > 1
ORDER BY event_count DESC;

-- ============================================================
-- STEP 19.5: CHECK WHATSAPP EVENT-ID ATTRIBUTE CONFLICTS (No duplicates)
-- ============================================================

SELECT
    whatsapp_event_id,
    COUNT(*) AS record_count,
    COUNT(DISTINCT account_id) AS account_count,
    COUNT(DISTINCT borrower_id) AS borrower_count,
    COUNT(DISTINCT event_at) AS event_time_count,
    COUNT(DISTINCT message_id) AS message_count,
    COUNT(DISTINCT event_type) AS event_type_count,
    COUNT(DISTINCT template_code) AS template_count,
    COUNT(DISTINCT provider_id) AS provider_count
FROM dbo.whatsapp_events
GROUP BY whatsapp_event_id
HAVING COUNT(*) > 1
   AND
   (
        COUNT(DISTINCT account_id) > 1
        OR COUNT(DISTINCT borrower_id) > 1
        OR COUNT(DISTINCT event_at) > 1
        OR COUNT(DISTINCT message_id) > 1
        OR COUNT(DISTINCT event_type) > 1
        OR COUNT(DISTINCT template_code) > 1
        OR COUNT(DISTINCT provider_id) > 1
   )
ORDER BY whatsapp_event_id;

-- ============================================================
-- STEP 19.6: WHATSAPP EVENT-TYPE DISTRIBUTION
-- ============================================================

SELECT
    event_type,
    COUNT(*) AS records
FROM dbo.whatsapp_events
GROUP BY event_type
ORDER BY records DESC;

-- ============================================================
-- STEP 19.7: DUPLICATE WHATSAPP IMPACT BY EVENT TYPE
-- ============================================================

SELECT
    event_type,
    COUNT(*) AS total_records,
    COUNT(DISTINCT whatsapp_event_id) AS unique_event_ids
FROM dbo.whatsapp_events
GROUP BY event_type
ORDER BY total_records DESC;

-- ============================================================
-- STEP 19.8: RECORD WHATSAPP DUPLICATE FINDINGS
-- ============================================================

INSERT INTO audit.duplicate_records
(
    table_name,
    key_column,
    key_value,
    duplicate_count,
    classification,
    treatment,
    business_impact
)
SELECT
    'whatsapp_events',
    'whatsapp_event_id',
    CAST(whatsapp_event_id AS VARCHAR(200)),
    COUNT(*) AS duplicate_count,
    'EXACT_DUPLICATE' AS classification,
    'KEEP_ONE_COPY_IN_CLEAN' AS treatment,
    'Duplicate WhatsApp events can inflate digital engagement and downstream channel-conversion metrics.'
FROM dbo.whatsapp_events
GROUP BY whatsapp_event_id
HAVING COUNT(*) > 1;

-- ============================================================
-- STEP 19.9: CREATE CLEAN WHATSAPP EVENTS
--
-- Treatment:
-- For exact duplicate rows, retain one copy.
-- Original dbo.whatsapp_events remains unchanged.
-- ============================================================

DROP TABLE IF EXISTS clean.whatsapp_events;
GO

WITH ranked_whatsapp AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                whatsapp_event_id,
                account_id,
                borrower_id,
                event_at,
                message_id,
                event_type,
                template_code,
                provider_id
            ORDER BY whatsapp_event_id
        ) AS rn
    FROM stg.whatsapp_events
)
SELECT
    whatsapp_event_id,
    account_id,
    borrower_id,
    event_at,
    message_id,
    event_type,
    template_code,
    provider_id
INTO clean.whatsapp_events
FROM ranked_whatsapp
WHERE rn = 1;
GO

-- ============================================================
-- STEP 19.10: VERIFY CLEAN WHATSAPP UNIQUENESS
-- ============================================================

SELECT
    whatsapp_event_id,
    COUNT(*) AS cnt
FROM clean.whatsapp_events
GROUP BY whatsapp_event_id
HAVING COUNT(*) > 1;

-- ============================================================
-- STEP 19.11: WHATSAPP CLEANING IMPACT
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM dbo.whatsapp_events)
        AS imported_rows,

    (SELECT COUNT(*) FROM stg.whatsapp_events)
        AS staging_rows,

    (SELECT COUNT(*) FROM clean.whatsapp_events)
        AS clean_rows,

    (SELECT COUNT(*) FROM dbo.whatsapp_events)
        -
    (SELECT COUNT(*) FROM clean.whatsapp_events)
        AS removed_rows;

-- ============================================================
-- STEP 19.12: WHATSAPP CLEANING PERCENTAGE
-- ============================================================

SELECT
    CAST(
        100.0 *
        (
            (SELECT COUNT(*) FROM dbo.whatsapp_events)
            -
            (SELECT COUNT(*) FROM clean.whatsapp_events)
        )
        /
        NULLIF(
            (SELECT COUNT(*) FROM dbo.whatsapp_events), 0
        )
        AS DECIMAL(10,2)
    ) AS removed_percentage;

-- ============================================================
-- STEP 19.13: WHATSAPP → ACCOUNT REFERENTIAL INTEGRITY CHECK
-- Purpose:
-- Check whether WhatsApp events reference an account that
-- exists in the staging accounts table.
--
-- We use STG here because CLEAN tables have not been created yet.
-- ============================================================

SELECT
    COUNT(*) AS orphan_whatsapp_events
FROM stg.whatsapp_events w
LEFT JOIN stg.accounts a
    ON w.account_id = a.account_id
WHERE a.account_id IS NULL;

-- ============================================================
-- STEP 19.13B: INSPECT ORPHAN WHATSAPP EVENTS
-- ============================================================

SELECT
    w.*
FROM stg.whatsapp_events w
LEFT JOIN stg.accounts a
    ON w.account_id = a.account_id
WHERE a.account_id IS NULL
ORDER BY w.event_at;

-- ============================================================

-- STEP 20.1: PAYMENT STATUS DISTRIBUTION
-- Purpose:
-- Understand all payment statuses and their financial value
-- before deciding which transactions represent valid recovery.
-- ============================================================

SELECT
    payment_status,
    COUNT(*) AS payment_records,
    SUM(amount) AS total_amount
FROM dbo.payments
GROUP BY payment_status
ORDER BY total_amount DESC;

-- ============================================================
-- STEP 20.2: QUANTIFY DUPLICATE PAYMENT IDs
-- Purpose:
-- Determine how many payment IDs appear more than once and
-- how many excess payment records they create.
-- ============================================================

SELECT
    COUNT(*) AS duplicated_payment_ids,
    SUM(cnt - 1) AS excess_payment_rows
FROM
(
    SELECT
        payment_id,
        COUNT(*) AS cnt
    FROM dbo.payments
    GROUP BY payment_id
    HAVING COUNT(*) > 1
) d;

-- ============================================================
-- STEP 20.3: INSPECT DUPLICATE PAYMENT RECORDS
-- Purpose:
-- Retrieve all records where payment_id appears more than once.
-- Do not delete anything.
-- ============================================================

SELECT
    payment_id,
    account_id,
    borrower_id,
    event_at,
    payment_reference,
    amount,
    payment_status,
    payment_method,
    provider_id
FROM dbo.payments
WHERE payment_id IN
(
    SELECT payment_id
    FROM dbo.payments
    GROUP BY payment_id
    HAVING COUNT(*) > 1
)
ORDER BY payment_id, event_at;

-- ============================================================
-- STEP 20.4: VERIFY EXACT PAYMENT DUPLICATES
-- Purpose:
-- Check whether duplicate payment IDs have identical financial
-- and identifying attributes.
-- ============================================================

SELECT
    payment_id,
    account_id,
    borrower_id,
    event_at,
    payment_reference,
    amount,
    payment_status,
    payment_method,
    provider_id,
    COUNT(*) AS duplicate_count
FROM dbo.payments
GROUP BY
    payment_id,
    account_id,
    borrower_id,
    event_at,
    payment_reference,
    amount,
    payment_status,
    payment_method,
    provider_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================
-- STEP 20.5: CHECK DUPLICATE PAYMENT REFERENCES
-- Purpose:
-- Identify cases where the same payment reference appears
-- multiple times, including under different payment IDs.
-- ============================================================

SELECT
    payment_reference,
    COUNT(*) AS record_count,
    COUNT(DISTINCT payment_id) AS payment_id_count,
    COUNT(DISTINCT account_id) AS account_count,
    COUNT(DISTINCT amount) AS amount_count,
    SUM(amount) AS total_amount
FROM dbo.payments
WHERE payment_reference IS NOT NULL
GROUP BY payment_reference
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- ============================================================
-- STEP 20.6: INSPECT DUPLICATE PAYMENT REFERENCES
-- ============================================================

SELECT
    payment_id,
    account_id,
    borrower_id,
    event_at,
    payment_reference,
    amount,
    payment_status,
    payment_method,
    provider_id
FROM dbo.payments
WHERE payment_reference IN
(
    SELECT payment_reference
    FROM dbo.payments
    WHERE payment_reference IS NOT NULL
    GROUP BY payment_reference
    HAVING COUNT(*) > 1
)
ORDER BY payment_reference, event_at;

-- ============================================================
-- STEP 20.7: SAME ACCOUNT + DATE + AMOUNT
-- Purpose:
-- Find payment combinations that require investigation.
-- These are NOT automatically duplicates.
-- ============================================================

SELECT
    account_id,
    CAST(event_at AS DATE) AS payment_date,
    amount,
    COUNT(*) AS record_count,
    COUNT(DISTINCT payment_id) AS payment_id_count,
    COUNT(DISTINCT payment_reference) AS reference_count
FROM dbo.payments
GROUP BY
    account_id,
    CAST(event_at AS DATE),
    amount
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- ============================================================
-- STEP 20.8: STATUS DISTRIBUTION OF DUPLICATE PAYMENT IDs
-- ============================================================

SELECT
    payment_status,
    COUNT(*) AS records,
    SUM(amount) AS total_amount
FROM dbo.payments
WHERE payment_id IN
(
    SELECT payment_id
    FROM dbo.payments
    GROUP BY payment_id
    HAVING COUNT(*) > 1
)
GROUP BY payment_status
ORDER BY total_amount DESC;

-- ============================================================
-- STEP 20.9: POTENTIALLY DUPLICATED SUCCESSFUL AMOUNT
-- IMPORTANT:
-- This is an amount requiring reconciliation.
-- It is NOT yet confirmed inflated recovery.
-- ============================================================

SELECT
    COUNT(*) AS duplicate_success_rows,
    SUM(amount) AS potentially_duplicated_success_amount
FROM dbo.payments
WHERE payment_status = 'SUCCESS'
  AND payment_id IN
  (
      SELECT payment_id
      FROM dbo.payments
      GROUP BY payment_id
      HAVING COUNT(*) > 1
  );

  -- ============================================================
-- STEP 20.10: PAYMENT → ACCOUNT REFERENTIAL INTEGRITY
-- ============================================================

SELECT
    COUNT(*) AS orphan_payment_records
FROM stg.payments p
LEFT JOIN stg.accounts a
    ON p.account_id = a.account_id
WHERE a.account_id IS NULL;

-- ============================================================
-- STEP 20.11: PAYMENT → ACCOUNT/BORROWER CONSISTENCY
-- ============================================================

SELECT
    COUNT(*) AS borrower_account_mismatches
FROM stg.payments p
INNER JOIN stg.accounts a
    ON p.account_id = a.account_id
WHERE
    p.borrower_id <> a.borrower_id
    OR (p.borrower_id IS NULL AND a.borrower_id IS NOT NULL)
    OR (p.borrower_id IS NOT NULL AND a.borrower_id IS NULL);

-- ============================================================
-- STEP 20.12: PAYMENT DATE RANGE
-- ============================================================

SELECT
    MIN(event_at) AS earliest_payment,
    MAX(event_at) AS latest_payment,
    COUNT(*) AS payment_records,
    SUM(amount) AS total_payment_amount
FROM stg.payments;

-- ============================================================
-- STEP 20.13: SUCCESS → REVERSED PAYMENT CHECK
-- Purpose:
-- Identify successful payments that may later have been reversed.
-- ============================================================

SELECT
    s.payment_id AS success_payment_id,
    s.account_id,
    s.event_at AS success_time,
    s.payment_reference AS success_reference,
    s.amount AS success_amount,

    r.payment_id AS reversed_payment_id,
    r.event_at AS reversed_time,
    r.payment_reference AS reversed_reference,
    r.amount AS reversed_amount

FROM dbo.payments s
INNER JOIN dbo.payments r
    ON s.account_id = r.account_id
    AND s.amount = r.amount
    AND r.event_at > s.event_at

WHERE s.payment_status = 'SUCCESS'
  AND r.payment_status = 'REVERSED'

ORDER BY s.account_id, s.event_at;

-- ============================================================
-- STEP 20.14: SUCCESS → REVERSED WITHIN 30 DAYS
-- ============================================================

SELECT
    COUNT(*) AS possible_success_reversal_pairs,
    SUM(s.amount) AS possible_reversed_success_amount

FROM dbo.payments s
INNER JOIN dbo.payments r
    ON s.account_id = r.account_id
    AND s.amount = r.amount
    AND r.event_at > s.event_at
    AND r.event_at <= DATEADD(DAY, 30, s.event_at)

WHERE s.payment_status = 'SUCCESS'
  AND r.payment_status = 'REVERSED';

-- ============================================================
-- STEP 20.15: PAYMENT REFERENCE STATUS CONFLICTS
-- Purpose:
-- Determine whether the same payment reference appears
-- with different payment statuses.
--
-- This helps distinguish duplicate ingestion from legitimate
-- payment lifecycle/retry events.
-- ============================================================

SELECT
    payment_reference,
    COUNT(*) AS record_count,
    COUNT(DISTINCT payment_id) AS payment_id_count,
    COUNT(DISTINCT payment_status) AS status_count,

    SUM(CASE
        WHEN payment_status = 'SUCCESS'
        THEN amount ELSE 0
    END) AS success_amount,

    SUM(CASE
        WHEN payment_status = 'FAILED'
        THEN amount ELSE 0
    END) AS failed_amount,

    SUM(CASE
        WHEN payment_status = 'PENDING'
        THEN amount ELSE 0
    END) AS pending_amount,

    SUM(CASE
        WHEN payment_status = 'REVERSED'
        THEN amount ELSE 0
    END) AS reversed_amount

FROM dbo.payments

WHERE payment_reference IS NOT NULL

GROUP BY payment_reference

HAVING COUNT(DISTINCT payment_status) > 1

ORDER BY record_count DESC;

-- ============================================================
-- STEP 20.16: PAYMENT REFERENCE CONSISTENCY
-- Purpose:
-- Identify payment references associated with different
-- amounts or different accounts.
-- ============================================================

SELECT
    payment_reference,
    COUNT(*) AS record_count,
    COUNT(DISTINCT payment_id) AS payment_id_count,
    COUNT(DISTINCT account_id) AS account_count,
    COUNT(DISTINCT amount) AS amount_count,

    MIN(amount) AS minimum_amount,
    MAX(amount) AS maximum_amount

FROM dbo.payments

WHERE payment_reference IS NOT NULL

GROUP BY payment_reference

HAVING
       COUNT(DISTINCT account_id) > 1
    OR COUNT(DISTINCT amount) > 1

ORDER BY record_count DESC;

-- ============================================================

-- STEP 21.1: CREATE CLEAN SCHEMA
-- Purpose:
-- Create the schema that will contain validated payment data.
-- ============================================================

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'clean'
)
BEGIN
    EXEC('CREATE SCHEMA clean');
END;

-- ============================================================
-- STEP 21.2: CREATE AUDIT SCHEMA
-- Purpose:
-- Store rejected/excluded records and the reason for exclusion.
-- ============================================================

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'audit'
)
BEGIN
    EXEC('CREATE SCHEMA audit');
END;

-- ============================================================
-- STEP 21.3: CREATE PAYMENT REJECTION AUDIT TABLE
-- ============================================================

DROP TABLE IF EXISTS audit.payment_rejections;

CREATE TABLE audit.payment_rejections
(
    payment_id           NVARCHAR(100),
    account_id           NVARCHAR(100),
    borrower_id          NVARCHAR(100),
    event_at             DATETIME2,
    payment_reference    NVARCHAR(200),
    amount               DECIMAL(18,2),
    payment_status       NVARCHAR(50),
    payment_method       NVARCHAR(100),
    provider_id          NVARCHAR(100),

    rejection_reason     NVARCHAR(200),
    rejected_at          DATETIME2 DEFAULT SYSDATETIME()
);

-- ============================================================
-- STEP 21.4: NUMBER DUPLICATE PAYMENT RECORDS
-- Purpose:
-- Assign ROW_NUMBER to duplicate payment IDs so that one
-- representative record can be retained and excess copies
-- can be audited.
-- ============================================================

DROP TABLE IF EXISTS #payment_dedup;

SELECT
    p.*,

    ROW_NUMBER() OVER
    (
        PARTITION BY payment_id
        ORDER BY
            event_at,
            payment_reference,
            amount
    ) AS rn

INTO #payment_dedup

FROM stg.payments p;

-- ============================================================
-- STEP 21.5: RECORD DUPLICATE PAYMENT COPIES IN AUDIT
-- ============================================================

INSERT INTO audit.payment_rejections
(
    payment_id,
    account_id,
    borrower_id,
    event_at,
    payment_reference,
    amount,
    payment_status,
    payment_method,
    provider_id,
    rejection_reason
)
SELECT
    payment_id,
    account_id,
    borrower_id,
    event_at,
    payment_reference,
    amount,
    payment_status,
    payment_method,
    provider_id,
    'EXACT_DUPLICATE_PAYMENT_ID'
FROM #payment_dedup
WHERE rn > 1;

-- ============================================================
-- STEP 21.6: CREATE CLEAN PAYMENTS
-- Purpose:
-- Retain exactly one record for each payment_id.
-- No records are deleted from dbo.payments.
-- ============================================================

DROP TABLE IF EXISTS clean.payments;

SELECT
    payment_id,
    account_id,
    borrower_id,
    event_at,
    payment_reference,
    amount,
    payment_status,
    payment_method,
    provider_id
INTO clean.payments
FROM #payment_dedup
WHERE rn = 1;

-- ============================================================
-- STEP 21.7: VALIDATE CLEAN PAYMENT UNIQUENESS
-- ============================================================

SELECT
    payment_id,
    COUNT(*) AS cnt
FROM clean.payments
GROUP BY payment_id
HAVING COUNT(*) > 1;

-- ============================================================
-- STEP 21.8: RAW → CLEAN PAYMENT RECONCILIATION
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM dbo.payments) AS raw_rows,

    (SELECT COUNT(*) FROM stg.payments) AS staging_rows,

    (SELECT COUNT(*) FROM clean.payments) AS clean_rows,

    (SELECT COUNT(*) FROM audit.payment_rejections)
        AS rejected_rows,

    (
        SELECT COUNT(*)
        FROM dbo.payments
    )
    -
    (
        SELECT COUNT(*)
        FROM clean.payments
    ) AS removed_rows;

-- ============================================================
-- STEP 21.9: PAYMENT CLEANING RATE
-- ============================================================

SELECT
    100.0 *
    (
        SELECT COUNT(*)
        FROM audit.payment_rejections
    )
    /
    NULLIF
    (
        (SELECT COUNT(*) FROM dbo.payments),
        0
    ) AS removed_percentage;

-- ============================================================
-- STEP 21.10: VALIDATED SUCCESSFUL RECOVERY
-- Purpose:
-- Calculate SUCCESS amount after payment_id deduplication.
-- ============================================================

SELECT
    COUNT(*) AS successful_payment_count,
    SUM(amount) AS validated_success_amount
FROM clean.payments
WHERE payment_status = 'SUCCESS';

-- ============================================================
-- STEP 21.11: GROSS VS VALIDATED SUCCESS RECOVERY
-- Purpose:
-- Compare SUCCESS amount before and after payment deduplication.
-- dbo.payments = original/raw payment population
-- clean.payments = deduplicated payment population
-- ============================================================

SELECT
    (
        SELECT SUM(p.amount)
        FROM dbo.payments p
        WHERE p.payment_status = 'SUCCESS'
    ) AS raw_success_amount,

    (
        SELECT SUM(cp.amount)
        FROM clean.payments cp
        WHERE cp.payment_status = 'SUCCESS'
    ) AS clean_success_amount;

-- ============================================================
-- STEP 21.11A: CHECK CLEAN.PAYMENTS TABLE STRUCTURE
-- Purpose:
-- Verify the actual column names and data types in clean.payments.
-- ============================================================

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'clean'
  AND TABLE_NAME = 'payments'
ORDER BY ORDINAL_POSITION;

-- ============================================================
-- STEP 21.11B: PREVIEW CLEAN.PAYMENTS
-- ============================================================

SELECT TOP 10 *
FROM clean.payments;

-- ============================================================
-- STEP 21.12: SUCCESS AMOUNT REMOVED BY DEDUPLICATION
-- Purpose:
-- Quantify how much SUCCESS amount was removed because of
-- duplicate payment_id records.
-- ============================================================

SELECT
    (
        SELECT SUM(p.amount)
        FROM dbo.payments p
        WHERE p.payment_status = 'SUCCESS'
    )
    -
    (
        SELECT SUM(cp.amount)
        FROM clean.payments cp
        WHERE cp.payment_status = 'SUCCESS'
    )
    AS success_amount_removed;

-- ============================================================
-- STEP 21.13: SUCCESS AMOUNT OVERSTATEMENT PERCENTAGE
-- Purpose:
-- Measure the percentage of gross SUCCESS amount attributable
-- to duplicate payment records.
-- ============================================================

SELECT
    CAST(
        100.0 *
        (
            (
                SELECT SUM(p.amount)
                FROM dbo.payments p
                WHERE p.payment_status = 'SUCCESS'
            )
            -
            (
                SELECT SUM(cp.amount)
                FROM clean.payments cp
                WHERE cp.payment_status = 'SUCCESS'
            )
        )
        /
        NULLIF(
            (
                SELECT SUM(p.amount)
                FROM dbo.payments p
                WHERE p.payment_status = 'SUCCESS'
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS success_amount_overstatement_pct;

-- ============================================================
-- STEP 21.14: CLEAN PAYMENT QUALITY CHECK
-- Purpose:
-- Confirm that payment_id is unique and there are no NULL
-- payment IDs.
-- ============================================================

SELECT
    COUNT(*) AS clean_payment_rows,
    COUNT(DISTINCT payment_id) AS unique_payment_ids,
    SUM(CASE WHEN payment_id IS NULL THEN 1 ELSE 0 END)
        AS null_payment_ids
FROM clean.payments;

-- ============================================================
-- STEP 21.15: RAW → REJECTED → GOLDEN PAYMENT RECONCILIATION
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM dbo.payments) AS raw_rows,

    (SELECT COUNT(*) FROM audit.payment_rejections)
        AS rejected_rows,

    (SELECT COUNT(*) FROM clean.payments)
        AS clean_rows,

    CAST(
        100.0 *
        (SELECT COUNT(*) FROM audit.payment_rejections)
        /
        NULLIF(
            (SELECT COUNT(*) FROM dbo.payments),
            0
        )
        AS DECIMAL(10,2)
    ) AS rejected_pct;


    -- ============================================================
-- STEP 21.16A: CREATE CLEAN ACCOUNTS TABLE
-- Purpose:
-- Create the cleaned account master table.
-- account_id has already been checked for duplicates.
-- ============================================================

DROP TABLE IF EXISTS clean.accounts;

SELECT
    TRIM(account_id) AS account_id,
    TRIM(borrower_id) AS borrower_id,
    UPPER(TRIM(loan_type)) AS loan_type,
    TRY_CONVERT(DECIMAL(18,2), principal_amount) AS principal_amount,
    TRY_CONVERT(DECIMAL(18,2), outstanding_amount) AS outstanding_amount,
    TRY_CONVERT(INT, dpd) AS dpd,
    UPPER(TRIM(risk_segment)) AS risk_segment,
    UPPER(TRIM(status)) AS status,
    TRY_CONVERT(DATETIME2, opened_at) AS opened_at,
    TRIM(timezone) AS timezone,
    TRIM(schema_version) AS schema_version
INTO clean.accounts
FROM stg.accounts
WHERE NULLIF(TRIM(account_id), '') IS NOT NULL;

-- ============================================================
-- STEP 21.16B: VERIFY CLEAN ACCOUNTS
-- ============================================================

SELECT TOP 10 *
FROM clean.accounts;

-- ============================================================
-- STEP 21.16C: VERIFY CLEAN ACCOUNT UNIQUENESS
-- ============================================================

SELECT
    account_id,
    COUNT(*) AS cnt
FROM clean.accounts
GROUP BY account_id
HAVING COUNT(*) > 1;

-- ============================================================
-- STEP 21.16D: PAYMENT → ACCOUNT REFERENTIAL INTEGRITY
-- Purpose:
-- Identify payment records whose account_id does not exist
-- in the clean account master.
-- ============================================================

SELECT
    COUNT(*) AS orphan_payment_records
FROM clean.payments p
LEFT JOIN clean.accounts a
    ON p.account_id = a.account_id
WHERE a.account_id IS NULL;

-- ============================================================
-- STEP 21.16E: CREATE GOLD RECOVERY PAYMENTS
-- Purpose:
-- Create the authoritative SUCCESS payment population.
--
-- Attribution rule:
-- payment.account_id
--        ↓
-- clean.accounts.account_id
--        ↓
-- clean.accounts.borrower_id
--
-- The borrower_id stored directly in payments is NOT used
-- for attribution because payment borrower/account mismatches
-- were identified during forensic analysis.
-- ============================================================

DROP TABLE IF EXISTS gold.recovery_payments;

SELECT
    p.payment_id,
    p.account_id,
    a.borrower_id AS attributed_borrower_id,
    p.event_at,
    p.payment_reference,
    p.amount,
    p.payment_method,
    p.provider_id
INTO gold.recovery_payments
FROM clean.payments AS p
INNER JOIN clean.accounts AS a
    ON p.account_id = a.account_id
WHERE UPPER(TRIM(p.payment_status)) = 'SUCCESS';

-- ============================================================
-- STEP 21.17: VALIDATE GOLD RECOVERY
-- ============================================================

SELECT
    COUNT(*) AS recovery_transactions,
    COUNT(DISTINCT payment_id) AS unique_recovery_payments,
    COUNT(DISTINCT account_id) AS recovered_accounts,
    COUNT(DISTINCT attributed_borrower_id) AS recovered_borrowers,
    SUM(amount) AS total_validated_recovery
FROM gold.recovery_payments;

-- ============================================================

-- STEP 22.1: DETERMINE PAYMENT ANALYSIS PERIOD
-- Purpose:
-- Identify the actual date range available in the validated
-- recovery dataset.
-- ============================================================

SELECT
    MIN(event_at) AS first_recovery_date,
    MAX(event_at) AS last_recovery_date,
    COUNT(*) AS recovery_transactions,
    SUM(amount) AS total_recovery
FROM gold.recovery_payments;

-- ============================================================
-- STEP 22.2: MONTHLY VALIDATED RECOVERY
-- Purpose:
-- Reconstruct actual monthly recovery using only the Golden
-- SUCCESS payment population.
-- ============================================================

SELECT
    DATEFROMPARTS(
        YEAR(event_at),
        MONTH(event_at),
        1
    ) AS recovery_month,

    COUNT(*) AS recovery_transactions,

    COUNT(DISTINCT payment_id) AS unique_payments,

    COUNT(DISTINCT account_id) AS recovered_accounts,

    COUNT(DISTINCT attributed_borrower_id) AS recovered_borrowers,

    SUM(amount) AS validated_recovery

FROM gold.recovery_payments

GROUP BY
    DATEFROMPARTS(
        YEAR(event_at),
        MONTH(event_at),
        1
    )

ORDER BY recovery_month;

-- ============================================================
-- STEP 22.3: MONTH-ON-MONTH RECOVERY CHANGE
-- Purpose:
-- Independently calculate monthly recovery growth.
-- ============================================================

WITH monthly_recovery AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(event_at),
            MONTH(event_at),
            1
        ) AS recovery_month,

        SUM(amount) AS validated_recovery

    FROM gold.recovery_payments

    GROUP BY
        DATEFROMPARTS(
            YEAR(event_at),
            MONTH(event_at),
            1
        )
),

with_previous AS
(
    SELECT
        recovery_month,
        validated_recovery,

        LAG(validated_recovery)
            OVER (
                ORDER BY recovery_month
            ) AS previous_month_recovery

    FROM monthly_recovery
)

SELECT
    recovery_month,
    validated_recovery,
    previous_month_recovery,

    CAST(
        100.0 *
        (
            validated_recovery
            - previous_month_recovery
        )
        /
        NULLIF(previous_month_recovery, 0)
        AS DECIMAL(10,2)
    ) AS mom_recovery_change_pct

FROM with_previous

ORDER BY recovery_month;

-- ============================================================
-- STEP 22.4: CHECK ACCOUNT ANALYSIS PERIOD
-- Purpose:
-- Determine the available account population period for
-- constructing the monthly recovery denominator.
-- ============================================================

SELECT
    MIN(opened_at) AS first_account_date,
    MAX(opened_at) AS last_account_date,
    COUNT(*) AS total_accounts,
    COUNT(DISTINCT account_id) AS unique_accounts
FROM clean.accounts;

-- ============================================================
-- STEP 22.5: ACCOUNT STATUS DISTRIBUTION
-- Purpose:
-- Understand the account population before defining
-- eligible collection accounts.
-- ============================================================

SELECT
    status,
    COUNT(*) AS account_count,
    SUM(outstanding_amount) AS total_outstanding
FROM clean.accounts
GROUP BY status
ORDER BY account_count DESC;

-- ============================================================
-- STEP 22.6: DPD DISTRIBUTION
-- Purpose:
-- Understand collection opportunity by delinquency bucket.
-- ============================================================

SELECT
    CASE
        WHEN dpd = 0 THEN 'CURRENT'
        WHEN dpd BETWEEN 1 AND 30 THEN '1-30'
        WHEN dpd BETWEEN 31 AND 60 THEN '31-60'
        WHEN dpd BETWEEN 61 AND 90 THEN '61-90'
        WHEN dpd > 90 THEN '90+'
        ELSE 'UNKNOWN'
    END AS dpd_bucket,

    COUNT(*) AS account_count,

    SUM(outstanding_amount) AS total_outstanding

FROM clean.accounts

GROUP BY
    CASE
        WHEN dpd = 0 THEN 'CURRENT'
        WHEN dpd BETWEEN 1 AND 30 THEN '1-30'
        WHEN dpd BETWEEN 31 AND 60 THEN '31-60'
        WHEN dpd BETWEEN 61 AND 90 THEN '61-90'
        WHEN dpd > 90 THEN '90+'
        ELSE 'UNKNOWN'
    END;

-- ============================================================
-- STEP 22.7: RECOVERY PERFORMANCE BY DPD BUCKET
-- Purpose:
-- Compare outstanding amount with successful payment recovery
-- across different delinquency buckets.
-- ============================================================

WITH account_dpd AS
(
    SELECT
        account_id,
        dpd,
        outstanding_amount,

        CASE
            WHEN dpd = 0 THEN 'CURRENT'
            WHEN dpd BETWEEN 1 AND 30 THEN '1-30'
            WHEN dpd BETWEEN 31 AND 60 THEN '31-60'
            WHEN dpd BETWEEN 61 AND 90 THEN '61-90'
            WHEN dpd > 90 THEN '90+'
            ELSE 'UNKNOWN'
        END AS dpd_bucket

    FROM clean.accounts
),

account_recovery AS
(
    SELECT
        account_id,
        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN amount
                ELSE 0
            END
        ) AS recovered_amount

    FROM clean.payments
    GROUP BY account_id
)

SELECT
    a.dpd_bucket,

    COUNT(*) AS account_count,

    SUM(a.outstanding_amount) AS total_outstanding,

    SUM(
        ISNULL(r.recovered_amount, 0)
    ) AS total_recovered,

    CAST(
        100.0 *
        SUM(ISNULL(r.recovered_amount, 0))
        / NULLIF(SUM(a.outstanding_amount), 0)
        AS DECIMAL(10,2)
    ) AS recovery_pct

FROM account_dpd a

LEFT JOIN account_recovery r
    ON a.account_id = r.account_id

GROUP BY
    a.dpd_bucket;

-- ============================================================
-- STEP 22.8: HIGH-VALUE LOW-RECOVERY ACCOUNTS
-- Purpose:
-- Identify accounts with significant outstanding balances
-- but relatively low successful payment recovery.
-- ============================================================

WITH account_recovery AS
(
    SELECT
        account_id,

        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN amount
                ELSE 0
            END
        ) AS recovered_amount

    FROM clean.payments

    GROUP BY account_id
)

SELECT TOP 50

    a.account_id,
    a.borrower_id,
    a.dpd,
    a.status,
    a.risk_segment,
    a.outstanding_amount,

    ISNULL(r.recovered_amount, 0) AS recovered_amount,

    CAST(
        100.0 *
        ISNULL(r.recovered_amount, 0)
        / NULLIF(a.outstanding_amount, 0)
        AS DECIMAL(10,2)
    ) AS recovery_pct

FROM clean.accounts a

LEFT JOIN account_recovery r
    ON a.account_id = r.account_id

WHERE a.outstanding_amount > 0

ORDER BY
    a.outstanding_amount DESC;

-- ============================================================
-- STEP 22.9: COLLECTION PRIORITY SEGMENTATION
-- Purpose:
-- Classify accounts according to delinquency and recovery.
-- ============================================================

WITH account_recovery AS
(
    SELECT
        account_id,

        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN amount
                ELSE 0
            END
        ) AS recovered_amount

    FROM clean.payments

    GROUP BY account_id
)

SELECT

    CASE
        WHEN a.dpd > 90
             AND ISNULL(r.recovered_amount, 0) = 0
            THEN 'CRITICAL'

        WHEN a.dpd BETWEEN 61 AND 90
             AND ISNULL(r.recovered_amount, 0) = 0
            THEN 'HIGH'

        WHEN a.dpd BETWEEN 31 AND 60
             AND ISNULL(r.recovered_amount, 0) = 0
            THEN 'MEDIUM'

        WHEN a.dpd BETWEEN 1 AND 30
             AND ISNULL(r.recovered_amount, 0) = 0
            THEN 'EARLY'

        WHEN a.dpd = 0
            THEN 'CURRENT'

        WHEN ISNULL(r.recovered_amount, 0) > 0
            THEN 'RECOVERING'

        ELSE 'OTHER'
    END AS collection_priority,

    COUNT(*) AS account_count,

    SUM(a.outstanding_amount) AS total_outstanding,

    SUM(ISNULL(r.recovered_amount, 0)) AS total_recovered

FROM clean.accounts a

LEFT JOIN account_recovery r
    ON a.account_id = r.account_id

GROUP BY

    CASE
        WHEN a.dpd > 90
             AND ISNULL(r.recovered_amount, 0) = 0
            THEN 'CRITICAL'

        WHEN a.dpd BETWEEN 61 AND 90
             AND ISNULL(r.recovered_amount, 0) = 0
            THEN 'HIGH'

        WHEN a.dpd BETWEEN 31 AND 60
             AND ISNULL(r.recovered_amount, 0) = 0
            THEN 'MEDIUM'

        WHEN a.dpd BETWEEN 1 AND 30
             AND ISNULL(r.recovered_amount, 0) = 0
            THEN 'EARLY'

        WHEN a.dpd = 0
            THEN 'CURRENT'

        WHEN ISNULL(r.recovered_amount, 0) > 0
            THEN 'RECOVERING'

        ELSE 'OTHER'
    END;

-- ============================================================
-- STEP 22.10: COLLECTION PRIORITY × RISK SEGMENT
-- Purpose:
-- Identify which risk segments contain the greatest
-- collection exposure.
-- ============================================================

WITH account_recovery AS
(
    SELECT
        account_id,

        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN amount
                ELSE 0
            END
        ) AS recovered_amount

    FROM clean.payments

    GROUP BY account_id
),

classified_accounts AS
(
    SELECT

        a.account_id,
        a.risk_segment,
        a.dpd,
        a.outstanding_amount,

        CASE
            WHEN a.dpd > 90
                 AND ISNULL(r.recovered_amount, 0) = 0
                THEN 'CRITICAL'

            WHEN a.dpd BETWEEN 61 AND 90
                 AND ISNULL(r.recovered_amount, 0) = 0
                THEN 'HIGH'

            WHEN a.dpd BETWEEN 31 AND 60
                 AND ISNULL(r.recovered_amount, 0) = 0
                THEN 'MEDIUM'

            WHEN a.dpd BETWEEN 1 AND 30
                 AND ISNULL(r.recovered_amount, 0) = 0
                THEN 'EARLY'

            WHEN a.dpd = 0
                THEN 'CURRENT'

            WHEN ISNULL(r.recovered_amount, 0) > 0
                THEN 'RECOVERING'

            ELSE 'OTHER'
        END AS collection_priority

    FROM clean.accounts a

    LEFT JOIN account_recovery r
        ON a.account_id = r.account_id
)

SELECT

    risk_segment,

    collection_priority,

    COUNT(*) AS account_count,

    SUM(outstanding_amount) AS total_outstanding

FROM classified_accounts

GROUP BY
    risk_segment,
    collection_priority

ORDER BY
    risk_segment,
    total_outstanding DESC;

-- ============================================================
-- STEP 22.11: RISK SEGMENT EXPOSURE SUMMARY
-- Purpose:
-- Summarize accounts and outstanding exposure by risk segment.
-- ============================================================

SELECT
    risk_segment,

    COUNT(*) AS account_count,

    SUM(outstanding_amount) AS total_outstanding,

    AVG(outstanding_amount) AS average_outstanding,

    SUM(
        CASE
            WHEN dpd > 90 THEN outstanding_amount
            ELSE 0
        END
    ) AS dpd_90_plus_outstanding,

    SUM(
        CASE
            WHEN dpd >= 31 THEN outstanding_amount
            ELSE 0
        END
    ) AS dpd_31_plus_outstanding

FROM clean.accounts

GROUP BY
    risk_segment

ORDER BY
    total_outstanding DESC;

-- ============================================================
-- STEP 21.12: RECOVERY PERFORMANCE BY RISK SEGMENT
-- Purpose:
-- Compare outstanding exposure with successful payment
-- recovery across risk segments.
-- ============================================================

WITH recovery AS
(
    SELECT
        account_id,

        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN amount
                ELSE 0
            END
        ) AS recovered_amount

    FROM clean.payments

    GROUP BY account_id
)

SELECT
    a.risk_segment,

    COUNT(*) AS account_count,

    SUM(a.outstanding_amount) AS total_outstanding,

    SUM(ISNULL(r.recovered_amount, 0)) AS total_recovered,

    CAST(
        100.0 *
        SUM(ISNULL(r.recovered_amount, 0))
        / NULLIF(SUM(a.outstanding_amount), 0)
        AS DECIMAL(10,2)
    ) AS recovery_pct

FROM clean.accounts a

LEFT JOIN recovery r
    ON a.account_id = r.account_id

GROUP BY
    a.risk_segment

ORDER BY
    total_outstanding DESC;

-- ============================================================
-- STEP 21.13: RECOVERY BY RISK SEGMENT AND DPD BUCKET
-- Purpose:
-- Analyze recovery performance across both risk level
-- and delinquency severity.
-- ============================================================

WITH recovery AS
(
    SELECT
        account_id,
        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN amount
                ELSE 0
            END
        ) AS recovered_amount
    FROM clean.payments
    GROUP BY account_id
),

account_data AS
(
    SELECT
        a.account_id,
        a.risk_segment,
        a.outstanding_amount,

        CASE
            WHEN a.dpd = 0 THEN 'CURRENT'
            WHEN a.dpd BETWEEN 1 AND 30 THEN '1-30'
            WHEN a.dpd BETWEEN 31 AND 60 THEN '31-60'
            WHEN a.dpd BETWEEN 61 AND 90 THEN '61-90'
            WHEN a.dpd > 90 THEN '90+'
            ELSE 'UNKNOWN'
        END AS dpd_bucket,

        ISNULL(r.recovered_amount, 0) AS recovered_amount

    FROM clean.accounts a

    LEFT JOIN recovery r
        ON a.account_id = r.account_id
)

SELECT
    risk_segment,
    dpd_bucket,

    COUNT(*) AS account_count,

    SUM(outstanding_amount) AS total_outstanding,

    SUM(recovered_amount) AS total_recovered,

    CAST(
        100.0 * SUM(recovered_amount)
        / NULLIF(SUM(outstanding_amount), 0)
        AS DECIMAL(10,2)
    ) AS recovery_pct

FROM account_data

GROUP BY
    risk_segment,
    dpd_bucket

ORDER BY
    risk_segment,
    dpd_bucket;

-- ============================================================
-- STEP 21.14: TEST THE REPORTED 11% MONTH-ON-MONTH RECOVERY
-- ============================================================
-- Purpose:
-- Independently calculate monthly validated recovery from
-- clean payments and compare actual MoM growth with the
-- reported 11% improvement.
-- ============================================================

WITH monthly_recovery AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(event_at),
            MONTH(event_at),
            1
        ) AS recovery_month,

        COUNT(*) AS successful_payment_count,

        SUM(amount) AS validated_recovery

    FROM clean.payments

    WHERE payment_status = 'SUCCESS'

    GROUP BY
        DATEFROMPARTS(
            YEAR(event_at),
            MONTH(event_at),
            1
        )
),

with_previous AS
(
    SELECT
        recovery_month,
        successful_payment_count,
        validated_recovery,

        LAG(validated_recovery) OVER
        (
            ORDER BY recovery_month
        ) AS previous_month_recovery

    FROM monthly_recovery
)

SELECT
    recovery_month,
    successful_payment_count,
    validated_recovery,
    previous_month_recovery,

    CAST(
        (
            (validated_recovery - previous_month_recovery)
            / NULLIF(previous_month_recovery, 0)
        ) * 100
        AS DECIMAL(10,2)
    ) AS actual_mom_recovery_pct,

    CAST(
        11.00 AS DECIMAL(10,2)
    ) AS reported_mom_pct,

    CAST(
        (
            (
                (validated_recovery - previous_month_recovery)
                / NULLIF(previous_month_recovery, 0)
            ) * 100
        ) - 11.00
        AS DECIMAL(10,2)
    ) AS difference_vs_reported_pct,

    CASE
        WHEN previous_month_recovery IS NULL
            THEN 'BASE MONTH'

        WHEN
            (
                (validated_recovery - previous_month_recovery)
                / NULLIF(previous_month_recovery, 0)
            ) * 100 >= 11
            THEN 'MEETS OR EXCEEDS 11%'

        ELSE 'BELOW 11%'
    END AS claim_check

FROM with_previous

ORDER BY recovery_month;
