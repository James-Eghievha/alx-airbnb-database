-- =====================================================
-- Airbnb Clone Database Schema
-- =====================================================
-- This script creates the complete database schema for the Airbnb clone project
-- Following 3NF normalization principles

-- Drop database if exists and create fresh
DROP DATABASE IF EXISTS airbnb_clone;
CREATE DATABASE airbnb_clone;
USE airbnb_clone;

-- =====================================================
-- 1. USER TABLE
-- =====================================================
-- Stores all user information (guests, hosts, admins)
CREATE TABLE User (
    user_id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    role ENUM('guest', 'host', 'admin') NOT NULL DEFAULT 'guest',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index on email for fast login lookups
CREATE INDEX idx_user_email ON User(email);

-- =====================================================
-- 2. PROPERTY TABLE
-- =====================================================
-- Stores property listings that hosts offer for rent
CREATE TABLE Property (
    property_id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    host_id VARCHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    pricepernight DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key constraint: property must belong to a valid host
    FOREIGN KEY (host_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- Indexes for performance optimization
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_price ON Property(pricepernight);

-- =====================================================
-- 3. BOOKING TABLE
-- =====================================================
-- Stores booking information when guests book properties
CREATE TABLE Booking (
    booking_id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    
    -- Business logic constraints
    CHECK (end_date > start_date),
    CHECK (total_price > 0)
);

-- Indexes for common queries
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_status ON Booking(status);

-- =====================================================
-- 4. PAYMENT TABLE
-- =====================================================
-- Stores payment information for bookings
CREATE TABLE Payment (
    payment_id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    booking_id VARCHAR(36) NOT NULL UNIQUE,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,
    
    -- Foreign key constraint: payment must be for a valid booking
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE,
    
    -- Business logic constraints
    CHECK (amount > 0)
);

-- Index on booking_id for fast payment lookups
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);

-- =====================================================
-- 5. REVIEW TABLE
-- =====================================================
-- Stores reviews that users write about properties
CREATE TABLE Review (
    review_id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    
    -- Business logic constraints
    CHECK (rating >= 1 AND rating <= 5)
);

-- Indexes for common queries
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);

-- =====================================================
-- 6. MESSAGE TABLE
-- =====================================================
-- Stores messages between users (hosts and guests communication)
CREATE TABLE Message (
    message_id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    sender_id VARCHAR(36) NOT NULL,
    recipient_id VARCHAR(36) NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (sender_id) REFERENCES User(user_id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES User(user_id) ON DELETE CASCADE,
    
    -- Business logic: user cannot send message to themselves
    CHECK (sender_id != recipient_id)
);

-- Indexes for message queries
CREATE INDEX idx_message_sender_id ON Message(sender_id);
CREATE INDEX idx_message_recipient_id ON Message(recipient_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);

-- =====================================================
-- PERFORMANCE OPTIMIZATIONS
-- =====================================================

-- Composite indexes for common multi-column queries
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);

-- =====================================================
-- SCHEMA CREATION COMPLETE
-- =====================================================
-- Database schema successfully created with:
-- ✅ 6 normalized tables
-- ✅ Primary and foreign key constraints
-- ✅ Data type validation
-- ✅ Business logic constraints
-- ✅ Performance-optimized indexes
