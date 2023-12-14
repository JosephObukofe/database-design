-- 

CREATE OR REPLACE PROCEDURE brt.trip_payments(
    card_id brt.passenger_payment_cards.id%type,
    tip decimal(6, 2),
    scheduled_trip_id brt.scheduled_trips.id%type
)
LANGUAGE plpgsql
AS $$
DECLARE
    passenger_card_bal brt.passenger_payment_cards.card_balance%type;
    driver_card_bal brt.driver_payment_cards.card_balance%type;
    driver_tip_bal brt.driver_payment_cards.tip_balance%type;
    fare brt.scheduled_trips.trip_fare%type;
    tipping_amount decimal(6, 2);
BEGIN
    -- Input validation for null checks
    IF fname IS NULL OR lname IS NULL OR gen IS NULL OR dob IS NULL THEN
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for data type checks
    IF NOT (
        pg_typeof(fname) = 'varchar'::regtype AND
        pg_typeof(lname) = 'varchar'::regtype AND
        pg_typeof(gen) = 'varchar'::regtype AND
        pg_typeof(dob) = 'date'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Content validation to ascertain the existence of the passenger card
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_payment_cards WHERE id = card_id) THEN
        RAISE EXCEPTION ''
            USING HINT = '';
    END IF;

    -- Content validation to ascertain the existence of the scheduled trip
    IF NOT EXISTS (SELECT 1 FROM brt.scheduled_trips WHERE id = scheduled_trip_id) THEN
        RAISE EXCEPTION ''
            USING HINT = '';
    END IF;

    -- Getting the passenger's card balance 
    SELECT card_balance 
    INTO passenger_card_bal
    FROM brt.passenger_payment_cards
    WHERE id = card_id;

    -- Create a CTE to get the driver's pairing details based on the scheduled trip info
    WITH CTE AS (
        SELECT
            c.card_balance,
            c.tip_balance
        FROM brt.scheduled_trips t
        INNER JOIN brt.driver_vehicle_pairings p
            ON t.pairing_id = p.id 
        INNER JOIN brt.driver_details d 
            ON p.driver_id = d.id
        INNER JOIN brt.driver_phone_number n 
            ON d.id = n.driver_id
        INNER JOIN brt.driver_payment_cards c 
            ON n.id = c.phone_id
        WHERE t.id = scheduled_trip_id
    )

    SELECT card_balance, tip_balance
    INTO driver_card_bal, driver_tip_bal
    FROM CTE;

    -- Getting the trip amount
    SELECT trip_fare
    INTO fare
    FROM brt.scheduled_trips
    WHERE id = scheduled_trip_id;

    -- Getting the tipping amount
    IF tip IS NULL THEN
        tipping_amount := 0;
    ELSIF tip IN (50, 100, 200, 500, 1000) THEN
        tipping_amount := tip;
    ELSE
        RAISE EXCEPTION 'Invalid tipping amount'
            USING HINT = 'Choose between the predefined tipping amounts';
    END IF;

    -- The payment process
    UPDATE brt.passenger_payment_cards
    SET card_balance = passenger_card_bal - (fare + tipping_amount)
    WHERE id = card_id;
    
    UPDATE brt.driver_payment_cards
    SET 
        card_balance = driver_card_bal + fare,
        tip_balance = driver_tip_bal + tipping_amount
    WHERE phone_id = (
        SELECT phone_id 
        FROM brt.driver_phone_number 
        WHERE driver_id = (
            SELECT driver_id 
            FROM brt.driver_vehicle_pairings 
            WHERE id = scheduled_trip_id
        )
    );

    RAISE NOTICE 'Payment successful';

END;
$$