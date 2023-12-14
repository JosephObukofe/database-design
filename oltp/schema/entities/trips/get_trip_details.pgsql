/*

-- View -> Trip Search View
-- Function -> Viewing Available/Scheduled Trips 

CREATE VIEW brt.vw_trip_search AS 
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
    dep_terminal,
    arr_terminal,
    sch_dep_time,
    est_arr_time,
    dow, 
    trip_fare,
    trip_status,
    trip_comp_status,
    CTE.first_name,
    CTE.last_name,
    CTE.model,
    CTE.plate_number
FROM brt.scheduled_trips s 
INNER JOIN CTE 
    ON s.pairing_id = CTE.id;

*/

CREATE OR REPLACE FUNCTION brt.get_trip_details (
    departure brt.scheduled_trips.dep_terminal%type,
    arrival brt.scheduled_trips.arr_terminal%type,
    departure_time brt.scheduled_trips.sch_dep_time%type
)
RETURNS TABLE(
    departure_terminal varchar(20),
    arrival_terminal varchar(20),
    est_departure_time timestamp,
    est_arrival_time timestamp,
    day_of_the_week varchar(10),
    trip_fare decimal(6, 2),
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
    IF departure IS NULL OR arrival IS NULL OR departure_time IS NULL THEN   
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for data type checks
    IF NOT (
        pg_typeof(departure) = 'varchar'::regtype AND
        pg_typeof(arrival) = 'varchar'::regtype AND
        pg_typeof(departure_time) = 'timestamp'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain valid departure and arrival terminals
    IF NOT EXISTS (SELECT 1 FROM brt.terminals WHERE name = departure) THEN
        RAISE EXCEPTION 'The provided departure terminal does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM brt.terminals WHERE name = arrival) THEN
        RAISE EXCEPTION 'The provided arrival terminal does not exist';
    END IF;

    query := (
        'SELECT 
            dep_terminal,
            arr_terminal,
            sch_dep_time,
            est_arr_time,
            dow,
            trip_fare,
            first_name,
            last_name,
            model, 
            plate_number
        FROM brt.vw_trip_search
        WHERE
            dep_terminal = $1 AND 
            arr_terminal = $2 AND 
            sch_dep_time > $3::timestamp AND 
            trip_status = ''Ongoing'' AND 
            trip_comp_status = ''None''
        ORDER BY sch_dep_time ASC;'
    );

    RETURN QUERY EXECUTE query USING departure, arrival, departure_time;
END;
$$

-- Executing the scheduled trips viewing function

SELECT * FROM brt.get_trip_details(
    departure := [ ],
    arrival := [ ],
    departure_time := [ ]
);