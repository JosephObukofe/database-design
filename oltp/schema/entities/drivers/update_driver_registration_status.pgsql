-- Creating a trigger function that updates the registration status field of a driver after completing the user registration operation
-- INSERT in (brt.driver_nin) -> UPDATE on (brt.driver_details)

CREATE OR REPLACE FUNCTION brt.update_driver_registration_status()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
BEGIN 
    UPDATE brt.driver_details
    SET registration_status = TRUE 
    WHERE id = NEW.driver_id;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS update_driver_registration_status_trigger 
ON brt.driver_nin;

CREATE TRIGGER update_driver_registration_status_trigger 
    AFTER INSERT 
    ON brt.driver_nin 
    FOR EACH ROW 
    EXECUTE FUNCTION brt.update_driver_registration_status();