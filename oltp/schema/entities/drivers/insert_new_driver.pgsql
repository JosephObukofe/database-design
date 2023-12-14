-- This procedure inserts a new driver into the drivers table

CREATE OR REPLACE PROCEDURE brt.insert_new_driver(
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
    -- Input validation for null checks
    IF fname IS NULL OR lname IS NULL OR gen IS NULL OR dob IS NULL THEN 
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(fname) = 'varchar'::regtype AND
        pg_typeof(lname) = 'varchar'::regtype AND
        pg_typeof(gen) = 'varchar'::regtype AND
        pg_typeof(dob) = 'date'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Format validation to ascertain the date of birth is in a valid format (YYYY-MM-DD)
    IF NOT dob::text ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN
        RAISE EXCEPTION 'Invalid date format for date of birth'
            USING HINT = 'Valid date representations incorporates the ISO 8601 format of (YYYY-MM-DD)';
    END IF;

    -- Content validation to check if gender is valid
    IF NOT gen IN ('Male', 'Female', 'Other') THEN
        RAISE EXCEPTION 'Invalid gender value';
    END IF;

    query := (
        'INSERT INTO brt.driver_details (first_name, last_name, gender, date_of_birth)
        VALUES ($1, $2, $3, $4);'
    );

    EXECUTE query USING fname, lname, gen, dob;
    RAISE NOTICE 'Driver: % % successfully inserted', fname, lname;
END;
$$

-- Initiating the driver insert procedure

CALL brt.insert_new_driver (
    fname := [ ],
    lname := [ ],
    gen := [ ],
    dob := [ ]
);



