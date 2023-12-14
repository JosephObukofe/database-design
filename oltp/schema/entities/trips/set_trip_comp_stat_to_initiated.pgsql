CREATE OR REPLACE FUNCTION brt.set_trip_comp_stat_to_initiated (
    trip_id brt.scheduled_trips.id%type
) 
RETURNS VOID 
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for trip existence check
    IF NOT EXISTS (SELECT 1 FROM brt.scheduled_trips WHERE id = trip_id) THEN 
        RAISE EXCEPTION 'The specified trip does not exist'
            USING HINT = 'Ensure a valid trip ID is provided for an existing trip';
    END IF;

    query := (
        'UPDATE brt.scheduled_trips 
        SET trip_comp_status = ''Initiated''
        WHERE id = $1;'
    );

    EXECUTE query USING trip_id;
    RAISE NOTICE 'Trip % has been initiated', trip_id;
END;
$$

BEGIN;
	SELECT brt.set_trip_comp_stat_to_initiated(trip_id := 4); -- No return value since it is a void function
COMMIT;