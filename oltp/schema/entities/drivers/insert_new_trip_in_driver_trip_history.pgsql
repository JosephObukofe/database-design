-- This function inserts a new trip into the driver's trip history when a new trip is scheduled.
-- INSERT in (brt.scheduled_trips) -> INSERT in (brt.driver_trip_history)

CREATE OR REPLACE FUNCTION brt.insert_new_trip_in_driver_trip_history()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
BEGIN 
    INSERT INTO brt.driver_trip_history (pairing_id, trip_id)
    VALUES (NEW.pairing_id, NEW.id);

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS insert_new_trip_in_driver_trip_history_trigger 
ON brt.scheduled_trips;

CREATE TRIGGER insert_new_trip_in_driver_trip_history_trigger 
    AFTER INSERT 
    ON brt.scheduled_trips 
    FOR EACH ROW 
    EXECUTE FUNCTION brt.insert_new_trip_in_driver_trip_history();