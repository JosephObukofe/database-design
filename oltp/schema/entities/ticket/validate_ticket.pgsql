/*

- Create or replace a PostgreSQL stored procedure to validate a specified ticket.
- This procedure performs a dual operation of updating the validation status of the booked trip after the ticket has been validated and incrementing the sitting trip capacity of the assigned trip (for the driver)

*/
CREATE OR REPLACE PROCEDURE brt.validate_ticket (
    trip_booking_id brt.passenger_booked_trips.id%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    ticket_num brt.tickets.ticket_number%type;
    t_id brt.driver_trip_history.trip_id;
    query1 text;
    query2 text;
    trip_cap brt.driver_trip_history.trip_capacity;
BEGIN 
    -- Input validation to check for tickets existence
    IF NOT EXISTS (SELECT 1 FROM brt.tickets WHERE booking_id = trip_booking_id) THEN 
        RAISE EXCEPTION 'The provided ticket to be validated does not exist'
            USING HINT = 'Ensure a valid booking ID is provided';
    END IF;

    -- Construct a dynamic SQL query to modify the validation status for booked trips (passengers)
    query1 := (
        'UPDATE brt.passenger_trip_history 
        SET val_stat = TRUE
        WHERE booking_id = $1;'
    );

    -- Construct a SQL query to store the ticket number in (ticket_num)
    SELECT ticket_number 
    INTO ticket_num
    FROM brt.tickets
    WHERE booking_id = trip_booking_id;

    -- Execute the SQL query using the provided parameter(s)
    EXECUTE query1 USING trip_booking_id;
    RAISE NOTICE 'Ticket % has been validated successfully', ticket_num;

    -- Construct a SQL query to store the trip id in (t_id)
    SELECT trip_id 
    INTO t_id
    FROM brt.passenger_booked_trips b
    INNER JOIN brt.tickets t
        ON b.id = t.booking_id 
    WHERE booking_id = trip_booking_id;

    -- Construct a dynamic SQL query to increment the trip capacity for assigned trips (drivers)
    query2 := (
        'UPDATE brt.driver_trip_history
        SET trip_capacity = trip_capacity + 1
        WHERE trip_id = $1';
    );

    -- Execute the SQL query using the provided parameter(s)
    EXECUTE query2 USING t_id;

    -- Construct a SQL query to store the current sitting capacity in (trip_cap)
    SELECT trip_capacity
    INTO trip_cap
    FROM brt.driver_trip_history 
    WHERE trip_id = t_id;

    -- Notify successful update
    RAISE NOTICE 'The current sitting capacity is %', trip_cap;
END;
$$

-- Begin a database transaction
BEGIN;

-- Call the validate_ticket procedure
CALL brt.validate_ticket (
    trip_booking_id := [ ]
);

-- Commit the transaction
COMMIT;