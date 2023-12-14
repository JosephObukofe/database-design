-- Schema Definition
CREATE SCHEMA brt;

-- Passenger Details
CREATE TABLE brt.passenger_details (
	id serial PRIMARY KEY,
	first_name varchar(20) NOT NULL,
	last_name varchar(20) NOT NULL,
	gender varchar(6) NOT NULL CHECK(gender IN ('Male', 'Female', 'Other')),
	date_of_birth date NOT NULL CHECK((date_part('year', now()) - date_part('year', date_of_birth)) >= 10)
);

COMMENT ON TABLE brt.passenger_details IS 'This defines the registered passengers in the database. It stores details about their first and last names, as well as their genders and dates of birth';
COMMENT ON COLUMN brt.passenger_details.gender IS 'Gender of the passenger. It is either Male, Female or Others if intended to be unspecified or preferably not to be stated';
COMMENT ON COLUMN brt.passenger_details.date_of_birth IS 'Date of birth of the passenger. Passengers should be the ages of 10 years and above to be duly registered';

-- Passenger Email Address
CREATE TABLE brt.passenger_email_address (
	id serial PRIMARY KEY,
	email_address varchar(50) UNIQUE NOT NULL,
	passenger_id integer REFERENCES brt.passenger_details(id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE brt.passenger_email_address IS 'This defines the email addresses of passengers. Passengers are allowed to have multiple email addresses, each referenced by the unique ID of the passenger';

-- Passenger Phone Number
CREATE TABLE brt.passenger_phone_number (
	id serial PRIMARY KEY,
	phone_number varchar(15) UNIQUE NOT NULL,
	passenger_id integer REFERENCES brt.passenger_details(id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE brt.passenger_phone_number IS 'This defines the phone numbers of passengers. Passengers are allowed to have multiple phone numbers, each referenced by the unique ID of the passenger';

-- Passenger Payment Cards
CREATE TABLE brt.passenger_payment_cards (
	id serial PRIMARY KEY,
	card_number char(10) UNIQUE NOT NULL,
	card_balance decimal(7,2) DEFAULT(2000) CHECK(card_balance <= 20000 AND card_balance >= 0),
	phone_id integer UNIQUE REFERENCES brt.passenger_phone_number(id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE brt.passenger_payment_cards IS 'This table defines the payment cards of registered passengers. Upon registration, a payment card is automiacally created for a passenger, with an initial amount of ₦2,000. It is also associated with the passengers phone number, representing a unique one-on-one association identified by cascaded inserts and delete operations';
COMMENT ON COLUMN brt.passenger_payment_cards.card_number IS 'Card number of the payment card. A 10-character code uniquely identifying the payment card.';
COMMENT ON COLUMN brt.passenger_payment_cards.card_balance IS 'Card balance of the payment card. This defines the amount balance of the payment card at a particular time.';

-- LGAs
CREATE TABLE brt.lga (
	id serial PRIMARY KEY,
	name varchar(20) UNIQUE NOT NULL,
	postal_code char(6) UNIQUE NOT NULL
);

COMMENT ON TABLE brt.lga IS 'List of LGAs in Lagos State with their postal codes.';

-- Passenger Address
CREATE TABLE brt.passenger_address (
	id serial PRIMARY KEY,
	building_number varchar(4) NOT NULL,
	street_name varchar(50) NOT NULL,
	lg_id integer REFERENCES brt.lga(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

COMMENT ON TABLE brt.passenger_address IS 'This defines the residential addresses of registered passengers.';

-- Passenger and Address Pairings
CREATE TABLE brt.passenger_address_pairings (
	id serial,
	passenger_id integer REFERENCES brt.passenger_details(id) ON UPDATE CASCADE ON DELETE CASCADE,
	address_id integer REFERENCES brt.passenger_address(id) ON UPDATE CASCADE ON DELETE CASCADE,
	pair_date timestamp DEFAULT(now()::timestamp(0)),
	PRIMARY KEY (passenger_id, address_id) 
);

COMMENT ON TABLE brt.passenger_address_pairings IS 'This defines a bridge associativity table referencing both passengers and their residential addresses. It is possible and permissible for passengers to have multiple addresses, as a single residential address is owned by multiple passengers.';
COMMENT ON COLUMN brt.passenger_address_pairings.pair_date IS 'This refers to the date in which a passenger was paired to their residential address. Pair dates are database-centric.';

-- Terminals
CREATE TABLE brt.terminals (
	id serial PRIMARY KEY,
	name varchar(20) UNIQUE NOT NULL
);

COMMENT ON TABLE brt.terminals IS 'List of terminals in Lagos State.';

-- LGA and Terminal Pairings
CREATE TABLE brt.lga_terminal_pairing (
	id serial,
	lg_id integer REFERENCES brt.lga(id) ON UPDATE CASCADE,
	terminal_id integer REFERENCES brt.terminals(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  	PRIMARY KEY (lg_id, terminal_id)
);

COMMENT ON TABLE brt.lga_terminal_pairing IS 'LGA-Terminal Pairing';

-- Driver Details
CREATE TABLE brt.driver_details (
	id serial PRIMARY KEY,
	first_name varchar(20) NOT NULL,
	last_name varchar(20) NOT NULL,
	gender varchar(6) NOT NULL CHECK(gender IN ('Male', 'Female', 'Other')),
	date_of_birth date NOT NULL CHECK((date_part('year', NOW()) - date_part('year', date_of_birth)) >= 20),
	terminal_id integer NOT NULL REFERENCES brt.terminals(id) ON UPDATE CASCADE,
	registration_status boolean NOT NULL DEFAULT(FALSE)
);

COMMENT ON TABLE brt.driver_details IS 'This defines the registered drivers in the database. Similar to passengers, it also stores details about their first and last names, as well as their genders and dates of birth';
COMMENT ON COLUMN brt.driver_details.gender IS 'Gender of the driver. It is either Male, Female or Others if intended to be unspecified or preferably not to be stated';
COMMENT ON COLUMN brt.driver_details.date_of_birth IS 'Date of birth of the driver. Drivers should be the ages of 20 years and above, which serves as a criteria for registration';
COMMENT ON COLUMN brt.driver_details.terminal_id IS 'Terminal ID. This defines the assigned terminal of the driver. A driver can only be assigned to a terminal at time. Terminal recommendations are based on the choice of the LGA of the driver during residential address registration.';
COMMENT ON COLUMN brt.driver_details.registration_status IS 'Registration status of the driver. This denotes whether a driver has completed registration or not. Once a driver is registered, they would be assigned a vehicle and hence would be able to handle trips.';


-- Driver Email Address
CREATE TABLE brt.driver_email_address (
	id serial PRIMARY KEY,
	email_address varchar(50) UNIQUE NOT NULL,
	driver_id integer REFERENCES brt.driver_details(id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE brt.driver_email_address IS 'This defines the email addresses of driver. Drivers are allowed to have multiple email addresses, each referenced by the unique ID of the driver';

-- Driver Phone Number 
CREATE TABLE brt.driver_phone_number (
	id serial PRIMARY KEY,
	phone_number varchar(15) UNIQUE NOT NULL,
	driver_id integer REFERENCES brt.driver_details(id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE brt.driver_phone_number IS 'This defines the phone numbers of drivers.';

-- Driver Payment Cards
CREATE TABLE brt.driver_payment_cards (
	id serial PRIMARY KEY,
	card_number char(10) UNIQUE NOT NULL,
	card_balance decimal(8,2) NOT NULL DEFAULT(0) CHECK(card_balance >= 0),
	tip_balance decimal(7,2) NOT NULL DEFAULT(0) CHECK(tip_balance >= 0),
	phone_id integer UNIQUE REFERENCES brt.driver_phone_number(id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE brt.driver_payment_cards IS 'This defines the payment cards of registered drivers. Upon registration, drivers are issued a payment card which is solely used to accept payments for trips. Unlike passenger payment cards, these cards do not have a default starting amount.';
COMMENT ON COLUMN brt.driver_payment_cards.card_balance IS 'Card balance for driver payment cards';
COMMENT ON COLUMN brt.driver_payment_cards.tip_balance IS 'Tip balance for driver payment cards. This is independent of the card balance and is solely used for collecting tips';

-- Driver Address
CREATE TABLE brt.driver_address (
	id serial PRIMARY KEY,
	building_number varchar(4) NOT NULL,
	street_name varchar(50) NOT NULL,
	lg_id integer REFERENCES brt.lga(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

COMMENT ON TABLE brt.driver_address IS 'This defines the residential addresses of registered drivers.';

-- Drivers and Address Pairings 
CREATE TABLE brt.driver_address_pairings (
	id serial,
	driver_id integer REFERENCES brt.driver_details(id) ON UPDATE CASCADE ON DELETE CASCADE,
	address_id integer REFERENCES brt.driver_address(id) ON UPDATE CASCADE ON DELETE CASCADE,
	pair_date timestamp DEFAULT(now()::timestamp(0)),
	PRIMARY KEY (driver_id, address_id)
);

-- Driver License
CREATE TABLE brt.driver_license (
	id serial PRIMARY KEY,
	license_number varchar(12) UNIQUE NOT NULL,
	issue_date date NOT NULL CHECK((date_part('year', now()) - date_part('year', issue_date)) >= 1), 
	expiry_date date NOT NULL CHECK(expiry_date > issue_date),
	license_status varchar(7),
	driver_id integer UNIQUE REFERENCES brt.driver_details(id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE brt.driver_license IS 'This defines the license details of registered drivers in the database. Driver license information is a prerequisite for a complete registration operation';

-- Driver Identification Cards
CREATE TABLE brt.driver_identification_cards (
	id serial PRIMARY KEY,
	card_no char(5) UNIQUE,
	issue_date date NOT NULL DEFAULT(now()::timestamp(0)),
	driver_id integer UNIQUE REFERENCES brt.driver_details(id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE brt.driver_identification_cards IS 'This defines the ID card info of registered drivers in the system. Upon registration, every driver is assigned an ID card for unique identification purposes in the system.';
COMMENT ON COLUMN brt.driver_identification_cards.issue_date IS 'This defines the issue date of the ID card.';

-- Driver NIN 
CREATE TABLE brt.driver_nin (
	id serial PRIMARY KEY,
	nin char(11) UNIQUE NOT NULL,
	driver_id integer UNIQUE REFERENCES brt.driver_details(id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE brt.driver_nin IS 'This defines the drivers NIN info';

-- Vehicle Details
CREATE TABLE brt.vehicle (
	id serial PRIMARY KEY,
	vin varchar(20) UNIQUE NOT NULL,
	plate_number varchar(10) UNIQUE NOT NULL,
	model varchar(20) NOT NULL,
	capacity integer NOT NULL CHECK(capacity > 0),
	status varchar(20) NOT NULL CHECK(status IN ('Available', 'In Use', 'Under Maintenance', 'Decommissioned')),
	terminal_id integer REFERENCES brt.terminals(id) ON UPDATE CASCADE
);

COMMENT ON TABLE brt.vehicle IS 'This defines the vehicles used for trips in the BRT system. It contains information on the vehicle model, its plate number information as well as its maximum sitting capacity.';
COMMENT ON COLUMN brt.vehicle.status IS 'Vehicle availability status. This refers to the state of the vehicle at any particular time. A vehicle could either be available for handling trips, in use by another driver, under maintenance or decommissioned.';
COMMENT ON COLUMN brt.vehicle.terminal_id IS 'Terminal ID. This explains the terminal that the vehicle is assigned to. It is possible that a driver may be assigned a vehicle with a different assigned terminal info from the drivers themselves.';

-- Drivers and Vehicles Pairings
CREATE TABLE brt.driver_vehicle_pairings (
	id serial PRIMARY KEY,
	driver_id integer REFERENCES brt.driver_details(id) ON UPDATE CASCADE ON DELETE CASCADE,
	vehicle_id integer REFERENCES brt.vehicle(id) ON UPDATE CASCADE ON DELETE CASCADE,
	pair_date timestamp NOT NULL DEFAULT(now()::timestamp)
);

COMMENT ON TABLE brt.driver_vehicle_pairings IS 'This refers to driver-vehicle pairing information. It serves as a bridge table between the two (2) one-to-many instance between drivers and vehicles, with both entities having multiple associations with each other.';
COMMENT ON COLUMN brt.driver_vehicle_pairings.pair_date IS 'Pair date. This explains the date in which the driver-vehicle pairing took place.';

-- Scheduled Trips
CREATE TABLE brt.scheduled_trips (
	id serial PRIMARY KEY,
	dep_terminal varchar(20) NOT NULL,
	arr_terminal varchar(20) NOT NULL CHECK(arr_terminal != dep_terminal),
	sch_dep_time timestamp NOT NULL,
	est_arr_time timestamp NOT NULL CHECK(est_arr_time > sch_dep_time),
	dow varchar(10), 
	subtotal decimal(6,2) NOT NULL CHECK(subtotal > 0),
	booking_fee decimal(5,2) NOT NULL,
	trip_fare decimal(6,2) NOT NULL CHECK(trip_fare = subtotal + booking_fee),
	max_trip_cap smallint NOT NULL, 
	current_trip_cap smallint NOT NULL DEFAULT(0),
	trip_status varchar(10) NOT NULL DEFAULT('Ongoing') CHECK(trip_status IN ('Ongoing', 'Expired', 'Maximum')),
	trip_comp_status varchar(10) NOT NULL DEFAULT('None') CHECK(trip_comp_status IN ('None', 'Initiated', 'Completed')),
	pairing_id integer DEFAULT(0) REFERENCES brt.driver_vehicle_pairings(id) ON UPDATE CASCADE ON DELETE SET DEFAULT
);

COMMENT ON TABLE brt.scheduled_trips IS 'This refers to the scheduled trips to be undergone. Each trip information is an aggregate of the (trip itself + pairing details), with the pairing information referring to a particular driver-vehicle pair';
COMMENT ON COLUMN brt.scheduled_trips.arr_terminal IS 'Arrival Terminal. This is the trip arrival location (denoted by a terminal). No trip can depart from and arrive at the same given terminal';
COMMENT ON COLUMN brt.scheduled_trips.est_arr_time IS 'Estimated Arrival Time. This refers to the estimated time of arrival of passengers at a particular terminal. This trip attribute must always be greater than the scheduled departure time.';
COMMENT ON COLUMN brt.scheduled_trips.subtotal IS 'Trip Subtotal. This refers to the trip fare (exlusive of booking fee). The booking fee is a non-constant value added to the trip subtotal. The trip subtotal must always be a positive value.';
COMMENT ON COLUMN brt.scheduled_trips.trip_fare IS 'Trip Fare. This denotes the trip fare (inclusive of the booking fee).';
COMMENT ON COLUMN brt.scheduled_trips.current_trip_cap IS 'Current Trip Capacity. This refers to the current booking capacity of the trip. It differs from the current sitting capacity; defined by the number of the passengers present at the departure terminal for the booked trip in context. This attribute is computed based on active trip bookings and used to indicate the current booking status.';
COMMENT ON COLUMN brt.scheduled_trips.trip_status IS 'Trip Status. This attribute establishes the trip availability status. It is determined by the (current_trip_cap) attribute and the Maximum Trip Capacity (defined by the maximum vehicle sitting capacity). It could either be Ongoing (denoting an ongoing booking process), Expired (referring to expired trips with respect to the expiration time), and Maximum (denoting a fully booked trip).';
COMMENT ON COLUMN brt.scheduled_trips.trip_comp_status IS 'Trip Completion Status. This attribute refers to the completion status of the trip.';

-- Passenger Booked Trips 
CREATE TABLE brt.passenger_booked_trips (
	id serial PRIMARY KEY,
	passenger_id integer REFERENCES brt.passenger_details(id) ON UPDATE CASCADE ON DELETE CASCADE,
	trip_id integer REFERENCES brt.scheduled_trips ON UPDATE CASCADE ON DELETE CASCADE,
	booking_time timestamp NOT NULL DEFAULT(now()::timestamp),
	amount_paid decimal(6,2)
);

COMMENT ON TABLE brt.passenger_booked_trips IS 'This refers to the trips booked by passengers. It allows for a more granular trip tracking operation from the passengers';
COMMENT ON COLUMN brt.passenger_booked_trips.booking_time IS 'Booking Time. It refers to the time the trip was booked.';

-- Tickets 
CREATE TABLE brt.tickets (
	id serial PRIMARY KEY,
	ticket_number char(5) UNIQUE NOT NULL,
	booking_id integer UNIQUE REFERENCES brt.passenger_booked_trips(id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE brt.tickets IS 'This denotes the ticket information generated from booked trips. It is only valid when the booked trip is available, meaning it cascade deletes on booked trip deletion.';

-- Driver Trip History
CREATE TABLE brt.driver_trip_history (
	id serial PRIMARY KEY,
	pairing_id integer REFERENCES brt.driver_vehicle_pairings(id) ON UPDATE CASCADE ON DELETE CASCADE,
	trip_id integer REFERENCES brt.scheduled_trips(id) ON UPDATE CASCADE ON DELETE CASCADE,
	dep_time timestamp,
	arr_time timestamp,
	trip_capacity smallint NOT NULL DEFAULT(0)
);

COMMENT ON TABLE brt.driver_trip_history IS 'This refers to the trips handled by a driver. It describes the driver-vehicle pairing information (defining the vehicle used for the trip), the trip in context, the departure and arrival time as well as the sitting trip capacity. Recall that the sitting trip capacity refers to the actual number of passengers present in the vehicle.';

-- Passenger Trip History
CREATE TABLE brt.passenger_trip_history (
	id serial PRIMARY KEY,
	passenger_id integer REFERENCES brt.passenger_details(id) ON UPDATE CASCADE ON DELETE CASCADE,
	trip_id integer REFERENCES brt.scheduled_trips(id) ON UPDATE CASCADE ON DELETE CASCADE,
	val_stat boolean NOT NULL DEFAULT(FALSE),
	dep_time timestamp,
	arr_time timestamp
);

COMMENT ON TABLE brt.passenger_trip_history IS 'This describes the trips undergone by a passenger. It describes the details of the passenger, the trip in context, the validation status and the departure and arrival times.';
COMMENT ON COLUMN brt.passenger_trip_history.val_stat IS 'Validation Status. This attribute creates the distinction between booking capacity and sitting capacity';

-- Driver License Image
CREATE TABLE brt.driver_license_images (
    id serial PRIMARY KEY,
    image_data bytea NOT NULL,
    uploaded_at timestamp DEFAULT(now()),
    driver_id integer UNIQUE 
);

COMMENT ON TABLE brt.driver_license_images IS 'This denotes the uploaded license images by registering drivers.';
COMMENT ON COLUMN brt.driver_license_images.uploaded_at IS 'This attribute describes the time when the license image was uploaded.';

ALTER TABLE brt.driver_license 
ADD COLUMN license_image_id integer REFERENCES brt.driver_license_images(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE brt.driver_license_images
ADD CONSTRAINT fk_driver_license_image_details
FOREIGN KEY (driver_id)
REFERENCES brt.driver_details (id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE brt.driver_license_images
ADD CONSTRAINT unique_driver_id UNIQUE (driver_id);

-- Driver NIN Image 
CREATE TABLE brt.driver_nin_images (
    id serial PRIMARY KEY,
    image_data bytea NOT NULL,
    uploaded_at timestamp DEFAULT(now()),
    driver_id integer UNIQUE 
);

COMMENT ON TABLE brt.driver_nin_images IS 'This denotes the uploaded NIN images by registering drivers.';
COMMENT ON COLUMN brt.driver_nin_images.uploaded_at IS 'This attribute describes the time when the NIN image was uploaded.';

ALTER TABLE brt.driver_nin 
ADD COLUMN nin_image_id integer REFERENCES brt.driver_nin_images(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE brt.driver_nin_images
ADD CONSTRAINT fk_driver_nin_image_details
FOREIGN KEY (driver_id)
REFERENCES brt.driver_details (id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE brt.driver_nin_images
ADD CONSTRAINT uq_driver_id UNIQUE (driver_id);

-- Trip Completion Log
CREATE TABLE brt.trip_completion_log (
    id serial PRIMARY KEY,
    function text NOT NULL,
    execution_time timestamp DEFAULT(now()),
    completed_trip integer
);

COMMENT ON TABLE brt.trip_completion_log IS 'This is a log table used to track the execution of the trip UDF';
COMMENT ON COLUMN brt.trip_completion_log.function IS 'This refers to the UDF name';
COMMENT ON COLUMN brt.trip_completion_log.execution_time IS 'This denotes the UDF execution time';
COMMENT ON COLUMN brt.trip_completion_log.completed_trip IS 'This attribute refers to the completed trip referenced by the UDF.';

