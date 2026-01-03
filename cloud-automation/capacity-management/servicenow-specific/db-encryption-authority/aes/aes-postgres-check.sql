-- Capability: Validate PostgreSQL encryption alignment for AES.

-- Check cluster encryption state
SHOW data_encryption;

-- Check WAL encryption state
SHOW wal_encryption;

-- Check cluster key identifier (if exposed)
SHOW cluster_encryption_key_id;

-- Identify unencrypted relations (if supported by engine)
SELECT
    relname AS relation,
    relkind AS type,
    pg_relation_filepath(oid) AS file_path
FROM pg_class
WHERE relkind IN ('r', 'i')
  AND pg_relation_is_encrypted(oid) = false;

-- Validate tablespace encryption state
SELECT
    spcname AS tablespace,
    pg_tablespace_is_encrypted(oid) AS encrypted
FROM pg_tablespace;

-- Cross-check AES metadata stored in DB (placeholder table)
SELECT
    dbserver_id,
    aes_key_id,
    aes_key_version,
    last_updated
FROM aes_encryption_metadata
WHERE dbserver_id = :DBSERVER_ID;
