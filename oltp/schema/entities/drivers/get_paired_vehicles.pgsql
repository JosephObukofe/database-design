/*

-- View -> Paired Vehicles View
-- Function -> Viewing Paired Vehicles

CREATE VIEW brt.vw_get_paired_vehicles AS
WITH CTE AS (
    SELECT 
        v.id,
        v.vin,
        v.plate_number,
        v.model,
        v.capacity,
        t.name
    FROM brt.vehicle v 
    INNER JOIN brt.terminals t
        ON v.terminal_id = t.id
)

SELECT 
    CTE.vin,
    CTE.plate_number,
    CTE.model,
    CTE.capacity,
    CTE.name,
    p.pair_date,
    p.driver_id
FROM CTE 
INNER JOIN brt.driver_vehicle_pairings p 
    ON CTE.id = p.vehicle_id 
ORDER BY pair_date DESC;

*/

CREATE OR REPLACE FUNCTION brt.get_paired_vehicles (
    driver brt.driver_details.id%type
)
RETURNS TABLE(
    vin varchar(20),
    plate_number varchar(10),
    model varchar(20),
    capacity integer,
    terminal varchar(20),
    pair_date timestamp
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

    -- Content vaalidation to ascertain the existence of the driver
    IF NOT EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver) THEN 
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a valid driver ID is provided';
    END IF;

    query := (
        'SELECT 
            vin,
            plate_number,
            model,
            capacity,
            name, 
            pair_date 
        FROM brt.vw_get_paired_vehicles 
        WHERE driver_id = $1;'
    );

    RETURN QUERY EXECUTE query USING driver;
END;
$$

-- Executing the paired vehicles viewing function

SELECT * FROM brt.get_paired_vehicles (
    driver := [ ]
);