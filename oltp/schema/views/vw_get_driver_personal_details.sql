-- Driver's Personal Details View

CREATE VIEW brt.vw_driver_personal_details AS
SELECT 
    d.id,
    d.first_name,
    d.last_name,
    d.gender,
    d.date_of_birth,
    e.email_address,
    n.phone_number,
    t.name
FROM brt.driver_details d
INNER JOIN brt.terminals t
    ON d.terminal_id = t.id 
INNER JOIN brt.driver_email_address e 
    ON d.id = e.driver_id 
INNER JOIN brt.driver_phone_number n 
    ON d.id = n.driver_id;