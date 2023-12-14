/*

-- View -> Driver Personal Details View
-- Function -> Viewing Driver Personal Details

CREATE VIEW brt.vw_driver_personal_details AS
SELECT 
    d.id,
    d.first_name,
    d.last_name,
    d.gender,
    d.date_of_birth,
    e.email_address,
    n.phone_number,
    t.name
FROM brt.driver_details d
INNER JOIN brt.terminals t
    ON d.terminal_id = t.id 
INNER JOIN brt.driver_email_address e 
    ON d.id = e.driver_id 
INNER JOIN brt.driver_phone_number n 
    ON d.id = n.driver_id;
    
*/

CREATE OR REPLACE FUNCTION brt.get_driver_personal_details(
    driver brt.driver_details.id%type
)
RETURNS TABLE(
    first_name varchar(20),
    last_name varchar(20),
    gender varchar(6),
    date_of_birth date,
    email_address varchar(50),
    phone_number varchar(12),
    terminal varchar(20)
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF driver IS NULL THEN 
        RAISE EXCEPTION 'The driver parameter must not be null';
    END IF;

    -- Input validation for data type checks
    IF NOT (
        pg_typeof(driver) = 'integer'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain the existence of the driver
    IF NOT EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver) THEN 
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a valid driver ID is provided';
    END IF;

    query := (
        'SELECT 
            first_name,
            last_name,
            gender,
            date_of_birth,
            email_address,
            phone_number,
            name
        FROM brt.vw_driver_personal_details
        WHERE id = $1;'
    );

    RETURN QUERY EXECUTE query USING driver;
END;
$$

-- Executing driver personal details viewing function

SELECT * FROM brt.get_driver_personal_details(
    driver := [ ]
);