/*

-- View -> Assigned Trips View
-- Function -> Viewing Driver Assigned Trips

CREATE VIEW brt.vw_get_assigned_trips AS
SELECT 
    s.dep_terminal,
    s.arr_terminal,
    s.sch_dep_time,
    s.est_arr_time,
    s.dow,
    s.trip_fare,
    s.current_trip_cap,
    p.driver_id
FROM brt.scheduled_trips s 
INNER JOIN brt.driver_vehicle_pairings p 
    ON s.pairing_id = p.id
ORDER BY sch_dep_time ASC;

*/

CREATE OR REPLACE FUNCTION brt.get_assigned_trips (
    driver brt.driver_details.id%type
)
RETURNS TABLE(
    departure_terminal varchar(20),
    arrival_terminal varchar(20),
    departure_time timestamp,
    arrival_time timestamp,
    day_of_the_week varchar(10),
    fare decimal(6, 2),
    current_trip_capacity smallint
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

    -- Content validation to ascertain the existence of the driver
    IF NOT EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver) THEN 
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a valid driver ID is provided';
    END IF;

    query := (
        'SELECT 
            dep_terminal,
            arr_terminal,
            sch_dep_time,
            est_arr_time,
            dow,
            trip_fare,
            current_trip_cap
        FROM brt.vw_get_assigned_trips
        WHERE driver_id = $1;'
    );

    RETURN QUERY EXECUTE query USING driver;
END;
$$

-- Executing the assigned trips view function

SELECT * FROM brt.get_assigned_trips (
    driver := [ ]
);