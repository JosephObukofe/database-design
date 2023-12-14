-- This procedure inserts a new terminal record in the terminal table

CREATE OR REPLACE PROCEDURE brt.insert_new_terminal(
    terminal brt.terminals.name%type
)
LANGUAGE plpgsql 
AS $$ 
DECLARE 
    terminal_name brt.terminals.name%type;
    query text;
BEGIN
    -- Input validation for null checks
    IF terminal IS NULL THEN
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(terminal) = 'varchar'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain a valid terminal value
    IF EXISTS (SELECT 1 FROM brt.terminals WHERE name = terminal) THEN 
        RAISE EXCEPTION 'The provided terminal already exists'
            USING HINT = 'Kindly provide a distinct terminal name';
    ELSE 
        terminal_name := terminal;
    END IF;

    query := (
        'INSERT INTO brt.terminals (name)
        VALUES ($1);'
    );

    EXECUTE query USING terminal_name;
    RAISE NOTICE 'Terminal: % has been successfully inserted', terminal_name;
END;
$$;

-- Executing the terminal insert procedure

CALL brt.insert_new_terminal (
	terminal := [ ]
);