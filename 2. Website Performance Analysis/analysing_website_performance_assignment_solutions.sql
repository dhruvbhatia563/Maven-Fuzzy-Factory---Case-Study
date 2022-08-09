USE mavenfuzzyfactory;

-- Analyzing Website Performance

/* first 100 sessions*/

SELECT * FROM website_sessions;
SELECT * FROM website_sessions
WHERE website_session_id<101;

-- create a temp table to store first 100 sessions
CREATE TEMPORARY TABLE first_hundered_sessions
SELECT * FROM website_sessions
WHERE website_session_id<101;

SELECT * FROM first_hundered_sessions;

-- finding top pages of the website to see where to focus

SELECT * FROM website_pageviews
WHERE website_pageview_id<1000; -- arbitary

-- top pages will be based on the size of volume of page_views_count

SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) as total_count_of_page_views
FROM website_pageviews
WHERE website_pageview_id<1000 -- arbitary
GROUP BY 1
ORDER BY 2 DESC;

-- MOST VIEWED WEBSITE PAGES, RANKED BY SESSION VOLUME

SELECT
	pageview_url,
    COUNT(DISTINCT website_pageview_id) as page_view_sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY 1
ORDER BY 2 DESC;

-- top entry pages ? means: where the customer landed for the first time before June 12, 2012
/*  two steps will be used here:
Step1: find the first page view for each session id
Step2: find the url that customer landed, on that first page view
*/

-- Step: 1
SELECT * FROM website_pageviews;
SELECT
	website_session_id,
    MIN(website_pageview_id) as first_pageview
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY 1;

-- Note: will create a temp table for the first_pageview_per_session_id
CREATE TEMPORARY TABLE first_pageview_per_session_id
SELECT
	website_session_id,
    MIN(website_pageview_id) as first_pageview
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY 1;

SELECT * FROM first_pageview_per_session_id;
-- Step: 2
SELECT
	website_pageviews.pageview_url as entry_pages,
    COUNT(DISTINCT first_pageview_per_session_id.website_session_id) AS sessions_hitting_page
FROM first_pageview_per_session_id
LEFT JOIN website_pageviews
	ON first_pageview_per_session_id.first_pageview  = website_pageviews.website_pageview_id
GROUP BY 1
ORDER BY 2 DESC;

-- find the sessions, bounced_sessions and bounced_rate for landing_page 'home'

SELECT * FROM website_pageviews;

CREATE TEMPORARY TABLE first_pv_per_sessions
SELECT
	website_session_id,
    MIN(website_pageview_id) as first_pv_per_session
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY 1;

SELECT * FROM first_pv_per_sessions;

CREATE TEMPORARY TABLE sessions_wrt_home
SELECT
	first_pv_per_sessions.website_session_id as sessions,
    website_pageviews.pageview_url as landing_page
FROM first_pv_per_sessions
LEFT JOIN website_pageviews
	ON first_pv_per_sessions.first_pv_per_session = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url = '/home';

SELECT * FROM first_pv_per_sessions;
SELECT * FROM sessions_wrt_home;

SELECT
	sessions_wrt_home.sessions,
    sessions_wrt_home.landing_page,
    COUNT(DISTINCT website_pageviews.website_pageview_id) as count_pages_viewd
FROM sessions_wrt_home
LEFT JOIN website_pageviews
	ON sessions_wrt_home.sessions  = website_pageviews.website_session_id
GROUP BY 1,2;

-- Note: as we ned to have bounced sessions means sessions that saw only one page not more then that
 SELECT
	sessions_wrt_home.sessions,
    sessions_wrt_home.landing_page,
    COUNT(DISTINCT website_pageviews.website_pageview_id) as count_pages_viewd
FROM sessions_wrt_home
LEFT JOIN website_pageviews
	ON sessions_wrt_home.sessions  = website_pageviews.website_session_id
GROUP BY 1,2
HAVING count_pages_viewd = 1;

CREATE TEMPORARY TABLE bounced_sessions_overview
SELECT
	sessions_wrt_home.sessions,
    sessions_wrt_home.landing_page,
    COUNT(DISTINCT website_pageviews.website_pageview_id) as count_pages_viewd
FROM sessions_wrt_home
LEFT JOIN website_pageviews
	ON sessions_wrt_home.sessions  = website_pageviews.website_session_id
GROUP BY 1,2
HAVING count_pages_viewd = 1;

SELECT * FROM first_pv_per_sessions;
SELECT * FROM sessions_wrt_home;
SELECT * FROM bounced_sessions_overview;

SELECT
	COUNT(DISTINCT sessions_wrt_home.sessions) as total_sessions,
    COUNT(DISTINCT bounced_sessions_overview.sessions) as bounced_sessions,
    COUNT(DISTINCT bounced_sessions_overview.sessions)/COUNT(DISTINCT sessions_wrt_home.sessions) as bounced_rate
FROM sessions_wrt_home
LEFT JOIN bounced_sessions_overview
	ON sessions_wrt_home.sessions = bounced_sessions_overview.sessions;
    
/* A/B TESTING: ASSIGNMENT
where to entry paes: home and lander-1
for utm_source: gsearch and
utm_campaign: nonbrand
*/

SELECT * FROM website_pageviews;

SELECT
	MIN(created_at) as first_created_at,
    MIN(website_pageview_id) as first_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL;

-- first created at: 2012-06-19
-- first page viewd = 23504

SELECT * FROM website_sessions;
SELECT * FROM website_pageviews;

CREATE TEMPORARY TABLE first_pv_table_1
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) as first_pv_per_session
FROM website_pageviews
INNER JOIN website_sessions
	ON website_pageviews.website_session_id = website_sessions.website_session_id
    AND website_sessions.created_at < '2012-07-28' -- prescribed by the assignment
    AND website_pageviews.website_pageview_id > 23504
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1;

CREATE TEMPORARY TABLE sessions_wrt_home_lander_table_2
SELECT
	first_pv_table_1.website_session_id as sessions,
    website_pageviews.pageview_url as landing_page
FROM first_pv_table_1
LEFT JOIN website_pageviews
	ON first_pv_table_1.first_pv_per_session = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

CREATE TEMPORARY TABLE bounced_sessions_overview_table_3
SELECT
	sessions_wrt_home_lander_table_2.sessions,
    sessions_wrt_home_lander_table_2.landing_page,
    COUNT(DISTINCT website_pageviews.website_pageview_id) as count_pages_viewd
FROM sessions_wrt_home_lander_table_2
LEFT JOIN website_pageviews
	ON sessions_wrt_home_lander_table_2.sessions  = website_pageviews.website_session_id
GROUP BY 1,2
HAVING count_pages_viewd = 1;

SELECT * FROM first_pv_table_1;
SELECT * FROM sessions_wrt_home_lander_table_2;
SELECT * FROM bounced_sessions_overview_table_3;

SELECT
	sessions_wrt_home_lander_table_2.landing_page,
	COUNT(DISTINCT sessions_wrt_home_lander_table_2.sessions) as total_sessions,
    COUNT(DISTINCT bounced_sessions_overview_table_3.sessions) as bounced_sessions,
    COUNT(DISTINCT bounced_sessions_overview_table_3.sessions)/COUNT(DISTINCT sessions_wrt_home_lander_table_2.sessions) as bounced_rate
FROM sessions_wrt_home_lander_table_2
LEFT JOIN bounced_sessions_overview_table_3
	ON sessions_wrt_home_lander_table_2.sessions = bounced_sessions_overview_table_3.sessions
GROUP BY 1;







