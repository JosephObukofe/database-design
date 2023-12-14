CREATE OR REPLACE PROCEDURE brt.insert_new_driver_license(
    license_num brt.driver_license.license_number%type,
    license_issue_date brt.driver_license.issue_date%type,
    license_expiry_date brt.driver_license.expiry_date%type,
    driver brt.driver_license.driver_id%type
)
LANGUAGE plpgsql
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF license_num IS NULL OR license_issue_date IS NULL OR license_expiry_date IS NULL OR driver IS NULL THEN 
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(license_num) = 'varchar'::regtype AND
        pg_typeof(license_issue_date) = 'date'::regtype AND
        pg_typeof(license_expiry_date) = 'date'::regtype AND
        pg_typeof(driver) = 'integer'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Input validation for driver existence
    IF NOT EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver) THEN 
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a parent record exists for the provided driver ID';
    END IF;

    query := (
        'INSERT INTO brt.driver_license (license_number, issue_date, expiry_date, driver_id)
        VALUES ($1, $2, $3, $4);'
    );
    
    EXECUTE query USING license_num, license_issue_date, license_expiry_date, driver;
    COMMIT;
    RAISE NOTICE 'Driver License: % inserted successfully', license_num;
END;
$$

CALL brt.insert_new_driver_license (
    license_num := [ ],
    license_issue_date := [ ],
    license_expiry_date := [ ],
    driver := [ ]
);