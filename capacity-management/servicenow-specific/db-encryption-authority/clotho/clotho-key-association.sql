-- Capability: Validate Clotho key association for DB server encryption.

-- Retrieve Clotho key association metadata
SELECT
    dbserver_id,
    key_id,
    key_version,
    workflow_state,
    last_updated
FROM clotho_encryption_keys
WHERE dbserver_id = :DBSERVER_ID;

-- Detect stale or mismatched key references
SELECT
    c.dbserver_id,
    c.key_id AS clotho_key,
    d.key_id AS dare_key
FROM clotho_encryption_keys c
LEFT JOIN dare_key_registry d
    ON c.dbserver_id = d.dbserver_id
WHERE c.dbserver_id = :DBSERVER_ID
  AND c.key_id <> d.key_id;

-- Identify missing workflow entries
SELECT
    dbserver_id
FROM clotho_encryption_workflows
WHERE dbserver_id = :DBSERVER_ID
  AND workflow_state IS NULL;
