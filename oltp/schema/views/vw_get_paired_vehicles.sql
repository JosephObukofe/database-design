-- Driver-Vehicle Pairing View

CREATE VIEW brt.vw_get_paired_vehicles AS
WITH CTE AS (
    SELECT 
        v.id,
        v.vin,
        v.plate_number,
        v.model,
        v.capacity,
        t.name
    FROM brt.vehicle v 
    INNER JOIN brt.terminals t
        ON v.terminal_id = t.id
)

SELECT 
    CTE.vin,
    CTE.plate_number,
    CTE.model,
    CTE.capacity,
    CTE.name,
    p.pair_date,
    p.driver_id
FROM CTE 
INNER JOIN brt.driver_vehicle_pairings p 
    ON CTE.id = p.vehicle_id 
ORDER BY pair_date DESC;