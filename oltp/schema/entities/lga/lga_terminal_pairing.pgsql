-- This procedure pairs an LGA to a Terminal

CREATE OR REPLACE PROCEDURE brt.lga_terminal_pairing_operation(
    lg brt.lga.id%type,
    terminal brt.terminals.id%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    l brt.lga.name%type;
    t brt.terminals.name%type;
    query text;
BEGIN 
    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(lg) = 'integer'::regtype AND
        pg_typeof(terminal) = 'integer'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Input validation to check for the existence of LGA
    IF NOT EXISTS (SELECT 1 FROM brt.lga WHERE id = lg) THEN 
        RAISE EXCEPTION 'The provided LGA does not exist'
            USING HINT = 'Ensure a valid record exists for the provided LGA ID';
    ELSE 
        SELECT name 
        INTO l
        FROM brt.lga
        WHERE id = lg;
    END IF;

    -- Input validation to check for the existence of terminal
    IF NOT EXISTS (SELECT 1 FROM brt.terminals WHERE id = terminal) THEN 
        RAISE EXCEPTION 'The provided terminal does not exist'
            USING HINT = 'Ensure a valid record exists for the provided terminal ID';
    ELSE
        SELECT name
        INTO t 
        FROM brt.terminals
        WHERE id = terminal;
    END IF;
    
    query := (
        'INSERT INTO brt.lga_terminal_pairing (lg_id, terminal_id)
        VALUES ($1, $2);'
    );

    EXECUTE query USING lg, terminal;
    RAISE NOTICE 'Terminal: % has been successfully paired to % LGA', t, l;
END;
$$

-- Executing the pairing procedure

CALL brt.lga_terminal_pairing(
    lga := [ ],
    terminal := [ ]
);
