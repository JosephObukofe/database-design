-- Creating the pgcrypto extension into the brt schema
CREATE EXTENSION pgcrypto SCHEMA brt;

-- Loading the extension to the current database session
LOAD 'pgcrypto';

-- Creating a trigger function to insert new rows into the driver's ID table (incorporating the md5 function in the pgcrypto extension)
-- INSERT in (brt.driver_nin) -> INSERT in (brt.driver_identification_cards)

CREATE OR REPLACE FUNCTION brt.insert_driver_identification_card()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
DECLARE 
    card_num char(5);
    d_id integer;
BEGIN 
    card_num := upper(substr(md5(random()::text), 1, 5));

    d_id := NEW.driver_id;

    INSERT INTO brt.driver_identification_cards (card_no, driver_id)
    VALUES (card_num, d_id);
	RAISE NOTICE 'Payment card % for Driver with ID (%) has been successfully inserted', card_num, d_id;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS insert_driver_identification_card_trigger 
ON brt.driver_nin;

CREATE TRIGGER insert_driver_identification_card_trigger
    AFTER INSERT 
    ON brt.driver_nin 
    FOR EACH ROW 
    EXECUTE FUNCTION brt.insert_driver_identification_card();