-- This procedure assigns a terminal to a driver. It is usually done explicitly during registration processes

CREATE OR REPLACE PROCEDURE brt.insert_new_driver_terminal(
    driver brt.driver_details.id%type,
    terminal brt.terminals.name%type
)
LANGUAGE plpgsql
AS $$
DECLARE 
    term_id integer;
    term_name varchar(20);
    query text;
BEGIN
    -- Input validation for null checks
    IF driver IS NULL OR terminal IS NULL THEN 
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type check
    IF NOT (
        pg_typeof(driver) = 'integer'::regtype AND
        pg_typeof(terminal) = 'varchar'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;
    
    -- Content validation to ascertain the existence of the driver
    IF NOT EXISTS (SELECT id FROM brt.driver_details WHERE id = driver) THEN
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a parent record exists for the provided driver ID';
    END IF;

    -- Modification based on terminal selection
    -- To view the terminal list, run (SELECT * FROM brt.terminals)
    IF EXISTS (SELECT 1 FROM brt.terminals WHERE name = terminal) THEN 
        SELECT id 
        INTO term_id 
        FROM brt.terminals
        WHERE name = terminal;

        SELECT name 
        INTO term_name
        FROM brt.terminals
        WHERE name = terminal;

        query := (
            'UPDATE brt.driver_details 
            SET terminal_id = $1
            WHERE id = $2;'
        );

        EXECUTE query USING term_id, driver;
        RAISE NOTICE 'Driver % has been assigned to the % terminal', driver, term_name;
    ELSE 
        RAISE EXCEPTION 'The provided terminal does not exist'
            USING HINT = 'Ensure the terminal provided is a valid terminal';
    END IF;
END;
$$

-- Executing the procedure to assign a terminal to a driver

CALL brt.insert_new_driver_terminal(
    driver := [ ],
    terminal := [ ]
);