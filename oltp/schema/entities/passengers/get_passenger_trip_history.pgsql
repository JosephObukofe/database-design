/*

-- View -> Passenger Trip History View
-- Function -> Viewing Passenger Trip History

CREATE VIEW brt.vw_get_passenger_trip_history AS
WITH CTE AS (
    SELECT  
        p.id, 
        d.first_name,
        d.last_name,
        v.model, 
        v.plate_number
    FROM brt.driver_vehicle_pairings p 
    INNER JOIN brt.driver_details d 
        ON p.driver_id = d.id 
    INNER JOIN brt.vehicle v 
        ON p.vehicle_id = v.id 
)

SELECT 
    s.dep_terminal,
    s.arr_terminal,
    p.dep_time,
    p.arr_time,
    p.passenger_id,
    CTE.first_name,
    CTE.last_name,
    CTE.model,
    CTE.plate_number
FROM brt.scheduled_trips s
INNER JOIN CTE 
    ON s.pairing_id = CTE.id
INNER JOIN brt.passenger_trip_history p 
    ON s.id = p.trip_id
ORDER BY p.dep_time DESC;

*/

CREATE OR REPLACE FUNCTION brt.get_passenger_trip_history (
    passenger brt.passenger_details.id%type
)
RETURNS TABLE (
    departure_terminal varchar(20),
    arrival_terminal varchar(20),
    departure_time timestamp,
    arrival_time timestamp,
    driver_first_name varchar(20),
    driver_last_name varchar(20),
    vehicle_model varchar(20),
    vehicle_plate_number varchar(10)
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

    -- Content validation to ascertain the existence of the passenger
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_details WHERE id = passenger) THEN 
        RAISE EXCEPTION 'The provided passenger does not exist'
            USING HINT = 'Ensure a valid passenger ID is provided';
    END IF;

    query := (
        'SELECT 
            dep_terminal,
            arr_terminal,
            dep_time,
            arr_time,
            first_name,
            last_name,
            model,
            plate_number 
        FROM brt.vw_get_passenger_trip_history
        WHERE passenger_id = $1;'
    );

    RETURN QUERY EXECUTE query USING passenger;
END;
$$

-- Executing the passenger trip history view function

SELECT * FROM brt.brt.get_passenger_trip_history (
    passenger := [ ]
);