-- Driver's Payment Card View

CREATE VIEW brt.vw_get_driver_payment_cards AS
SELECT 
    p.card_number,
    p.card_balance,
    p.tip_balance,
    n.driver_id
FROM brt.driver_phone_number n
INNER JOIN brt.driver_payment_cards p
    ON n.id = p.phone_id;