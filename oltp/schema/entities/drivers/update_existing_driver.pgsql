-- This procedure modifies an existing driver

CREATE OR REPLACE PROCEDURE brt.update_existing_driver(
    driver_id brt.driver_details.id%type,
    fname brt.driver_details.first_name%type,
    lname brt.driver_details.last_name%type,
    gen brt.driver_details.gender%type,
    dob brt.driver_details.date_of_birth%type
)
LANGUAGE plpgsql
AS $$
DECLARE 
    query text;
BEGIN
    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(driver_id) = 'integer'::regtype AND
        pg_typeof(fname) = 'varchar'::regtype AND
        pg_typeof(lname) = 'varchar'::regtype AND
        pg_typeof(gen) = 'varchar'::regtype AND
        pg_typeof(dob) = 'date'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;
    
    -- Input validation for null checks
    IF driver_id IS NULL THEN 
        RAISE EXCEPTION 'The driver ID field must be provided';
    END IF;

    -- Input validation for driver record existence
    IF NOT EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver_id) THEN 
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a parent record exists for the provided driver ID';
    END IF;

    -- Conditional modification based on user entry
    -- First Name Modification
    IF fname IS NOT NULL THEN 
        IF fname <> (SELECT first_name FROM brt.driver_details WHERE id = driver_id) THEN 
            query := (
                'UPDATE brt.driver_details
                SET first_name = $1
                WHERE id = $2;'
            );

            EXECUTE query USING fname, driver_id;
            COMMIT;
            RAISE NOTICE 'First name updated to: %', fname;
        ELSE 
            RAISE NOTICE 'Field provided already matches the existing first name: %', fname;
        END IF;
    END IF;
    -- Last Name Modification
    IF lname IS NOT NULL THEN 
        IF lname <> (SELECT last_name FROM brt.driver_details WHERE id = driver_id) THEN 
            query := (
                'UPDATE brt.driver_details
                SET last_name = $1
                WHERE id = $2;'
            );
            
            EXECUTE query USING lname, driver_id;
            COMMIT;
            RAISE NOTICE 'Last name updated to: %', lname;
        ELSE 
            RAISE NOTICE 'Field provided already matches the existing last name: %', lname;
        END IF;
    END IF;
    -- Gender Modification
    IF gen IS NOT NULL THEN 
        IF gen IN ('Male', 'Female', 'Other') THEN
            IF gen <> (SELECT gender FROM brt.driver_details WHERE id = driver_id) THEN 
                query := (
                    'UPDATE brt.driver_details
                    SET gender = $1
                    WHERE id = $2;'
                );
                
                EXECUTE query USING gen, driver_id;
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
            IF ((date_part('year', NOW()) - date_part('year', dob)) >= 20) THEN
                IF dob <> (SELECT date_of_birth FROM brt.driver_details WHERE id = driver_id) THEN 
                    query := (
                        'UPDATE brt.driver_details
                        SET date_of_birth = $1
                        WHERE id = $2;'
                    );

                    EXECUTE query USING dob, driver_id;
                    COMMIT;
                    RAISE NOTICE 'Date of birth updated to: %', dob;
                ELSE 
                    RAISE NOTICE 'Field provided already matches the existing date of birth: %', dob;
                END IF;
            ELSE 
                RAISE EXCEPTION 'Invalid age. Driver should be within the ages of 20 years and above'
            END IF;
        ELSE
            RAISE EXCEPTION 'Invalid date format for date of birth'
                USING HINT = 'Valid date representations incorporates the ISO 8601 format of (YYYY-MM-DD)';
        END IF;
    END IF;
END;
$$

-- Executing the procedure for modifiying a driver's personal details

CALL brt.update_existing_driver (
	driver_id := [ ], 
	fname := NULL,
	lname := NULL,
	gen := NULL,
	dob := NULL
);