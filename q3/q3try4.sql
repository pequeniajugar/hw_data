-- no index

-- Step 1:  1868.365 ms
CREATE TEMPORARY TABLE all_friends AS
SELECT person1 AS person, person2 AS friend FROM friends
UNION
SELECT person2 AS person, person1 AS friend FROM friends;

-- Step 2:  3609.920 ms
CREATE TEMPORARY TABLE friends_likes AS
SELECT
    af.person,
    af.friend,
    l.artist              
FROM
    all_friends af
JOIN
    likes l ON af.friend = l.person;

-- Step 3:  5956.854ms
SELECT
fl.person,
    fl.friend,
    fl.artist
FROM
    friends_likes fl
LEFT JOIN
   likes l ON fl.person = l.person AND fl.artist = l.artist
WHERE
    l.artist IS NULL;