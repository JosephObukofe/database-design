-- This procedure completes the trip assigned to a driver, as well as sets the current arrival times and modifies the trip completion status field

CREATE OR REPLACE PROCEDURE brt.update_trip_completion_status_to_completed (
    trip brt.scheduled_trips.id%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query1 text;
    query2 text;
    query3 text;
    query4 text;
    departure brt.scheduled_trips.dep_terminal%type;
    arrival brt.scheduled_trips.arr_terminal%type;
BEGIN 
    -- Input validation for null checks
    IF trip IS NULL THEN 
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(trip) = 'integer'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain the existence of the trip
    IF NOT EXISTS (SELECT 1 FROM brt.scheduled_trips WHERE id = trip) THEN 
        RAISE EXCEPTION 'The provided trip does not exist'
            USING HINT = 'Ensure a parent record exists for the provided trip ID';
    END IF;

    -- Driver trip history arrival time modification -> To current time
    query1 := (
        'UPDATE brt.driver_trip_history
        SET arr_time = now()
        WHERE trip_id = $1;'
    );
    
    EXECUTE query1 USING trip;

    -- Passenger trip history arrival time modification -> To current time
    query2 := (
        'UPDATE brt.passenger_trip_history
        SET arr_time = now()
        WHERE trip_id = $1;'
    );

    EXECUTE query2 USING trip;

    -- Scheduled trip completion status modification -> To 'Completed'
    query3 := (
        'UPDATE brt.scheduled_trips 
        SET trip_comp_status = ''Completed''
        WHERE id = $1;'
    );

    EXECUTE query3 USING trip;

    -- Insert in Trip Completion Log
    query4 := (
        'INSERT INTO brt.trip_completion_log (function, completed_trip)
        VALUES (''trip_completion'', $1);'
    );

    EXECUTE query4 USING trip;

    SELECT
        dep_terminal,
        arr_terminal
    INTO 
        departure,
        arrival
    FROM brt.scheduled_trips
    WHERE id = trip;

    RAISE NOTICE 'Trip %, departing from % and arriving at % has been completed', trip, departure, arrival;
END;
$$

-- Executing the trip completion procedure

CALL brt.update_trip_completion_status_to_completed (
    trip := [ ]
);
