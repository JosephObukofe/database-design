-- Creating the pgcrypto extension in PostgreSQL
CREATE EXTENSION pgcrypto SCHEMA brt;

-- To check if the extension has been installed properly
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';
