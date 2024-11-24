-- clustered covering index

CREATE INDEX idx_likes_person_artist ON likes(person, artist); -- 133.055ms
Cluster likes using idx_likes_person_artist; -- 329.883ms

-- Step 1:  1593.659 ms
CREATE TEMPORARY TABLE all_friends AS
SELECT person1 AS person, person2 AS friend FROM friends
UNION
SELECT person2 AS person, person1 AS friend FROM friends;

--  2068.649 ms
CREATE INDEX idx_all_friends_friend ON all_friends(friend);  
Cluster all_friends using idx_all_friends_friend; -- 5402.332 ms

-- Step 2:  3076.133 ms
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
Cluster friends_likes on idx_friends_likes_person_artist;-- 29764.872


-- Step 4: 2259.341
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