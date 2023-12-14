/*

-- View -> Driver Identification Card View 
-- Function -> Viewing Driver Identification Card

CREATE VIEW brt.vw_get_driver_identification_cards AS
SELECT 
    card_no,
    issue_date,
    driver_id
FROM brt.driver_identification_cards;

*/

CREATE OR REPLACE FUNCTION brt.get_driver_identification_cards (
    driver brt.driver_details.id%type
)
RETURNS TABLE (
    card_number char(5),
    card_issue_date date
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
            card_no, 
            issue_date
        FROM brt.vw_get_driver_identification_cards
        WHERE driver_id = $1;'
    );

    RETURN QUERY EXECUTE query USING driver;
END;
$$

-- Executing the driver identification card viewing function

SELECT * FROM brt.get_driver_identification_cards (
    driver := [ ]
);