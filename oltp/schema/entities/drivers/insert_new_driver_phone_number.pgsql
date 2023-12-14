-- This procedure inserts a phone number in the driver's phone number table

CREATE OR REPLACE PROCEDURE brt.insert_new_driver_phone_number(
    driver_id brt.driver_phone_number.driver_id %type,
	phone brt.driver_phone_number.phone_number%type
)
LANGUAGE plpgsql
AS $$
DECLARE 
    query text;
    san_phone text;
BEGIN 
    -- Input validation for null checks
    IF driver_id IS NULL OR phone IS NULL THEN 
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(driver_id) = 'integer'::regtype AND
        pg_typeof(phone) = 'varchar'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Input validation for driver existence
	IF NOT EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver_id) THEN 
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a parent record exists for the provided driver ID';
    END IF;
    
    -- Format validation for phone number to conform to the Nigerian calling code (+234)
    san_phone := regexp_replace(phone, '[^\d+]', '', 'g');

    IF NOT san_phone ~ '^\+234[0-9]{10}$' THEN
        RAISE EXCEPTION 'Invalid phone number format'
            USING HINT = 'Ensure the provided number conforms to the (+234) calling code';
    END IF;

    query := (
        'INSERT INTO brt.driver_phone_number(phone_number, driver_id)
        VALUES ($1, $2);'
    );

    EXECUTE query USING phone, driver_id;
    RAISE NOTICE 'Driver phone number: % successfully inserted', phone;
END;
$$

-- Executing the phone number insert procedure

CALL brt.insert_new_driver_phone_number (
    driver_id := [ ],
    phone := [ ]
);
