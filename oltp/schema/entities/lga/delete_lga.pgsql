CREATE OR REPLACE PROCEDURE brt.delete_lga(
    lga_id brt.lga.id%type
)
LANGUAGE plpgsql 
AS $$ 
DECLARE 
    query text;
BEGIN
    IF lga_id IS NULL THEN
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    IF NOT (pg_typeof(lga_id) = 'integer'::regtype) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    query := 'DELETE FROM brt.lga WHERE id = $1;';

    IF EXISTS (SELECT 1 FROM brt.lga WHERE id = lga_id) THEN 
        EXECUTE query USING lga_id;
        RAISE NOTICE 'LGA with ID: % has been successfully deleted', lga_id;
    ELSE 
        RAISE EXCEPTION 'The provided LGA does not exist';
    END IF;
END;
$$;

CALL brt.delete_lga (
	lga_id := [ ]
);
