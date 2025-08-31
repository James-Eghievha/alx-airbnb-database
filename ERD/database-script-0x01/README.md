# Database Schema Creation

## Overview
This directory contains SQL scripts for creating the Airbnb clone database schema.

## Files
- `schema.sql` - Complete database schema with tables, constraints, and indexes
- `README.md` - This documentation file

## Database Design
The schema implements a normalized relational database design supporting:
- User management (guests, hosts, admins)
- Property listings and management
- Booking system with status tracking
- Payment processing
- Review and rating system
- Messaging between users

## Schema Features
- **Primary Keys**: UUID-based for all entities
- **Foreign Keys**: Proper referential integrity
- **Constraints**: Data validation and business rules
- **Indexes**: Optimized for common query patterns
- **Normalization**: Follows 3NF principles

## Usage
To create the database:
```sql
-- Run the schema.sql file in your MySQL/PostgreSQL environment
source schema.sql;
```

## Entity Relationships
Based on the ERD design:
- Users can be guests, hosts, or admins
- Hosts can own multiple properties
- Properties can receive multiple bookings
- Each booking has one payment
- Users can write multiple reviews
- Properties can receive multiple reviews
- Users can send/receive multiple messages

Created by: James Eghievha
Date: 31 August 2025
