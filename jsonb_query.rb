# SELECT id, (payload->>'published_date')::date FROM books;

INSERT INTO books (title, payload,created_at,updated_at) VALUES ('book12','{"price": 100, "authors": [{"id": 1, "name": "author1"}, {"id": 2, "name": "author2"}],
     "publisher": "publisher1", "published_date": "2017-15-07"}', '2022-15-05 19:55:21.364624', '2022-05-05 19:55:21.364624');

Book.select("(payload->>'published_date')::date AS published_date").map(&:published_date)

Book.create!({
  title: 'book11',
  payload: {'publisher' => 'publisher1',
             'published_date' => '2017-15-07'}})

# ---------------------------- query 1 ----------------------------

Book.select("payload -> 'authors' -> 1 AS author").map(&:author)
#   Book Load (0.5ms)  SELECT payload -> 'authors' -> 1 AS author FROM "books"
#  => [nil, {"id"=>2, "name"=>"Morgan Brown"}, {"id"=>3, "name"=>"Morgan Browns"}]

Book.select("payload -> 'authors' ->> 1 AS author").map(&:author)
#   Book Load (0.6ms)  SELECT payload -> 'authors' ->> 1 AS author FROM "books"
#  => [nil, "{\"id\": 2, \"name\": \"Morgan Brown\"}", "{\"id\": 3, \"name\": \"Morgan Browns\"}"]

SELECT jsonb_typeof(payload -> 'authors' -> 1) AS author FROM "books" Where id = 20;
#  author 
# --------
#  object
# (1 row)
SELECT pg_typeof(payload -> 'authors' ->> 1) AS author FROM "books" Where id = 20;
#  author 
# --------
#  text
# (1 row)

SELECT payload ->> 'authors' -> 1 AS author FROM "books" Where id = 20;
# ERROR:  operator does not exist: text -> integer
# LINE 1: SELECT payload ->> 'authors' -> 1 AS author FROM "books" Whe...
#                                      ^
# HINT:  No operator matches the given name and argument types. You might need to add explicit type casts.

SELECT payload -> 'publisher' AS publisher FROM "books" Where id = 20;
#     publisher    
# -----------------
#  "new publisher"
# (1 row)

SELECT payload ->> 'publisher' AS publisher FROM "books" Where id = 20;
#    publisher   
# ---------------
#  new publisher
# (1 row)

Book.select("payload ->> 'publisher' AS publisher").map(&:publisher)
#   Book Load (0.5ms)  SELECT payload ->> 'publisher' AS publisher FROM "books"
#  => [nil, "Currency", "Currency2"]

# it is like Book.select("payload -> 'authors' -> 1 AS author").map(&:author)
Book.select("payload #> '{authors, 1}' AS author").map(&:author)
#   Book Load (0.6ms)  SELECT payload #> '{authors, 1}' AS author FROM "books"
#  => [nil, {"id"=>2, "name"=>"Morgan Brown"}, {"id"=>3, "name"=>"Morgan Browns"}] 

Book.select("payload #>> '{authors, 1,name}' AS author_name").map(&:author_name)
#   Book Load (0.6ms)  SELECT payload #>> '{authors, 1,name}' AS author_name FROM "books"
#  => [nil, "Morgan Brown", "Morgan Browns"] 

# Matches where 'Book' contains 'publisher': 'Currency'
Book.where("payload ->> 'publisher' = :publisher", publisher: 'Currency')
#   Book Load (0.6ms)  SELECT "books".* FROM "books" WHERE (payload ->> 'publisher' = 'Currency')
#  => 
# [#<Book:0x00007fb7f400b6e0
#   id: 2,
#   title: "book1",
#   payload:
#    {"authors"=>[{"id"=>1, "name"=>"Sean Ellis"}, {"id"=>2, "name"=>"Morgan Brown"}],
#     "publisher"=>"Currency",
#     "published_date"=>"2017-04-07"},
#   created_at: Tue, 05 Apr 2022 21:14:09.735881000 UTC +00:00,
#   updated_at: Tue, 05 Apr 2022 21:14:09.735881000 UTC +00:00>]

# ---------------------------- query 2 ----------------------------

SELECT '{"a":1, "b":2}'::jsonb @> '{"b":2}'::jsonb ;
#  ?column? 
# ----------
#  t
# (1 row)

SELECT '{"a":1, "b":2}'::jsonb @> '{"b":3}'::jsonb ;
#  ?column? 
# ----------
#  f
# (1 row)

SELECT '{"a":1, "b":2}'::jsonb @> '{"c":3}'::jsonb ;
#  ?column? 
# ----------
#  f
# (1 row)

SELECT '{"a":1, "b":2}'::jsonb @> '{"b":2,"a":5}'::jsonb ;
#  ?column? 
# ----------
#  f
# (1 row)

Book.where("payload @> ?", { publisher: 'Currency' }.to_json)
#   Book Load (0.5ms)  SELECT "books".* FROM "books" WHERE (payload @> '{"publisher":"Currency"}')
#  => 
# [#<Book:0x000055c1785def50
#   id: 2,
#   title: "book1",
#   payload:
#    {"authors"=>[{"id"=>1, "name"=>"Sean Ellis"}, {"id"=>2, "name"=>"Morgan Brown"}],
#     "publisher"=>"Currency",
#     "published_date"=>"2017-04-07"},
#   created_at: Tue, 05 Apr 2022 21:14:09.735881000 UTC +00:00,
#   updated_at: Tue, 05 Apr 2022 21:14:09.735881000 UTC +00:00>]

Book.where("? <@ payload", { publisher: 'Currency' }.to_json)
#   Book Load (0.5ms)  SELECT "books".* FROM "books" WHERE ('{"publisher":"Currency"}' <@ payload)
#  => 
# [#<Book:0x00007fb80cd85218
#   id: 2,
#   title: "book1",
#   payload:
#    {"authors"=>[{"id"=>1, "name"=>"Sean Ellis"}, {"id"=>2, "name"=>"Morgan Brown"}],
#     "publisher"=>"Currency",
#     "published_date"=>"2017-04-07"},
#   created_at: Tue, 05 Apr 2022 21:14:09.735881000 UTC +00:00,
#   updated_at: Tue, 05 Apr 2022 21:14:09.735881000 UTC +00:00>]

Book.where("? <@ payload", { publisher: nil }.to_json)
#   Book Load (0.5ms)  SELECT "books".* FROM "books" WHERE ('{"publisher":null}' <@ payload)
#  => 
#   id: 1,
#   title: "book1",
#   payload: {"publisher"=>nil},
#   updated_at: Tue, 05 Apr 2022 23:20:11.788982000 UTC +00:00>]

Book.where("payload -> 'authors' -> 1 = ?",{"id"=>2, "name"=>"Morgan Brown"}.to_json)
#   Book Load (0.7ms)  SELECT "books".* FROM "books" WHERE (payload -> 'authors' -> 1 = '{"id":2,"name":"Morgan Brown"}')
#  => 
# [#<Book:0x000055c178858948
#   id: 2,
#   title: "book1",
#   payload:
#    {"authors"=>[{"id"=>1, "name"=>"Sean Ellis"}, {"id"=>2, "name"=>"Morgan Brown"}],
#     "publisher"=>"Currency",
#     "published_date"=>"2017-04-07"},
#   created_at: Tue, 05 Apr 2022 21:14:09.735881000 UTC +00:00,
#   updated_at: Tue, 05 Apr 2022 21:14:09.735881000 UTC +00:00>]

# we did not have key 0 index should be integer
Book.where("payload -> 'authors' -> '0' ->> 'name' = :name", name: 'author1')
#  => []
Book.where("payload -> 'authors' -> 0 ->> 'name' = :name", name: 'author1')
  # Book Load (0.6ms)  SELECT "books".* FROM "books" WHERE (payload -> 'authors' -> 0 ->> 'name' = 'author1')
#  => 
# [#<Book:0x000055b6f13b8528
#   id: 22,
#   title: "book3",
#   payload:
#    {"price"=>170, "authors"=>[{"id"=>1, "name"=>"author1"}, {"id"=>3, "name"=>"author3"}], "publisher"=>"publisher2", "published_date"=>"2018-04-07"},
#   created_at: Sat, 07 May 2022 18:44:33.087149000 UTC +00:00,
#   updated_at: Sat, 07 May 2022 18:44:33.087149000 UTC +00:00>,
#  #<Book:0x000055b6f13b8438
#   id: 20,
#   title: "book1",
#   payload:
#    {"tags"=>["tag3"],
#     "price"=>100,
#     "authors"=>[{"id"=>1, "name"=>"author1"}, {"id"=>2, "name"=>"author2"}],
#     "publisher"=>"new publisher",
#     "published_date"=>"2017-04-07"},
#   created_at: Sat, 07 May 2022 18:44:33.055553000 UTC +00:00,
#   updated_at: Sat, 07 May 2022 18:44:33.055553000 UTC +00:00>]

Book.where("payload #>> '{authors,0,name}' = :name", name: 'author1')
Book.where("payload -> 'authors' -> 0 @> :val", val: { name: 'author1' }.to_json)

Book.where("payload = :val", val: {})
#   Book Load (0.4ms)  SELECT "books".* FROM "books" WHERE (payload = NULL)
#  => [] 
SELECT "books".* FROM "books" WHERE (payload = '{}');
#  id | title | payload |         created_at         |         updated_at         
# ----+-------+---------+----------------------------+----------------------------
#  35 | book5 | {}      | 2022-06-11 18:30:03.332863 | 2022-06-11 18:30:03.332863
# (1 row)
Book.where("payload = :val", val: {}.to_json)
#   Book Load (0.4ms)  SELECT "books".* FROM "books" WHERE (payload = '{}')
#  => 
# [#<Book:0x000055b6eec4f428
#   id: 35,
#   title: "book5",
#   payload: {},
#   created_at: Sat, 11 Jun 2022 18:30:03.332863000 UTC +00:00,
#   updated_at: Sat, 11 Jun 2022 18:30:03.332863000 UTC +00:00>] 

# ---------------------------- query 3 ----------------------------
SELECT '{"a":1, "b":2, "c":3}'::jsonb ? 'd';
#  ?column? 
# ----------
#  f
# (1 row)

SELECT '{"a":1, "b":2, "c":3}'::jsonb ? 'a';
#  ?column? 
# ----------
#  t
# (1 row)

SELECT '["a", "b"]'::jsonb ? 'a';
#  ?column? 
# ----------
#  t
# (1 row)

SELECT '["a", "b"]'::jsonb ? 'c';
#  ?column? 
# ----------
#  f
# (1 row)

SELECT '{"a":1, "b":2, "c":3}'::jsonb ?| array['b', 'c'];
#  ?column? 
# ----------
#  t
# (1 row)

SELECT '{"a":1, "b":2, "c":3}'::jsonb ?| array['a', 'd'];
#  ?column? 
# ----------
#  t
# (1 row)

SELECT '{"a":1, "b":2, "c":3}'::jsonb ?| array['f', 'd'];
#  ?column? 
# ----------
#  f
# (1 row)

SELECT '["a", "b"]'::jsonb ?| array['a', 'b'];
#  ?column? 
# ----------
#  t
# (1 row)

SELECT '["a", "b"]'::jsonb ?| array['a', 'c'];
#  ?column? 
# ----------
#  t
# (1 row)

SELECT '["a", "b"]'::jsonb ?| array['c', 'f'];
#  ?column? 
# ----------
#  f
# (1 row)

SELECT '{"a":1, "b":2, "c":3}'::jsonb ?& array['b', 'c'];
#  ?column? 
# ----------
#  t
# (1 row)

SELECT '{"a":1, "b":2, "c":3}'::jsonb ?& array['b', 'f'];
#  ?column? 
# ----------
#  f
# (1 row)

SELECT '{"a":1, "b":2, "c":3}'::jsonb ?& array['d', 'f'];
#  ?column? 
# ----------
#  f
# (1 row)

SELECT '["a", "b"]'::jsonb ?& array['a', 'b'];
#  ?column? 
# ----------
#  t
# (1 row)

SELECT '["a", "b"]'::jsonb ?& array['a', 'c'];
#  ?column? 
# ----------
#  f
# (1 row)

SELECT '["a", "b"]'::jsonb ?& array['d', 'c'];
#  ?column? 
# ----------
#  f
# (1 row)

Book.where("payload ? :key", key: 'authors').count
#    (0.5ms)  SELECT COUNT(*) FROM "books" WHERE (payload ? 'authors')
#  => 2 

Book.where("payload ?| array[:keys]", keys: ['authors','publisher']).count
#    (0.7ms)  SELECT COUNT(*) FROM "books" WHERE (payload ?| array['authors','publisher'])
#  => 3

Book.where("payload ?& array[:keys]", keys: ['authors','publisher']).count
#    (0.6ms)  SELECT COUNT(*) FROM "books" WHERE (payload ?&array['authors','publisher'])
#  => 2

# ---------------------------- query 4 ----------------------------

Book.where("(payload #>> '{authors,0,id}')::int = :val", val: 1).count
#    (0.6ms)  SELECT COUNT(*) FROM "books" WHERE ((payload #>> '{authors,0,id}')::int = 1)
#  => 2

# ---------------------------- aggregate functions ----------------------------

SELECT
   MIN (CAST (payload ->> 'price' AS INTEGER)),
   MAX (CAST (payload ->> 'price' AS INTEGER)),
   SUM (CAST (payload ->> 'price' AS INTEGER)),
   AVG (CAST (payload ->> 'price' AS INTEGER))
FROM books;
# min | max | sum |         avg          
# -----+-----+-----+----------------------
#  100 | 200 | 940 | 156.6666666666666667
# (1 row)

SELECT
   MIN (CAST (payload ->> 'price' AS INTEGER)),
   MAX (CAST (payload ->> 'price' AS INTEGER)),
   SUM (CAST (payload ->> 'price' AS INTEGER)),
   AVG (CAST (payload ->> 'price' AS INTEGER))
FROM books
GROUP BY payload ->> 'publisher';
# first row is null
# min | max | sum |         avg          
# -----+-----+-----+----------------------
#      |     |     |                     
#  100 | 100 | 100 | 100.0000000000000000
#  100 | 100 | 100 | 100.0000000000000000
#  170 | 200 | 740 | 185.0000000000000000
# (4 rows)

Book.minimum("CAST (payload ->> 'price' AS INTEGER)")
#  (0.6ms)  SELECT MIN(CAST (payload ->> 'price' AS INTEGER)) FROM "books"
#  => 100

Book.group("payload ->> 'publisher'").maximum("CAST (payload ->> 'price' AS INTEGER)")
#    (0.6ms)  SELECT MAX(CAST (payload ->> 'price' AS INTEGER)) AS maximum_cast_payload_price_as_integer, payload ->> 'publisher' AS payload_publisher FROM "books" GROUP BY payload ->> 'publisher'
#  => {nil=>nil, "publisher1"=>100, "publisher2"=>200}

Book.group("payload ->> 'publisher'").sum("CAST (payload ->> 'price' AS INTEGER)")
#    (0.8ms)  SELECT SUM(CAST (payload ->> 'price' AS INTEGER)) AS sum_cast_payload_price_as_integer, payload ->> 'publisher' AS payload_publisher FROM "books" GROUP BY payload ->> 'publisher'
#  => {nil=>0, "publisher1"=>100, "publisher2"=>370}

Book.group("payload ->> 'publisher'").average("CAST (payload ->> 'price' AS INTEGER)")
#    (0.5ms)  SELECT AVG(CAST (payload ->> 'price' AS INTEGER)) AS average_cast_payload_price_as_integer, payload ->> 'publisher' AS payload_publisher FROM "books" GROUP BY payload ->> 'publisher'
#  => {nil=>nil, "publisher1"=>0.1e3, "publisher2"=>0.185e3}
