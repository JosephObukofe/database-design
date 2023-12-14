/*

-- View -> Driver Payment Cards View
-- Function -> Viewing Payment Cards

CREATE VIEW brt.vw_get_driver_payment_cards AS
SELECT 
    p.card_number,
    p.card_balance,
    p.tip_balance,
    n.driver_id
FROM brt.driver_phone_number n
INNER JOIN brt.driver_payment_cards p
    ON n.id = p.phone_id;

*/

CREATE OR REPLACE FUNCTION brt.get_driver_payment_cards (
    driver brt.driver_details.id%type
) 
RETURNS TABLE(
    card_number char(10),
    card_balance decimal(8, 2),
    tip_balance decimal(7, 2)
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

    -- Content validation to ascertain the existence of a driver
    IF NOT EXISTS (SELECT 1 FROM brt.driver_details WHERE id = driver) THEN 
        RAISE EXCEPTION 'The provided driver does not exist'
            USING HINT = 'Ensure a valid driver ID is provided';
    END IF;

    query := (
        'SELECT 
            card_number,
            card_balance,
            tip_balance
        FROM brt.vw_get_driver_payment_cards 
        WHERE driver_id = $1;'
    );

    RETURN QUERY EXECUTE query USING driver;
END;
$$

-- Executing the payment card viewing function

SELECT * FROM brt.get_driver_payment_cards (
    driver := [ ]
);
