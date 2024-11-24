-- unclustered uncovering index with likes index

CREATE INDEX idx_likes_person ON likes(person); -- 138.039 ms
CREATE INDEX idx_likes_artist ON likes(artist); -- 96.271 ms

-- Step 1:  2461.500 ms
CREATE TEMPORARY TABLE all_friends AS -- 1854.056 ms
SELECT person1 AS person, person2 AS friend FROM friends
UNION
SELECT person2 AS person, person1 AS friend FROM friends;

CREATE INDEX idx_all_friends_person ON all_friends(person);  -- 1631.388 ms
CREATE INDEX idx_all_friends_friend ON all_friends(friend); -- 1341.168 ms

-- Step 2: 6841.119 ms
CREATE TEMPORARY TABLE friends_likes AS
SELECT
    af.person,
    af.friend,
    l.artist               
FROM
    all_friends af
JOIN
    likes l ON af.friend = l.person;

CREATE INDEX idx_friends_likes_person ON friends_likes(person); -- 9314.967 ms
CREATE INDEX idx_friends_likes_artist ON friends_likes(artist); -- 7881.842 ms

-- Step 4: 5764.265 ms
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