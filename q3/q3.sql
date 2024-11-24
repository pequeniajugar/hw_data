create table likes(person int, artist int);
create table friends(person1 int, person2 int);
COPY likes (person, artist)
FROM '/like.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');
COPY friends (person, artist)
FROM '/friends.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- Step 1: Build clustered covering index on table likes
CREATE INDEX idx_likes_person_artist ON likes(person, artist);   -- 133.055 ms
Cluster likes using idx_likes_person_artist;                       -- 329.883 ms

-- Step 2: Build a complete friend table, including bidirectional relationships
-- 1505.659 ms
CREATE TEMPORARY TABLE all_friends AS
SELECT person1 AS person, person2 AS friend FROM friends
UNION
SELECT person2 AS person, person1 AS friend FROM friends;

-- Step 3: Get the artists that each person's friends like 
-- 3216.133 ms
CREATE TEMPORARY TABLE friends_likes AS
SELECT
    af.person,
    af.friend,
    l.artist             
FROM
    all_friends af
JOIN
    likes l ON af.friend = l.person;

-- Step 4: Find artists that your friends like but you don't like
-- Use LEFT JOIN to match artists liked by friends with artists liked by the user
-- WHERE condition filters out artists that the user doesn't already like
--  4262.063 ms
SELECT
    fl.person AS u1,
    fl.friend AS u2,
    fl.artist AS a
FROM
    friends_likes fl
LEFT JOIN
   likes l ON fl.person = l.person AND fl.artist = l.artist
WHERE
l.artist IS NULL;