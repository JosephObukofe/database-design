-- This procedure inserts a new LGA record in the LGA table

CREATE OR REPLACE PROCEDURE brt.insert_new_lga(
    lga_name brt.lga.name%type,
    lga_postal_code brt.lga.postal_code%type
)
LANGUAGE plpgsql 
AS $$ 
DECLARE 
    lg brt.lga.name%type;
    code brt.lga.postal_code%type;
    query text;
BEGIN
    -- Input validation for null checks
    IF lga_name IS NULL OR lga_postal_code IS NULL THEN
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(lga_name) = 'varchar'::regtype AND
        pg_typeof(lga_postal_code) = 'char'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain a valid LGA value
    IF EXISTS (SELECT 1 FROM brt.lga WHERE name = lga_name) THEN 
        RAISE EXCEPTION 'The provided LGA already exists'
            USING HINT = 'Kindly provide a distinct LGA name';
    ELSE 
        lg := lga_name;
    END IF;

    -- Content validation to ascertain a valid postal code value
    IF EXISTS (SELECT 1 FROM brt.lga WHERE postal_code = lga_postal_code) THEN
        RAISE EXCEPTION 'The provided postal code already exists'
            USING HINT = 'Kindly provide a distinct postal code';
    ELSE 
        code := lga_postal_code;
    END IF;

    query := (
        'INSERT INTO brt.lga (name, postal_code)
        VALUES ($1, $2);'
    );

    EXECUTE query USING lg, code;
    RAISE NOTICE 'LGA: % with postal code: % has been successfully inserted', lg, code;
END;
$$;

-- Executing the LGA insert procedure

CALL brt.insert_new_lga (
	lga_name := [ ],
	lga_postal_code := [ ]
);