-- create_avaprod_db.sql

-- Drop the user if it already exists
DROP USER IF EXISTS avaai;

-- Create the new user "avaai" with a password
CREATE USER avaai WITH PASSWORD 'avaaiPassword1';

-- Drop the database if it already exists
DROP DATABASE IF EXISTS avaprod;

-- Create the database "avaprod" and assign "avaai" as the owner
CREATE DATABASE avaprod OWNER avaai;

-- (Optional) Grant all privileges on the database to the user, 
-- although the owner already has full access.
GRANT ALL PRIVILEGES ON DATABASE avaprod TO avaai;
