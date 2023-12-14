-- This procedure inserts an email address into the driver's email address table

CREATE OR REPLACE PROCEDURE brt.insert_new_driver_email(
    driver_id brt.driver_email_address.driver_id%type,
	email brt.driver_email_address.email_address%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN
    -- Input Validation for null checks
    IF driver_id IS NULL OR email IS NULL THEN 
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

	-- Input Validation for argument data type checks
    IF NOT (
        pg_typeof(driver_id) = 'integer'::regtype AND
        pg_typeof(email) = 'varchar'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Input validation for driver record existence
    IF NOT EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver_id) THEN 
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a parent record exists for the provided driver ID';
    END IF;

    query := (
        'INSERT INTO brt.driver_email_address(email_address, driver_id)
        VALUES ($1, $2);'
    );

    EXECUTE query USING email, driver_id;
    RAISE NOTICE 'Driver Email Address: % successfully inserted', email;
END;
$$

-- Executing the email address insert procedure

CALL brt.insert_new_driver_email (
    driver_id := [ ],
    email := [ ]
);


