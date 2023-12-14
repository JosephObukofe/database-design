-- Passenger Booked Trips View

CREATE VIEW brt.vw_get_passenger_booked_trips AS 
SELECT 
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
ORDER BY s.sch_dep_time DESC;