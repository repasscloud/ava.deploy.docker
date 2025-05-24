SELECT * FROM public."AspNetUsers";
DELETE FROM public."AspNetUsers" WHERE "UserName" = 'test@djjm.io';

SELECT * FROM public."AvaUserSysPreferences";
DELETE FROM public."AvaUserSysPreferences" WHERE "Id" = 1;


SELECT * FROM public."AvaUsers" ORDER BY "Id" ASC LIMIT 100;
DELETE FROM public."AvaUsers" WHERE "Id" = 5;