-- Active: 1778344529639@@127.0.0.1@3306@airBnB_Market

-- Cross-market comparison: Compare Airbnb performance across cities and countries in Europe
-- Investment screening: Identify the best-performing STR markets by occupancy, ADR, and RevPAR
-- Seasonality analysis: Understand how seasonal patterns differ across Europe markets
-- Supply analysis: Study listing density, property types, and professional management rates
-- Academic research: Analyze short-term rental regulation impacts, tourism economics, and housing markets

-- Data Understanding
USE airBnB_Market;

DESCRIBE listings;
DESCRIBE past_rates;

SELECT 
    *
FROM listings;

SELECT
    *
FROM past_rates;

-- Listing Count Percentiles
CREATE VIEW percentile AS
WITH country_counts AS (
    SELECT country, COUNT(listing_id) as total_listings
    FROM listings
    GROUP BY country
),
quartiles AS (
    SELECT 
        total_listings,
        NTILE(4) OVER (ORDER BY total_listings) AS quartile
    FROM country_counts
)
SELECT 
    quartile, 
    MIN(total_listings) AS min_val, 
    MAX(total_listings) AS max_val
FROM quartiles
GROUP BY quartile;

-- Listing Density (City, state, and country)
CREATE OR REPLACE VIEW market_structure AS
WITH city_density AS (
    SELECT
        country AS Country,
        state AS State,
        city AS city,
        COUNT(listing_id) AS Total_Listing
    FROM listings
    WHERE city IS NOT NULL AND city != '' AND listing_type IS NOT NULL AND listing_type != ''
    GROUP BY 1,2,3
), 
property_breakdown AS (
    SELECT
        TRIM(country) AS Country,
        TRIM(state) AS State,
        TRIM(city) AS City,
        CASE 
            WHEN listing_type LIKE 'Entire%' THEN 'Entire House'
            WHEN listing_type LIKE '%Room%' THEN 'Private/Shared Room'
            ELSE 'Other'
        END AS Listing_Type,
        COUNT(listing_id) AS Property_Type_Count
    FROM listings
    WHERE city IS NOT NULL 
    AND city != '' AND listing_type IS NOT NULL AND listing_type != ''
    GROUP BY 1, 2, 3, 4
) SELECT 
    p.Country,
    p.State,
    p.City,
    p.Listing_Type,
    p.Property_Type_Count,
    c.Total_Listing,
    -- Metrics 1 : City Density over total country
    ROUND(c.Total_Listing * 100 / SUM(c.Total_Listing) OVER(PARTITION BY p.Country), 2) AS pct_density_of_country,
    -- Metrics 2 : Property type domination
    ROUND(p.Property_Type_Count * 100 / c.Total_Listing) AS pct_market_in_city
FROM property_breakdown p
JOIN city_density c
    ON p.Country = c.Country 
    AND p.State = c.State 
    AND p.City = c.City
ORDER BY p.Country ASC, c.Total_Listing DESC, p.Property_Type_Count DESC;

-- Property Performance Summary
WITH property_performance_summary AS (
    SELECT
        l.listing_id,
        CASE 
            WHEN l.listing_type LIKE 'Entire%' THEN 'Entire House'
            WHEN l.listing_type LIKE '%Room%' THEN 'Private/Shared Room'
            ELSE 'Other'
        END AS Listing_Type,
        p.occupancy,
        p.rate_avg
    FROM listings l
    JOIN past_rates p ON l.listing_id = p.listing_id
    WHERE l.listing_type IS NOT NULL AND l.listing_type != ''
)
SELECT
    Listing_Type,
    COUNT(listing_id) AS total_property,
    ROUND(AVG(occupancy) * 100, 2) AS occupancy_pct,
    ROUND(AVG(rate_avg), 2) AS adr_avg,
    ROUND(AVG(rate_avg * occupancy), 2) AS revpar_avg
FROM property_performance_summary
GROUP BY Listing_Type
ORDER BY 5 DESC;

-- City Performance Summary
WITH country_performance_summary AS (
    SELECT
        l.listing_id,
        l.country AS Country,
        p.occupancy,
        p.rate_avg
    FROM listings l
    JOIN past_rates p ON l.listing_id = p.listing_id
    WHERE l.listing_type IS NOT NULL AND l.listing_type != ''
)
SELECT
    Country,
    COUNT(DISTINCT listing_id) AS total_property,
    ROUND(AVG(occupancy) * 100, 2) AS occupancy_pct,
    ROUND(AVG(rate_avg), 2) AS adr_avg,
    ROUND(AVG(rate_avg * occupancy), 2) AS revpar_avg,
    DENSE_RANK() OVER(ORDER BY AVG(rate_avg * occupancy) DESC) AS rank_performance
FROM country_performance_summary
GROUP BY 1
HAVING COUNT(DISTINCT listing_id) > 300
ORDER BY revpar_avg DESC;

-- Property Performance Over All Countries
WITH country_property_performance AS (
    SELECT
        l.listing_id,
        l.country AS Country,
        listing_type AS Raw_Type,
        p.occupancy,
        p.rate_avg
    FROM listings l
    JOIN past_rates p ON l.listing_id = p.listing_id
    WHERE l.listing_type IS NOT NULL AND l.listing_type != ''
)
SELECT
    Country,
    CASE 
        WHEN Raw_Type LIKE 'Entire%' THEN 'Entire House'
        WHEN Raw_Type LIKE '%Room%' THEN 'Private/Shared Room'
        ELSE 'Other'
    END AS Listing_Type,
    COUNT(listing_id) AS total_property,
    ROUND(AVG(occupancy) * 100, 2) AS occupancy_pct,
    ROUND(AVG(rate_avg), 2) AS adr_avg,
    ROUND(AVG(rate_avg * occupancy), 2) AS revpar_avg
FROM country_property_performance
GROUP BY 1,2
ORDER BY 1,2,6 DESC;

CREATE OR REPLACE VIEW performance_master AS
WITH base_performance AS (
    SELECT
        l.listing_id,
        TRIM(l.country) as Country,
        TRIM(l.city) AS City,
        CASE 
            WHEN l.listing_type LIKE 'Entire%' THEN 'Entire House'
            WHEN l.listing_type LIKE '%Room%' THEN 'Private/Shared Room'
            ELSE 'Other'
        END AS Listing_Type,
        p.occupancy AS Occupancy,
        p.rate_avg AS ADR,
        ROUND((p.rate_avg * p.occupancy), 2) AS RevPAR
    FROM listings l
    JOIN past_rates p ON l.listing_id = p.listing_id
    WHERE l.listing_type IS NOT NULL 
    AND l.listing_type != ''
    AND l.city IS NOT NULL 
    AND l.city != ''
    AND p.rate_avg > 0 
    AND p.occupancy BETWEEN 0 AND 1
),
country_counts AS (
    SELECT 
        Country, 
        COUNT(DISTINCT listing_id) AS Total_Properties_Country
    FROM base_performance
    GROUP BY Country
)
SELECT
    bp.Country,
    bp.Listing_Type,
    cc.Total_Properties_Country,
    COUNT(bp.listing_id) AS total_property_segment,
    ROUND(AVG(bp.Occupancy) * 100, 2) AS occupancy_pct,
    ROUND(AVG(bp.ADR), 2) AS adr_avg,
    ROUND(AVG(bp.RevPAR), 2) AS revpar_avg,
    DENSE_RANK() OVER(ORDER BY AVG(bp.RevPAR) DESC) AS rank_performance_europe
FROM base_performance bp
JOIN country_counts cc ON bp.Country = cc.Country
GROUP BY bp.Country, bp.Listing_Type, cc.Total_Properties_Country
ORDER BY bp.Country ASC, revpar_avg DESC; 
-- Work On this later


SELECT * FROM performance_master;

-- Top Performer Drill Down
SELECT 
    l.country,
    l.city,
    COUNT(l.listing_id) AS total_listings,
    ROUND(AVG(occupancy) * 100, 2) AS occupancy_pct,
    ROUND(AVG(rate_avg), 2) AS adr_avg,
    ROUND(AVG(rate_avg * occupancy), 2) AS revpar_avg
FROM listings l
JOIN past_rates p ON l.listing_id = p.listing_id
WHERE l.country IN ('Ireland', 'Netherlands', 'United Kingdom') AND l.listing_type IS NOT NULL AND l.listing_type != ''
GROUP BY 1, 2
ORDER BY 6 DESC;

-- Proterty in Top Performer
SELECT 
    l.city,
    CASE 
        WHEN l.listing_type LIKE 'Entire%' THEN 'Entire House'
        WHEN l.listing_type LIKE '%Room%' THEN 'Private/Shared Room'
        ELSE 'Other'
    END AS category,
    COUNT(l.listing_id) AS property_count,
    ROUND(AVG(p.rate_avg * p.occupancy), 2) AS revpar_avg
FROM listings l
JOIN past_rates p ON l.listing_id = p.listing_id
WHERE l.city = 'City of Edinburgh' AND l.listing_type IS NOT NULL AND l.listing_type != ''
GROUP BY 1, 2
ORDER BY 4 DESC;

-- Seasonality Analysis: Monthly performance trends for Top Countries
SELECT 
    l.country AS Country,
    MONTH(p.date) AS Month_Number,
    -- Menggunakan CASE untuk mengubah angka bulan menjadi teks agar visualisasi di dashboard lebih mudah
    CASE MONTH(p.date)
        WHEN 1 THEN 'Jan' WHEN 2 THEN 'Feb' WHEN 3 THEN 'Mar' 
        WHEN 4 THEN 'Apr' WHEN 5 THEN 'May' WHEN 6 THEN 'Jun'
        WHEN 7 THEN 'Jul' WHEN 8 THEN 'Aug' WHEN 9 THEN 'Sep' 
        WHEN 10 THEN 'Oct' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Dec'
    END AS Month_Name,
    COUNT(DISTINCT l.listing_id) AS Active_Listings,
    ROUND(AVG(p.occupancy) * 100, 2) AS Avg_Occupancy_Pct,
    ROUND(AVG(p.rate_avg), 2) AS Avg_ADR,
    ROUND(AVG(p.rate_avg * p.occupancy), 2) AS Avg_RevPAR
FROM listings l
JOIN past_rates p ON l.listing_id = p.listing_id
WHERE l.country IN ('Ireland', 'Netherlands', 'United Kingdom')
  AND l.listing_type IS NOT NULL AND l.listing_type != ''
GROUP BY l.country, MONTH(p.date), Month_Name
ORDER BY l.country ASC, Month_Number ASC;

-- Professional Management Impact: Superhost vs Regular Host Performance
SELECT 
    l.country AS Country,
    CASE 
        WHEN l.superhost = 1 OR l.superhost LIKE 't%' THEN 'Professional (Superhost)'
        ELSE 'Regular Host'
    END AS Host_Type,
    COUNT(DISTINCT l.listing_id) AS Total_Properties,
    ROUND(AVG(p.occupancy) * 100, 2) AS Occupancy_Pct,
    ROUND(AVG(p.rate_avg), 2) AS ADR_Avg,
    ROUND(AVG(p.rate_avg * p.occupancy), 2) AS RevPAR_Avg
FROM listings l
JOIN past_rates p ON l.listing_id = p.listing_id
WHERE l.country IN ('Ireland', 'Netherlands', 'United Kingdom')
  AND l.listing_type IS NOT NULL AND l.listing_type != ''
GROUP BY 1, 2
ORDER BY 1 ASC, 6 DESC;

-- Academic Insights: Size Distribution & Pricing Power (Regulation Context)
SELECT 
    l.city AS City,
    COALESCE(l.bedrooms, 0) AS Bedrooms_Count,
    COUNT(DISTINCT l.listing_id) AS Property_Count,
    ROUND(AVG(p.rate_avg * p.occupancy), 2) AS RevPAR_Avg
FROM listings l
JOIN past_rates p ON l.listing_id = p.listing_id
WHERE l.city IN ('City of Edinburgh', 'London', 'Amsterdam') -- Contoh kota besar
GROUP BY 1, 2
ORDER BY 1 ASC, 2 ASC;