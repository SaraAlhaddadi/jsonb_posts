UPDATE books SET payload ->> 'publisher' = 'sara'
 WHERE title = 'book1';
-- ERROR:  syntax error at or near "->>"
-- LINE 1: UPDATE books SET payload ->> 'publisher' = 'sara'

-- update value
SELECT jsonb_set('[{"f1":1,"f2":null},2]', '{0,f3}','[2,3,4]');
--                   jsonb_set                  
-- ---------------------------------------------
--  [{"f1": 1, "f2": null, "f3": [2, 3, 4]}, 2]
-- (1 row)

SELECT jsonb_set('[{"f1":1,"f2":null},2]', '{0,f3}','[2,3,4]',false);
--          jsonb_set          
-- ----------------------------
--  [{"f1": 1, "f2": null}, 2]
-- (1 row)

SELECT jsonb_set('[1,2,{"f1":1,"f2":null}]', '{-1,f2}','[2,3,4]',false);
--              jsonb_set              
-- ------------------------------------
--  [1, 2, {"f1": 1, "f2": [2, 3, 4]}]
-- (1 row)

SELECT jsonb_set('[{"f1":1,"f2":null},2]', '{0}','[2,3,4]',false);
--    jsonb_set    
-- ----------------
--  [[2, 3, 4], 2]
-- (1 row)

SELECT jsonb_set(payload, '{publisher}', '"new publisher"') from books WHERE title = 'book1';
-- {"price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "new publisher", "published_date": "2017-04-07"}

UPDATE books SET payload = jsonb_set(payload, '{publisher}', '"new publisher"') WHERE title = 'book1';

SELECT payload from books  WHERE title = 'book1';

-- Replace the tags (as oppose to adding or removing tags) add tags key:
UPDATE books SET payload = jsonb_set(payload, '{tags}', '["tag3", "tag4"]') WHERE title = 'book1';
-- {"tags": ["tag3", "tag4"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "publisher1", "published_date": "2017-04-07"}

SELECT jsonb_set(payload, '{tags}', '["tag3"]') FROM books WHERE title = 'book1';
-- {"tags": ["tag3"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "publisher1", "published_date": "2017-04-07"}

-- Replacing the second tag (0-indexed):
UPDATE books SET payload = jsonb_set(payload, '{tags,1}', '"tag5"') WHERE title = 'book1';
-- {"tags": ["tag3", "tag5"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "publisher1", "published_date": "2017-04-07"}

------------------------------------------------------
SELECT '["a", "b"]'::jsonb || '["c", "d"]'::jsonb;
--        ?column?       
-- ----------------------
--  ["a", "b", "c", "d"]
-- (1 row)

SELECT '["a", "b"]'::jsonb || '["a", "d"]'::jsonb;
--        ?column?       
-- ----------------------
--  ["a", "b", "a", "d"]
-- (1 row)

SELECT '{"a":1, "b":2}'::jsonb || '{"c":3, "d":4}'::jsonb;
--              ?column?             
-- ----------------------------------
--  {"a": 1, "b": 2, "c": 3, "d": 4}
-- (1 row)

SELECT '{"a":1, "b":2}'::jsonb || '{"a":3, "d":4}'::jsonb;
--          ?column?         
-- --------------------------
--  {"a": 3, "b": 2, "d": 4}
-- (1 row)

SELECT '{"a": "b"}'::jsonb - 'a';
--  ?column? 
-- ----------
--  {}
-- (1 row)

SELECT '{"a": 1,"b":2}'::jsonb - 'c';
--      ?column?     
-- ------------------
--  {"a": 1, "b": 2}
-- (1 row)

SELECT '["a", "b"]'::jsonb - 1;
--  ?column? 
-- ----------
--  ["a"]
-- (1 row)

SELECT '["a", "b"]'::jsonb - -1;
--  ?column? 
-- ----------
--  ["a"]
-- (1 row)

SELECT '["a", "b"]'::jsonb - 'a';
--  ?column? 
-- ----------
--  ["b"]
-- (1 row)

SELECT '{"a":1, "b":2}'::jsonb - -1;
-- ERROR:  cannot delete from object using integer index

SELECT '["a", {"b":1}]'::jsonb #- '{1,b}';
--  ?column?  
-- -----------
--  ["a", {}]
-- (1 row)

SELECT '["a", {"b":1}]'::jsonb #- '{0,b}';
--     ?column?     
-- -----------------
--  ["a", {"b": 1}]
-- (1 row)

SELECT '{"1": {"b":1,"c":2}}'::jsonb #- '{1,b}';
--     ?column?     
-- -----------------
--  {"1": {"c": 2}}
-- (1 row)

-- Remove the last tag:
-- {"tags": ["tag3", "tag5"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "publisher1", "published_date": "2017-04-07"}
UPDATE books SET payload = payload #- '{tags,-1}';
-- {"tags": ["tag3"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "publisher1", "published_date": "2017-04-07"}

-- Complex update (delete the last tag, insert a new tag, and change the name or insert it if it is not there):
UPDATE books SET payload = jsonb_set(jsonb_set(payload #- '{tags,-1}', '{tags,0}', '"tag10"', true), '{name}', '"my-other-name"');
-- {"name": "my-other-name", "tags": ["tag10"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "publisher1", "published_date": "2017-04-07"}

UPDATE books SET payload = jsonb_set(payload, '{tags,1}', '"tag5"') WHERE title = 'book1';
-- {"name": "my-other-name", "tags": ["tag10", "tag5"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "publisher1", "published_date": "2017-04-07"}

UPDATE books SET payload = payload || '{"a": "apple"}' WHERE title = 'book1';
-- {"a": "apple", "name": "my-other-name", "tags": ["tag10", "tag5"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "new publisher", "published_date": "2017-04-07"}

SELECT payload - 'a' from books  WHERE title = 'book1';
-- {"name": "my-other-name", "tags": ["tag10", "tag5"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "new publisher", "published_date": "2017-04-07"}

SELECT (payload -> 'tags') - 'tag10' from books  WHERE title = 'book1';
-- ["tag5"]

-- tags are "tags": ["tag10", "tag5"] the proives query is select not update
SELECT (payload -> 'tags') - 0 from books  WHERE title = 'book1';
-- ["tag5"]

SELECT payload  #- '{"tags",0}' from books  WHERE title = 'book1';
-- {"a": "apple", "name": "my-other-name", "tags": ["tag5"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "new publisher", "published_date": "2017-04-07"}

SELECT payload  #- '{"authors",0,"name"}' from books  WHERE title = 'book1';
-- {"a": "apple", "name": "my-other-name", "tags": ["tag10", "tag5"], "price": 100, "authors": [{"id": 1}, {"id": 2, "name": "author2"}], "publisher": "new publisher", "published_date": "2017-04-07"}

-- no error if key is not found
SELECT payload  #- '{"authors",0,"age"}' from books  WHERE title = 'book1';
-- {"a": "apple", "name": "my-other-name", "tags": ["tag10", "tag5"], "price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}], "publisher": "new publisher", "published_date": "2017-04-07"}
