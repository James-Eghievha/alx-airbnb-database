-- ============================================
-- Advanced SQL Joins - Airbnb Database Analysis
-- Author: [Your Name]
-- Date: [Current Date]
-- Course: ALX Advanced Database Module
-- ============================================

-- ============================================
-- TASK 1: INNER JOIN
-- Objective: Retrieve all bookings and the respective users who made those bookings
-- ============================================

-- Business Question: "Show me all confirmed bookings with complete guest information"
-- Why INNER JOIN? We only want bookings that have valid user records (data integrity)

SELECT 
    -- Booking information
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    DATEDIFF(b.end_date, b.start_date) as nights_stayed,
    
    -- User (Guest) information
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    
    -- Calculated fields for business insights
    ROUND(b.total_price / DATEDIFF(b.end_date, b.start_date), 2) as price_per_night,
    CASE 
        WHEN b.total_price > 200000 THEN 'Premium Booking'
        WHEN b.total_price > 100000 THEN 'Standard Booking'
        ELSE 'Budget Booking'
    END as booking_category,
    
    -- Format Nigerian currency
    CONCAT('₦', FORMAT(b.total_price, 0)) as formatted_price

FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
WHERE b.status IN ('confirmed', 'pending')  -- Only active bookings
ORDER BY b.created_at DESC;

-- ============================================
-- ENHANCED INNER JOIN: Bookings with Complete Context
-- ============================================

-- Business Question: "Show me booking details with guest AND property information"
-- Triple INNER JOIN: Booking + User + Property

SELECT 
    -- Booking core data
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    b.total_price,
    
    -- Guest information
    guest.first_name as guest_first_name,
    guest.last_name as guest_last_name,
    guest.email as guest_email,
    guest.phone_number as guest_phone,
    
    -- Property information
    p.name as property_name,
    p.location as property_location,
    p.pricepernight as property_rate,
    
    -- Host information (property owner)
    host.first_name as host_first_name,
    host.last_name as host_last_name,
    host.email as host_email,
    
    -- Business calculations
    DATEDIFF(b.end_date, b.start_date) as nights_booked,
    ROUND((b.total_price - (DATEDIFF(b.end_date, b.start_date) * p.pricepernight)), 2) as fees_taxes

FROM Booking b
INNER JOIN User guest ON b.user_id = guest.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User host ON p.host_id = host.user_id
WHERE 
    b.status = 'confirmed'
    AND b.start_date >= '2024-01-01'
ORDER BY b.total_price DESC
LIMIT 20;

-- ============================================
-- TASK 2: LEFT JOIN  
-- Objective: Retrieve all properties and their reviews, including properties with no reviews
-- ============================================

-- Business Question: "Show me all properties with their review status (including unreviewed ones)"
-- Why LEFT JOIN? We want to see ALL properties, even those with no reviews

SELECT 
    -- Property information (all properties will appear)
    p.property_id,
    p.name as property_name,
    p.location,
    p.pricepernight,
    p.created_at as property_created,
    
    -- Host information
    u.first_name as host_name,
    u.last_name as host_surname,
    
    -- Review information (NULL for properties with no reviews)
    r.review_id,
    r.rating,
    r.comment,
    r.created_at as review_date,
    
    -- Review statistics per property
    COUNT(r.review_id) as total_reviews,
    ROUND(AVG(r.rating), 2) as average_rating,
    
    -- Business insights
    CASE 
        WHEN COUNT(r.review_id) = 0 THEN 'New Property - No Reviews Yet'
        WHEN AVG(r.rating) >= 4.5 THEN 'Highly Rated Property'
        WHEN AVG(r.rating) >= 3.5 THEN 'Good Property'
        WHEN AVG(r.rating) >= 2.5 THEN 'Average Property'
        ELSE 'Needs Improvement'
    END as property_status,
    
    -- Nigerian market insights
    CASE 
        WHEN p.location LIKE '%Lagos%' THEN 'Commercial Hub'
        WHEN p.location LIKE '%Abuja%' THEN 'Government District'
        WHEN p.location LIKE '%Port Harcourt%' THEN 'Oil & Gas Center'
        ELSE 'Cultural/Tourism Destination'
    END as market_segment

FROM Property p
-- LEFT JOIN ensures ALL properties appear, even without reviews
LEFT JOIN Review r ON p.property_id = r.property_id
-- INNER JOIN for host info (every property must have a host)
INNER JOIN User u ON p.host_id = u.user_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight, p.created_at,
    u.first_name, u.last_name, r.review_id, r.rating, r.comment, r.created_at
ORDER BY p.created_at DESC;

-- ============================================
-- SIMPLIFIED LEFT JOIN: Properties with Review Summary
-- ============================================

-- Cleaner version focusing on review statistics per property
SELECT 
    p.property_id,
    p.name,
    p.location,
    CONCAT('₦', FORMAT(p.pricepernight, 0)) as formatted_price,
    
    -- Host details
    CONCAT(u.first_name, ' ', u.last_name) as host_name,
    
    -- Review aggregates (NULL becomes 0 for properties without reviews)
    COALESCE(COUNT(r.review_id), 0) as review_count,
    COALESCE(ROUND(AVG(r.rating), 2), 0) as avg_rating,
    
    -- Latest review date
    MAX(r.created_at) as latest_review_date,
    
    -- Property performance indicator
    CASE 
        WHEN COUNT(r.review_id) = 0 THEN 'Unreviewed'
        WHEN AVG(r.rating) >= 4.5 THEN 'Top Rated'
        WHEN AVG(r.rating) >= 4.0 THEN 'Highly Rated'
        WHEN AVG(r.rating) >= 3.0 THEN 'Well Rated'
        ELSE 'Needs Attention'
    END as rating_status

FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
INNER JOIN User u ON p.host_id = u.user_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight, u.first_name, u.last_name
ORDER BY avg_rating DESC, review_count DESC;

-- ============================================
-- TASK 3: FULL OUTER JOIN
-- Objective: Retrieve all users and all bookings, even if user has no booking or booking has no user
-- ============================================

-- NOTE: MySQL doesn't support FULL OUTER JOIN directly
-- We simulate it using UNION of LEFT JOIN and RIGHT JOIN

-- Business Question: "Show me complete user-booking relationship map, including orphaned records"
-- This helps identify data integrity issues and complete user engagement picture

-- Method 1: UNION Simulation of FULL OUTER JOIN
(
    -- LEFT JOIN: All users, with their bookings (if any)
    SELECT 
        u.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.role,
        u.created_at as user_joined_date,
        
        b.booking_id,
        b.property_id,
        b.start_date,
        b.end_date,
        b.total_price,
        b.status,
        
        -- User activity analysis
        CASE 
            WHEN b.booking_id IS NULL THEN 'No Bookings Yet'
            WHEN b.status = 'confirmed' THEN 'Active Guest'
            WHEN b.status = 'pending' THEN 'Potential Guest'
            ELSE 'Past Guest'
        END as user_booking_status,
        
        -- Flag the join source
        'USER_FOCUSED' as data_source
        
    FROM User u
    LEFT JOIN Booking b ON u.user_id = b.user_id
    WHERE u.role IN ('guest', 'host')  -- Exclude admin from guest analysis
)

UNION

(
    -- RIGHT JOIN equivalent: All bookings, with their users (if any)
    SELECT 
        u.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.role,
        u.created_at as user_joined_date,
        
        b.booking_id,
        b.property_id,
        b.start_date,
        b.end_date,
        b.total_price,
        b.status,
        
        -- Booking integrity analysis
        CASE 
            WHEN u.user_id IS NULL THEN 'ORPHANED BOOKING - Data Issue'
            WHEN u.role = 'guest' THEN 'Valid Guest Booking'
            ELSE 'Host Self-Booking'
        END as user_booking_status,
        
        -- Flag the join source
        'BOOKING_FOCUSED' as data_source
        
    FROM User u
    RIGHT JOIN Booking b ON u.user_id = b.user_id
)

ORDER BY user_id, booking_id;

-- ============================================
-- ENHANCED FULL OUTER JOIN: Complete Engagement Analysis
-- ============================================

-- Business Question: "Give me a complete picture of user engagement across the platform"
-- Shows users who book, users who host, users who do both, and inactive users

SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) as full_name,
    u.email,
    u.role,
    u.created_at as registration_date,
    
    -- Booking activity (as guest)
    guest_bookings.booking_count as bookings_as_guest,
    guest_bookings.total_spent,
    guest_bookings.last_booking_date,
    
    -- Property hosting activity (as host)
    host_properties.property_count as properties_owned,
    host_properties.total_earned,
    host_properties.host_rating,
    
    -- Overall platform engagement score
    COALESCE(guest_bookings.booking_count, 0) + 
    COALESCE(host_properties.property_count * 2, 0) +
    CASE WHEN u.role = 'host' THEN 5 ELSE 0 END as engagement_score,
    
    -- User classification
    CASE 
        WHEN guest_bookings.booking_count > 0 AND host_properties.property_count > 0 THEN 'Host & Guest'
        WHEN host_properties.property_count > 0 THEN 'Host Only' 
        WHEN guest_bookings.booking_count > 0 THEN 'Guest Only'
        ELSE 'Inactive User'
    END as user_type,
    
    -- Nigerian cultural context
    CASE 
        WHEN u.first_name IN ('Adebayo', 'Folake', 'Temitope') THEN 'Yoruba'
        WHEN u.first_name IN ('Chukwuemeka', 'Adaeze', 'Kelechi') THEN 'Igbo'
        WHEN u.first_name IN ('Amina', 'Ibrahim') THEN 'Hausa'
        WHEN u.first_name IN ('Osaze', 'Eghosa') THEN 'Edo'
        ELSE 'Mixed/Other'
    END as cultural_background

FROM User u

-- LEFT JOIN for guest booking activity
LEFT JOIN (
    SELECT 
        b.user_id,
        COUNT(b.booking_id) as booking_count,
        SUM(b.total_price) as total_spent,
        MAX(b.created_at) as last_booking_date
    FROM Booking b
    WHERE b.status = 'confirmed'
    GROUP BY b.user_id
) guest_bookings ON u.user_id = guest_bookings.user_id

-- LEFT JOIN for host property activity
LEFT JOIN (
    SELECT 
        p.host_id,
        COUNT(p.property_id) as property_count,
        COALESCE(SUM(py.amount), 0) as total_earned,
        COALESCE(AVG(r.rating), 0) as host_rating
    FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id AND b.status = 'confirmed'
    LEFT JOIN Payment py ON b.booking_id = py.booking_id
    LEFT JOIN Review r ON p.property_id = r.property_id
    GROUP BY p.host_id
) host_properties ON u.user_id = host_properties.host_id

ORDER BY engagement_score DESC, u.created_at;

-- ============================================
-- ADVANCED JOIN SCENARIOS - Real-World Business Queries
-- ============================================

-- Query 4: Multi-table join with aggregations
-- "Show me the most popular properties by location with host and guest info"

SELECT 
    p.location,
    p.name as property_name,
    CONCAT(host.first_name, ' ', host.last_name) as host_name,
    
    -- Booking statistics
    COUNT(DISTINCT b.booking_id) as total_bookings,
    COUNT(DISTINCT b.user_id) as unique_guests,
    ROUND(AVG(b.total_price), 2) as average_booking_value,
    SUM(b.total_price) as total_revenue,
    
    -- Review statistics
    COUNT(DISTINCT r.review_id) as total_reviews,
    ROUND(AVG(r.rating), 2) as average_rating,
    
    -- Performance metrics
    ROUND(
        COUNT(DISTINCT b.booking_id) / 
        GREATEST(DATEDIFF(CURDATE(), p.created_at) / 30.44, 1), 2
    ) as bookings_per_month

FROM Property p
INNER JOIN User host ON p.host_id = host.user_id
LEFT JOIN Booking b ON p.property_id = b.property_id AND b.status = 'confirmed'
LEFT JOIN Review r ON p.property_id = r.property_id  
LEFT JOIN Payment py ON b.booking_id = py.booking_id
GROUP BY p.property_id, p.location, p.name, host.first_name, host.last_name
HAVING COUNT(DISTINCT b.booking_id) > 0  -- Only properties with bookings
ORDER BY total_bookings DESC, average_rating DESC
LIMIT 10;

-- ============================================
-- Query 5: Complex JOIN with Nigerian Market Analysis
-- ============================================

-- "Analyze guest travel patterns across Nigerian regions"
SELECT 
    -- Guest demographics
    CONCAT(u.first_name, ' ', u.last_name) as guest_name,
    u.email,
    
    -- Travel pattern analysis
    COUNT(DISTINCT b.booking_id) as total_trips,
    COUNT(DISTINCT 
        CASE WHEN p.location LIKE '%Lagos%' THEN p.property_id END
    ) as lagos_stays,
    COUNT(DISTINCT 
        CASE WHEN p.location LIKE '%Abuja%' THEN p.property_id END  
    ) as abuja_stays,
    COUNT(DISTINCT 
        CASE WHEN p.location LIKE '%Port Harcourt%' THEN p.property_id END
    ) as port_harcourt_stays,
    
    -- Financial analysis
    SUM(b.total_price) as total_spent,
    ROUND(AVG(b.total_price), 2) as avg_trip_cost,
    MIN(b.start_date) as first_trip,
    MAX(b.start_date) as last_trip,
    
    -- Travel frequency
    ROUND(
        COUNT(DISTINCT b.booking_id) / 
        GREATEST(DATEDIFF(CURDATE(), MIN(b.start_date)) / 365, 1), 2
    ) as trips_per_year,
    
    -- Guest value classification
    CASE 
        WHEN SUM(b.total_price) > 500000 THEN 'VIP Guest'
        WHEN SUM(b.total_price) > 200000 THEN 'Premium Guest'
        WHEN SUM(b.total_price) > 50000 THEN 'Regular Guest'
        ELSE 'Budget Traveler'
    END as guest_category

FROM User u
INNER JOIN Booking b ON u.user_id = b.user_id
INNER JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment py ON b.booking_id = py.booking_id
WHERE 
    u.role = 'guest'
    AND b.status = 'confirmed'
    AND py.payment_id IS NOT NULL  -- Only paid bookings
GROUP BY u.user_id, u.first_name, u.last_name, u.email
HAVING COUNT(DISTINCT b.booking_id) >= 1  -- Active guests only
ORDER BY total_spent DESC;

-- ============================================
-- QUERY PERFORMANCE ANALYSIS
-- ============================================

-- Always analyze your complex queries for performance
EXPLAIN FORMAT=JSON
SELECT b.booking_id, u.first_name, p.name 
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
WHERE b.start_date >= '2024-01-01';

-- Check if indexes are being used effectively
EXPLAIN 
SELECT p.name, COUNT(r.review_id), AVG(r.rating)
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name;

-- ============================================
-- BUSINESS INTELLIGENCE QUERIES
-- ============================================

-- Query 6: Revenue analysis by host performance
-- "Which hosts generate the most revenue and how?"

SELECT 
    host.user_id as host_id,
    CONCAT(host.first_name, ' ', host.last_name) as host_name,
    host.email as host_email,
    
    -- Property portfolio
    COUNT(DISTINCT p.property_id) as total_properties,
    GROUP_CONCAT(DISTINCT p.location ORDER BY p.location) as locations_served,
    
    -- Revenue metrics
    COUNT(DISTINCT b.booking_id) as total_bookings,
    SUM(COALESCE(py.amount, 0)) as total_revenue,
    ROUND(AVG(py.amount), 2) as avg_booking_value,
    
    -- Performance ratios
    ROUND(
        SUM(COALESCE(py.amount, 0)) / COUNT(DISTINCT p.property_id), 2
    ) as revenue_per_property,
    ROUND(
        COUNT(DISTINCT b.booking_id) / COUNT(DISTINCT p.property_id), 2
    ) as bookings_per_property,
    
    -- Host efficiency score
    ROUND(
        (SUM(COALESCE(py.amount, 0)) / 1000) * 
        (AVG(COALESCE(r.rating, 3)) / 5) * 
        (COUNT(DISTINCT b.booking_id) / COUNT(DISTINCT p.property_id)), 2
    ) as efficiency_score

FROM User host
INNER JOIN Property p ON host.user_id = p.host_id
LEFT JOIN Booking b ON p.property_id = b.property_id AND b.status = 'confirmed'  
LEFT JOIN Payment py ON b.booking_id = py.booking_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE host.role = 'host'
GROUP BY host.user_id, host.first_name, host.last_name, host.email
HAVING COUNT(DISTINCT p.property_id) > 0  -- Hosts with at least one property
ORDER BY total_revenue DESC
LIMIT 15;
