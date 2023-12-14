/*

-- View -> Passenger Tickets View
-- Function -> Viewiing Passenger Tickets

CREATE VIEW brt.vw_get_passenger_tickets AS
SELECT 
    p.first_name,
    p.last_name,
	t.ticket_number,
    s.dep_terminal,
    s.arr_terminal,
    s.sch_dep_time,
    s.est_arr_time,
    b.booking_time,
    b.amount_paid,
    b.passenger_id
FROM brt.passenger_booked_trips b
INNER JOIN brt.scheduled_trips s
    ON b.trip_id = s.id 
INNER JOIN brt.tickets t
    ON b.id = t.booking_id
INNER JOIN brt.passenger_details p 
    ON b.passenger_id = p.id
ORDER BY booking_time ASC;

*/

CREATE OR REPLACE FUNCTION brt.get_passenger_tickets (
    passenger brt.passenger_details.id%type
)
RETURNS TABLE (
    passenger_first_name varchar(20),
    passenger_last_name varchar(20),
    ticket_number char(5),
    departure_terminal varchar(20),
    arrival_terminal varchar(20),
    departure_time timestamp,
    arrival_time timestamp,
    booking_time timestamp,
    amount_paid decimal(6, 2)
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN
    -- Input validation for null checks
    IF passenger IS NULL THEN 
        RAISE EXCEPTION 'The passenger parameter must not be null';
    END IF;

    -- Input validation for data type checks
    IF NOT (
        pg_typeof(passenger) = 'integer'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain the existence of the passenger
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_details WHERE id = passenger) THEN 
        RAISE EXCEPTION 'The provided passenger does not exist'
            USING HINT = 'Ensure a valid passenger ID is provided';
    END IF;

    query := (
        'SELECT 
            first_name, 
            last_name,
            ticket_number,
            dep_terminal,
            arr_terminal,
            sch_dep_time,
            est_arr_time,
            booking_time,
            amount_paid
        FROM brt.vw_get_passenger_tickets
        WHERE passenger_id = $1;'
    );

    RETURN QUERY EXECUTE query USING passenger;
END;
$$

-- Executing passenger tickets view function

SELECT * FROM brt.get_passenger_tickets (
    passenger := [ ]
);