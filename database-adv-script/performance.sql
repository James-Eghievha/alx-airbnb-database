-- performance.sql
-- Initial Complex Query: All booking details with user, property, and payment info
-- This query demonstrates common performance issues before optimization

-- ===================================
-- INITIAL UNOPTIMIZED QUERY
-- ===================================

-- Query 1: Retrieve all bookings with complete details (INEFFICIENT VERSION)
SELECT 
    -- Booking details
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at as booking_date,
    
    -- User details (Guest)
    u.user_id,
    u.first_name as guest_first_name,
    u.last_name as guest_last_name,
    u.email as guest_email,
    u.phone_number as guest_phone,
    u.role as guest_role,
    u.created_at as guest_registration_date,
    
    -- Property details
    p.property_id,
    p.name as property_name,
    p.description as property_description,
    p.location as property_location,
    p.pricepernight,
    p.created_at as property_created_date,
    
    -- Host details
    h.user_id as host_id,
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    h.email as host_email,
    h.phone_number as host_phone,
    
    -- Payment details
    pay.payment_id,
    pay.amount as payment_amount,
    pay.payment_date,
    pay.payment_method
    
FROM Booking b
-- Join with guest user information
LEFT JOIN User u ON b.user_id = u.user_id
-- Join with property information
LEFT JOIN Property p ON b.property_id = p.property_id
-- Join with host information through property
LEFT JOIN User h ON p.host_id = h.user_id
-- Join with payment information
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id

-- No WHERE clause - retrieves ALL data
ORDER BY b.created_at DESC;

-- ===================================
-- PERFORMANCE ANALYSIS COMMANDS
-- ===================================

-- Command to analyze query performance
EXPLAIN ANALYZE 
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name as guest_name,
    u.email as guest_email,
    p.name as property_name,
    p.location,
    p.pricepernight,
    h.first_name as host_name,
    pay.amount as payment_amount,
    pay.payment_method
FROM Booking b
LEFT JOIN User u ON b.user_id = u.user_id
LEFT JOIN Property p ON b.property_id = p.property_id
LEFT JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- ===================================
-- IDENTIFYING PERFORMANCE BOTTLENECKS
-- ===================================

-- Check table sizes to understand data volume
SELECT 
    'User' as table_name,
    COUNT(*) as row_count
FROM User
UNION ALL
SELECT 
    'Property' as table_name,
    COUNT(*) as row_count
FROM Property
UNION ALL
SELECT 
    'Booking' as table_name,
    COUNT(*) as row_count
FROM Booking
UNION ALL
SELECT 
    'Payment' as table_name,
    COUNT(*) as row_count
FROM Payment;

-- ===================================
-- OPTIMIZED QUERY VERSIONS
-- ===================================

-- Query 2: Optimized version with selective columns and filtering
-- (Only retrieve recent bookings - last 6 months)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- Only essential user information
    u.first_name,
    u.last_name,
    u.email,
    
    -- Only essential property information  
    p.name as property_name,
    p.location,
    p.pricepernight,
    
    -- Host name only
    h.first_name as host_name,
    h.last_name as host_name_last,
    
    -- Payment essentials
    pay.amount,
    pay.payment_method
    
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id

-- Filter for recent bookings only
WHERE b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
  AND b.status IN ('confirmed', 'completed')

-- Limit results and optimize sorting
ORDER BY b.created_at DESC
LIMIT 1000;

-- Query 3: Further optimized with subquery for specific use case
-- Nigerian market focus - properties in major cities
SELECT 
    booking_details.booking_id,
    booking_details.guest_name,
    booking_details.property_name,
    booking_details.location,
    booking_details.total_price,
    booking_details.status,
    booking_details.payment_amount
FROM (
    SELECT 
        b.booking_id,
        CONCAT(u.first_name, ' ', u.last_name) as guest_name,
        p.name as property_name,
        p.location,
        b.total_price,
        b.status,
        pay.amount as payment_amount,
        b.created_at
    FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
    
    -- Focus on Nigerian major cities
    WHERE p.location IN ('Lagos', 'Abuja', 'Port Harcourt', 'Kano', 'Ibadan')
      AND b.status = 'confirmed'
      AND b.start_date >= CURRENT_DATE
      
) as booking_details
ORDER BY booking_details.created_at DESC
LIMIT 100;

-- ===================================
-- PERFORMANCE COMPARISON QUERIES
-- ===================================

-- Before optimization - measure execution time
SET @start_time = NOW(6);
SELECT COUNT(*) FROM (
    SELECT b.booking_id
    FROM Booking b
    LEFT JOIN User u ON b.user_id = u.user_id
    LEFT JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
) as full_query;
SET @end_time = NOW(6);
SELECT TIMEDIFF(@end_time, @start_time) as unoptimized_execution_time;

-- After optimization - measure execution time  
SET @start_time = NOW(6);
SELECT COUNT(*) FROM (
    SELECT b.booking_id
    FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    WHERE b.status = 'confirmed'
      AND b.created_at >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
) as optimized_query;
SET @end_time = NOW(6);
SELECT TIMEDIFF(@end_time, @start_time) as optimized_execution_time;
