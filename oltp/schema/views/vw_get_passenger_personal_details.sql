-- Passenger Personal Details View

CREATE VIEW brt.vw_passenger_personal_details AS
SELECT 
    p.id,
    p.first_name,
    p.last_name,
    p.gender,
    p.date_of_birth,
    e.email_address,
    n.phone_number
FROM brt.passenger_details p 
INNER JOIN brt.passenger_email_address e 
    ON p.id = e.passenger_id 
INNER JOIN brt.passenger_phone_number n 
    ON p.id = n.passenger_id;