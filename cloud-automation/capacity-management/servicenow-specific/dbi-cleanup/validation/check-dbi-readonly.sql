-- Capability: Validate DBI read-only mode before retirement.

-- Global read-only state
SELECT
    @@global.read_only AS global_read_only,
    @@global.super_read_only AS super_read_only;

-- Session-level read-only state
SELECT
    @@session.tx_read_only AS session_tx_read_only;

-- Detect active write operations
SELECT
    id,
    user,
    host,
    db,
    command,
    time,
    state,
    info AS query
FROM information_schema.processlist
WHERE command = 'Query'
  AND info IS NOT NULL
  AND info NOT LIKE 'SELECT%'
ORDER BY time DESC;
