-- Create or replace a PostgreSQL stored procedure for inserting/updating driver license images
CREATE OR REPLACE PROCEDURE brt.insert_new_driver_license_image (
    image brt.driver_license_images.image_data%type,
    d_id brt.driver_license_images.driver_id%type
)
LANGUAGE plpgsql
AS $$
DECLARE 
    query1 text;
    query2 text;
BEGIN 
    -- Check if a record with the same driver_id already exists
    IF EXISTS (SELECT 1 FROM brt.driver_license_images WHERE driver_id = d_id) THEN
        -- Update the existing record with the new image_data and uploaded_at timestamp
        query1 := (
            'UPDATE brt.driver_license_images
            SET
                image_data = $1,
                uploaded_at = now()
            WHERE driver_id = $2;'
        );

        EXECUTE query1 USING image, d_id;
        -- Notify that the image was updated
        RAISE NOTICE 'Driver license image updated successfully';
    ELSE
        -- Insert a new record if it doesn't exist
        query2 := (
            'INSERT INTO brt.driver_license_images (image_data, driver_id)
            VALUES ($1, $2);'
        );

        EXECUTE query2 USING image, d_id;
        -- Notify that a new image was inserted
        RAISE NOTICE 'Driver license image inserted successfully';
    END IF;
END;
$$

-- Call the 'insert_new_driver_license_image' stored procedure
CALL brt.insert_new_driver_license_image (
    image := [], -- Image data in hexadecimal representation eg. E'//*******
    d_id := []
);


