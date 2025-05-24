SELECT trg.tgname AS trigger_name,
       tbl.relname AS table_name,
       prc.proname AS function_name
FROM pg_catalog.pg_trigger trg
JOIN pg_catalog.pg_class tbl ON trg.tgrelid = tbl.oid
JOIN pg_catalog.pg_proc prc ON trg.tgfoid = prc.oid
WHERE tbl.relname = 'AspNetUsers'
  AND trg.tgname = 'trg_after_insert_create_user_syspref';
