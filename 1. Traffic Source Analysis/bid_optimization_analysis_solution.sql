/*
Assignment: 1
As the gsource-nonbrand was giving less CVR the company made its bid down at April 15, 2012. 
Therefore, need to get the session volume by weekly for gsource-nonbrand, to see if the bid changes from up to down 
has an impact on the session volume to drop
*/
-- Solution: 1
SELECT * FROM website_sessions;
SELECT
	-- YEARWEEK(created_at) as year_week,
	MIN(DATE(created_at)) as week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) as sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-05-10'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at);

/*
Assignment: 2
Pull conversion rate (CVR) by device type?
*/
-- Solution: 2
SELECT
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) as sessions,
    COUNT(DISTINCT orders.order_id) as orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) as conversion_rate
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 1;

/*
Assignment: 3
Now the company has increased its bid for gsearch-nonbrand for device type desktop on May 19,2012 
and we received mail on June,9,2012 that need weekly analysis of device type session volume
*/
-- Solution: 3
SELECT
	MIN(DATE(created_at)) as week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) as desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) as mobile_sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-06-09'
	AND website_sessions.created_at > '2012-04-15'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	YEARWEEK(website_sessions.created_at)
;