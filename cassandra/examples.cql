DESCRIBE keyspaces;
CREATE KEYSPACE cassandra WITH REPLICATION = { 'class':'NetworkTopologyStrategy', 'datacenter1': 1 };
USE cassandra;

-- Simple Primary Key
CREATE TABLE cyclist_name (id UUID PRIMARY KEY, lastname text, firstname text);

-- Tombstones
CREATE TABLE todo_by_user_email (user_email text, name text, creation_date timestamp, PRIMARY KEY ((user_email), creation_date));
INSERT INTO todo_by_user_email (user_email, creation_date, name) VALUES('john@email.com', toTimestamp(now()), 'This entry should be removed soon') USING TTL 60;
SELECT * FROM todo_by_user_email WHERE user_email='john@email.com';

/*

Expected Response

 user_email     | creation_date | name
----------------+---------------+--------------------
 john@email.com | 2022-05-06... | This entry should be removed soon

*/

SELECT TTL(name) FROM todo_by_user_email WHERE user_email='john@email.com';

/*

Expected Response
```
 ttl(name)
-----------
        43

*/

-- UPDATE equals INSERT
INSERT INTO todo_by_user_email (user_email, creation_date, name) VALUES('john@email.com', '2022-05-05 16:07:19.622+0000', 'Insert query');
UPDATE todo_by_user_email SET name = 'Update query' WHERE user_email = 'john@email.com' AND creation_date = '2022-05-05 16:10:19.622+0000';
INSERT INTO todo_by_user_email (user_email, creation_date, name) VALUES('john@email.com', '2022-05-05 16:07:19.622+0000', 'Insert query updated');
SELECT * FROM todo_by_user_email WHERE user_email='john@email.com';

/*

Expected Response

 user_email     | creation_date            | name
----------------+--------------------------+----------------------
 john@email.com | 2022-05-05 16:10:19.62   |         Update query
 john@email.com | 2022-05-05 16:07:19.62   | Insert query updated

*/

-- Lightweight Transactions
UPDATE todo_by_user_email SET name = 'Update query with LWT' WHERE user_email = 'john@email.com' AND creation_date = '2022-05-05 16:07:19.622+0000' IF EXISTS;
INSERT INTO todo_by_user_email (user_email, creation_date, name) VALUES('john@email.com', toTimestamp(now()), 'Yet another entry') IF NOT EXISTS;

-- User-defined Functions (UDFs)

/*

CREATE [OR REPLACE] FUNCTION [IF NOT EXISTS] 
  [keyspace_name.]function_name ( 
      var_name var_type [,...] )
  [CALLED | RETURNS NULL] ON NULL INPUT 
  RETURNS cql_data_type 
  LANGUAGE language_name AS 
  'code_block’;

*/

CREATE OR REPLACE FUNCTION 
  fLog (input double) 
  CALLED ON NULL INPUT 
  RETURNS double 
  LANGUAGE java AS
  'return Double.valueOf(Math.log(input.doubleValue()));';

-- Materialized Views
-- Base Table
CREATE TABLE cc_transactions (
  userid text, 
  year int, 
  month int, 
  day int, 
  id int, 
  amount int, 
  card text, 
  status text, 
  PRIMARY KEY ((userid, year), month, day, id)
);

-- Materialized View
CREATE MATERIALIZED VIEW transactions_by_day AS
    SELECT year, month, day, userid, id, amount, card, status
    FROM cc_transactions
    WHERE userid IS NOT NULL 
     AND year IS NOT NULL 
     AND month IS NOT NULL 
     AND day IS NOT NULL 
     AND id IS NOT NULL 
     AND card IS NOT NULL
    PRIMARY KEY ((year, month, day), userid, id);

INSERT INTO cc_transactions (userid, year, month, day, id, card, amount, status) VALUES ('John', 2022, 2, 6, 1, '1111-1111-1111-1111', -10, 'COMPLETED');
INSERT INTO cc_transactions (userid, year, month, day, id, card, amount, status) VALUES ('John', 2022, 2, 6, 2, '1111-1111-1111-1111', 20, 'PENDING');
INSERT INTO cc_transactions (userid, year, month, day, id, card, amount, status) VALUES ('Bob', 2022, 2, 6, 3, '2222-2222-2222-2222', -17, 'COMPLETED');
INSERT INTO cc_transactions (userid, year, month, day, id, card, amount, status) VALUES ('Bob', 2022, 2, 7, 4, '2222-2222-2222-2222', -32, 'COMPLETED');

SELECT * FROM cc_transactions WHERE userid = 'John' and year = 2022;
SELECT * FROM transactions_by_day WHERE year = 2022 and month = 2 and day = 6;

-- # Deleting & Updating
SELECT * FROM cc_transactions WHERE userid = 'Bob' and year = 2022;

/*

Expected Response

 userid | year | month | day | id | amount | card                | status
--------+------+-------+-----+----+--------+---------------------+-----------
    Bob | 2022 |     2 |   6 |  3 |    -17 | 2222-2222-2222-2222 | COMPLETED
    Bob | 2022 |     2 |   7 |  4 |    -32 | 2222-2222-2222-2222 | COMPLETED
    Bob | 2022 |     2 |   7 |  5 |   1200 | 2222-2222-2222-2222 | COMPLETED

*/

SELECT * FROM transactions_by_day WHERE year = 2022 and month = 2 and day = 7;

/*

Expected Response

 year | month | day | userid | id | amount | card                | status
------+-------+-----+--------+----+--------+---------------------+-----------
 2022 |     2 |   7 |    Bob |  4 |    -32 | 2222-2222-2222-2222 | COMPLETED
 2022 |     2 |   7 |    Bob |  5 |   1200 | 2222-2222-2222-2222 | COMPLETED

*/

UPDATE cc_transactions SET status = 'PENDING' WHERE userid = 'Bob' AND year = 2022 AND month = 2 AND day = 7 AND id = 5;
DELETE FROM cc_transactions WHERE userid = 'Bob' AND year = 2022 AND month = 2 AND day = 7 AND id = 4;
SELECT * FROM cc_transactions WHERE userid = 'Bob' AND year = 2022;

/*

Expected Response

 userid | year | month | day | id | amount | card                | status
--------+------+-------+-----+----+--------+---------------------+-----------
    Bob | 2022 |     2 |   6 |  3 |    -17 | 2222-2222-2222-2222 | COMPLETED
    Bob | 2022 |     2 |   7 |  5 |   1200 | 2222-2222-2222-2222 |   PENDING

*/

SELECT * FROM transactions_by_day WHERE year = 2022 AND month = 2 AND day = 7;

/*

Expected Response

 year | month | day | userid | id | amount | card                | status
------+-------+-----+--------+----+--------+---------------------+---------
 2022 |     2 |   7 |    Bob |  5 |   1200 | 2222-2222-2222-2222 | PENDING

*/
