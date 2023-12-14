CREATE OR REPLACE PROCEDURE brt.delete_driver_details(
    driver_id brt.driver_details.id%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN
    query := (
        'DELETE FROM brt.driver_details
        WHERE id = $1;'
    );

    IF EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver_id) THEN 
        EXECUTE query USING driver_id;
        COMMIT;
        RAISE NOTICE 'Driver with ID: % deleted successfully', driver_id;
    ELSE 
        RAISE NOTICE 'The driver with ID: % does not exist', driver_id;
    END IF;
END;
$$

-- Deleting a driver record using ID
CALL brt.delete_driver_details (
    driver_id := [ ]
)   