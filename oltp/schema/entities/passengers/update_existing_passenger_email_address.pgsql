-- This procedure updates the email address of an existing passenger

CREATE OR REPLACE PROCEDURE brt.update_existing_passenger_email_address (
    pass_id brt.passenger_details.id%type,
    old_passenger_email_address brt.passenger_email_address.email_address%type,
    new_passenger_email_address brt.passenger_email_address.email_address%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF pass_id IS NULL OR old_passenger_email_address IS NULL OR new_passenger_email_address IS NULL THEN   
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(pass_id) = 'integer'::regtype AND
        pg_typeof(old_passenger_email_address) = 'varchar'::regtype AND 
        pg_typeof(new_passenger_email_address) = 'varchar'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- To check if the provided passenger owns an email address
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_email_address WHERE passenger_id = pass_id) THEN 
        RAISE EXCEPTION 'The provided passenger does not have an email address'
            USING HINT = 'Ensure the provided passenger is referenced to an existing email address';
    END IF;

    -- To check if the old email address exists
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_email_address WHERE email_address = old_passenger_email_address) THEN 
        RAISE EXCEPTION 'The provided email address does not exist'
            USING HINT = 'Ensure a valid passenger email address is provided';
    END IF;

    -- To check if the new email is already in use by another passenger
    IF EXISTS (
        SELECT 1 FROM brt.passenger_email_address 
        WHERE 
            email_address = new_passenger_email_address AND
            passenger_id != pass_id
    ) THEN 
        RAISE EXCEPTION 'The provided email address is already in use by another passenger'
            USING HINT = 'Ensure a unique email address is provided to replace the existing email address';
    END IF;

    IF new_passenger_email_address <> old_passenger_email_address THEN
        query := (
            'UPDATE brt.passenger_email_address 
            SET email_address = $1
            WHERE passenger_id = $2;'
        );

        EXECUTE query USING new_passenger_email_address, pass_id;
        RAISE NOTICE 'Passenger email successfully changed from % to %', old_passenger_email_address, new_passenger_email_address;
    ELSE 
        RAISE NOTICE 'The current passenger email address already matches the provided email address';
    END IF;
END;
$$

-- Executing the procedure to modify an existing passenger email address

CALL brt.update_existing_passenger_email_address (
    pass_id := [ ],
    old_passenger_email_address := [ ],
    new_passenger_email_address := [ ]
);
