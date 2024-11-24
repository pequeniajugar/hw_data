-- unclustered uncovering index
-- Step 1:  2461.500 ms
CREATE TEMPORARY TABLE all_friends AS
SELECT person1 AS person, person2 AS friend FROM friends
UNION
SELECT person2 AS person, person1 AS friend FROM friends;

CREATE INDEX idx_all_friends_person ON all_friends(person);  -- 1827.092 ms
CREATE INDEX idx_all_friends_friend ON all_friends(friend);  -- 1404.495 ms

-- Step 2:  4037.779 ms
CREATE TEMPORARY TABLE friends_likes AS
SELECT
    af.person AS user,   
    af.friend AS friend,   
    l.artist           
FROM
    all_friends af
JOIN
    likes l ON af.friend = l.person;

CREATE INDEX idx_friends_likes_user ON friends_likes(user);  -- 1223.865 ms
CREATE INDEX idx_friends_likes_artist ON friends_likes(artist);  -- 11158.713 ms 

-- Step 4:  5942.673 ms
SELECT
    fl.user AS u1,
    fl.friend AS u2,
    fl.artist AS a
FROM
    friends_likes fl
LEFT JOIN
   likes ul ON fl.user = ul.person AND fl.artist = ul.artist
WHERE
    ul.artist IS NULL;