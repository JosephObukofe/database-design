-- Define a PL/pgSQL stored procedure to update trip availability status based on expiration
CREATE OR REPLACE PROCEDURE brt.update_trip_availability_status_by_expiration()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Update trip availability status
    UPDATE brt.scheduled_trips
    SET trip_status = (
        CASE
            -- Check if the time elapsed from current time to dep_time (departure time) is less than or equal to 300 seconds (5 minutes)
            WHEN (extract(EPOCH FROM sch_dep_time -  now()) <= 300) THEN 'Expired' ELSE 'Ongoing'
        END
    )
    WHERE trip_comp_status = 'None';

    -- Commit the transaction
    COMMIT;
END;
$$;

-- Define an anonymous code block to set up the pgAgent job, step, and schedule
DO $$
DECLARE
    jid integer;
    scid integer;
BEGIN
    -- Creating a new job
    INSERT INTO pgagent.pga_job (
        jobjclid, 
        jobname, 
        jobdesc, 
        jobhostagent, 
        jobenabled
    ) VALUES (
        1::integer, 
        'update_trip_availability_status'::text, 
        'This job updates the availability status for "yet to be booked" trips in the scheduled trips table. It sets the status to "Expired" if the current time has encroached into or passed the booking duration time and "Ongoing" if not.  '::text, 
        ''::text, 
        true
    ) RETURNING jobid INTO jid;

    -- Steps
    -- Inserting a step (jobid: NULL)
    INSERT INTO pgagent.pga_jobstep (
        jstjobid, 
        jstname, 
        jstenabled, 
        jstkind,
        jstconnstr, 
        jstdbname, 
        jstonerror,
        jstcode, 
        jstdesc
    ) VALUES (
        jid, 
        'InitialStep'::text, 
        true, 's'::character(1),
        ''::text, 
        'brt'::name, 
        'f'::character(1),
        'CALL brt.update_trip_availability_status_by_expiration()'::text, 
        'This is an update job to be executed every minute'::text
    );

    -- Schedules
    -- Inserting a schedule
    INSERT INTO pgagent.pga_schedule (
        jscjobid, 
        jscname, 
        jscdesc, 
        jscenabled,
        jscstart,     
        jscminutes, 
        jschours, 
        jscweekdays, 
        jscmonthdays, 
        jscmonths
    ) 
    VALUES (
        jid, 
        'UpdateJobScheduler'::text, 
        'This is an update job to modify fields through the scheduler'::text, 
        true,
        '2023-08-06 15:06:00 +01:00'::timestamp with time zone, 
        -- Minutes
        '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[],
        -- Hours
        '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[],
        -- Week days
        '{t,t,t,t,t,t,t}'::bool[]::boolean[],
        -- Month days
        '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[],
        -- Months
        '{t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[]
    ) RETURNING jscid INTO scid;
END
$$;
