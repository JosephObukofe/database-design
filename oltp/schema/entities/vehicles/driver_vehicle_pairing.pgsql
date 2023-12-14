-- Create or replace a function for driver-vehicle pairing

CREATE OR REPLACE FUNCTION brt.driver_vehicle_pairing()
RETURNS TABLE (
    driver integer,
    vehicle integer
)
LANGUAGE plpgsql
AS $$
DECLARE 
    drivers integer[] := ARRAY[];
    vehicles integer[] := ARRAY[];
    query text;
BEGIN 
    -- Creating a temp table to store the registered but unpaired drivers
    CREATE TEMP TABLE brt.available_drivers (
        id serial PRIMARY KEY,
        driver_id integer
    );

    -- Creating a temp table to store the available vehicles to be paired
    CREATE TEMP TABLE brt.available_vehicles (
        id serial PRIMARY KEY,
        vehicle_id integer
    );

    -- Construct a SQL query to retrieve the drivers that have been registered but haven't been paired to a vehicle, as well as drivers currently paired to an inoperational vehicle
    SELECT d.id
    INTO drivers
    FROM brt.driver_details d
    LEFT JOIN (
        SELECT 
            p.driver_id,
            p.vehicle_id,
            v.status
        FROM brt.driver_vehicle_pairings p
        INNER JOIN brt.vehicles v
            ON p.vehicle_id = v.id
    ) p
        ON d.id = p.driver_id 
    WHERE d.registration_status = TRUE AND (p.vehicle_id IS NULL OR p.status IN ('Under Maintenance', 'Decommissioned'))
    ORDER BY d.id ASC;

    -- Construct a SQL query to retrieve the available vehicles
    SELECT id
    INTO vehicles
    FROM brt.vehicles
    WHERE status = 'Available';

    -- Loop to insert unpaired drivers into the temporary table
    FOR i IN drivers[1]..drivers[array_length(drivers, 1)] LOOP
        INSERT INTO brt.available_drivers (driver_id)
        VALUES (i);
    END LOOP;

    -- Loop to insert available vehicles into the temporary table
    FOR j IN vehicles[1]..vehicles[array_length(vehicles, 1)] LOOP 
        INSERT INTO brt.available_vehicles (vehicle_id)
        VALUES (j);
    END LOOP;

    -- Construct a dynamic SQL query to select pairs where both driver and vehicle are available
    query := (
        'SELECT 
            driver_id,
            vehicle_id 
        FROM brt.available_drivers 
        FULL JOIN brt.available_vehicles
            USING (id)
        WHERE driver_id IS NOT NULL AND vehicle_id IS NOT NULL;'
    );

    -- Return the result of the dynamic query
    RETURN QUERY EXECUTE query;
END;
$$;


-- Create a procedure to insert the pairings into brt.driver_vehicle_pairings table
CREATE OR REPLACE PROCEDURE brt.insert_driver_vehicle_pairings()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Define a record variable to hold the result of the function (brt.driver_vehicle_pairing)
    pairing_record RECORD; 
BEGIN
    -- Call the function and insert the results into brt.driver_vehicle_pairings
    FOR pairing_record IN (SELECT * FROM brt.driver_vehicle_pairing()) LOOP
        INSERT INTO brt.driver_vehicle_pairings (driver_id, vehicle_id, pair_date)
        VALUES (pairing_record.driver, pairing_record.vehicle, now());
    END LOOP;
END;
$$;