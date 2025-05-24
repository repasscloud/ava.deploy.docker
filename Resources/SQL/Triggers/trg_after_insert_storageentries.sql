-- Clean up old records (older than 10 days) from the table on INSERT or UPDATE

CREATE OR REPLACE FUNCTION cleanup_old_records()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public."StorageEntries"
    WHERE "Expires" < NOW() - INTERVAL '10 days';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_cleanup_old_records ON public."StorageEntries";

CREATE TRIGGER trigger_cleanup_old_records
AFTER INSERT OR UPDATE ON public."StorageEntries"
FOR EACH STATEMENT
EXECUTE FUNCTION cleanup_old_records();