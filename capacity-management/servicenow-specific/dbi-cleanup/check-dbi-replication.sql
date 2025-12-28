-- Capability: Validate DBI replication state before cleanup or retirement.

-- Replication status (if this node is a replica)
SHOW SLAVE STATUS\G;

-- Key fields to check:
--  Slave_IO_Running
--  Slave_SQL_Running
--  Seconds_Behind_Master
--  Last_IO_Error
--  Last_SQL_Error
--  Retrieved_Gtid_Set
--  Executed_Gtid_Set

-- Confirm global GTID mode
SELECT
    @@global.gtid_mode AS gtid_mode,
    @@global.enforce_gtid_consistency AS enforce_gtid_consistency;

-- Identify if this node is acting as a master
SHOW MASTER STATUS;
