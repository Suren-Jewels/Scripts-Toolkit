-- Capability: Validate actual DBI size for comparison with CMDB capacity fields.

SELECT
    table_schema AS schema_name,
    ROUND(SUM(data_length) / 1024 / 1024, 2) AS data_mb,
    ROUND(SUM(index_length) / 1024 / 1024, 2) AS index_mb,
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS total_mb,
    COUNT(*) AS table_count
FROM information_schema.tables
GROUP BY table_schema
ORDER BY total_mb DESC;

-- Total DB size summary
SELECT
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS total_db_mb
FROM information_schema.tables;
