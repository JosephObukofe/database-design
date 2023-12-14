CREATE OR REPLACE FUNCTION brt.set_trip_comp_stat_to_completed (
    trip_id brt.scheduled_trips.id%type
) 
RETURNS VOID 
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
    query2 text;
BEGIN 
    -- Input validation for trip existence check
    IF NOT EXISTS (SELECT 1 FROM brt.scheduled_trips WHERE id = trip_id) THEN 
        RAISE EXCEPTION 'The specified trip does not exist'
            USING HINT = 'Ensure a valid trip ID is provided for an existing trip';
    END IF;
	
    -- Updating the trip_comp_status field in brt.scheduled_trips
    query := (
        'UPDATE brt.scheduled_trips 
        SET trip_comp_status = ''Completed''
        WHERE id = $1;'
    );

    EXECUTE query USING trip_id;
    RAISE NOTICE 'Trip % has been successfully completed', trip_id;

    -- Inserting records in brt.trip_completion_log table
    query2 := (
        'INSERT INTO brt.trip_completion_log (function, completed_trip)
        VALUES (''set_trip_comp_stat_to_completed'', $1);'
    );

    EXECUTE query2 USING trip_id;
    RAISE NOTICE 'Trip % successfully logged', trip_id;
END;
$$


BEGIN;
	SELECT brt.set_trip_comp_stat_to_completed(trip_id := 5); -- No return value since it is a void function
COMMIT;