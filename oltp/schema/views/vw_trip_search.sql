-- Scheduled Trips View

CREATE VIEW brt.vw_trip_search AS 
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
    dep_terminal,
    arr_terminal,
    sch_dep_time,
    est_arr_time,
    dow, 
    trip_fare,
    trip_status,
    trip_comp_status,
    CTE.first_name,
    CTE.last_name,
    CTE.model,
    CTE.plate_number
FROM brt.scheduled_trips s 
INNER JOIN CTE 
    ON s.pairing_id = CTE.id;