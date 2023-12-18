-- This procedure modifies an existing LGA (Local Government Area)

CREATE OR REPLACE PROCEDURE brt.update_lga (
    lga_id brt.lga.id%type,
    lga_name brt.lga.name%type
    lga_postal_code brt.lga.postal_code%type
)
LANGUAGE plpgsql 
AS $$
DECLARE
    former_lga_name brt.lga.name%type;
    former_lga_postal_code brt.lga.postal_code%type;
    query1 text;
    query2 text;
BEGIN
    -- Input validation for null checks
    IF lga_id IS NULL OR lga_name IS NULL OR lga_postal_code IS NULL THEN   
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(lga_id) = 'integer'::regtype AND
        pg_typeof(lga_name) = 'varchar'::regtype AND
        pg_typeof(lga_postal_code) = 'char'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain the existence of the LGA
    IF NOT EXISTS (SELECT 1 FROM brt.lga WHERE id = lga_id) THEN 
        RAISE EXCEPTION 'The provided LGA does not exist'
            USING HINT = 'Ensure a valid LGA ID is provdided';
    END IF;

    -- Fetching the former values
    SELECT 
        name,
        postal_code
    INTO 
        former_lga_name,
        former_lga_postal_code
    FROM brt.lga
    WHERE id = lga_id;


    -- Modifying the LGA name
    IF lga_name <> former_lga_name THEN 
        query1 := (
            'UPDATE brt.lga 
            SET name = $1 
            WHERE id = $2;'
        );

        EXECUTE query1 USING lga_name, lga_id;
        RAISE NOTICE 'LGA name successfully changed from % to %', former_lga_name, lga_name;
    ELSE 
        RAISE NOTICE 'The provided LGA name already matches an existing LGA';
    END IF;

    -- Modifying the LGA postal code
    IF lga_postal_code <> former_lga_postal_code THEN 
        query2 := (
            'UPDATE brt.lga 
            SET postal_code = $1 
            WHERE id = $2;'
        );

        EXECUTE query2 USING lga_postal_code, lga_id;
        RAISE NOTICE 'LGA postal code successfully changed from % to %', former_lga_postal_code, lga_postal_code;
    ELSE 
        RAISE NOTICE 'The provided LGA postal code already matches an existing postal code';
    END IF;
END;
$$

-- Executing the terminal modification procedure 

CALL brt.update_lga (
    lga_id := [ ],
    lga_name := [ ]
    lga_postal_code := [ ]
);