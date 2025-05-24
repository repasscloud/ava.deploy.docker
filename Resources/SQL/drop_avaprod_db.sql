-- drop_avaprod_db.sql

-- Terminate all connections to the avaprod database
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'avaprod'
  AND pid <> pg_backend_pid();

-- Drop the database if it exists.
-- Note: DROP DATABASE runs outside of any transaction block,
-- so a COMMIT is neither needed nor allowed, and CASCADE is not applicable.
DROP DATABASE IF EXISTS avaprod;
