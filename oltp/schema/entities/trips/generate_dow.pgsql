-- Creating a trigger function that generates a day of the week (dow) field for every newly inserted trip record
-- INSERT in (brt.scheduled_trips) -> UPDATE on (brt.scheduled_trips)

CREATE OR REPLACE FUNCTION brt.generate_dow()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.dow := to_char(NEW.sch_dep_time, 'Day');

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS update_trip_fare_trigger
ON brt.scheduled_trips;

CREATE TRIGGER update_trip_fare_trigger
    BEFORE INSERT
    ON brt.scheduled_trips
    FOR EACH ROW
    EXECUTE FUNCTION brt.update_trip_fare();