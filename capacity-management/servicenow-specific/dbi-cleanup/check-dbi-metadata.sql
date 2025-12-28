-- Capability: Validate DBI metadata (version, uptime, UUID, replication state)

SELECT
    @@hostname AS host_name,
    @@version AS db_version,
    @@server_uuid AS server_uuid,
    @@read_only AS read_only_mode,
    NOW() - INTERVAL VARIABLE_VALUE SECOND AS last_restart_time
FROM performance_schema.global_status
WHERE VARIABLE_NAME = 'Uptime';

-- Replication role (if applicable)
SHOW SLAVE STATUS;
