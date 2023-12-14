-- Creating a trigger function that inserts a new payment card for the corresponding inserted driver phone number
-- INSERT in (brt.driver_phone_number) -> INSERT in (brt.driver_payment_cards)

CREATE OR REPLACE FUNCTION brt.insert_new_driver_card()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE 
	card_num brt.driver_payment_cards.card_number%type;
	card_bal brt.driver_payment_cards.card_balance%type;
    tip_bal brt.driver_payment_cards.tip_balance%type;
BEGIN
    SELECT brt.generate_random_character() INTO card_num; -- Generating a set of 10 random characters for the new card

    card_bal := 0.00; -- Setting an initial balance for the new card

    tip_bal := 0.00; -- Setting a defualt tip balance

    INSERT INTO brt.driver_payment_cards (card_number, card_balance, tip_balance, phone_id)
    VALUES (card_num, card_bal, tip_bal, NEW.id);
    RAISE NOTICE 'Driver payment card % successfully inserted', card_num;

    RETURN NEW;
END;
$$

DROP TRIGGER IF EXISTS insert_new_driver_card_trigger 
ON brt.driver_phone_number;

CREATE TRIGGER insert_new_driver_card_trigger
	AFTER INSERT
	ON brt.driver_phone_number
	FOR EACH ROW
	EXECUTE FUNCTION brt.insert_new_driver_card();