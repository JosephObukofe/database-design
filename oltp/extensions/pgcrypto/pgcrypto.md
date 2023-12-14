### The `pgcrypto` extension

pgcrpto
: This is extension in the PostgreSQL DBMS that provides cryptographic and hashing capabilities within the database environment. It can also be used to generate random numbers.

In order to create a five-character string in PostgreSQL, we'd need to incorporate a hashing algorithm. To do so, we first check the `pg_extension` view in PostgreSQL to ascertain whether the extension; `pgcrypto` was present. If not, then we install the extension into the schema; `brt`.

> This extension would only be local in the `brt` schema and not in any other schema, including `public`.

### Creating random characters

Once the extension is present, we can then incorporate it in a function to create a random character upon every execution.

The hashing function `md5` would be used in this case and it accepts an input (message) of type 'string'. The message itself must be random as this function creates an identical hash for every identical message. To create a random input for the function, we'd implememt the built-in `random()` function. This generates a random number (decimal) between 0 and 1 (similar to NumPy's `random.rand()` function).

Recall that md5 only accepts strings so we'd need to cast the output of `random()` to generate random numbers but in string format. Given as:

```
    md5(random()::text)
```

The output of the `md5()` function is a 32-charactered hexadecimal output of any character between `0` to `9` and `a` to `f`, which corresponds to the alphanumeric need of the `card_no` column in the `driver_identification_cards` table. Since we only need five characters, we can use a substring function to extract such. Given as:

```
    substr(md5(random()::text), 1, 5)
```
We can retrieve more than 5 characters but in this case, only 5 characters are requires.

Where `md5(random()::text)` corresponds to the string input (hash), 1 is the start position of the hash and 5 is the length of characters to be extracted from the hash.
