CREATE OR REPLACE FUNCTION brt.generate_trip_fare()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.trip_fare := NEW.subtotal + NEW.booking_fee;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS generate_trip_fare_trigger
ON brt.scheduled_trips;

CREATE TRIGGER generate_trip_fare_trigger
    BEFORE INSERT
    ON brt.scheduled_trips
    FOR EACH ROW
    EXECUTE FUNCTION brt.generate_trip_fare();