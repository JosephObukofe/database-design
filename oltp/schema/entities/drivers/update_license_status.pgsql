CREATE OR REPLACE FUNCTION brt.update_license_status()
RETURNS TRIGGER
LANGUAGE plpgsql 
AS $$
BEGIN
    CASE 
        WHEN ((NEW.expiry_date - NEW.issue_date) < 5) THEN 
            NEW.license_status := 'Valid';
        ELSE 
            NEW.license_status := 'Expired';
    END CASE;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS update_license_status_trigger 
ON brt.driver_license;

CREATE TRIGGER update_license_status_trigger
    BEFORE INSERT 
    ON brt.driver_license
    FOR EACH ROW 
    EXECUTE FUNCTION brt.update_license_status();