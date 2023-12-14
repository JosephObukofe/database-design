-- Creating a trigger function that inserts a ticket for the corresponding inserted booked trips for passengers
-- INSERT in (brt.passenger_booked_trips) -> INSERT in (brt.tickets)

CREATE OR REPLACE FUNCTION brt.generate_ticket()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
DECLARE 
    ticket_num brt.tickets.ticket_number%type;
BEGIN 
    ticket_num := upper(substr(md5(random()::text), 1, 5));
    
    INSERT INTO brt.tickets (ticket_number, booking_id)
    VALUES (ticket_num, NEW.id);

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS generate_ticket_trigger 
ON brt.passenger_booked_trips;

CREATE TRIGGER generate_ticket_trigger
    BEFORE INSERT 
    ON brt.passenger_booked_trips 
    FOR EACH ROW
    EXECUTE FUNCTION brt.generate_ticket();