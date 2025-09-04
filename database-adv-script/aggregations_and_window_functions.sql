-- ============================================
-- Advanced SQL Aggregations and Window Functions
-- Airbnb Database Business Intelligence Analysis
-- Author: [Your Name]
-- Date: [Current Date]
-- Course: ALX Advanced Database Module
-- ============================================

-- ============================================
-- TASK 1: AGGREGATION FUNCTIONS WITH GROUP BY
-- Objective: Find total number of bookings made by each user
-- ============================================

-- Business Question: "Which users are our most frequent guests and how much do they spend?"
-- This demonstrates basic aggregation with GROUP BY

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    
    -- AGGREGATION: Count total bookings per user
    COUNT(b.booking_id) as total_bookings,
    
    -- AGGREGATION: Sum total amount spent per user
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_spent,
    
    -- AGGREGATION: Calculate average booking value per user
    ROUND(AVG(CASE WHEN b.status = 'confirmed' THEN b.total_price END), 2) as avg_booking_value,
    
    -- AGGREGATION: Find min and max booking amounts
    MIN(CASE WHEN b.status = 'confirmed' THEN b.total_price END) as min_booking,
    MAX(CASE WHEN b.status = 'confirmed' THEN b.total_price END) as max_booking,
    
    -- AGGREGATION: Count confirmed vs pending/cancelled bookings
    SUM(CASE WHEN b.status = 'confirmed' THEN 1 ELSE 0 END) as confirmed_bookings,
    SUM(CASE WHEN b.status = 'pending' THEN 1 ELSE 0 END) as pending_bookings,
    SUM(CASE WHEN b.status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_bookings,
    
    -- Calculate booking success rate
    ROUND(
        (SUM(CASE WHEN b.status = 'confirmed' THEN 1 ELSE 0 END) * 100.0) / COUNT(b.booking_id), 
        2
    ) as booking_success_rate,
    
    -- AGGREGATION: Find earliest and latest booking dates
    MIN(b.start_date) as first_booking_date,
    MAX(b.start_date) as latest_booking_date,
    
    -- Nigerian market context - format currency
    CONCAT('₦', FORMAT(SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END), 0)) as formatted_total_spent,
    
    -- Guest classification based on activity
    CASE 
        WHEN COUNT(b.booking_id) >= 10 THEN 'VIP Guest'
        WHEN COUNT(b.booking_id) >= 5 THEN 'Frequent Guest'
        WHEN COUNT(b.booking_id) >= 2 THEN 'Regular Guest'
        ELSE 'New Guest'
    END as guest_category,
    
    -- Cultural background analysis (Nigerian names)
    CASE 
        WHEN u.first_name IN ('Adebayo', 'Folake', 'Temitope', 'Yemi', 'Babatunde') THEN 'Yoruba'
        WHEN u.first_name IN ('Chukwuemeka', 'Adaeze', 'Kelechi', 'Ngozi', 'Obiora') THEN 'Igbo'
        WHEN u.first_name IN ('Amina', 'Usman', 'Fatima', 'Ibrahim', 'Aisha') THEN 'Hausa'
        WHEN u.first_name IN ('Osaze', 'Eghosa', 'Osas', 'Ivie', 'Ewere') THEN 'Edo'
        ELSE 'Mixed/Other'
    END as cultural_background

FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
WHERE u.role = 'guest'
GROUP BY u.user_id, u.first_name, u.last_name, u.email
ORDER BY total_bookings DESC, total_spent DESC;

-- ============================================
-- ENHANCED AGGREGATION: Multi-Level Analysis
-- ============================================

-- Business Question: "What are our booking patterns by month and guest category?"
-- This demonstrates GROUP BY with multiple dimensions

SELECT 
    YEAR(b.created_at) as booking_year,
    MONTH(b.created_at) as booking_month,
    MONTHNAME(b.created_at) as month_name,
    
    -- AGGREGATION: Basic booking counts
    COUNT(b.booking_id) as total_bookings,
    COUNT(DISTINCT b.user_id) as unique_guests,
    COUNT(DISTINCT b.property_id) as properties_booked,
    
    -- AGGREGATION: Financial metrics
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as confirmed_revenue,
    ROUND(AVG(CASE WHEN b.status = 'confirmed' THEN b.total_price END), 2) as avg_booking_value,
    
    -- AGGREGATION: Booking status breakdown
    SUM(CASE WHEN b.status = 'confirmed' THEN 1 ELSE 0 END) as confirmed_count,
    SUM(CASE WHEN b.status = 'pending' THEN 1 ELSE 0 END) as pending_count,
    SUM(CASE WHEN b.status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_count,
    
    -- Calculate conversion rates
    ROUND(
        (SUM(CASE WHEN b.status = 'confirmed' THEN 1 ELSE 0 END) * 100.0) / COUNT(b.booking_id),
        2
    ) as conversion_rate,
    
    -- AGGREGATION: Stay duration analysis
    ROUND(AVG(DATEDIFF(b.end_date, b.start_date)), 1) as avg_stay_duration,
    MIN(DATEDIFF(b.end_date, b.start_date)) as min_stay_duration,
    MAX(DATEDIFF(b.end_date, b.start_date)) as max_stay_duration,
    
    -- Nigerian seasonal context
    CASE 
        WHEN MONTH(b.created_at) IN (12, 1, 2) THEN 'Dry Season - Peak Travel'
        WHEN MONTH(b.created_at) IN (3, 4, 5) THEN 'Hot Season - Moderate Travel'
        WHEN MONTH(b.created_at) IN (6, 7, 8, 9) THEN 'Rainy Season - Low Travel'
        ELSE 'Transition Period'
    END as nigerian_season

FROM Booking b
WHERE b.created_at >= '2024-01-01'
GROUP BY YEAR(b.created_at), MONTH(b.created_at), MONTHNAME(b.created_at)
ORDER BY booking_year, booking_month;

-- ============================================
-- TASK 2: WINDOW FUNCTIONS - Property Rankings
-- Objective: Rank properties based on total bookings using ROW_NUMBER and RANK
-- ============================================

-- Business Question: "How do our properties rank by booking volume and revenue?"
-- This demonstrates various ranking window functions

WITH PropertyStats AS (
    -- First, create base statistics for each property
    SELECT 
        p.property_id,
        p.name as property_name,
        p.location,
        p.pricepernight,
        CONCAT(u.first_name, ' ', u.last_name) as host_name,
        
        -- AGGREGATION: Calculate property metrics
        COUNT(b.booking_id) as total_bookings,
        COUNT(DISTINCT b.user_id) as unique_guests,
        SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue,
        ROUND(AVG(CASE WHEN b.status = 'confirmed' THEN b.total_price END), 2) as avg_booking_value,
        ROUND(AVG(r.rating), 2) as avg_rating,
        COUNT(r.review_id) as total_reviews
        
    FROM Property p
    INNER JOIN User u ON p.host_id = u.user_id
    LEFT JOIN Booking b ON p.property_id = b.property_id
    LEFT JOIN Review r ON p.property_id = r.property_id
    GROUP BY p.property_id, p.name, p.location, p.pricepernight, u.first_name, u.last_name
)

SELECT 
    property_id,
    property_name,
    location,
    CONCAT('₦', FORMAT(pricepernight, 0)) as formatted_price,
    host_name,
    total_bookings,
    unique_guests,
    CONCAT('₦', FORMAT(total_revenue, 0)) as formatted_revenue,
    avg_booking_value,
    avg_rating,
    total_reviews,
    
    -- WINDOW FUNCTION: ROW_NUMBER - Sequential ranking (no ties)
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) as booking_rank_row_number,
    
    -- WINDOW FUNCTION: RANK - Standard ranking (gaps for ties)
    RANK() OVER (ORDER BY total_bookings DESC) as booking_rank_with_gaps,
    
    -- WINDOW FUNCTION: DENSE_RANK - Dense ranking (no gaps for ties)
    DENSE_RANK() OVER (ORDER BY total_bookings DESC) as booking_rank_dense,
    
    -- WINDOW FUNCTION: Rankings by different metrics
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank,
    ROW_NUMBER() OVER (ORDER BY avg_rating DESC) as rating_rank,
    ROW_NUMBER() OVER (ORDER BY unique_guests DESC) as guest_diversity_rank,
    
    -- WINDOW FUNCTION: Partitioned ranking (rank within location)
    ROW_NUMBER() OVER (
        PARTITION BY SUBSTRING_INDEX(location, ',', -1) 
        ORDER BY total_bookings DESC
    ) as rank_within_state,
    
    -- WINDOW FUNCTION: Percentile ranking
    NTILE(4) OVER (ORDER BY total_bookings) as booking_quartile,
    NTILE(10) OVER (ORDER BY total_revenue) as revenue_decile,
    
    -- Performance tier classification
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY total_bookings DESC) <= 5 THEN 'Top Performer'
        WHEN ROW_NUMBER() OVER (ORDER BY total_bookings DESC) <= 15 THEN 'High Performer'
        WHEN ROW_NUMBER() OVER (ORDER BY total_bookings DESC) <= 30 THEN 'Good Performer'
        ELSE 'Developing Property'
    END as performance_tier,
    
    -- Nigerian market context
    CASE 
        WHEN location LIKE '%Lagos%' THEN 'Commercial Hub - High Competition'
        WHEN location LIKE '%Abuja%' THEN 'Government Center - Stable Demand'
        WHEN location LIKE '%Port Harcourt%' THEN 'Oil Industry - Business Travel'
        ELSE 'Regional Market - Tourism/Cultural'
    END as market_context

FROM PropertyStats
WHERE total_bookings > 0  -- Only include properties with bookings
ORDER BY booking_rank_row_number;

-- ============================================
-- ADVANCED WINDOW FUNCTIONS: Comparative Analysis
-- ============================================

-- Business Question: "How does each property perform compared to similar properties?"
-- This demonstrates advanced window function usage

SELECT 
    p.property_id,
    p.name as property_name,
    p.location,
    p.pricepernight,
    
    -- Basic metrics
    COUNT(b.booking_id) as total_bookings,
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue,
    
    -- WINDOW FUNCTION: Compare to overall averages
    ROUND(AVG(COUNT(b.booking_id)) OVER (), 2) as platform_avg_bookings,
    ROUND(AVG(SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END)) OVER (), 2) as platform_avg_revenue,
    
    -- WINDOW FUNCTION: Compare to location peers
    ROUND(AVG(COUNT(b.booking_id)) OVER (
        PARTITION BY SUBSTRING_INDEX(p.location, ',', -1)
    ), 2) as location_avg_bookings,
    
    -- WINDOW FUNCTION: Performance vs peers
    COUNT(b.booking_id) - AVG(COUNT(b.booking_id)) OVER () as bookings_vs_platform,
    COUNT(b.booking_id) - AVG(COUNT(b.booking_id)) OVER (
        PARTITION BY SUBSTRING_INDEX(p.location, ',', -1)
    ) as bookings_vs_location,
    
    -- WINDOW FUNCTION: Moving averages and trends
    LAG(COUNT(b.booking_id), 1) OVER (
        PARTITION BY p.property_id 
        ORDER BY YEAR(b.created_at), MONTH(b.created_at)
    ) as prev_period_bookings,
    
    -- WINDOW FUNCTION: Cumulative metrics
    SUM(COUNT(b.booking_id)) OVER (
        PARTITION BY p.property_id 
        ORDER BY YEAR(b.created_at), MONTH(b.created_at)
    ) as cumulative_bookings,
    
    -- Performance indicators
    CASE 
        WHEN COUNT(b.booking_id) > AVG(COUNT(b.booking_id)) OVER () THEN 'Above Average'
        WHEN COUNT(b.booking_id) = AVG(COUNT(b.booking_id)) OVER () THEN 'Average'
        ELSE 'Below Average'
    END as performance_vs_platform

FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
HAVING COUNT(b.booking_id) > 0
ORDER BY total_bookings DESC;

-- ============================================
-- COMPLEX BUSINESS ANALYSIS: Host Performance Dashboard
-- ============================================

-- Business Question: "Create a comprehensive host performance dashboard"
-- This combines aggregations and window functions for deep insights

WITH HostMetrics AS (
    SELECT 
        h.user_id as host_id,
        CONCAT(h.first_name, ' ', h.last_name) as host_name,
        h.email as host_email,
        h.created_at as host_since,
        
        -- AGGREGATION: Host portfolio metrics
        COUNT(DISTINCT p.property_id) as total_properties,
        COUNT(DISTINCT b.booking_id) as total_bookings,
        COUNT(DISTINCT b.user_id) as unique_guests,
        
        -- AGGREGATION: Financial metrics
        SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue,
        ROUND(AVG(CASE WHEN b.status = 'confirmed' THEN b.total_price END), 2) as avg_booking_value,
        
        -- AGGREGATION: Quality metrics
        ROUND(AVG(r.rating), 2) as avg_rating,
        COUNT(r.review_id) as total_reviews,
        
        -- AGGREGATION: Efficiency metrics
        ROUND(
            SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) / 
            COUNT(DISTINCT p.property_id), 
            2
        ) as revenue_per_property,
        
        ROUND(
            COUNT(DISTINCT b.booking_id) / COUNT(DISTINCT p.property_id), 
            2
        ) as bookings_per_property,
        
        -- AGGREGATION: Geographic diversity
        COUNT(DISTINCT SUBSTRING_INDEX(p.location, ',', -1)) as states_served,
        GROUP_CONCAT(DISTINCT SUBSTRING_INDEX(p.location, ',', -1)) as location_list

    FROM User h
    LEFT JOIN Property p ON h.user_id = p.host_id
    LEFT JOIN Booking b ON p.property_id = b.property_id
    LEFT JOIN Review r ON p.property_id = r.property_id
    WHERE h.role = 'host'
    GROUP BY h.user_id, h.first_name, h.last_name, h.email, h.created_at
)

SELECT 
    host_id,
    host_name,
    host_email,
    host_since,
    total_properties,
    total_bookings,
    unique_guests,
    CONCAT('₦', FORMAT(total_revenue, 0)) as formatted_revenue,
    avg_booking_value,
    avg_rating,
    total_reviews,
    revenue_per_property,
    bookings_per_property,
    states_served,
    location_list,
    
    -- WINDOW FUNCTION: Host rankings
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank,
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) as booking_rank,
    ROW_NUMBER() OVER (ORDER BY avg_rating DESC) as rating_rank,
    
    -- WINDOW FUNCTION: Percentile analysis
    NTILE(4) OVER (ORDER BY total_revenue) as revenue_quartile,
    NTILE(10) OVER (ORDER BY total_bookings) as booking_decile,
    
    -- WINDOW FUNCTION: Compare to cohort (hosts who started same year)
    ROUND(AVG(total_revenue) OVER (
        PARTITION BY YEAR(host_since)
    ), 2) as cohort_avg_revenue,
    
    -- Performance vs cohort
    total_revenue - AVG(total_revenue) OVER (
        PARTITION BY YEAR(host_since)
    ) as revenue_vs_cohort,
    
    -- Host tier classification
    CASE 
        WHEN NTILE(10) OVER (ORDER BY total_revenue) >= 9 THEN 'Elite Host'
        WHEN NTILE(10) OVER (ORDER BY total_revenue) >= 7 THEN 'Super Host'
        WHEN NTILE(10) OVER (ORDER BY total_revenue) >= 5 THEN 'Established Host'
        WHEN total_properties > 0 THEN 'Active Host'
        ELSE 'New Host'
    END as host_tier,
    
    -- Nigerian market context
    CASE 
        WHEN states_served >= 3 THEN 'Multi-Regional Host'
        WHEN location_list LIKE '%Lagos%' AND location_list LIKE '%Abuja%' THEN 'Major Cities Host'
        WHEN location_list LIKE '%Lagos%' THEN 'Lagos Focused Host'
        WHEN location_list LIKE '%Abuja%' THEN 'Abuja Focused Host'
        ELSE 'Regional Specialist Host'
    END as market_focus

FROM HostMetrics
WHERE total_properties > 0
ORDER BY revenue_rank;

-- ============================================
-- TIME SERIES ANALYSIS: Revenue Trends
-- ============================================

-- Business Question: "What are our monthly revenue trends and growth patterns?"
-- This demonstrates time series analysis with window functions

SELECT 
    YEAR(py.payment_date) as year,
    MONTH(py.payment_date) as month,
    MONTHNAME(py.payment_date) as month_name,
    DATE_FORMAT(py.payment_date, '%Y-%m') as year_month,
    
    -- AGGREGATION: Monthly metrics
    COUNT(DISTINCT py.payment_id) as total_transactions,
    COUNT(DISTINCT b.user_id) as unique_customers,
    COUNT(DISTINCT b.property_id) as properties_with_revenue,
    SUM(py.amount) as monthly_revenue,
    ROUND(AVG(py.amount), 2) as avg_transaction_value,
    
    -- WINDOW FUNCTION: Comparative analysis
    LAG(SUM(py.amount), 1) OVER (ORDER BY YEAR(py.payment_date), MONTH(py.payment_date)) as prev_month_revenue,
    LAG(SUM(py.amount), 12) OVER (ORDER BY YEAR(py.payment_date), MONTH(py.payment_date)) as same_month_prev_year,
    
    -- WINDOW FUNCTION: Growth calculations
    ROUND(
        (SUM(py.amount) - LAG(SUM(py.amount), 1) OVER (ORDER BY YEAR(py.payment_date), MONTH(py.payment_date))) * 100.0 /
        LAG(SUM(py.amount), 1) OVER (ORDER BY YEAR(py.payment_date), MONTH(py.payment_date)),
        2
    ) as month_over_month_growth,
    
    ROUND(
        (SUM(py.amount) - LAG(SUM(py.amount), 12) OVER (ORDER BY YEAR(py.payment_date), MONTH(py.payment_date))) * 100.0 /
        LAG(SUM(py.amount), 12) OVER (ORDER BY YEAR(py.payment_date), MONTH(py.payment_date)),
        2
    ) as year_over_year_growth,
    
    -- WINDOW FUNCTION: Rolling averages
    ROUND(AVG(SUM(py.amount)) OVER (
        ORDER BY YEAR(py.payment_date), MONTH(py.payment_date) 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) as three_month_avg,
    
    ROUND(AVG(SUM(py.amount)) OVER (
        ORDER BY YEAR(py.payment_date), MONTH(py.payment_date) 
        ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    ), 2) as six_month_avg,
    
    -- WINDOW FUNCTION: Cumulative metrics
    SUM(SUM(py.amount)) OVER (
        PARTITION BY YEAR(py.payment_date)
        ORDER BY MONTH(py.payment_date)
    ) as ytd_revenue,
    
    SUM(SUM(py.amount)) OVER (
        ORDER BY YEAR(py.payment_date), MONTH(py.payment_date)
    ) as cumulative_revenue,
    
    -- WINDOW FUNCTION: Ranking months by performance
    ROW_NUMBER() OVER (ORDER BY SUM(py.amount) DESC) as revenue_rank_all_time,
    ROW_NUMBER() OVER (
        PARTITION BY YEAR(py.payment_date) 
        ORDER BY SUM(py.amount) DESC
    ) as revenue_rank_within_year,
    
    -- Nigerian seasonal context
    CASE 
        WHEN MONTH(py.payment_date) IN (12, 1) THEN 'Peak Season (Dry/Holiday)'
        WHEN MONTH(py.payment_date) IN (2, 3, 4) THEN 'High Season (Dry Continues)'
        WHEN MONTH(py.payment_date) IN (7, 8) THEN 'Rainy Season Low'
        ELSE 'Transition Period'
    END as nigerian_season,
    
    -- Performance classification
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY SUM(py.amount) DESC) <= 3 THEN 'Best Month'
        WHEN NTILE(4) OVER (ORDER BY SUM(py.amount)) = 4 THEN 'Strong Month'
        WHEN NTILE(4) OVER (ORDER BY SUM(py.amount)) = 3 THEN 'Good Month'
        WHEN NTILE(4) OVER (ORDER BY SUM(py.amount)) = 2 THEN 'Average Month'
        ELSE 'Challenging Month'
    END as performance_category

FROM Payment py
INNER JOIN Booking b ON py.booking_id = b.booking_id
WHERE py.payment_date >= '2024-01-01'
GROUP BY YEAR(py.payment_date), MONTH(py.payment_date), MONTHNAME(py.payment_date)
ORDER BY year, month;

-- ============================================
-- PERFORMANCE OPTIMIZATION EXAMPLES
-- ============================================

-- Analyze query performance for complex aggregations and window functions
EXPLAIN 
SELECT user_id, COUNT(*) as booking_count,
       ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as rank
FROM Booking 
GROUP BY user_id;

-- Compare performance of different ranking approaches
EXPLAIN
SELECT property_id, 
       COUNT(*) as bookings,
       ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as row_rank,
       RANK() OVER (ORDER BY COUNT(*) DESC) as standard_rank,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as dense_rank
FROM Booking 
GROUP BY property_id;

-- ============================================
-- BUSINESS INTELLIGENCE SUMMARY QUERIES
-- ============================================

-- Executive Summary: Key Platform Metrics
SELECT 
    'Platform Overview' as metric_category,
    COUNT(DISTINCT u.user_id) as total_users,
    COUNT(DISTINCT CASE WHEN u.role = 'host' THEN u.user_id END) as total_hosts,
    COUNT(DISTINCT CASE WHEN u.role = 'guest' THEN u.user_id END) as total_guests,
    COUNT(DISTINCT p.property_id) as total_properties,
    COUNT(DISTINCT b.booking_id) as total_bookings,
    COUNT(DISTINCT CASE WHEN b.status = 'confirmed' THEN b.booking_id END) as confirmed_bookings,
    CONCAT('₦', FORMAT(SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END), 0)) as total_revenue,
    ROUND(AVG(r.rating), 2) as platform_avg_rating

FROM User u
LEFT JOIN Property p ON u.user_id = p.host_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id;

-- Nigerian Market Breakdown by Region
SELECT 
    SUBSTRING_INDEX(p.location, ',', -1) as nigerian_region,
    COUNT(DISTINCT p.property_id) as properties_count,
    COUNT(DISTINCT b.booking_id) as total_bookings,
    ROUND(AVG(p.pricepernight), 2) as avg_property_price,
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as region_revenue,
    ROUND(AVG(r.rating), 2) as avg_rating,
    
    -- Regional performance ranking
    ROW_NUMBER() OVER (ORDER BY SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) DESC) as revenue_rank,
    
    -- Market share calculation
    ROUND(
        SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) * 100.0 / 
        SUM(SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END)) OVER (), 
        2
    ) as market_share_percentage

FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY SUBSTRING_INDEX(p.location, ',', -1)
ORDER BY region_revenue DESC;
