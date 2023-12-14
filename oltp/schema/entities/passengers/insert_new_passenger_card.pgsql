-- This operation creates a payment card for a newly registered passenger
-- Creating a function to generate a random set of numbers
CREATE OR REPLACE FUNCTION brt.generate_random_numbers(min_value integer, max_value integer, count integer)
RETURNS SETOF integer 
LANGUAGE plpgsql
AS $$
DECLARE
    i integer := 1;
BEGIN
    WHILE i <= count LOOP
        RETURN NEXT ((min_value + floor(random() * (max_value - min_value + 1)))::integer)::text;
        i := i + 1;
    END LOOP;

    RETURN;
END;
$$

-- Creating a function to generate a random set of alphabets
CREATE OR REPLACE FUNCTION brt.generate_random_alphabets(length integer)
RETURNS text 
LANGUAGE plpgsql
AS $$
DECLARE
    random_string TEXT := '';
    i INTEGER := 1;
BEGIN
    WHILE i <= length LOOP
        random_string := random_string || CHR(65 + (RANDOM() * 26)::integer);
        i := i + 1;
    END LOOP;

    RETURN random_string;
END;
$$

-- Creating a function that incorporates the previous functions (generate_random_numbers and generate_random_alphabets)
CREATE OR REPLACE FUNCTION brt.generate_random_character()
RETURNS varchar(10)
LANGUAGE plpgsql
AS $$
DECLARE 
    rand_num varchar(6);
    rand_alpha varchar(4);
    rand_char varchar(10);
BEGIN
	SELECT brt.generate_random_alphabets(4) INTO rand_alpha;

    SELECT brt.generate_random_numbers(100000, 999999, 1) INTO rand_num;

    rand_char := rand_alpha || rand_num;

    RAISE NOTICE '%', rand_char;

    RETURN rand_char;
END;
$$

-- Creating a trigger function that inserts a new payment card for the corresponding inserted passenger phone number
CREATE OR REPLACE FUNCTION brt.insert_new_passenger_card()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE 
    card_num brt.passenger_payment_cards.card_number%type;
    card_bal brt.passenger_payment_cards.card_balance%type;
BEGIN
    SELECT brt.generate_random_character() INTO card_num; -- Generating a set of 10 random characters for the new card

    card_bal := 2000.00; -- Setting an initial balance for the new

    INSERT INTO brt.passenger_payment_cards (card_number, card_balance, phone_id)
    VALUES (card_num, card_bal, NEW.id);

    RETURN NEW;
END;
$$

-- Creating a trigger to be fired after inserts on the brt.passenger_phone_number table
DROP TRIGGER IF EXISTS insert_new_passenger_card_trigger 
ON brt.passenger_phone_number;

CREATE TRIGGER insert_new_passenger_card_trigger
	AFTER INSERT
	ON brt.passenger_phone_number
	FOR EACH ROW
	EXECUTE FUNCTION brt.insert_new_passenger_card();
