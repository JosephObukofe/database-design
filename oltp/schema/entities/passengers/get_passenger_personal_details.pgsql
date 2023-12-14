/*

- View -> Passenger Personal Details View
- Function -> Viewing Passenger Personal Details

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
*/

CREATE OR REPLACE FUNCTION brt.get_passenger_personal_details(
    passenger brt.passenger_details.id%type
)
RETURNS TABLE(
    first_name varchar(20),
    last_name varchar(20),
    gender varchar(6),
    date_of_birth date,
    email_address varchar(50),
    phone_number varchar(12)
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
			first_name,
			last_name,
			gender,
			date_of_birth,
			email_address,
			phone_number
        FROM brt.vw_passenger_personal_details 
        WHERE id = $1;'
    );

    RETURN QUERY EXECUTE query USING passenger;
END;
$$

-- Executing the passenger personal details viewing function

SELECT * FROM brt.get_passenger_personal_details(
    passenger := [ ]
);



