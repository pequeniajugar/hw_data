-- unclustered covering index

CREATE INDEX idx_likes_person_artist ON likes(person, artist); -- 177.055ms

-- Step 1: 1981.242 ms
CREATE TEMPORARY TABLE all_friends AS
SELECT person1 AS person, person2 AS friend FROM friends
UNION
SELECT person2 AS person, person1 AS friend FROM friends;

-- 2304.649 ms
CREATE INDEX idx_all_friends_friend ON all_friends(friend);  

-- Step 2: 9840.502 ms
CREATE TEMPORARY TABLE friends_likes AS
SELECT
    af.person,
    af.friend,
    l.artist             
FROM
    all_friends af
JOIN
    likes l ON af.friend = l.person;

CREATE INDEX idx_friends_likes_person_artist ON friends_likes(person, artist); -- 10989.931 ms


-- Step 4: 20801.203
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