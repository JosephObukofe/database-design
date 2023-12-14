CREATE OR REPLACE PROCEDURE brt.insert_driver_nin(
    driver brt.driver_nin.driver_id%type,
    nin brt.driver_nin.nin%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF driver IS NULL OR driver IS NULL THEN   
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(driver) = 'integer'::regtype AND
        pg_typeof(nin) = 'char'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Input validation for driver existence
    IF NOT EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver) THEN
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a parent record exists for the provided driver ID';
    END IF;

    query := (
        'INSERT INTO brt.driver_nin (nin, driver_id)
        VALUES ($1, $2);'
    );
    
    EXECUTE query USING nin, driver;
    COMMIT;
    RAISE NOTICE 'Driver NIN: % successfully inserted', nin;
END;
$$

CALL brt.insert_driver_nin (
    driver := [ ],
    nin := [ ]
)