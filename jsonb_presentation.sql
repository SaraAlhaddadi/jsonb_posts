SELECT '{"c":0,   "a":2,"a":1,"d":3,"b":5}'::json, '{"c":0,   "a":2,"a":1,"d":"3","b":5}'::jsonb;
--                 json                |               jsonb                
-- ------------------------------------+------------------------------------
--  {"c":0,   "a":2,"a":1,"d":3,"b":5} | {"a": 1, "b": 5, "c": 0, "d": "3"}
-- (1 row)


-- JSON Primitive Types ---
----------------------- jsonb string ---------------------------
select E'\u0001' as value;
--  value 
-- -------
--  \x01
-- (1 row)

select E'\u0000' as value;
-- ERROR:  invalid Unicode escape value at or near "E'\u0000"
-- LINE 1: select E'\u0000' as value;

SELECT '1234\u0000';
--   ?column?  
-- ------------
--  1234\u0000
-- (1 row)

SELECT E'My star \u2B50';
--  ?column?  
-- -----------
--  My star ⭐
-- (1 row)

SELECT E'1234\u0000';
-- ERROR:  invalid Unicode escape value at or near "E'1234\u0000"
-- LINE 1: SELECT E'1234\u0000';

SELECT '"1234\u0000"'::jsonb;
-- ERROR:  unsupported Unicode escape sequence
-- LINE 1: SELECT '"1234\u0000"'::jsonb;
--                ^
-- DETAIL:  \u0000 cannot be converted to text.
-- CONTEXT:  JSON data, line 1: ...

SELECT '"My face \u2B50"'::jsonb;
--     jsonb    
-- -------------
--  "My face ⭐"
-- (1 row)

----------------------- jsonb number ---------------------------
SELECT jsonb_typeof('1'::jsonb);
--  jsonb_typeof 
-- --------------
--  number
-- (1 row)

SELECT jsonb_typeof('-1'::jsonb);
--  jsonb_typeof 
-- --------------
--  number
-- (1 row)

-- NaN (not a number) value is used to represent undefined calculational results
select 'infinity'::float / 'infinity'::float;
--  ?column? 
-- ----------
--       NaN
-- (1 row)

SELECT jsonb_typeof('inf'::jsonb);
-- ERROR:  invalid input syntax for type json
-- LINE 1: SELECT jsonb_typeof('inf'::jsonb);
--                             ^
-- DETAIL:  Token "inf" is invalid.
-- CONTEXT:  JSON data, line 1: inf

SELECT jsonb_typeof('-inf'::jsonb);
-- ERROR:  invalid input syntax for type json
-- LINE 1: SELECT jsonb_typeof('-inf'::jsonb);
--                             ^
-- DETAIL:  Token "-inf" is invalid.
-- CONTEXT:  JSON data, line 1: -inf


SELECT jsonb_typeof('NAN'::jsonb);
-- ERROR:  invalid input syntax for type json
-- LINE 1: SELECT jsonb_typeof('NAN'::jsonb);
--                             ^
-- DETAIL:  Token "NAN" is invalid.
-- CONTEXT:  JSON data, line 1: NAN

----------------------- jsonb boolean ---------------------------

SELECT 'true'::jsonb;
--  jsonb 
-- -------
--  true
-- (1 row)

SELECT jsonb_typeof('true'::jsonb);
--  jsonb_typeof 
-- --------------
--  boolean
-- (1 row)

SELECT jsonb_typeof('false'::jsonb);
--  jsonb_typeof 
-- --------------
--  boolean
-- (1 row)

SELECT jsonb_typeof('False'::jsonb);
-- ERROR:  invalid input syntax for type json
-- LINE 1: SELECT jsonb_typeof('False'::jsonb);
--                             ^
-- DETAIL:  Token "False" is invalid.
-- CONTEXT:  JSON data, line 1: False

SELECT jsonb_typeof('True'::jsonb);
-- ERROR:  invalid input syntax for type json
-- LINE 1: SELECT jsonb_typeof('True'::jsonb);
--                             ^
-- DETAIL:  Token "True" is invalid.
-- CONTEXT:  JSON data, line 1: True

SELECT jsonb_typeof('"True"'::jsonb);
--  jsonb_typeof 
-- --------------
--  string
-- (1 row)

----------------------- null and Null in jsonb and postgres---------------------------

select '{"a": 1, "b": null}'::jsonb->'c';
--  ?column? 
-- ----------
 
-- (1 row)

select '{"a": 1, "b": null}'::jsonb->'b';
--  ?column? 
-- ----------
--  null
-- (1 row)

select '{"a": 1, "b": null}'::jsonb->'b' IS NULL;
--  ?column? 
-- ----------
--  f
-- (1 row)

select '{"a": 1, "b": null}'::jsonb->'c' IS NULL;
--  ?column? 
-- ----------
--  t
-- (1 row)

select '{"a": 1, "b": null}'::jsonb->>'b' IS Null;
--  ?column? 
-- ----------
--  t
-- (1 row)

select '{"a": 1, "b": null}'::jsonb->>'c' IS Null;
--  ?column? 
-- ----------
--  t
-- (1 row)

-- explain from PostgreSQL
-- One of the design principles of PostgreSQL, however, 
-- is that casting anything to text should give something parsable back to the original value (whenever possible).
select '{"a": 1, "b": null}'::jsonb->>'b';
--  ?column? 
-- ----------
 
-- (1 row)

select '{"a": 1, "b": "null"}'::jsonb->>'b';
--  ?column? 
-- ----------
--  null
-- (1 row)

select pg_typeof('{"a": 1, "b": "null"}'::jsonb->>'b');
--  pg_typeof 
-- -----------
--  text
-- (1 row)

select pg_typeof('{"a": 1, "b": null}'::jsonb->>'b');
--  pg_typeof 
-- -----------
--  text
-- (1 row)
