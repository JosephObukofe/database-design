/*

-- View -> Passenger Booked Trips View
-- Function -> Viewing Passenger Booked Trips

CREATE VIEW brt.vw_get_passenger_booked_trips AS 
SELECT 
    s.dep_terminal,
    s.arr_terminal,
    s.sch_dep_time,
    s.est_arr_time,
    b.booking_time,
    b.amount_paid,
    b.passenger_id
FROM brt.passenger_booked_trips b
INNER JOIN brt.scheduled_trips s
    ON b.trip_id = s.id
ORDER BY s.sch_dep_time DESC;

*/

CREATE OR REPLACE FUNCTION brt.get_passenger_booked_trips (
    passenger brt.passenger_details.id%type
)
RETURNS TABLE (
    departure_terminal varchar(20),
    arrival_terminal varchar(20),
    departure_time timestamp,
    arrival_time timestamp,
    booking_time timestamp,
    amount_paid decimal(6, 2)
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF passenger IS NULL THEN 
        RAISE EXCEPTION 'The passenger parameter must not be null';
    END IF;

    -- Input validation for data type checks
    IF NOT (
        pg_typeof(passenger) = 'integer'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation for passenger existence
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_details WHERE id = passenger) THEN 
        RAISE EXCEPTION 'The provided passenger does not exist'
            USING HINT = 'Ensure a valid passenger ID is provided';
    END IF;

    query := (
        'SELECT 
            dep_terminal,
            arr_terminal,
            sch_dep_time,
            est_arr_time,
            booking_time,
            amount_paid
        FROM brt.vw_get_passenger_booked_trips
        WHERE passenger_id = $1;'
    );

    RETURN QUERY EXECUTE query USING passenger;
END;    
$$

-- Executing the booked trips viewing function

SELECT * FROM brt.get_passenger_booked_trips (
    passenger := [ ]
);