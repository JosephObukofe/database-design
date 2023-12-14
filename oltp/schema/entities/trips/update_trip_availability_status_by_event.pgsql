-- Creating a trigger function that increments the current sitting capacity and confirms its availability with the maximum sitting capacity
-- INSERT in (brt.passenger_booked_trips) -> UPDATE on (brt.scheduled_trips)

CREATE OR REPLACE FUNCTION brt.update_trip_availabilty_status_by_event()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    -- First modification to increment the current trip capacity
    UPDATE brt.scheduled_trips
    SET current_trip_cap = current_trip_cap + 1
    WHERE id = NEW.trip_id;

    -- Second modification to update the trip status based on the current trip capacity
    IF (SELECT current_trip_cap FROM brt.scheduled_trips WHERE id = NEW.trip_id) = (SELECT max_trip_cap FROM brt.scheduled_trips WHERE id = NEW.trip_id) THEN
        UPDATE brt.scheduled_trips
        SET trip_status = 'Maximum'
        WHERE id = NEW.trip_id;
    ELSE 
        UPDATE brt.scheduled_trips
        SET trip_status = 'Ongoing'
        WHERE id = NEW.trip_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS update_trip_availabilty_status_by_event_trigger
ON brt.passenger_booked_trips;

CREATE TRIGGER update_trip_availabilty_status_by_event_trigger
    BEFORE INSERT 
    ON brt.passenger_booked_trips
    FOR EACH ROW
    EXECUTE FUNCTION brt.update_trip_availabilty_status_by_event();


