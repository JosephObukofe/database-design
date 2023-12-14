-- Driver's Identification Card View

CREATE VIEW vw_get_driver_identification_cards AS
SELECT 
    card_no,
    issue_date
FROM brt.driver_identification_cards;