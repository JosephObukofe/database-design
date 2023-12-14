-- Driver's Completed Trips View

CREATE VIEW brt.vw_get_driver_completed_trips AS
WITH CTE AS (
    SELECT 
        p.id,
        p.driver_id,
        v.plate_number,
        v.model
    FROM brt.vehicle v 
    INNER JOIN brt.driver_vehicle_pairings p 
        ON v.id = p.vehicle_id
)

SELECT 
    s.dep_terminal,
    s.arr_terminal,
    h.dep_time,
    h.arr_time,
    h.trip_capacity,
    CTE.plate_number,
    CTE.model,
    CTE.driver_id
FROM brt.driver_trip_history h
INNER JOIN brt.scheduled_trips s 
    ON h.trip_id = s.id
INNER JOIN CTE  
    ON h.pairing_id = CTE.id
WHERE 
    h.trip_capacity > 0
ORDER BY h.id DESC;