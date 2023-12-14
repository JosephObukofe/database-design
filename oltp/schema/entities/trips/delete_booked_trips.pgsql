
-- INSERT in (brt.trip_completion_log) -> DELETE from (brt.passenger_booked_trips)

CREATE OR REPLACE FUNCTION brt.delete_booked_trips()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
BEGIN 
    DELETE FROM brt.passenger_booked_trips 
    WHERE trip_id = NEW.completed_trip;

    RETURN NEW;
END;
$$

DROP TRIGGER IF EXISTS delete_booked_trips_trigger 
ON brt.trip_completion_log;

CREATE TRIGGER delete_booked_trips_trigger
    AFTER INSERT 
    ON brt.trip_completion_log
    FOR EACH ROW
    EXECUTE FUNCTION brt.delete_booked_trips();
