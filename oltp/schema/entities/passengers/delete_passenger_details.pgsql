CREATE OR REPLACE PROCEDURE brt.delete_passenger_details(
    pass_id brt.passenger_details.id%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN
    query := (
        'DELETE FROM brt.passenger_details
        WHERE id = $1;'
    );
    
	IF EXISTS (SELECT 1 FROM brt.passenger_details WHERE id = pass_id) THEN 
		EXECUTE query USING pass_id;
		COMMIT;
		RAISE NOTICE 'Passenger with ID: % deleted successfully', pass_id;
	ELSE 
		RAISE NOTICE 'The passenger with ID: % does not exist', pass_id;
	END IF;
END;
$$

CALL brt.delete_passenger_details(
    pass_id := [ ]
);