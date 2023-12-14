/*

-- View -> Driver Completed Trips View
-- Function -> Viewing Driver Completed Trips/Trip History

CREATE VIEW brt.vw_get_driver_completed_trips AS
WITH CTE AS (
    SELECT 
        p.id,
        p.driver_id,
        v.plate_number,
        v.model
    FROM brt.vehicle v 
    INNER JOIN brt.driver_vehicle_pairings p 
        ON v.id = p.vehicle_id
)

SELECT 
    s.dep_terminal,
    s.arr_terminal,
    h.dep_time,
    h.arr_time,
    h.trip_capacity,
    CTE.plate_number,
    CTE.model,
    CTE.driver_id
FROM brt.driver_trip_history h
INNER JOIN brt.scheduled_trips s 
    ON h.trip_id = s.id
INNER JOIN CTE  
    ON h.pairing_id = CTE.id
WHERE 
    h.trip_capacity > 0
ORDER BY h.id DESC;

*/

CREATE OR REPLACE FUNCTION brt.get_driver_completed_trips (
    driver brt.driver_details.id%type
)
RETURNS TABLE (
    departure_terminal varchar(20),
    arrival_terminal varchar(20),
    departure_time timestamp,
    arrival_time timestamp,
    trip_capacity smallint,
    vehicle_plate_number varchar(10),
    vehicle_model varchar(20)
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF driver IS NULL THEN 
        RAISE EXCEPTION 'The driver parameter must not be null';
    END IF;

    -- Input validation for data type checks
    IF NOT (
        pg_typeof(driver) = 'integer'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain the existence of a driver
    IF NOT EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver) THEN 
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a valid driver ID is provided';
    END IF;

    query := (
        'SELECT 
            dep_terminal,
            arr_terminal,
            dep_time,
            arr_time,
            trip_capacity,
            plate_number,
            model 
        FROM brt.vw_get_driver_completed_trips
        WHERE driver_id = $1;'
    );

    RETURN QUERY EXECUTE query USING driver;
END;
$$

-- Executing the drivers trip history view function

SELECT * FROM brt.get_driver_completed_trips (
    driver := [ ]
);