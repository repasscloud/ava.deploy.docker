-- =============================================
-- Trigger Function: invalidate_expired_tokens_after
-- This function runs AFTER INSERT, UPDATE, or DELETE
--
-- Purpose:
-- - If INSERT/UPDATE: checks if token is valid but expired, sets IsValid = false
-- - If INSERT/UPDATE: deletes tokens that expired more than 5 days ago
-- - If DELETE: (optional cleanup or logging logic can be added here)
-- =============================================

DROP FUNCTION IF EXISTS public.invalidate_expired_tokens_after();

CREATE OR REPLACE FUNCTION public.invalidate_expired_tokens_after()
RETURNS TRIGGER AS $$
BEGIN
  -- INSERT or UPDATE logic (uses NEW)
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    -- Invalidate if still marked as valid but already expired
    IF NEW."IsValid" = true AND NEW."Expires" < now() THEN
      UPDATE public."AvaAIAppJwtTokens"
      SET "IsValid" = false
      WHERE "Id" = NEW."Id";
    END IF;

    -- Delete if more than 5 days past expiry
    IF NEW."Expires" < (now() - INTERVAL '5 days') THEN
      DELETE FROM public."AvaAIAppJwtTokens"
      WHERE "Id" = NEW."Id";
    END IF;
  END IF;

  -- DELETE logic (uses OLD)
  IF TG_OP = 'DELETE' THEN
    -- You can add logging or archive logic here if needed
    -- Example:
    -- INSERT INTO DeletedTokenLog("Id", "DeletedAt") VALUES (OLD."Id", now());
    -- For now, we do nothing on delete.
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Drop existing trigger to avoid conflicts
-- =============================================
DROP TRIGGER IF EXISTS trg_invalidate_token_after ON public."AvaAIAppJwtTokens";

-- =============================================
-- Create the trigger
-- Fires AFTER INSERT, UPDATE, or DELETE
-- =============================================
CREATE TRIGGER trg_invalidate_token_after
AFTER INSERT OR UPDATE OR DELETE ON public."AvaAIAppJwtTokens"
FOR EACH ROW
EXECUTE FUNCTION public.invalidate_expired_tokens_after();
