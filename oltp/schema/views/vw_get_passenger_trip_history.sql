-- Passenger Trip History View

CREATE VIEW brt.vw_get_passenger_trip_history AS
WITH CTE AS (
    SELECT  
        p.id, 
        d.first_name,
        d.last_name,
        v.model, 
        v.plate_number
    FROM brt.driver_vehicle_pairings p 
    INNER JOIN brt.driver_details d 
        ON p.driver_id = d.id 
    INNER JOIN brt.vehicle v 
        ON p.vehicle_id = v.id 
)

SELECT 
    s.dep_terminal,
    s.arr_terminal,
    p.dep_time,
    p.arr_time,
    p.passenger_id,
    CTE.first_name,
    CTE.last_name,
    CTE.model,
    CTE.plate_number
FROM brt.scheduled_trips s
INNER JOIN CTE 
    ON s.pairing_id = CTE.id
INNER JOIN brt.passenger_trip_history p 
    ON s.id = p.trip_id
ORDER BY p.dep_time DESC;