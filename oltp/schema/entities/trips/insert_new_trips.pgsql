-- This procedure inserts a new record of a given trip in the scheduled trips table

CREATE OR REPLACE PROCEDURE brt.insert_new_trips(
    departure varchar(20),
    arrival varchar(20),
    departure_time timestamp,
    est_arrival_time timestamp,
    trip_sub_total numeric,
    trip_booking_fee numeric,
	maximum_trip_cap integer,
    pair_id integer
)
LANGUAGE plpgsql 
AS $$
DECLARE 
	departure_terminal varchar(20);
	arrival_terminal varchar(20);
    query text;
BEGIN
    -- Input validation for null checks
    IF departure IS NULL OR arrival IS NULL OR departure_time IS NULL OR est_arrival_time IS NULL OR trip_sub_total IS NULL OR trip_booking_fee IS NULL OR maximum_trip_cap IS NULL OR pair_id IS NULL THEN
        RAISE EXCEPTION 'All fields must be provided';
    END IF;
	
	-- Input validation for argument data type checks
    IF NOT (
        pg_typeof(departure) = 'varchar'::regtype AND
        pg_typeof(arrival) = 'varchar'::regtype AND
        pg_typeof(departure_time) = 'timestamp'::regtype AND
        pg_typeof(est_arrival_time) = 'timestamp'::regtype AND
        pg_typeof(trip_sub_total) = 'numeric'::regtype AND
        pg_typeof(trip_booking_fee) = 'numeric'::regtype AND
		pg_typeof(maximum_trip_cap) = 'integer'::regtype AND
        pg_typeof(pair_id) = 'integer'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Input validation for driver-vehicle pairing record existence
    IF NOT EXISTS (SELECT 1 FROM brt.driver_vehicle_pairings WHERE id = pair_id) THEN
        RAISE EXCEPTION 'The provided driver-vehicle pairing does not exist'
            USING HINT = 'Ensure that the provided driver-vehicle pair is valid';
    END IF;
	
	-- Asserting the domain of the terminals list for departures
	IF EXISTS (SELECT 1 FROM brt.terminals WHERE name = departure) THEN
		SELECT name
		INTO departure_terminal
		FROM brt.terminals
		WHERE name = departure;
	ELSE
		RAISE EXCEPTION 'The provided departure terminal "%" is not valid', departure;
	END IF;
	
	-- Asserting the domain of the terminals list for arrivals
	IF EXISTS (SELECT 1 FROM brt.terminals WHERE name = arrival) THEN
		SELECT name
		INTO arrival_terminal
		FROM brt.terminals
		WHERE name = arrival;
	ELSE 
		RAISE EXCEPTION 'The provided arrival terminal "%" is not valid', arrival;
	END IF;
		
    query := (
        'INSERT INTO brt.scheduled_trips (dep_terminal, arr_terminal, sch_dep_time, est_arr_time, subtotal, booking_fee, max_trip_cap, pairing_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8);'
    );

    EXECUTE query USING departure_terminal, arrival_terminal, departure_time, est_arrival_time, trip_sub_total, trip_booking_fee, maximum_trip_cap, pair_id;
    RAISE NOTICE 'Trip: % to % departing at % and arriving at % has been successfully inserted', departure_terminal, arrival_terminal, departure_time, est_arrival_time;
END;
$$

-- Executing the trip insertion procedure

CALL brt.insert_new_trips (
    departure := [ ],
    arrival := [ ],
    departure_time := [ ],
    est_arrival_time := [ ],
    trip_sub_total := [ ],
    trip_booking_fee := [ ],
	maximum_trip_cap := [ ],
    pair_id := [ ]
);