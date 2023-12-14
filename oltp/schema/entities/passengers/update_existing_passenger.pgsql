-- This procedure modifies the personal details of an existing passenger

CREATE OR REPLACE PROCEDURE brt.update_existing_passenger(
    pass_id brt.passenger_details.id%type,
    fname brt.passenger_details.first_name%type,
    lname brt.passenger_details.last_name%type,
    gen brt.passenger_details.gender%type,
    dob brt.passenger_details.date_of_birth%type
)
LANGUAGE plpgsql
AS $$
DECLARE 
    query text;
BEGIN
    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(pass_id) = 'integer'::regtype AND
        pg_typeof(fname) = 'varchar'::regtype AND
        pg_typeof(lname) = 'varchar'::regtype AND
        pg_typeof(gen) = 'varchar'::regtype AND
        pg_typeof(dob) = 'date'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;
    
    -- Input validation for null checks
    IF pass_id IS NULL THEN 
        RAISE EXCEPTION 'The passenger ID field must be provided';
    END IF;

    -- Input validation for passenger record existence
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_details WHERE id = pass_id) THEN 
        RAISE EXCEPTION 'The provided passenger does not exist'
            USING HINT = 'Ensure a parent record exists for the provided passenger ID';
    END IF;

    -- Conditional modification based on user entry
    -- First Name Modification
    IF fname IS NOT NULL THEN 
        IF fname <> (SELECT first_name FROM brt.passenger_details WHERE id = pass_id) THEN 
            query := (
                'UPDATE brt.passenger_details
                SET first_name = $1
                WHERE id = $2;'
            );

            EXECUTE query USING fname, pass_id;
            COMMIT;
            RAISE NOTICE 'First name updated to: %', fname;
        ELSE 
            RAISE NOTICE 'Field provided already matches the existing first name: %', fname;
        END IF;
    END IF;
    -- Last Name Modification
    IF lname IS NOT NULL THEN 
        IF lname <> (SELECT last_name FROM brt.passenger_details WHERE id = pass_id) THEN 
            query := (
                'UPDATE brt.passenger_details
                SET last_name = $1
                WHERE id = $2;'
            );
            
            EXECUTE query USING lname, pass_id;
            COMMIT;
            RAISE NOTICE 'Last name updated to: %', lname;
        ELSE 
            RAISE NOTICE 'Field provided already matches the existing last name: %', lname;
        END IF;
    END IF;
    -- Gender Modification
    IF gen IS NOT NULL THEN 
        IF gen IN ('Male', 'Female', 'Other') THEN
            IF gen <> (SELECT gender FROM brt.passenger_details WHERE id = pass_id) THEN 
                query := (
                    'UPDATE brt.passenger_details
                    SET gender = $1
                    WHERE id = $2;'
                );
                
                EXECUTE query USING gen, pass_id;
                COMMIT;
                RAISE NOTICE 'Gender updated to: %', gen;
            ELSE 
                RAISE NOTICE 'Field provided already matches the existing gender: %', gen;
            END IF;
        ELSE 
            RAISE EXCEPTION 'Invalid gender value: %', gen;
        END IF;
    END IF;
    -- Date of Birth Modification
    IF dob IS NOT NULL THEN 
        IF dob::text ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN
            IF ((date_part('year', NOW()) - date_part('year', dob)) >= 10) THEN
                IF dob <> (SELECT date_of_birth FROM brt.passenger_details WHERE id = pass_id) THEN 
                    query := (
                        'UPDATE brt.passenger_details
                        SET date_of_birth = $1
                        WHERE id = $2;'
                    );

                    EXECUTE query USING dob, pass_id;
                    COMMIT;
                    RAISE NOTICE 'Date of birth updated to: %', dob;
                ELSE 
                    RAISE NOTICE 'Field provided already matches the existing date of birth: %', dob;
                END IF;
            ELSE 
                RAISE EXCEPTION 'Invalid age. Passenger should be within the ages of 10 years and above'
            END IF;
        ELSE    
            RAISE EXCEPTION 'Invalid date format for date of birth'
                USING HINT = 'Valid date representations incorporates the ISO 8601 format of (YYYY-MM-DD)';
        END IF;
    END IF;
END;
$$

-- Executing the procedure for modifying a passenger's personal detail

CALL brt.update_existing_passenger (
	pass_id := [ ],
	fname := NULL,
	lname := NULL,
	gen := NULL,
	dob := NULL
);