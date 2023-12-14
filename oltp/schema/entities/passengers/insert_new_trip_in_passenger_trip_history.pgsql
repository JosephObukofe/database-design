-- Creating a trigger function that inserts a record into the passenger's trip history for the corresponding inserted records for booked trips
-- INSERT in (brt.passenger_booked_trips) -> INSERT in (brt.passenger_trip_history)

CREATE OR REPLACE FUNCTION brt.insert_new_trip_in_passenger_history()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
BEGIN 
    INSERT INTO brt.passenger_trip_history (passenger_id, trip_id, booking_id)
    VALUES (NEW.passenger_id, NEW.trip_id, NEW.id);

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS insert_new_trip_in_passenger_history_trigger
ON brt.passenger_booked_trips;

CREATE TRIGGER insert_new_trip_in_passenger_history_trigger
    AFTER INSERT 
    ON brt.passenger_booked_trips 
    FOR EACH ROW
    EXECUTE FUNCTION brt.insert_new_trip_in_passenger_history()