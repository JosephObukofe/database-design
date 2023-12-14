-- This procedure modifies the driver-vehicle pairing information for scheduled trips

CREATE OR REPLACE PROCEDURE brt.update_trip_pairing_info (
    trip_id brt.scheduled_trips.id%type,
    pair_id brt.scheduled_trips.pairing_id%type
)
LANGUAGE plpgsql
AS $$
DECLARE
    query text;
    arrival brt.scheduled_trips.arr_terminal%type;
    departure brt.scheduled_trips.dep_terminal%type;
    dep_time brt.scheduled_trips.sch_dep_time%type;
BEGIN
    -- Input validation for null checks
    IF trip_id IS NULL OR pair_id IS NULL THEN   
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(trip_id) = 'integer'::regtype AND
        pg_typeof(pair_id) = 'integer'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain if the provided trip exists
    IF NOT EXISTS (SELECT 1 FROM brt.scheduled_trips WHERE id = trip_id) THEN 
        RAISE EXCEPTION 'The provided trip ID does not exist'
            USING HINT = 'Ensure the provided trip ID is referenced to an existing trip';
    END IF;

    -- Content validation to ascertain if the provided pair exists
    IF NOT EXISTS (SELECT 1 FROM brt.scheduled_trips WHERE pairing_id = pair_id) THEN 
        RAISE EXCEPTION 'The provided pairing ID does not exist'
            USING HINT = 'Ensure the provided pair ID is referenced to an existing driver-vehicle pair';
    END IF;

    -- Defining the arrival terminal
    SELECT arr_terminal 
    INTO arrival
    FROM brt.scheduled_trips
    WHERE id = trip_id;

    -- Defining the departure terminal
    SELECT dep_terminal 
    INTO departure
    FROM brt.scheduled_trips
    WHERE id = trip_id;

    -- Defining the departure time
    SELECT sch_dep_time 
    INTO dep_time
    FROM brt.scheduled_trips
    WHERE id = trip_id;

    IF pair_id == 0 THEN
        IF pair_id <> (SELECT pairing_id FROM brt.scheduled_trips WHERE id = trip_id) THEN 
            query := (
                'UPDATE brt.scheduled_trips
                SET pairing_id = $1
                WHERE id = $2;'
            );

            EXECUTE query USING pair_id, trip_id;
            RAISE NOTICE 'Trip departing from % and arriving at % at % has been successfully paired to Driver-Vehicle Pair: %', departure, arrival, dep_time, pair_id;
        ELSE
            RAISE EXCEPTION 'The provided pairing information already exist for the specified trip'
        END IF;
    ELSE 
        RAISE EXCEPTION 'Invalid value'
            USING HINT = 'Ensure a non-zero value argument'
    END IF;
END;
$$

-- Executing the pair modification procedure

CALL brt.update_trip_pairing_info (
    trip_id := [ ],
    pair_id := [ ],
);