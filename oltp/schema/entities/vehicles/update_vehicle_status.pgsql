-- Creating a trigger function that updates the vehicle status after pairing to registered drivers
-- INSERT in (brt.driver_vehicle_pairings) -> UPDATE on (brt.vehicles)

CREATE OR REPLACE FUNCTION brt.update_vehicle_status()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
DECLARE 
    vehicle integer[] := ARRAY[];
BEGIN 
    -- Retrieve the list of vehicle IDs from the recently inserted driver-vehicle pairings
    SELECT NEW.vehicle_id 
    INTO vehicle 
    FROM brt.driver_vehicle_pairings;

    -- Loop through each vehicle ID to update their status to 'In Use'
    FOR i IN vehicle[1]..vehicle[array_length(vehicle, 1)] LOOP 
        UPDATE brt.vehicles 
        SET status = 'In Use'
        WHERE id = i;
    END LOOP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS update_vehicle_status
ON brt.driver_vehicle_pairings;

CREATE TRIGGER update_vehicle_status
    AFTER INSERT
    ON brt.driver_vehicle_pairings
    FOR EACH STATEMENT
    EXECUTE FUNCTION brt.update_vehicle_status();