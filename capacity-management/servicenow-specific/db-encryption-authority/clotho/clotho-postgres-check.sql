-- Capability: Validate PostgreSQL encryption metadata alignment with Clotho.

-- Check cluster encryption state
SHOW data_encryption;

-- Check WAL encryption state
SHOW wal_encryption;

-- Check cluster key identifier (if exposed)
SHOW cluster_encryption_key_id;

-- Validate tablespace encryption state
SELECT
    spcname AS tablespace,
    pg_tablespace_is_encrypted(oid) AS encrypted
FROM pg_tablespace;

-- Identify unencrypted relations (if supported by engine)
SELECT
    relname AS relation,
    relkind AS type,
    pg_relation_filepath(oid) AS file_path
FROM pg_class
WHERE relkind IN ('r', 'i')
  AND pg_relation_is_encrypted(oid) = false;

-- Cross-check Clotho workflow metadata (placeholder table)
SELECT
    dbserver_id,
    workflow_state,
    key_id,
    last_updated
FROM clotho_encryption_workflows
WHERE dbserver_id = :DBSERVER_ID;
