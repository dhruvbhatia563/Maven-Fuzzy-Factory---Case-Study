-- 1) adjusting max packet size to allow large files to run

SET GLOBAL max_allowed_packet = 1073741824;


-- 2) adjusting your SQL mode to allow invalid dates and use a smarter GROUP BY setting

SET GLOBAL SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES,ONLY_FULL_GROUP_BY';


-- 3) adjusting your timeout settings to run longer queries

SET GLOBAL connect_timeout=28800;

SET GLOBAL wait_timeout=28800;

SET GLOBAL interactive_timeout=28800;