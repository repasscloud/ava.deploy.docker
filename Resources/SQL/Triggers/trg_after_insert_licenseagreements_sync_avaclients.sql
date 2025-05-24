-- File: create_sync_license_agreement_trigger.sql
-- Purpose: Whenever a new LicenseAgreement is inserted, copy its Id into the matching AvaClients record

/* ----------------------------------------------------------------------------
   1) Trigger function definition
   ----------------------------------------------------------------------------
   - Fires AFTER INSERT on public."LicenseAgreements"
   - NEW."AvaClientId": the client identifier from the newly inserted LicenseAgreement
   - NEW."Id":        the PK of that new LicenseAgreement
   - Looks up public."AvaClients" WHERE "ClientId" matches NEW."AvaClientId"
     and updates that row’s "LicenseAgreementId" to point back to NEW."Id"
   - If no row matches, we emit a NOTICE (but do not abort)
*/
CREATE OR REPLACE FUNCTION public.sync_license_agreement_id()
RETURNS trigger AS $$
DECLARE
  updated_count INT;
BEGIN
  -- perform the update
  UPDATE public."AvaClients"
     SET "LicenseAgreementId" = NEW."Id"
   WHERE "ClientId" = NEW."AvaClientId";

  -- check how many rows were updated
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count = 0 THEN
    -- no matching client found
    RAISE NOTICE 'No AvaClients row for ClientId=%', NEW."AvaClientId";
    -- to abort the insert instead, replace NOTICE with:
    -- RAISE EXCEPTION 'No matching AvaClient for %', NEW."AvaClientId";
  END IF;

  -- must return NEW for row-level triggers
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;


-- ----------------------------------------------------------------------------
-- 2) Attach the trigger function to LicenseAgreements
-- ----------------------------------------------------------------------------
-- - Name: trg_license_agreement_insert
-- - Event: AFTER INSERT ON public."LicenseAgreements"
-- - Granularity: FOR EACH ROW
CREATE TRIGGER trg_license_agreement_insert
  AFTER INSERT ON public."LicenseAgreements"
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_license_agreement_id();
