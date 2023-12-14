-- This procedure inserts a new record into the passenger's email address table

CREATE OR REPLACE PROCEDURE brt.insert_new_passenger_email(
    pass_id brt.passenger_email_address.passenger_id%type,
	email brt.passenger_email_address.email_address%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN
    -- Input validation for null checks
    IF pass_id IS NULL OR email IS NULL THEN 
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(pass_id) = 'integer'::regtype AND
        pg_typeof(email) = 'varchar'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Input validation for passenger record existence
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_details WHERE id = pass_id) THEN 
        RAISE EXCEPTION 'The provided passenger does not exist'
            USING HINT = 'Ensure a parent record exists for the provided passenger ID';
    END IF;

    query := (
        'INSERT INTO brt.passenger_email_address(email_address, passenger_id)
        VALUES ($1, $2);'
    );

    EXECUTE query USING email, pass_id;
    RAISE NOTICE 'Passenger Email Address: % successfully inserted', email;
END;
$$

-- Executing the passenger email address insert procedure

CALL brt.insert_new_passenger_email (
	pass_id := [],
	email := []
);