/*

-- View -> Passenger Payment Cards View
-- Function -> Viewing Passenger Payment Cards

CREATE VIEW brt.vw_get_passenger_payment_cards AS 
SELECT 
    p.card_number,
    p.card_balance,
    n.passenger_id
FROM brt.passenger_phone_number n
INNER JOIN brt.passenger_payment_cards p
    ON n.id = p.phone_id;

*/

CREATE OR REPLACE FUNCTION brt.get_passenger_payment_cards (
    passenger brt.passenger_details.id%type
)
RETURNS TABLE (
    card_number char(10),
    card_balance decimal(7, 2)
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF passenger IS NULL THEN 
        RAISE EXCEPTION 'The passenger parameter must not be null';
    END IF;
    
    -- Input validation for data type checks
    IF NOT (
        pg_typeof(passenger) = 'integer'::regtype 
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain the existence of the passenger
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_details WHERE id = passenger) THEN 
        RAISE EXCEPTION 'The provided passenger does not exist'
            USING HINT = 'Ensure a valid passenger ID is provided';
    END IF;

    query := (
        'SELECT 
            card_number,
            card_balance
        FROM brt.vw_get_passenger_payment_cards
        WHERE passenger_id = $1;'
    );

    RETURN QUERY EXECUTE query USING passenger;
END;
$$

-- Executing the payment card viewing function

SELECT * FROM brt.get_passenger_payment_cards (
    passenger := [ ]
);