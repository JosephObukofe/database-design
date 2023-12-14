-- This procedure mofies an existing terminal

CREATE OR REPLACE PROCEDURE brt.update_terminal (
    terminal_id brt.terminals.id%type,
    terminal_name brt.terminals.name%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    former_terminal brt.terminals.name%type;
    query text;
BEGIN 

    -- Input validation for null checks
    IF terminal_id IS NULL OR terminal_name IS NULL THEN   
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(terminal_id) = 'integer'::regtype AND
        pg_typeof(terminal_name) = 'varchar'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain the existence of the terminal
    IF NOT EXISTS (SELECT 1 FROM brt.terminals WHERE id = terminal_id) THEN 
        RAISE EXCEPTION 'The provided terminal does not exist'
            USING HINT = 'Ensure a valid terminal ID is provdided';
    END IF;

    SELECT name
    INTO former_terminal
    FROM brt.terminals
    WHERE id = terminal_id;

    IF terminal_name <> (SELECT name FROM brt.terminals WHERE id = terminal_id) THEN 
        query := (
            'UPDATE brt.terminals 
            SET name = $1 
            WHERE id = $2;'
        );

        EXECUTE query USING terminal_name, terminal_id;
        RAISE NOTICE 'Terminal successfully changed from % to %', former_terminal, terminal_name;
    ELSE 
        RAISE NOTICE 'The provided terminal name already matches an existing terminal';
    END IF;
END;
$$

-- Executing the terminal modification procedure 

CALL brt.update_terminal (
    terminal_id := [ ],
    terminal_name := [ ]
);