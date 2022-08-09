/*
Assignment: 1
Which traffic source is the major traffic source based on number of sessions before April,12, 2012?
*/
-- Solution: 1
SELECT * FROM website_sessions;

SELECT 
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_session_id) as total_sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 1,2,3
ORDER BY total_sessions DESC;

/*
Assignment: 2
Will gsource-nonbrand session are driving sales or not ?
Expected CVR = 4% to make the numbers work
*/
-- Solution: 2
SELECT
	COUNT(DISTINCT website_sessions.website_session_id) as sessions,
    COUNT(DISTINCT orders.order_id) as orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) as session_to_order_conv_rate
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-06-12'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
;
