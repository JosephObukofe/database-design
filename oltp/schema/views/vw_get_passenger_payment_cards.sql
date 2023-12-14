-- Passenger Payment Cards View

CREATE VIEW brt.vw_get_passenger_payment_cards AS 
SELECT 
    p.card_number,
    p.card_balance,
    n.passenger_id
FROM brt.passenger_phone_number n
INNER JOIN brt.passenger_payment_cards p
    ON n.id = p.phone_id;