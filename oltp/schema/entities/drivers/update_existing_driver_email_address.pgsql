-- This procedure modifies an existing driver's email address

CREATE OR REPLACE PROCEDURE brt.update_existing_driver_email_address (
    driv_id brt.driver_details.id%type,
    old_driver_email_address brt.driver_email_address.email_address%type,
    new_driver_email_address brt.driver_email_address.email_address%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF driv_id IS NULL OR old_driver_email_address IS NULL OR new_driver_email_address IS NULL THEN   
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(driv_id) = 'integer'::regtype AND
        pg_typeof(old_driver_email_address) = 'varchar'::regtype AND 
        pg_typeof(new_driver_email_address) = 'varchar'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- To check if the provided driver owns an email address
    IF NOT EXISTS (SELECT 1 FROM brt.driver_email_address WHERE driver_id = driv_id) THEN 
        RAISE EXCEPTION 'The provided driver does not have an email address'
            USING HINT = 'Ensure the provided driver is referenced to an existing email address';
    END IF;

    -- To check if the old email address exists
    IF NOT EXISTS (SELECT 1 FROM brt.driver_email_address WHERE email_address = old_driver_email_address) THEN 
        RAISE EXCEPTION 'The provided email address does not exist'
            USING HINT = 'Ensure a valid driver email address is provided';
    END IF;

    -- To check if the new email is already in use by another driver
    IF EXISTS (
        SELECT 1 FROM brt.driver_email_address 
        WHERE 
            email_address = new_driver_email_address AND
            driver_id != driv_id
    ) THEN 
        RAISE EXCEPTION 'The provided email address is already in use by another driver'
            USING HINT = 'Ensure a unique email address is provided to replace the existing email address';
    END IF;

    IF new_driver_email_address <> old_driver_email_address THEN
        query := (
            'UPDATE brt.driver_email_address 
            SET email_address = $1
            WHERE driver_id = $2;'
        );

        EXECUTE query USING new_driver_email_address, driv_id;
        RAISE NOTICE 'Driver email address successfully changed from % to %', old_driver_email_address, new_driver_email_address;
    ELSE 
        RAISE NOTICE 'The current driver email address already matches the provided email address';
    END IF;
END;
$$

-- Executing the procedure to modify an existing email address

CALL brt.update_existing_driver_email_address (
    driv_id := [ ],
    old_driver_email_address := [ ],
    new_driver_email_address := [ ]
);
