-- ============================================
-- Advanced SQL Subqueries - Airbnb Database Analysis
-- Author: [Your Name]
-- Date: [Current Date]
-- Course: ALX Advanced Database Module
-- ============================================

-- ============================================
-- TASK 1: NON-CORRELATED SUBQUERY
-- Objective: Find all properties where the average rating is greater than 4.0
-- ============================================

-- Business Question: "Which properties are performing better than our quality benchmark of 4.0 stars?"
-- Why Non-Correlated? The 4.0 threshold is fixed - we don't need to recalculate for each property

-- Method 1: Using IN with subquery (Most Common Approach)
SELECT 
    p.property_id,
    p.name as property_name,
    p.location,
    p.pricepernight,
    CONCAT(u.first_name, ' ', u.last_name) as host_name,
    
    -- Calculate the actual average rating for display
    (SELECT ROUND(AVG(r.rating), 2) 
     FROM Review r 
     WHERE r.property_id = p.property_id) as avg_rating,
    
    -- Count total reviews
    (SELECT COUNT(*) 
     FROM Review r 
     WHERE r.property_id = p.property_id) as total_reviews,
    
    -- Business classification
    CASE 
        WHEN (SELECT AVG(r.rating) FROM Review r WHERE r.property_id = p.property_id) >= 4.7 THEN 'Premium Property'
        WHEN (SELECT AVG(r.rating) FROM Review r WHERE r.property_id = p.property_id) >= 4.3 THEN 'High-Quality Property'
        ELSE 'Good Property'
    END as quality_tier,
    
    -- Nigerian market context
    CASE 
        WHEN p.location LIKE '%Lagos%' THEN 'Commercial Hub - High Standards Expected'
        WHEN p.location LIKE '%Abuja%' THEN 'Capital City - Government & Business Travel'
        ELSE 'Regional Market - Cultural Tourism Focus'
    END as market_context

FROM Property p
INNER JOIN User u ON p.host_id = u.user_id
WHERE p.property_id IN (
    -- SUBQUERY: Find property IDs with average rating > 4.0
    SELECT r.property_id
    FROM Review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY 
    (SELECT AVG(r.rating) FROM Review r WHERE r.property_id = p.property_id) DESC,
    total_reviews DESC;

-- ============================================
-- ALTERNATIVE METHOD: Using EXISTS (More Efficient)
-- ============================================

-- Same business question, more efficient execution for large datasets
SELECT 
    p.property_id,
    p.name,
    p.location,
    CONCAT('₦', FORMAT(p.pricepernight, 0)) as formatted_price,
    CONCAT(u.first_name, ' ', u.last_name) as host_name
    
FROM Property p
INNER JOIN User u ON p.host_id = u.user_id
WHERE EXISTS (
    -- Check if this property has reviews with average > 4.0
    SELECT 1
    FROM Review r
    WHERE r.property_id = p.property_id
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.pricepernight DESC;

-- ============================================
-- ENHANCED NON-CORRELATED: Market Comparison
-- ============================================

-- Business Question: "Show me properties performing above their local market average"
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    
    -- Property's actual rating
    (SELECT ROUND(AVG(r.rating), 2) 
     FROM Review r 
     WHERE r.property_id = p.property_id) as property_rating,
    
    -- Market average for comparison (non-correlated - calculated once)
    (SELECT ROUND(AVG(rating), 2) 
     FROM Review) as platform_average,
    
    -- Performance above market
    ROUND((
        (SELECT AVG(r.rating) FROM Review r WHERE r.property_id = p.property_id) -
        (SELECT AVG(rating) FROM Review)
    ), 2) as above_market_by

FROM Property p
WHERE p.property_id IN (
    SELECT r.property_id
    FROM Review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > (
        -- Platform-wide average rating benchmark
        SELECT AVG(rating) FROM Review
    )
)
ORDER BY above_market_by DESC;

-- ============================================
-- TASK 2: CORRELATED SUBQUERY  
-- Objective: Find users who have made more than 3 bookings
-- ============================================

-- Business Question: "Which users are our most frequent guests and what are their booking patterns?"
-- Why Correlated? We need to count bookings FOR EACH SPECIFIC USER

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.created_at as registration_date,
    
    -- CORRELATED SUBQUERY: Count bookings for THIS specific user
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) as total_bookings,
    
    -- CORRELATED SUBQUERY: Calculate total spent by THIS user
    (SELECT COALESCE(SUM(b.total_price), 0) 
     FROM Booking b 
     WHERE b.user_id = u.user_id 
       AND b.status = 'confirmed') as total_spent,
    
    -- CORRELATED SUBQUERY: Find their latest booking date
    (SELECT MAX(b.start_date) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) as last_booking_date,
    
    -- CORRELATED SUBQUERY: Calculate their average booking value
    (SELECT ROUND(AVG(b.total_price), 2) 
     FROM Booking b 
     WHERE b.user_id = u.user_id 
       AND b.status = 'confirmed') as avg_booking_value,
    
    -- Business insights
    CASE 
        WHEN (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) > 10 THEN 'VIP Guest'
        WHEN (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) > 5 THEN 'Frequent Guest'
        ELSE 'Regular Guest'
    END as guest_tier,
    
    -- Nigerian market insights
    CASE 
        WHEN u.first_name IN ('Adebayo', 'Folake', 'Temitope') THEN 'Yoruba Guest'
        WHEN u.first_name IN ('Chukwuemeka', 'Adaeze', 'Kelechi') THEN 'Igbo Guest'
        WHEN u.first_name IN ('Amina', 'Ibrahim') THEN 'Hausa Guest'
        WHEN u.first_name IN ('Osaze', 'Eghosa') THEN 'Edo Guest'
        ELSE 'Mixed/International Guest'
    END as cultural_background

FROM User u
WHERE u.role = 'guest'  -- Only analyze guest users
  AND (
    -- CORRELATED SUBQUERY CONDITION: Users with more than 3 bookings
    SELECT COUNT(*) 
    FROM Booking b 
    WHERE b.user_id = u.user_id
  ) > 3
ORDER BY total_bookings DESC, total_spent DESC;

-- ============================================
-- ADVANCED CORRELATED SUBQUERY: User Activity Analysis
-- ============================================

-- Business Question: "Show me users who are more active than average users in their registration cohort"
-- This requires comparing each user to their specific cohort average

SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) as full_name,
    u.email,
    YEAR(u.created_at) as registration_year,
    MONTH(u.created_at) as registration_month,
    
    -- This user's booking count
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) as user_bookings,
    
    -- CORRELATED: Average bookings for users who registered in the same month/year
    (SELECT ROUND(AVG(booking_count), 2)
     FROM (
         SELECT COUNT(*) as booking_count
         FROM Booking b2
         WHERE b2.user_id IN (
             SELECT u2.user_id 
             FROM User u2 
             WHERE YEAR(u2.created_at) = YEAR(u.created_at)
               AND MONTH(u2.created_at) = MONTH(u.created_at)
               AND u2.role = 'guest'
         )
         GROUP BY b2.user_id
     ) as cohort_stats
    ) as cohort_average,
    
    -- Performance comparison
    ROUND((
        (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) -
        (SELECT AVG(booking_count)
         FROM (
             SELECT COUNT(*) as booking_count
             FROM Booking b2
             WHERE b2.user_id IN (
                 SELECT u2.user_id 
                 FROM User u2 
                 WHERE YEAR(u2.created_at) = YEAR(u.created_at)
                   AND MONTH(u2.created_at) = MONTH(u.created_at)
                   AND u2.role = 'guest'
             )
             GROUP BY b2.user_id
         ) as cohort_stats)
    ), 2) as above_cohort_average

FROM User u
WHERE u.role = 'guest'
  AND (
    SELECT COUNT(*) 
    FROM Booking b 
    WHERE b.user_id = u.user_id
  ) > (
    -- Compare to cohort average
    SELECT AVG(booking_count)
    FROM (
        SELECT COUNT(*) as booking_count
        FROM Booking b2
        WHERE b2.user_id IN (
            SELECT u2.user_id 
            FROM User u2 
            WHERE YEAR(u2.created_at) = YEAR(u.created_at)
              AND MONTH(u2.created_at) = MONTH(u.created_at)
              AND u2.role = 'guest'
        )
        GROUP BY b2.user_id
    ) as cohort_stats
  )
ORDER BY user_bookings DESC;

-- ============================================
-- SUBQUERY PERFORMANCE COMPARISON
-- ============================================

-- Compare subquery vs JOIN performance for the same business question
-- "Find properties with above-average ratings"

-- Method 1: Using Subquery (What we're practicing)
EXPLAIN
SELECT p.name, p.location
FROM Property p
WHERE p.property_id IN (
    SELECT r.property_id
    FROM Review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
);

-- Method 2: Using JOIN (Alternative approach)
EXPLAIN  
SELECT DISTINCT p.name, p.location
FROM Property p
INNER JOIN (
    SELECT property_id, AVG(rating) as avg_rating
    FROM Review
    GROUP BY property_id
    HAVING AVG(rating) > 4.0
) high_rated ON p.property_id = high_rated.property_id;

-- ============================================
-- COMPLEX BUSINESS SCENARIOS WITH SUBQUERIES
-- ============================================

-- Scenario 1: Properties that earn more than their location's average
-- CORRELATED subquery that changes based on each property's location

SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    
    -- CORRELATED: Calculate average for THIS property's location
    (SELECT ROUND(AVG(p2.pricepernight), 2)
     FROM Property p2
     WHERE SUBSTRING_INDEX(p2.location, ',', -1) = SUBSTRING_INDEX(p.location, ',', -1)
    ) as location_average_price,
    
    -- How much above/below location average
    ROUND(p.pricepernight - (
        SELECT AVG(p2.pricepernight)
        FROM Property p2
        WHERE SUBSTRING_INDEX(p2.location, ',', -1) = SUBSTRING_INDEX(p.location, ',', -1)
    ), 2) as price_difference,
    
    -- Performance indicator
    CASE 
        WHEN p.pricepernight > (
            SELECT AVG(p2.pricepernight)
            FROM Property p2
            WHERE SUBSTRING_INDEX(p2.location, ',', -1) = SUBSTRING_INDEX(p.location, ',', -1)
        ) THEN 'Above Market Rate'
        ELSE 'Below Market Rate'
    END as pricing_position

FROM Property p
WHERE p.pricepernight > (
    -- CORRELATED CONDITION: Price higher than location average
    SELECT AVG(p2.pricepernight)
    FROM Property p2
    WHERE SUBSTRING_INDEX(p2.location, ',', -1) = SUBSTRING_INDEX(p.location, ',', -1)
)
ORDER BY price_difference DESC;

-- ============================================
-- Scenario 2: Hosts who earn more than average hosts with similar property count
-- CORRELATED comparison within similar business profiles
-- ============================================

SELECT 
    host.user_id,
    CONCAT(host.first_name, ' ', host.last_name) as host_name,
    
    -- Property portfolio size
    (SELECT COUNT(*) 
     FROM Property p 
     WHERE p.host_id = host.user_id) as property_count,
    
    -- This host's total earnings
    (SELECT COALESCE(SUM(py.amount), 0)
     FROM Property p2
     JOIN Booking b ON p2.property_id = b.property_id
     JOIN Payment py ON b.booking_id = py.booking_id
     WHERE p2.host_id = host.user_id
       AND b.status = 'confirmed') as host_total_earnings,
    
    -- CORRELATED: Average earnings for hosts with similar property count
    (SELECT ROUND(AVG(host_earnings), 2)
     FROM (
         SELECT SUM(py2.amount) as host_earnings
         FROM User h2
         JOIN Property p3 ON h2.user_id = p3.host_id
         JOIN Booking b2 ON p3.property_id = b2.property_id
         JOIN Payment py2 ON b2.booking_id = py2.booking_id
         WHERE h2.role = 'host'
           AND b2.status = 'confirmed'
           AND (SELECT COUNT(*) FROM Property p4 WHERE p4.host_id = h2.user_id) = 
               (SELECT COUNT(*) FROM Property p5 WHERE p5.host_id = host.user_id)
         GROUP BY h2.user_id
     ) cohort_earnings
    ) as cohort_average_earnings

FROM User host
WHERE host.role = 'host'
  AND (
    -- Only hosts with above-average earnings for their property count
    SELECT COALESCE(SUM(py.amount), 0)
    FROM Property p
    JOIN Booking b ON p.property_id = b.property_id  
    JOIN Payment py ON b.booking_id = py.booking_id
    WHERE p.host_id = host.user_id
      AND b.status = 'confirmed'
  ) > (
    -- CORRELATED CONDITION: Compare to similar hosts' average
    SELECT AVG(host_earnings)
    FROM (
        SELECT SUM(py2.amount) as host_earnings
        FROM User h2
        JOIN Property p2 ON h2.user_id = p2.host_id
        JOIN Booking b2 ON p2.property_id = b2.property_id
        JOIN Payment py2 ON b2.booking_id = py2.booking_id
        WHERE h2.role = 'host'
          AND b2.status = 'confirmed'
          AND (SELECT COUNT(*) FROM Property p3 WHERE p3.host_id = h2.user_id) = 
              (SELECT COUNT(*) FROM Property p4 WHERE p4.host_id = host.user_id)
        GROUP BY h2.user_id
    ) cohort_data
  )
ORDER BY host_total_earnings DESC;

-- ============================================
-- UNDERSTANDING QUERY EXECUTION
-- ============================================

-- Let's analyze how these subqueries execute

-- Query 1: Simple Non-Correlated Subquery Breakdown
-- Step 1: Inner subquery runs once
SELECT property_id, AVG(rating) 
FROM Review 
GROUP BY property_id 
HAVING AVG(rating) > 4.0;

-- Step 2: Outer query uses those results
SELECT p.name 
FROM Property p 
WHERE p.property_id IN ('result_from_step_1');

-- Query 2: Correlated Subquery Breakdown  
-- For EACH user in the outer query:
-- Step 1: Count bookings for user_id = 'current_user_id'
-- Step 2: Compare count to 3
-- Step 3: Include user if count > 3
-- Repeat for every user

-- ============================================
-- ADDITIONAL SUBQUERY PATTERNS
-- ============================================

-- Pattern 1: ANY/ALL Subqueries
-- Find properties more expensive than ANY property in Lagos
SELECT name, location, pricepernight
FROM Property 
WHERE pricepernight > ANY (
    SELECT pricepernight 
    FROM Property 
    WHERE location LIKE '%Lagos%'
);

-- Find properties more expensive than ALL properties in a specific area
SELECT name, location, pricepernight  
FROM Property
WHERE pricepernight > ALL (
    SELECT pricepernight
    FROM Property  
    WHERE location LIKE '%Enugu%'
);

-- Pattern 2: Subqueries in SELECT clause (Calculated Columns)
SELECT 
    u.first_name,
    u.last_name,
    u.email,
    
    -- How many bookings has this user made?
    (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) as booking_count,
    
    -- How much has this user spent total?
    (SELECT COALESCE(SUM(b.total_price), 0) 
     FROM Booking b 
     WHERE b.user_id = u.user_id AND b.status = 'confirmed') as total_spent,
    
    -- What percentage of their bookings were confirmed?
    CASE 
        WHEN (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) > 0 THEN
            ROUND(
                (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id AND b.status = 'confirmed') * 100.0 /
                (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id)
            , 2)
        ELSE 0
    END as confirmation_rate

FROM User u
WHERE u.role = 'guest'
ORDER BY booking_count DESC;

-- Pattern 3: Subqueries for Business Rules Validation
-- Find bookings that might have pricing errors

SELECT 
    b.booking_id,
    p.name as property_name,
    b.start_date,
    b.end_date,
    DATEDIFF(b.end_date, b.start_date) as nights,
    p.pricepernight,
    b.total_price,
    
    -- Expected price calculation
    (DATEDIFF(b.end_date, b.start_date) * p.pricepernight) as expected_price,
    
    -- Identify potential pricing discrepancies
    ROUND(b.total_price - (DATEDIFF(b.end_date, b.start_date) * p.pricepernight), 2) as price_difference,
    
    CASE 
        WHEN b.total_price = (DATEDIFF(b.end_date, b.start_date) * p.pricepernight) THEN 'Correct Pricing'
        WHEN b.total_price > (DATEDIFF(b.end_date, b.start_date) * p.pricepernight) THEN 'Includes Fees/Taxes'
        ELSE 'Possible Discount Applied'
    END as pricing_analysis

FROM Booking b
INNER JOIN Property p ON b.property_id = p.property_id
WHERE b.status = 'confirmed'
  AND ABS(b.total_price - (DATEDIFF(b.end_date, b.start_date) * p.pricepernight)) > 1000
ORDER BY ABS(price_difference) DESC;

-- ============================================
-- NIGERIAN MARKET SPECIFIC SUBQUERIES
-- ============================================

-- Business Question: "Which Nigerian cities generate the most booking revenue?"
SELECT 
    SUBSTRING_INDEX(p.location, ',', -1) as nigerian_state,
    COUNT(DISTINCT p.property_id) as properties_in_state,
    COUNT(DISTINCT b.booking_id) as total_bookings,
    
    -- Revenue from this state
    (SELECT COALESCE(SUM(py.amount), 0)
     FROM Property p2
     JOIN Booking b2 ON p2.property_id = b2.property_id
     JOIN Payment py ON b2.booking_id = py.booking_id
     WHERE SUBSTRING_INDEX(p2.location, ',', -1) = SUBSTRING_INDEX(p.location, ',', -1)
       AND b2.status = 'confirmed'
    ) as state_revenue,
    
    -- Average property price in this state
    (SELECT ROUND(AVG(p3.pricepernight), 2)
     FROM Property p3
     WHERE SUBSTRING_INDEX(p3.location, ',', -1) = SUBSTRING_INDEX(p.location, ',', -1)
    ) as avg_property_price,
    
    -- Market position
    CASE 
        WHEN (
            SELECT AVG(p3.pricepernight)
            FROM Property p3
            WHERE SUBSTRING_INDEX(p3.location, ',', -1) = SUBSTRING_INDEX(p.location, ',', -1)
        ) > 75000 THEN 'Premium Market'
        WHEN (
            SELECT AVG(p3.pricepernight) 
            FROM Property p3
            WHERE SUBSTRING_INDEX(p3.location, ',', -1) = SUBSTRING_INDEX(p.location, ',', -1)
        ) > 45000 THEN 'Mid-Tier Market'
        ELSE 'Budget Market'
    END as market_tier

FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id AND b.status = 'confirmed'
GROUP BY SUBSTRING_INDEX(p.location, ',', -1)
ORDER BY state_revenue DESC;

-- ============================================
-- PERFORMANCE OPTIMIZATION EXAMPLES
-- ============================================

-- Show execution plan for correlated vs non-correlated approaches
EXPLAIN 
SELECT u.first_name, (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) as bookings
FROM User u
WHERE (SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id) > 3;

-- Alternative using window functions (often more efficient)
EXPLAIN
SELECT first_name, bookings
FROM (
    SELECT u.first_name, 
           COUNT(b.booking_id) OVER (PARTITION BY u.user_id) as bookings
    FROM User u
    LEFT JOIN Booking b ON u.user_id = b.user_id
    WHERE u.role = 'guest'
) ranked_users
WHERE bookings > 3;
