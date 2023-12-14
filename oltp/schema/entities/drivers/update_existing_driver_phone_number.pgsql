-- This procedure modifies an existing driver's phone number

CREATE OR REPLACE PROCEDURE brt.update_existing_driver_phone_number (
    driv_id brt.driver_details.id%type,
    old_driver_phone_number brt.driver_phone_number.phone_number%type,
    new_driver_phone_number brt.driver_phone_number.phone_number%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF driv_id IS NULL OR old_driver_phone_number IS NULL OR new_driver_phone_number IS NULL THEN   
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(driv_id) = 'integer'::regtype AND
        pg_typeof(old_driver_phone_number) = 'varchar'::regtype AND 
        pg_typeof(new_driver_phone_number) = 'varchar'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- To check if the provided driver owns a phone number or is referenced to one
    IF NOT EXISTS (SELECT 1 FROM brt.driver_phone_number WHERE driver_id = driv_id) THEN 
        RAISE EXCEPTION 'The provided driver does not have a phone number'
            USING HINT = 'Ensure the provided driver is referenced to an existing phone number';
    END IF;

    -- To check if the old phone number exists
    IF NOT EXISTS (SELECT 1 FROM brt.driver_phone_number WHERE phone_number = old_driver_phone_number) THEN 
        RAISE EXCEPTION 'The provided phone number does not exist'
            USING HINT = 'Ensure a valid driver phone number is provided';
    END IF;

    -- Sanitizing the new phone number to prepare it for format conformation checks
    san_new_driver_phone_number := regexp_replace(new_driver_phone_number, '[^\d+]', '', 'g');

    -- To check if the new phone number is already in use by another driver
    IF EXISTS (
        SELECT 1 FROM brt.driver_phone_number 
        WHERE 
            phone_number = san_new_driver_phone_number AND
            driver_id != driv_id
    ) THEN 
        RAISE EXCEPTION 'The provided phone number is already in use by another driver';
    END IF;

    -- Format validation checks
    IF san_new_driver_phone_number ~ '^\+234[0-9]{10}$' THEN
        IF san_new_driver_phone_number <> old_driver_phone_number THEN
            query := (
                'UPDATE brt.driver_phone_number
                SET phone_number = $1
                WHERE driver_id = $2;'
            );

            EXECUTE query USING san_new_driver_phone_number, driv_id;
            RAISE NOTICE 'Driver phone number successfully changed from % to %', old_driver_phone_number, san_new_driver_phone_number;
        ELSE 
            RAISE NOTICE 'The current driver phone number already matches the provided phone number';
        END IF;
    ELSE 
        RAISE EXCEPTION 'Invalid phone number format'
            USING HINT = 'Ensure the provided number conforms to the (+234) calling code';
    END IF;
END;
$$

-- Executing the driver phone number modification procedure

CALL brt.update_existing_driver_phone_number (
    driv_id := [ ],
    old_driver_phone_number := [ ],
    new_driver_phone_number := [ ]
);
