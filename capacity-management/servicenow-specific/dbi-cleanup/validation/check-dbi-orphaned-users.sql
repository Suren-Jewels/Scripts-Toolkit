-- Capability: Identify orphaned or unused DB users.

-- Users with no privileges
SELECT
    user,
    host
FROM mysql.user
WHERE user NOT IN (
    SELECT DISTINCT grantee
    FROM information_schema.user_privileges
);

-- Users with no schema access
SELECT
    u.user,
    u.host
FROM mysql.user u
LEFT JOIN information_schema.schema_privileges p
    ON CONCAT(u.user, '@', u.host) = p.grantee
WHERE p.grantee IS NULL;

-- Users with no recent activity (approx via processlist)
SELECT
    user,
    host
FROM mysql.user
WHERE user NOT IN (
    SELECT DISTINCT user
    FROM information_schema.processlist
);
