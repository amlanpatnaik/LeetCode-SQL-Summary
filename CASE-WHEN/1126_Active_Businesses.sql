--SOLUTION 1
SELECT e.business_id
FROM events e
LEFT JOIN
    (SELECT event_type,
        AVG(occurences) AS avg_occurences
    FROM events
    GROUP BY 1) AS a
USING(event_type)
GROUP BY 1
HAVING SUM(CASE WHEN e.occurences > a.avg_occurences THEN 1 ELSE 0 END) > 1

    

--SOLUTION 2
-- calculate average occurences of event types amont all business
WITH tb1 AS (
    SELECT *,
        AVG(occurences*1.0) OVER (PARTITION BY event_type) AS avg_oc
    FROM Events
)

SELECT business_id
FROM tb1
GROUP BY business_id
-- count number of event types of a business with occurences 
-- greater than the average occurences of that event type among all businesses
HAVING SUM(CASE WHEN occurences > avg_oc THEN 1 ELSE 0 END) > 1;
