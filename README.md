# Lagos BRT System Database Design 🚍👨🏽‍💻

This project focuses on creating an efficient and robust database structure for managing the bus rapid transit system in Lagos, Nigeria.

## Table of Contents
- [Introduction](#introduction)
- [Overview](#overview)
- [Key Features](#key-features)
- [Schema Definition](#schema-definition)
- [Database Extensions](#database-extensions)
- [Entity-Relationship Model Diagram](#entity-relationship-model-diagram)
- [Query Optimization](#query-optimization)
- [Database Automation](#database-automation)
- [Security](#security)
- [Getting Started](#getting-started)
- [Contributing](#contributing)
- [License](#license)

## Introduction

In this project, we'd explore the intricacies of data for enhanced efficiency and user experience in the Lagos BRT System. 
The database design covers entities like buses, routes, and passengers, with a focus on data integrity, normalization, and efficient query processing.

## Overview

## Key Features

## Schema Definition

The schema definition ensures and enforces a solid foundation for the database. 
It includes tables representing each entity with the appropriate data types, constraints, and relationships, providing a holistic and functional view of the mass transit system. 
Entity relationships are defined by mapping cardinalities (number of tuples), thus ensuring real-life associativity between them. 

The entities are:

- Passengers - `passenger_details`
- Email Address - `passenger_email_address` & `driver_email_address`
- Phone Number - `passenger_phone_number` & `driver_phone_number`
- Residential Address - `passenger_address`, `passenger_address_pairings`, `driver_address` & `driver_address_pairings`
- Payment Cards - `passenger_payment_card` & `driver_payment_card`
- Drivers - `driver_details`
- License - `driver_license_images` & `driver_license`
- NIN - `driver_nin_images` & `driver_nin`
- Identification Cards - `driver_identification_card`
- Vehicles - `vehicles`, `driver_vehicle_pairing`
- LGA - `lga`
- Terminals - `terminals`, `lga_terminal_pairing`
- Trips - `scheduled_trips`, `passenger_booked_trips`, `passenger_trip_history` & `driver_trip_history`
- Tickets - `tickets`


[View Schema Scripts](oltp/schema/schema.pgsql)

## Database Extensions

Database extensions played a crucial role in the proper functioning of the database. 

To load an extension in PostgreSQL:

```sql
CREATE EXTENSION <extension_name> SCHEMA <schema_name>;

```

To confirm if the extension has been loaded properly:

```sql
SELECT * FROM pg_extension WHERE extname = '<extension_name>';

```

The extensions implemented in this database are:

- `pgAgent`
- `plpgsql`
- `pgcrypto`


### The `pgAgent` extension

`pgAgent` is a job scheduling agent for PostgreSQL, designed to automate and manage the execution of tasks within the database. It serves as a crucial tool for database administrators and developers to automate recurring jobs, such as data maintenance, backups, and routine updates. Some notable features are job scheduling, concurrency control, logging, and monitoring. 


### The `plpgsql` extension - PostgreSQL Procedural Language

In contrast to SQL being a declarative language that tells the query compiler what to do, `plpgsql` is a procedural language that tells the compiler **how** to do the said task. It allows users to write stored procedures, functions, and triggers using the SQL language augmented with procedural elements. 

Think of the database as a cake factory and the query compiler is the attendee. The cake (stored in the database tables) would be our data to be retrieved/bought. For a declarative language like SQL, the buyer (you) tells the attendee what cake you would like to get, the flavor, from what shelf, and with what kind of icing, and so on. In the case of a procedural language like `plpgsql`, you are given all the ingredients you need to bake a cake you want and how you want it. This dynamic and finely grounded control enables a much more precise way to define custom database logic within the database itself.

Key features of `plpgsql` are function definition by the advent of UDFs, stored procedures, procedural elements such as loops, conditionals and exception handling, and database triggers. 

Example: The code below is written in `plpgsql`

```sql
DO
$$
DECLARE
    var text;
BEGIN
    var := 'Hello World';
    RAISE NOTICE '$1', var;
END;
$$;

```

The procedural constructs in `plpgsql` allow for more sophisticated logic and implementation of complex business requirements compared to standard SQL.

### The `pgcrypto` extension

This is extension in the PostgreSQL DBMS that provides cryptographic and hashing capabilities within the database environment.

In order to create a five-character string in PostgreSQL, we'd need to incorporate a hashing algorithm. 

*This extension would only be local in the `brt` schema and not in any other schema, including `public`.*

The `pgcrypto` extension was implemented for creating random numbers which are further used in payment information data such as card numbers and identification numbers for driver ID cards. This was further implemented using the hashing function `md5` would be used in this case and it accepts an input (message) of type 'string'. The message itself must be random as this function creates an identical hash for every identical message. 

To create a random input for the function, we'd implememt the built-in `random()` function. This generates a random number (decimal) between `0` and `1` (similar to NumPy's `random.rand()` function).

Recall that `md5` only accepts strings so we'd need to cast the output of `random()` to generate random numbers but in string format. 

Given as:

```sql
md5(random()::text)
```

The output of the `md5()` function is a 32-charactered hexadecimal output of any character between `0` to `9` and `a` to `f`, which corresponds to the alphanumeric need of the `card_no` column in the `driver_identification_cards` table. Since we only need five characters, we can use a substring function to extract such. 

Given as:

```sql
substr(md5(random()::text), 1, 5)
```

We can retrieve more than 5 characters but in this case, only 5 characters are required.

Where `md5(random()::text)` corresponds to the string input (hash), 1 is the start position of the hash and 5 is the length of characters to be extracted from the hash.


## Entity-Relationship Model Diagram

The Entity-Relationship Model Diagram, also known as an ERD, provides a visual representation of the relationships between different entities/entity set in the database. In our Lagos BRT System, this diagram is crucial for understanding how buses, routes, and passengers interact within the database.

![BRT Database Schema](/Users/josephobukofe/Downloads/BRT Database Schema.jpeg)


## Query Optimization

Query optimization is a key aspect of our database design, ensuring that data retrieval and manipulation are executed efficiently.

### Key Strategies

#### Execution Plan Analysis 

Regular analysis of query execution plans is performed to identify bottlenecks and optimize them for better performance.  

The `EXPLAIN` statement was used for such process given as:

```sql
EXPLAIN VERBOSE SELECT * FROM <table> WHERE <condition>;
```

#### Query Execution Plan Caching

Frequently executed queries or data are cached, reducing the need for repeated expensive operations. This operation is implemented using UDFs and Stored Procedures with parameterized queries that bind user input to database queries at runtime. This behavior 'skips' the query compilation (only when after executed once) and then the compiled query plan is cached in memory. Subsequent executions of the parameterized query reuses the cached execution plan, skipping the compilation step. The need for this implementation is to avoid the overhead of recompiling the same query repeatedly, especially when the structure of the query remains constant, and only the parameter values change. This is the core reason why UDFs and Stored Procedures were used as the only changing component(s) in the syntax are the input parameters.  

For example, consider the code to delete a LGA (Local Government Area) from the database:

```sql
-- This procedure deletes a LGA

CREATE OR REPLACE PROCEDURE brt.delete_lga(
    lga_id brt.lga.id%type
)
LANGUAGE plpgsql 
AS $$ 
DECLARE 
    query text;
BEGIN
    IF lga_id IS NULL THEN
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    IF NOT (pg_typeof(lga_id) = 'integer'::regtype) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    query := 'DELETE FROM brt.lga WHERE id = $1;';

    IF EXISTS (SELECT 1 FROM brt.lga WHERE id = lga_id) THEN 
        EXECUTE query USING lga_id;
        RAISE NOTICE 'LGA with ID: % has been successfully deleted', lga_id;
    ELSE 
        RAISE EXCEPTION 'The provided LGA does not exist';
    END IF;
END;
$$;

CALL brt.delete_lga (
	lga_id := [ ]
);

```

Instead of constructing a static `DELETE` query and just replacing the value of the `WHERE` condition with the ID value, the cached query plan can be reused over and over with different ID values without the overhead of query compilation. This significantly boosts query performance and overall resource optimization in the database.


## Database Automation

### Key Strategies

#### Enforcing Database Automation with Triggers

Triggers, as a database automation feature, empower users to automate actions based on predefined events. 

For example, consider the code below that generates a new payment card for a passenger for every phone number registration.

```sql
-- This operation creates a payment card for a newly registered passenger

-- Creating a function to generate a random set of numbers
CREATE OR REPLACE FUNCTION brt.generate_random_numbers(min_value integer, max_value integer, count integer)
RETURNS SETOF integer 
LANGUAGE plpgsql
AS $$
DECLARE
    i integer := 1;
BEGIN
    WHILE i <= count LOOP
        RETURN NEXT ((min_value + floor(random() * (max_value - min_value + 1)))::integer)::text;
        i := i + 1;
    END LOOP;

    RETURN;
END;
$$

-- Creating a function to generate a random set of alphabets
CREATE OR REPLACE FUNCTION brt.generate_random_alphabets(length integer)
RETURNS text 
LANGUAGE plpgsql
AS $$
DECLARE
    random_string TEXT := '';
    i INTEGER := 1;
BEGIN
    WHILE i <= length LOOP
        random_string := random_string || CHR(65 + (RANDOM() * 26)::integer);
        i := i + 1;
    END LOOP;

    RETURN random_string;
END;
$$

-- Creating a function that incorporates the previous functions (generate_random_numbers and generate_random_alphabets)
CREATE OR REPLACE FUNCTION brt.generate_random_character()
RETURNS varchar(10)
LANGUAGE plpgsql
AS $$
DECLARE 
    rand_num varchar(6);
    rand_alpha varchar(4);
    rand_char varchar(10);
BEGIN
	SELECT brt.generate_random_alphabets(4) INTO rand_alpha;

    SELECT brt.generate_random_numbers(100000, 999999, 1) INTO rand_num;

    rand_char := rand_alpha || rand_num;

    RAISE NOTICE '%', rand_char;

    RETURN rand_char;
END;
$$

-- Creating a trigger function that inserts a new payment card for the corresponding inserted passenger phone number
CREATE OR REPLACE FUNCTION brt.insert_new_passenger_card()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE 
    card_num brt.passenger_payment_cards.card_number%type;
    card_bal brt.passenger_payment_cards.card_balance%type;
BEGIN
    SELECT brt.generate_random_character() INTO card_num; -- Generating a set of 10 random characters for the new card

    card_bal := 2000.00; -- Setting an initial balance for the new

    INSERT INTO brt.passenger_payment_cards (card_number, card_balance, phone_id)
    VALUES (card_num, card_bal, NEW.id);

    RETURN NEW;
END;
$$

-- Creating a trigger to be fired after inserts on the brt.passenger_phone_number table
DROP TRIGGER IF EXISTS insert_new_passenger_card_trigger 
ON brt.passenger_phone_number;

CREATE TRIGGER insert_new_passenger_card_trigger
	AFTER INSERT
	ON brt.passenger_phone_number
	FOR EACH ROW
	EXECUTE FUNCTION brt.insert_new_passenger_card();

```

This trigger is associated with the `brt.passenger_phone_number` table and is configured to execute after an insertion operation (`AFTER INSERT`). It leverages the previously defined random character generation functions to create a unique card number and initializes a starting balance of **₦2000.00** for the new card. The trigger inserts this information into the `brt.passenger_payment_cards` table.

Now, every time a new passenger is registered, a payment card will be automatically generated and associated with the corresponding phone number.

The use of triggers in this context exemplifies the power of automation in database management. 

#### Enforcing Database Automation with Jobs: A `pgAgent` example

Database jobs are a fundamental aspect of automating recurring tasks in a database management system. In the context of the Lagos BRT System, we'll explore the utilization of pgAgent jobs to automate the update of trip availability status. 

The following SQL code demonstrates the setup of a pgAgent job, its associated steps, and a schedule.

**Job Definition**

Create a new pgAgent job named `'update_trip_availability_status'`:

```sql
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

```

**Job Step Definition**

Add a step to the job. This step executes a function to update the availability status:

```sql
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

```

**Job Schedule Definition**

Finally, we schedule the job to execute every minute:

```sql
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
    '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[],
    -- Hours
    '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[],
    -- Week days
    '{t,t,t,t,t,t,t}'::bool[]::boolean[],
    -- Month days
    '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[],
    -- Months
    '{t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[]
) RETURNING jscid INTO scid;

```

In this example, we've demonstrated the creation of a `pgAgent` job that automatically updates the trip availability status at regular intervals. This showcases the power of database jobs in automating routine tasks, ensuring data consistency, and enhancing overall system efficiency


## Security  
Ensuring and enforcing the security of the database is paramount in protecting sensitive information and maintaining data integrity throughout the database.

### Key Strategies

#### User Authentication and Authorization

Access to the database is limited by user authentication and specific user roles and permissions are meticulously defined.

#### Encryption

Sensitive data, such as payment information, is encrypted using the `pgcrypto` extension, enhancing data security.

#### Parameterized Queries

As opposed to constructing hard-coded queries, binding user parameters to a dynamically constructed query at runtime essentially separates the input values from the overall query logic. This eradicates the possibility of SQL injection attacks as the input values are properly sanitized for total conformation to input, content, and format rules. For **READ** operations, database views were implemented. These database objects were used as a modular component to a larger part of a UDF where input values are matched to `WHERE` conditions. This also separates user values from raw database information, as it only allows users to a virtual but comprehensive subset of data.  

For example, consider the code to modify an existing passenger's phone number below:

```sql
-- This procedure modifies the phone number of a passenger

CREATE OR REPLACE PROCEDURE brt.update_existing_passenger_phone_number (
    pass_id brt.passenger_details.id%type,
    old_passenger_phone_number brt.passenger_phone_number.phone_number%type,
    new_passenger_phone_number brt.passenger_phone_number.phone_number%type
)
LANGUAGE plpgsql 
AS $$
DECLARE 
    query text;
BEGIN 
    -- Input validation for null checks
    IF pass_id IS NULL OR old_passenger_phone_number IS NULL OR new_passenger_phone_number IS NULL THEN   
        RAISE EXCEPTION 'All fields must be provided';
    END IF;

    -- Input validation for argument data type checks
    IF NOT (
        pg_typeof(pass_id) = 'integer'::regtype AND
        pg_typeof(old_passenger_phone_number) = 'varchar'::regtype AND 
        pg_typeof(new_passenger_phone_number) = 'varchar'::regtype
    ) THEN
        RAISE EXCEPTION 'Invalid data type for the provided field(s)';
    END IF;

    -- To check if the provided passenger owns a phone number
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_phone_number WHERE passenger_id = pass_id) THEN 
        RAISE EXCEPTION 'The provided passenger does not have a phone number'
            USING HINT = 'Ensure the provided passenger is referenced to an existing phone number';
    END IF;

    -- To check if the old phone number exists
    IF NOT EXISTS (SELECT 1 FROM brt.passenger_phone_number WHERE phone_number = old_passenger_phone_number) THEN 
        RAISE EXCEPTION 'The provided phone number does not exist'
            USING HINT = 'Ensure a valid passenger phone number is provided';
    END IF;

    -- Sanitizing the new phone number to prepare it for format conformation checks
    san_new_passenger_phone_number := regexp_replace(new_passenger_phone_number, '[^\d+]', '', 'g');

    -- To check if the new phone number is already in use by another passenger
    IF EXISTS (
        SELECT 1 FROM brt.passenger_phone_number 
        WHERE 
            phone_number = san_new_passenger_phone_number AND
            passenger_id != pass_id
    ) THEN 
        RAISE EXCEPTION 'The provided phone number is already in use by another passenger';
    END IF;

    -- Format validation checks
    IF san_new_passenger_phone_number ~ '^\+234[0-9]{10}$' THEN
        IF san_new_passenger_phone_number <> old_passenger_phone_number THEN
            query := (
                'UPDATE brt.passenger_phone_number
                SET phone_number = $1
                WHERE passenger_id = $2;'
            );

            EXECUTE query USING san_new_passenger_phone_number, pass_id;
            RAISE NOTICE 'Passenger phone number successfully changed from % to %', old_passenger_phone_number, san_new_passenger_phone_number;
        ELSE 
            RAISE NOTICE 'The current passenger phone number already matches the provided phone number';
        END IF;
    ELSE 
        RAISE EXCEPTION 'Invalid phone number format'
            USING HINT = 'Ensure the provided number conforms to the (+234) calling code';
    END IF;
END;
$$

-- Executing the procedure to update a passenger's phone number

CALL brt.update_existing_passenger_phone_number (
    pass_id := [ ],
    old_passenger_phone_number := [ ],
    new_passenger_phone_number := [ ]
);

```

The input parameters = `pass_id`, `old_passenger_phone_number`, and `new_passenger_phone_number` are checked for NULL behaviors, data type conformation to the defined schema, existence validations (for `pass_id` and `old_passenger_phone_number`), then the to-be-replaced phone number (`new_passenger_phone_number`) is then checked for format and content validations. The actual query represented by the variable `query` contains placeholders for the new phone number and the passenger ID given as `$1` and `$2`. 

These placeholder values would be replaced by sanitized user inputs and then executed, enforcing data security and integrity.


## Getting Started

To explore and contribute to the project, follow these steps:

1. Clone the repository: `git clone https://github.com/your-username/lagos-brt-database.git`
2. Navigate to specific sections like [Schema](/schema-scripts), [UDFs](/udf-scripts), [Stored Procedures](/stored-procedures), or [Triggers](/trigger-scripts).
3. Execute the scripts in a PostgreSQL environment to set up the database.
   

## Contributing

Contributions are welcome! Feel free to submit issues, fork the repository, and create pull requests. Follow the [Contribution Guidelines](CONTRIBUTING.md) for more details.


## License

This project is licensed under the [MIT License](LICENSE.md).

Happy Coding! 🚀
