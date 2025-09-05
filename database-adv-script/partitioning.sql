-- partitioning.sql
-- Table Partitioning Implementation for Airbnb Booking Table
-- This script demonstrates range partitioning by date for performance optimization

-- ===================================
-- BACKUP EXISTING DATA (IMPORTANT!)
-- ===================================

-- Create backup of existing Booking table
CREATE TABLE Booking_backup AS SELECT * FROM Booking;

-- Verify backup
SELECT 'Original Booking table' as source, COUNT(*) as record_count FROM Booking
UNION ALL
SELECT 'Backup table' as source, COUNT(*) as record_count FROM Booking_backup;

-- ===================================
-- DROP EXISTING TABLE AND RECREATE WITH PARTITIONS
-- ===================================

-- Drop the existing table (make sure backup is created first!)
DROP TABLE IF EXISTS Booking;

-- Recreate Booking table with partitioning
CREATE TABLE Booking (
    booking_id VARCHAR(36) PRIMARY KEY,
    property_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    
    -- Constraints
    CHECK (end_date > start_date),
    CHECK (total_price > 0)
) 
-- Partition by RANGE on start_date column
PARTITION BY RANGE (YEAR(start_date)) (
    -- Historical partitions (older data, less frequently accessed)
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    
    -- Current year partition (high activity)
    PARTITION p2024 VALUES LESS THAN (2025),
    
    -- Future partitions (for upcoming bookings)
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    
    -- Catch-all partition for dates beyond 2026
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- ===================================
-- RESTORE DATA FROM BACKUP
-- ===================================

-- Insert data back into partitioned table
INSERT INTO Booking 
SELECT * FROM Booking_backup;

-- Verify data restoration
SELECT COUNT(*) as restored_records FROM Booking;

-- ===================================
-- CREATE INDEXES ON PARTITIONED TABLE
-- ===================================

-- Indexes for optimal performance across partitions
-- Note: Each partition will have its own copy of these indexes

-- Index for date range queries (most common)
CREATE INDEX idx_booking_start_date ON Booking(start_date);
CREATE INDEX idx_booking_date_range ON Booking(start_date, end_date);

-- Index for user bookings
CREATE INDEX idx_booking_user_date ON Booking(user_id, start_date);

-- Index for property bookings  
CREATE INDEX idx_booking_property_date ON Booking(property_id, start_date);

-- Index for status queries
CREATE INDEX idx_booking_status_date ON Booking(status, start_date);

-- ===================================
-- ALTERNATIVE PARTITIONING: BY MONTH (More Granular)
-- ===================================

-- If you need more granular partitioning, use this approach instead:

/*
-- Monthly partitioning example (comment out if using yearly)
CREATE TABLE Booking_monthly (
    booking_id VARCHAR(36) PRIMARY KEY,
    property_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    
    CHECK (end_date > start_date),
    CHECK (total_price > 0)
) 
PARTITION BY RANGE (YEAR(start_date) * 100 + MONTH(start_date)) (
    PARTITION p202401 VALUES LESS THAN (202402),  -- January 2024
    PARTITION p202402 VALUES LESS THAN (202403),  -- February 2024
    PARTITION p202403 VALUES LESS THAN (202404),  -- March 2024
    PARTITION p202404 VALUES LESS THAN (202405),  -- April 2024
    PARTITION p202405 VALUES LESS THAN (202406),  -- May 2024
    PARTITION p202406 VALUES LESS THAN (202407),  -- June 2024
    PARTITION p202407 VALUES LESS THAN (202408),  -- July 2024
    PARTITION p202408 VALUES LESS THAN (202409),  -- August 2024
    PARTITION p202409 VALUES LESS THAN (202410),  -- September 2024
    PARTITION p202410 VALUES LESS THAN (202411),  -- October 2024
    PARTITION p202411 VALUES LESS THAN (202412),  -- November 2024
    PARTITION p202412 VALUES LESS THAN (202501),  -- December 2024
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
*/

-- ===================================
-- PERFORMANCE TEST QUERIES
-- ===================================

-- Query 1: Test date range query performance
-- This should only scan the relevant partition(s)
EXPLAIN PARTITIONS
SELECT booking_id, user_id, property_id, start_date, end_date, total_price
FROM Booking
WHERE start_date BETWEEN '2024-01-01' AND '2024-03-31'
  AND status = 'confirmed';

-- Query 2: Test single month query performance
EXPLAIN PARTITIONS  
SELECT COUNT(*) as january_bookings,
       AVG(total_price) as avg_booking_value
FROM Booking
WHERE start_date >= '2024-01-01' 
  AND start_date < '2024-02-01';

-- Query 3: Test cross-year query (will scan multiple partitions)
EXPLAIN PARTITIONS
SELECT YEAR(start_date) as booking_year,
       COUNT(*) as total_bookings,
       SUM(total_price) as total_revenue
FROM Booking  
WHERE start_date BETWEEN '2023-12-01' AND '2024-02-28'
GROUP BY YEAR(start_date);

-- ===================================
-- PARTITION MANAGEMENT OPERATIONS
-- ===================================

-- View partition information
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_NAME = 'Booking' 
  AND TABLE_SCHEMA = DATABASE()
ORDER BY PARTITION_ORDINAL_POSITION;

-- Add new partition for 2027 (for future growth)
ALTER TABLE Booking ADD PARTITION (
    PARTITION p2027 VALUES LESS THAN (2028)
);

-- Drop old partition (careful - this deletes data!)
-- ALTER TABLE Booking DROP PARTITION p2022;

-- ===================================
-- PERFORMANCE MEASUREMENT QUERIES
-- ===================================

-- Measure query performance before and after partitioning

-- Test 1: Recent bookings query
SET @start_time = NOW(6);
SELECT COUNT(*) FROM Booking 
WHERE start_date >= '2024-01-01' 
  AND status IN ('confirmed', 'pending');
SET @end_time = NOW(6);
SELECT TIMEDIFF(@end_time, @start_time) as recent_bookings_time;

-- Test 2: Specific date range
SET @start_time = NOW(6);
SELECT user_id, COUNT(*) as booking_count, SUM(total_price) as total_spent
FROM Booking 
WHERE start_date BETWEEN '2024-06-01' AND '2024-08-31'
GROUP BY user_id
HAVING booking_count > 1
ORDER BY total_spent DESC
LIMIT 100;
SET @end_time = NOW(6);
SELECT TIMEDIFF(@end_time, @start_time) as date_range_analysis_time;

-- Test 3: Nigerian market analysis (location-based with date filtering)
SET @start_time = NOW(6);
SELECT 
    p.location,
    COUNT(b.booking_id) as bookings,
    AVG(b.total_price) as avg_price
FROM Booking b
INNER JOIN Property p ON b.property_id = p.property_id
WHERE b.start_date >= '2024-01-01'
  AND b.status = 'confirmed'  
  AND p.location IN ('Lagos', 'Abuja', 'Port Harcourt')
GROUP BY p.location
ORDER BY bookings DESC;
SET @end_time = NOW(6);
SELECT TIMEDIFF(@end_time, @start_time) as market_analysis_time;

-- ===================================
-- MAINTENANCE AND MONITORING
-- ===================================

-- Query to monitor partition sizes
SELECT 
    PARTITION_NAME as partition_name,
    TABLE_ROWS as row_count,
    ROUND(DATA_LENGTH/1024/1024, 2) as data_size_mb,
    ROUND(INDEX_LENGTH/1024/1024, 2) as index_size_mb,
    PARTITION_DESCRIPTION as date_range
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'Booking' 
  AND TABLE_SCHEMA = DATABASE()
  AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_ORDINAL_POSITION;

-- Query to analyze query performance by partition
SELECT 
    PARTITION_NAME,
    'SELECT COUNT(*) FROM Booking PARTITION(' + PARTITION_NAME + ')' as test_query
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'Booking' 
  AND TABLE_SCHEMA = DATABASE()
  AND PARTITION_NAME IS NOT NULL;

-- Clean up backup table (optional, after verifying partitioning works)
-- DROP TABLE Booking_backup;
