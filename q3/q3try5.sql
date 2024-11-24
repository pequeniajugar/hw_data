-- clustered uncovering index

CLUSTER likes USING idx_likes_person; -- 593.117 ms
Cluster likes using idx_likes_artist; -- 569.147 ms

-- 1592.719 ms 
CREATE TEMPORARY TABLE all_friends AS 
SELECT person1 AS person, person2 AS friend FROM friends
UNION
SELECT person2 AS person, person1 AS friend FROM friends;

CREATE INDEX idx_all_friends_person ON all_friends(person);   -- 2238.297 ms
Cluster all_friends using idx_all_friends_person; -- 2073.740
CREATE INDEX idx_all_friends_friend ON all_friends(friend);  -- 1341.168 ms
Cluster all_friends using idx_all_friends_friend; -- 6990.040 ms

-- Step 2: 获取每个用户的好友喜欢的艺术家 3046.112 ms
CREATE TEMPORARY TABLE friends_likes AS
SELECT
    af.person,
    af.friend,
    l.artist               
FROM
    all_friends af
JOIN
    likes l ON af.friend = l.person;

-- 为了加快后续查询，在 friends_likes 表上创建索引
CREATE INDEX idx_friends_likes_person ON friends_likes(person); -- 9314.967 ms
Cluster friends_likes using idx_friends_likes_person; -- 23452.842 ms
CREATE INDEX idx_friends_likes_artist ON friends_likes(artist); -- 7881.842 ms
Cluster friends_likes using idx_friends_likes_artist; -- 29452.453 ms

SELECT -- 4807.946 ms
    fl.person AS u1,
    fl.friend AS u2,
    fl.artist AS a
FROM
    friends_likes fl
LEFT JOIN
   likes l ON fl.person = l.person AND fl.artist = l.artist
WHERE
    l.artist IS NULL;