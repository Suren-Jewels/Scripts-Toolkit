-- Capability: Identify active schemas and determine if any user data remains.

-- List all schemas except system schemas
SELECT
    schema_name,
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS total_mb,
    COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')
GROUP BY schema_name
ORDER BY total_mb DESC;

-- Last access time per schema (approximation via table update times)
SELECT
    table_schema,
    MAX(update_time) AS last_update
FROM information_schema.tables
WHERE update_time IS NOT NULL
GROUP BY table_schema
ORDER BY last_update DESC;
