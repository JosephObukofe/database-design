-- This procedure initiates the trip assigned to a driver, as well as sets the current departure times and modifies the trip completion status field

CREATE OR REPLACE PROCEDURE brt.update_trip_completion_status_to_initiated (
    trip brt.scheduled_trips.id%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query1 text;
    query2 text;
    query3 text;
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

    -- Driver trip history departure time modification -> To current time
    query1 := (
        'UPDATE brt.driver_trip_history
        SET dep_time = now()
        WHERE trip_id = $1;'
    );

    EXECUTE query1 USING trip;

    -- Passenger trip history departure time modification -> To current time
    query2 := (
        'UPDATE brt.passenger_trip_history
        SET dep_time = now()
        WHERE trip_id = $1;'
    );

    EXECUTE query2 USING trip;

    -- Scheduled trip completion status modification -> To 'Initiated'
    query3 := (
        'UPDATE brt.scheduled_trips 
        SET trip_comp_status = ''Initiated''
        WHERE id = $1;'
    );

    EXECUTE query3 USING trip;

    SELECT
        dep_terminal,
        arr_terminal
    INTO 
        departure,
        arrival
    FROM brt.scheduled_trips
    WHERE id = trip;

    RAISE NOTICE 'Trip %, departing from % and arriving at % has been initiated', trip, departure, arrival;
END;
$$

-- Executing the trip initiation procedure

CALL brt.update_trip_completion_status_to_initiated (
    trip := [ ]
);
