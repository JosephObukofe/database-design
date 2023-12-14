-- This procedure modifies an existing record of a vehicle

CREATE OR REPLACE PROCEDURE brt.update_vehicle_info(
    vehicle_id brt.vehicle.id%type,
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
    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(vehicle_id) = 'integer'::regtype AND
        pg_typeof(vehicle_identification_num) = 'varchar'::regtype AND
        pg_typeof(vehicle_plate_number) = 'varchar'::regtype AND
        pg_typeof(vehicle_model) = 'varchar'::regtype AND
        pg_typeof(vehicle_capacity) = 'integer'::regtype AND
        pg_typeof(vehicle_status) = 'varchar'::regtype AND
        pg_typeof(terminal) = 'integer'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- Input validation for null checks (Vehicle ID)
    IF vehicle_id IS NULL THEN 
        RAISE EXCEPTION 'The vehicle ID field must be provided';
    END IF;

    -- Content validation to ascertain the existence of the provided vehicle
    IF NOT EXISTS (SELECT 1 FROM brt.vehicle WHERE id = vehicle_id) THEN 
        RAISE EXCEPTION 'The provided vehicle does not exist'
            USING HINT = 'Ensure a parent record exists for the provided vehicle ID';
    END IF;

    -- Conditional modification based on user entry
    -- Vehicle Identification Number (VIN) Modification
    IF vehicle_identification_num IS NOT NULL THEN 
        IF LENGTH(vehicle_identification_num) == 17 THEN
            IF vehicle_identification_num <> (SELECT vin FROM brt.vehicle WHERE id = vehicle_id) THEN 
                query := (
                    'UPDATE brt.vehicle 
                    SET vin = $1
                    WHERE id = $2;'
                );

                EXECUTE query USING vehicle_identification_num, vehicle_id;
                COMMIT;
                RAISE NOTICE 'Vehicle Identification Number (VIN) updated to: %', vehicle_identification_num;
            ELSE 
                RAISE NOTICE 'Field provided already matches the existing VIN: %', vehicle_identification_num;
            END IF;
        ELSE 
            RAISE EXCEPTION 'Invalid VIN length. VIN must be 17 characters';
        END IF;
    END IF;

    -- Vehicle Plate Number Modification
    IF vehicle_plate_number IS NOT NULL THEN 
        IF LENGTH(vehicle_plate_number) <= 10 THEN
            IF vehicle_plate_number <> (SELECT plate_number FROM brt.vehicle WHERE id = vehicle_id) THEN 
                query := (
                    'UPDATE brt.vehicle
                    SET plate_number = $1 
                    WHERE id = $2;'
                );

                EXECUTE query USING vehicle_plate_number, vehicle_id;
                COMMIT;
                RAISE NOTICE 'Vehicle plate number successfully updated to: %', vehicle_plate_number;
            ELSE 
                RAISE NOTICE 'Field provided already matches the existing vehicle plate number: %', vehicle_plate_number;
            END IF;
        ELSE    
            RAISE EXCEPTION 'Invalid plate number length. It cannot exceed 10 characters';
        END IF;
    END IF;

    -- Vehicle Model Modification
    IF vehicle_model IS NOT NULL THEN 
        IF vehicle_model <> (SELECT model FROM brt.vehicle WHERE id = vehicle_id) THEN 
            query := (
                'UPDATE brt.vehicle
                SET model = $1 
                WHERE id = $2;'
            );

            EXECUTE query USING vehicle_model, vehicle_id;
            COMMIT;
            RAISE NOTICE 'Vehicle model successfully updated to: %', vehicle_model;
        ELSE 
            RAISE NOTICE 'Field provided already matches the existing vehicle model: %', vehicle_model;
        END IF;
    END IF;

    -- Vehicle Capacity Modification
    IF vehicle_capacity IS NOT NULL THEN 
        IF vehicle_capacity <> (SELECT capacity FROM brt.vehicle WHERE id = vehicle_id) THEN 
            query := (
                'UPDATE brt.vehicle 
                SET capacity = $1
                WHERE id = $2;'
            );

            EXECUTE query USING vehicle_capacity, vehicle_id;
            COMMIT;
            RAISE NOTICE 'Vehicle capacity successfully updated to: %', vehicle_capacity;
        ELSE 
            RAISE NOTICE 'Field provided already matches the existing vehicle capacity: %', vehicle_capacity;
        END IF;
    END IF;

    -- Vehicle Status Modification
    IF vehicle_status IS NOT NULL THEN 
        IF vehicle_status IN ('Available', 'In Use', 'Under Maintenance', 'Decommissioned') THEN
            IF vehicle_status <> (SELECT status FROM brt.vehicle WHERE id = vehicle_id) THEN 
                query := (
                    'UPDATE brt.vehicle 
                    SET status = $1
                    WHERE id = $2;'
                );

                EXECUTE query USING vehicle_status, vehicle_id;
                COMMIT;
                RAISE NOTICE 'Vehicle availability status successfully updated to: %', vehicle_status;
            ELSE 
                RAISE NOTICE 'Field provided already matches the existing vehicle status: %', vehicle_status;
            END IF;
        ELSE 
            RAISE EXCEPTION 'Invalid vehicle status. It must be one of the allowed values (Available, In Use, Under Maintenance, Decommissioned)';
        END IF;
    END IF;

    -- Terminal Modification
    IF terminal IS NOT NULL THEN 
        IF terminal IN (SELECT id FROM brt.terminals) THEN
            IF terminal <> (SELECT terminal_id FROM brt.vehicle WHERE id = vehicle_id) THEN 
                query := (
                    'UPDATE brt.vehicle 
                    SET terminal_id = $1
                    WHERE id = $2;'
                );

                EXECUTE query USING terminal, vehicle_id;
                COMMIT;
                RAISE NOTICE 'Vehicle Terminal ID successfully updated to: %', terminal;
            ELSE 
                RAISE NOTICE 'Field provided already matches the existing vehicle terminal ID: %', terminal;
            END IF;
        ELSE 
            RAISE EXCEPTION 'Invalid terminal value. Ensure a valid terminal ID is provided';
        END IF;
    END IF;
END;
$$

-- Executing the vehicle modification procedure

CALL brt.update_vehicle_info(
    vehicle_id := [ ],
    vehicle_identification_num := NULL,
    vehicle_plate_number := NULL, 
    vehicle_model := NULL, 
    vehicle_capacity := NULL,
    vehicle_status := NULL,
	terminal := NULL 
);
