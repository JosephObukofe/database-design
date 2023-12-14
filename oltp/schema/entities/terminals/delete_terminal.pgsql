CREATE OR REPLACE PROCEDURE brt.delete_terminal(
    terminal_id brt.terminals.id%type
)
LANGUAGE plpgsql 
AS $$ 
DECLARE 
    query text;
BEGIN
    IF terminal_id IS NULL THEN
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    IF NOT (pg_typeof(terminal_id) = 'integer'::regtype) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    query := 'DELETE FROM brt.terminals WHERE id = $1;';

    IF EXISTS (SELECT 1 FROM brt.terminals WHERE id = terminal_id) THEN 
        EXECUTE query USING terminal_id;
        RAISE NOTICE 'Terminal with ID: % has been successfully deleted', terminal_id;
    ELSE 
        RAISE EXCEPTION 'The provided terminal does not exist';
    END IF;
END;
$$;

CALL brt.delete_terminal (
	terminal_id := [ ]
);