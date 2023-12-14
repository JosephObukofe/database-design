-- This procedure inserts a new record into the vehicle table

CREATE OR REPLACE PROCEDURE brt.insert_new_vehicle(
    vehicle_identification_num brt.vehicle.vin%type,
    vehicle_plate_number brt.vehicle.plate_number%type,
    vehicle_model brt.vehicle.model%type,
    vehicle_capacity brt.vehicle.capacity%type,
    vehicle_status brt.vehicle.status%type,
    terminal brt.vehicle.terminal_id%type
)
LANGUAGE plpgsql
AS $$
DECLARE 
    query text;
BEGIN
    -- Input validation for null checks
    IF vehicle_identification_num IS NULL OR vehicle_plate_number IS NULL OR vehicle_model IS NULL OR vehicle_capacity IS NULL OR vehicle_status IS NULL OR terminal IS NULL THEN 
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(vehicle_identification_num) = 'varchar'::regtype AND
        pg_typeof(vehicle_plate_number) = 'varchar'::regtype AND
        pg_typeof(vehicle_model) = 'varchar'::regtype AND
        pg_typeof(vehicle_capacity) = 'integer'::regtype AND
        pg_typeof(vehicle_status) = 'varchar'::regtype AND
        pg_typeof(terminal) = 'integer'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Format validation to confirm the VIN length of 17 characters
    IF LENGTH(vehicle_identification_num) != 17 THEN
        RAISE EXCEPTION 'Invalid VIN length. VIN must be 17 characters';
    END IF;

    -- Format validation to confirm the plate number length of 10 characters
    IF LENGTH(vehicle_plate_number) > 10 THEN
        RAISE EXCEPTION 'Invalid plate number length. It cannot exceed 10 characters';
    END IF;

    -- Content validation for valid status
    IF NOT (vehicle_status IN ('Available', 'In Use', 'Under Maintenance', 'Decommissioned')) THEN
        RAISE EXCEPTION 'Invalid vehicle status. It must be one of the allowed values (Available, In Use, Under Maintenance, Decommissioned)';
    END IF;

    -- Content validation for terminal existence
    IF NOT EXISTS (SELECT 1 FROM brt.terminals WHERE id = terminal) THEN 
        RAISE NOTICE 'The provided terminal does not exist'
            USING HINT = 'Ensure a parent record exists for the provided terminal ID';
    END IF;

    query := (
        'INSERT INTO brt.vehicle (vin, plate_number, model, capacity, status, terminal_id)
        VALUES ($1, $2, $3, $4, $5, $6);'
    );

    EXECUTE query USING vehicle_identification_num, vehicle_plate_number, vehicle_model, vehicle_capacity, vehicle_status, terminal;
    RAISE NOTICE 'A % with plate number % and a VIN of % with a seating capacity of % passengers has been successfully inserted', vehicle_model, vehicle_plate_number, vehicle_identification_num, vehicle_capacity;
END;
$$

-- Executing the vehicle insert procedure

CALL brt.insert_new_vehicle (
    vehicle_identification_num := [ ],
    vehicle_plate_number := [ ],
    vehicle_model := [ ], 
    vehicle_capacity := [ ], 
    vehicle_status := [ ], 
    terminal := [ ] 
);

