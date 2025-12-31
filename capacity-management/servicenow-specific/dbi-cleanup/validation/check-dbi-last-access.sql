-- Capability: Determine last access time for DBI activity validation.

-- Last query time per session
SELECT
    id,
    user,
    host,
    db,
    time AS idle_seconds,
    state,
    info AS last_query
FROM information_schema.processlist
ORDER BY time DESC;

-- Last table update time across all schemas
SELECT
    table_schema,
    table_name,
    update_time AS last_update
FROM information_schema.tables
WHERE update_time IS NOT NULL
ORDER BY update_time DESC;

-- Schema-level last activity summary
SELECT
    table_schema,
    MAX(update_time) AS last_activity
FROM information_schema.tables
WHERE update_time IS NOT NULL
GROUP BY table_schema
ORDER BY last_activity DESC;
