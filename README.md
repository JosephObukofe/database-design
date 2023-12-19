# Lagos BRT System Database Design

🚌 Excited to share my Database Design project for the Lagos BRT System! This project focuses on creating an efficient and robust database structure for managing the bus rapid transit system in Lagos, Nigeria.

## Table of Contents
- [Introduction](#introduction)
- [Overview](#overview)
- [Key Features](#key-features)
- [Schema Definition](#database-schema-definition)
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

The schema definition ensures a solid foundation for the database. 
It includes tables representing each entity with the appropriate data types, constraints and relationships, providing a holistic and functional view of the mass transit system. 
Entity relationships are defined by mapping cardinalities (number of tuples) between them, thus ensuring a real-life associativity between them.

- [View Schema Scripts](/schema-scripts)

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

### The `plpgsql` extension - PostgreSQL Procedural Language



### The `pgcrypto` extension

This is extension in the PostgreSQL DBMS that provides cryptographic and hashing capabilities within the database environment.

In order to create a five-character string in PostgreSQL, we'd need to incorporate a hashing algorithm. 

> This extension would only be local in the `brt` schema and not in any other schema, including `public`.

The `pgcrypto` extension was implemented for creating random numbers which are further used in payment information data such as card numbers and identification numbers for driver ID cards. This was further implemented using the hashing function `md5` would be used in this case and it accepts an input (message) of type 'string'. The message itself must be random as this function creates an identical hash for every identical message. To create a random input for the function, we'd implememt the built-in `random()` function. This generates a random number (decimal) between 0 and 1 (similar to NumPy's `random.rand()` function).

Recall that md5 only accepts strings so we'd need to cast the output of `random()` to generate random numbers but in string format. Given as:

```sql
    md5(random()::text)
```

The output of the `md5()` function is a 32-charactered hexadecimal output of any character between `0` to `9` and `a` to `f`, which corresponds to the alphanumeric need of the `card_no` column in the `driver_identification_cards` table. Since we only need five characters, we can use a substring function to extract such. Given as:

```sql
    substr(md5(random()::text), 1, 5)
```
We can retrieve more than 5 characters but in this case, only 5 characters are requires.

Where `md5(random()::text)` corresponds to the string input (hash), 1 is the start position of the hash and 5 is the length of characters to be extracted from the hash.

## Entity-Relationship Model Diagram

## Query Optimization

## Database Automation

## Security 

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
