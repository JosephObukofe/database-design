/*

- Create or replace a PostgreSQL trigger to drop records from the (trip_completion_log) table.
- This serves as a clean-up operation which is performed after a booked trip has been completed, thus preventing the log table from being overloaded with unnecessary records.

*/

-- Define a PostgreSQL function to clean up the trip_completion_log
CREATE OR REPLACE FUNCTION brt.clean_up_trip_completion_log()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
BEGIN
    -- Delete records from trip_completion_log where completed_trip matches the OLD trip_id
    DELETE FROM brt.trip_completion_log 
    WHERE completed_trip = OLD.trip_id;

    -- Return the NEW row
    RETURN NEW;
END;
$$

-- Drop the trigger if it already exists
DROP TRIGGER IF EXISTS clean_up_trip_completion_log_trigger 
ON brt.passenger_booked_trips;

-- Create a trigger that executes the clean_up_trip_completion_log function after a DELETE in passenger_booked_trips
CREATE TRIGGER clean_up_trip_completion_log_trigger
    AFTER DELETE 
    ON brt.passenger_booked_trips 
    FOR EACH ROW
    EXECUTE FUNCTION brt.clean_up_trip_completion_log();