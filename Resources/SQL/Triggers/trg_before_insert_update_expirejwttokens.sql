-- -- ============================================
-- -- This script creates a trigger function and a trigger
-- -- for the table "AvaJwtTokenResponses".
-- --
-- -- Purpose:
-- -- On every INSERT or UPDATE, it checks if a row is marked as IsValid = true
-- -- but the Expires timestamp is in the past. If so, it automatically sets
-- -- IsValid to false before the row is saved.
-- -- ============================================

-- -- Drop the function if it already exists to ensure clean redeploys
-- DROP FUNCTION IF EXISTS validate_jwt_expiry();

-- -- Create the trigger function
-- CREATE OR REPLACE FUNCTION validate_jwt_expiry()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   -- If the token is marked valid, but it's already expired, mark it invalid
--   IF NEW."IsValid" = TRUE AND NEW."Expires" < NOW() THEN
--     NEW."IsValid" := FALSE;
--   END IF;

--   -- Always return the modified row
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- Drop the trigger if it already exists (optional but good hygiene)
-- DROP TRIGGER IF EXISTS trigger_validate_jwt_expiry ON public."AvaJwtTokenResponses";

-- -- Create the trigger on INSERT or UPDATE of the table
-- CREATE TRIGGER trigger_validate_jwt_expiry
-- BEFORE INSERT OR UPDATE ON public."AvaJwtTokenResponses"
-- FOR EACH ROW
-- EXECUTE FUNCTION validate_jwt_expiry();
