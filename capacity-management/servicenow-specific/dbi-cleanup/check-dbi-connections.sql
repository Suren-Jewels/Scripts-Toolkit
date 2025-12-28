-- Capability: Validate active DB connections before DBI cleanup or retirement.

-- Total active connections
SELECT
    COUNT(*) AS total_connections
FROM information_schema.processlist;

-- Active vs idle breakdown
SELECT
    command,
    COUNT(*) AS count
FROM information_schema.processlist
GROUP BY command;

-- Long-running queries (over 60 seconds)
SELECT
    id,
    user,
    host,
    db,
    time AS seconds_running,
    state,
    info AS query
FROM information_schema.processlist
WHERE time > 60
ORDER BY time DESC;

-- Blocking sessions
SELECT
    p.id AS blocker_id,
    p.user AS blocker_user,
    p.host AS blocker_host,
    p.time AS blocker_time,
    p.info AS blocker_query
FROM information_schema.processlist p
WHERE p.command = 'Query'
  AND p.time > 30
  AND p.state LIKE '%lock%';
