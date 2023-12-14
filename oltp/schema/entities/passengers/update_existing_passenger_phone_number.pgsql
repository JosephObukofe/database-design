-- This procedure modifies the phone number of a passenger

CREATE OR REPLACE PROCEDURE brt.update_existing_passenger_phone_number (
    pass_id brt.passenger_details.id%type,
    old_passenger_phone_number brt.passenger_phone_number.phone_number%type,
    new_passenger_phone_number brt.passenger_phone_number.phone_number%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF pass_id IS NULL OR old_passenger_phone_number IS NULL OR new_passenger_phone_number IS NULL THEN   
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(pass_id) = 'integer'::regtype AND
        pg_typeof(old_passenger_phone_number) = 'varchar'::regtype AND 
        pg_typeof(new_passenger_phone_number) = 'varchar'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- To check if the provided passenger owns a phone number
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_phone_number WHERE passenger_id = pass_id) THEN 
        RAISE EXCEPTION 'The provided passenger does not have a phone number'
            USING HINT = 'Ensure the provided passenger is referenced to an existing phone number';
    END IF;

    -- To check if the old phone number exists
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_phone_number WHERE phone_number = old_passenger_phone_number) THEN 
        RAISE EXCEPTION 'The provided phone number does not exist'
            USING HINT = 'Ensure a valid passenger phone number is provided';
    END IF;

    -- Sanitizing the new phone number to prepare it for format conformation checks
    san_new_passenger_phone_number := regexp_replace(new_passenger_phone_number, '[^\d+]', '', 'g');

    -- To check if the new phone number is already in use by another passenger
    IF EXISTS (
        SELECT 1 FROM brt.passenger_phone_number 
        WHERE 
            phone_number = san_new_passenger_phone_number AND
            passenger_id != pass_id
    ) THEN 
        RAISE EXCEPTION 'The provided phone number is already in use by another passenger';
    END IF;

    -- Format validation checks
    IF san_new_passenger_phone_number ~ '^\+234[0-9]{10}$' THEN
        IF san_new_passenger_phone_number <> old_passenger_phone_number THEN
            query := (
                'UPDATE brt.passenger_phone_number
                SET phone_number = $1
                WHERE passenger_id = $2;'
            );

            EXECUTE query USING san_new_passenger_phone_number, pass_id;
            RAISE NOTICE 'Passenger phone number successfully changed from % to %', old_passenger_phone_number, san_new_passenger_phone_number;
        ELSE 
            RAISE NOTICE 'The current passenger phone number already matches the provided phone number';
        END IF;
    ELSE 
        RAISE EXCEPTION 'Invalid phone number format'
            USING HINT = 'Ensure the provided number conforms to the (+234) calling code';
    END IF;
END;
$$

-- Executing the procedure to update a passenger's phone number

CALL brt.update_existing_passenger_phone_number (
    pass_id := [ ],
    old_passenger_phone_number := [ ],
    new_passenger_phone_number := [ ]
);
