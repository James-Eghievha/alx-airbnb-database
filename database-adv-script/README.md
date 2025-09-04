# Advanced SQL Joins - Airbnb Database

## Overview
This directory contains advanced SQL join queries demonstrating complex data retrieval techniques for the Airbnb clone database. These queries showcase real-world scenarios for combining data from multiple tables to extract meaningful business insights.

## Learning Objectives
By completing these join queries, you will master:
- **INNER JOIN**: Retrieving only matching records from multiple tables
- **LEFT JOIN**: Preserving all records from the primary table while including related data
- **FULL OUTER JOIN**: Combining complete datasets from both tables regardless of matches
- **Complex query construction**: Building multi-table queries with filtering and sorting
- **Data analysis**: Extracting business intelligence from relational data

## Join Types Explained

### INNER JOIN
**Purpose**: Find only records that have matching relationships in both tables
**Business Use**: "Show me confirmed bookings with complete user information"
**Analogy**: "Show me only students who are actually enrolled in classes"

### LEFT JOIN  
**Purpose**: Show all records from the first table, plus any matching data from the second table
**Business Use**: "Show me all properties, including those that haven't been reviewed yet"
**Analogy**: "Show me all menu items, including ones no one has ordered yet"

### FULL OUTER JOIN
**Purpose**: Combine complete datasets from both tables, showing everything
**Business Use**: "Show me all users and all bookings, highlighting orphaned records"
**Analogy**: "Show me all customers and all orders, including customers who never bought anything"

## Nigerian Market Context
These queries include considerations for the Nigerian market:
- Multi-cultural naming conventions (Yoruba, Igbo, Hausa names)
- Nigerian geographic locations (Lagos, Abuja, Port Harcourt)
- Local currency formatting (Nigerian Naira)
- Cultural hospitality patterns reflected in reviews

## Query Categories

### 1. Business Intelligence Queries
- Host performance analysis
- Revenue tracking by location
- Guest booking patterns
- Property utilization rates

### 2. Operational Queries
- Booking management with user details
- Property inventory with review data
- Payment reconciliation across tables
- User activity comprehensive views

### 3. Analytical Queries
- Market trends analysis
- Host and guest relationship mapping
- Property performance correlations
- Revenue optimization insights

## Performance Considerations
All queries are optimized using:
- Appropriate indexes on join columns
- Efficient WHERE clause positioning
- Strategic use of LIMIT for large datasets
- Query execution plan analysis

## Files Description
- `joins_queries.sql`: Complete collection of advanced join queries
- `README.md`: This documentation file

## Usage Instructions
1. Ensure your Airbnb database is populated with sample data
2. Execute queries in the provided order
3. Analyze results and execution plans
4. Modify queries to explore different business scenarios

---
*Part of ALX Advanced Database Module*
*Author: James Eghievha*
*Date: 04 September 2025*
