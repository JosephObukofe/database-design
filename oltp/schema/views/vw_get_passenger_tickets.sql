-- Passenger Booking Ticket View

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