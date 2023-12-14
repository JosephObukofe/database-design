-- Driver's Assigned Trip View

CREATE VIEW brt.vw_get_assigned_trips AS
SELECT 
    s.dep_terminal,
    s.arr_terminal,
    s.sch_dep_time,
    s.est_arr_time,
    s.dow,
    s.trip_fare,
    s.current_trip_cap,
    p.driver_id
FROM brt.scheduled_trips s 
INNER JOIN brt.driver_vehicle_pairings p 
    ON s.pairing_id = p.id
ORDER BY sch_dep_time ASC;