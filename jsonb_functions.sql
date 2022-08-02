-- JSONB functions
SELECT title,jsonb_array_length(payload -> 'authors') FROM books;

-- title | jsonb_array_length 
-- -------+--------------------
--  book1 |                  2
--  book2 |                  2
--  book3 |                  2
--  book4 |                  0

SELECT jsonb_each (payload)
FROM books;

-- jsonb_each                                      
-- --------------------------------------------------------------------------------------
--  (price,100)
--  (authors,"[{""id"": 1, ""name"": ""author1""}, {""id"": 2, ""name"": ""author2""}]") 
--  (publisher,"""publisher1""")
--  (,"""2017-04-07""")
--  (price,200)
--  (authors,"[{""id"": 4, ""name"": ""author4""}, {""id"": 2, ""name"": ""author2""}]")
--  (publisher,"""publisher2""")
--  (published_date,"""2017-04-07""")
--  (price,170)
--  (authors,"[{""id"": 1, ""name"": ""author1""}, {""id"": 3, ""name"": ""author3""}]")
--  (publisher,"""publisher2""")
--  (published_date,"""2018-04-07""")
--  (authors,[])
-- (13 rows)

SELECT key, value
FROM books,jsonb_each (books.payload) WHERE id = '20';
--       key       |                            value                             
-- ----------------+--------------------------------------------------------------
--  tags           | ["tag3"]
--  price          | 100
--  authors        | [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}]
--  publisher      | "new publisher"
--  published_date | "2017-04-07"
-- (5 rows)

-- get and convert value to text not jsonb type
SELECT key, value
FROM books,jsonb_each_text (books.payload) WHERE id = '20';
--       key       |                            value                             
-- ----------------+--------------------------------------------------------------
--  tags           | ["tag3"]
--  price          | 100
--  authors        | [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}]
--  publisher      | new publisher
--  published_date | 2017-04-07
-- (5 rows)

-- 1 => first author
SELECT id , title , jsonb_extract_path_text(payload , 'authors','1','name') AS first_author ,jsonb_extract_path(payload , 'publisher') AS publisher FROM books;
--  id | title | first_author |  publisher   
-- ----+-------+--------------+--------------
--   9 | book1 | author2      | "publisher1"
--  10 | book2 | author2      | "publisher2"
--  11 | book3 | author3      | "publisher2"
--  12 | book4 |              | 

SELECT jsonb_object_keys (payload)
FROM books WHERE id=20;
--  jsonb_object_keys 
-- -------------------
--  tags
--  price
--  authors
--  publisher
--  published_date
-- (5 rows)

SELECT jsonb_array_elements(books.payload -> 'authors') AS authors FROM books WHERE id = 20;
--            authors            
-- ------------------------------
--  {"id": 1, "name": "author1"}
--  {"id": 2, "name": "author2"}
-- (2 rows)

SELECT authors.* FROM books, jsonb_array_elements_text(books.payload -> 'authors') AS authors;
--             value             
-- ------------------------------
--  {"id": 1, "name": "author1"}
--  {"id": 2, "name": "author2"}
--  {"id": 4, "name": "author4"}
--  {"id": 2, "name": "author2"}
--  {"id": 1, "name": "author1"}
--  {"id": 3, "name": "author3"}
-- (6 rows)

--  I rename it as payload to make it easy to show and work with them
Book.select("id,jsonb_array_elements(payload -> 'authors') AS payload")


Book.select("id,jsonb_array_elements(payload -> 'authors') AS payload").limit(2).offset(2)
-- Book Load (0.7ms)  SELECT id,jsonb_array_elements(payload -> 'authors') AS payload FROM "books"
--  => 
-- [#<Book:0x000055b6f0f38048 id: 21, payload: {"id"=>4, "name"=>"author4"}>,
--  #<Book:0x000055b6f0f33f48 id: 21, payload: {"id"=>2, "name"=>"author2"}>,
--  #<Book:0x000055b6f0f33e80 id: 22, payload: {"id"=>1, "name"=>"author1"}>,
--  #<Book:0x000055b6f0f33db8 id: 22, payload: {"id"=>3, "name"=>"author3"}>,
--  #<Book:0x000055b6f0f33cf0 id: 32, payload: {"id"=>4, "name"=>"author4"}>,
--  #<Book:0x000055b6f0f33c28 id: 32, payload: {"id"=>2, "name"=>"author2"}>,
--  #<Book:0x000055b6f0f33b60 id: 33, payload: {"id"=>1, "name"=>"author1"}>,
--  #<Book:0x000055b6f0f33a98 id: 33, payload: {"id"=>3, "name"=>"author3"}>,
--  #<Book:0x000055b6f0f339d0 id: 20, payload: {"id"=>1, "name"=>"author1"}>,
--  #<Book:0x000055b6f0f33908 id: 20, payload: {"id"=>2, "name"=>"author2"}>,
--  #<Book:0x000055b6f0f33840 id: 31, payload: {"id"=>1, "name"=>"author1"}>,
--  #<Book:0x000055b6f0f33778 id: 31, payload: {"id"=>2, "name"=>"author2"}>]

SELECT key,jsonb_typeof(value)
FROM books,jsonb_each(books.payload) 
WHERE title = 'book1';
--       key       | jsonb_typeof 
-- ----------------+--------------
--  price          | number
--  authors        | array
--  publisher      | string
--  published_date | string

-- it is not jsonb_type it is pg type => text
SELECT key,pg_typeof(value)
FROM books,jsonb_each_text(books.payload)
WHERE title = 'book1';
--       key       | pg_typeof 
-- ----------------+-----------
--  price          | text
--  authors        | text
--  publisher      | text
--  published_date | text

-- from key/value
SELECT * FROM json_object('{{a,1},{b,"book"},{c,3.2}}');
--               json_object               
-- ----------------------------------------
--  {"a" : "1", "b" : "book", "c" : "3.2"}

-- from keys and values array
SELECT * FROM json_object('{a,b,c}','{1,"book",3.2}');
--               json_object               
-- ----------------------------------------
--  {"a" : "1", "b" : "book", "c" : "3.2"}

SELECT payload_table.* FROM books,jsonb_to_record(books.payload) AS payload_table(price int, authors jsonb[], publisher text , published_date date);
--  price |                                   authors                                   | publisher  | published_date 
-- -------+-----------------------------------------------------------------------------+------------+----------------
--    100 | {"{\"id\": 1, \"name\": \"author1\"}","{\"id\": 2, \"name\": \"author2\"}"} | publisher1 | 2017-04-07
--    200 | {"{\"id\": 4, \"name\": \"author4\"}","{\"id\": 2, \"name\": \"author2\"}"} | publisher2 | 2017-04-07
--    170 | {"{\"id\": 1, \"name\": \"author1\"}","{\"id\": 3, \"name\": \"author3\"}"} | publisher2 | 2018-04-07
--        | {}                                                                          |            | 
-- (4 rows)

SELECT payload_table.* FROM books,jsonb_to_record(books.payload) AS payload_table(price int, authors jsonb[], publisher text , published_date date);
-- ERROR:  date/time field value out of range: "2017-15-07"
-- HINT:  Perhaps you need a different "datestyle" setting.

SELECT DISTINCT authors.* FROM books,jsonb_to_recordset(books.payload -> 'authors') AS authors(id int, name text) ORDER BY id;
--  id |  name   
-- ----+---------
--   1 | author1
--   2 | author2
--   3 | author3
--   4 | author4
-- (4 rows)

-- Table to josn
SELECT id,title FROM books;
SELECT row_to_json(t) FROM (SELECT id,title FROM books) AS t;
--        row_to_json        
-- --------------------------
--  {"id":5,"title":"book1"}
--  {"id":6,"title":"book2"}
--  {"id":7,"title":"book3"}
--  {"id":8,"title":"book4"}
-- (4 rows)

SELECT array_agg(t) FROM (SELECT id,title FROM books) AS t;
--                      array_agg                     
-- ---------------------------------------------------
--  {"(5,book1)","(6,book2)","(7,book3)","(8,book4)"}
-- (1 row)

SELECT array_to_json(array_agg(t)) FROM (SELECT id,title FROM books) AS t;
--                                              array_to_json                                             
-- -------------------------------------------------------------------------------------------------------
--  [{"id":5,"title":"book1"},{"id":6,"title":"book2"},{"id":7,"title":"book3"},{"id":8,"title":"book4"}]
-- (1 row)

-- pretty print
SELECT array_to_json(array_agg(t), true) FROM (SELECT id,title FROM books) AS t;
--        array_to_json        
-- ----------------------------
--  [{"id":5,"title":"book1"},+
--   {"id":6,"title":"book2"},+
--   {"id":7,"title":"book3"},+
--   {"id":8,"title":"book4"}]
-- (1 row)
