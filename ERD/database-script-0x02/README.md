# Database Seeding

## Overview
This directory contains SQL scripts to populate the Airbnb clone database with realistic sample data representing Nigerian diversity and culture.

## Files
- `seed.sql` - Complete database seeding script with sample data
- `README.md` - This documentation file

## Sample Data Features
- **Diverse Nigerian Names**: Representing Igbo, Yoruba, Hausa, Edo, and English names
- **Nigerian Locations**: Properties across major Nigerian cities (Lagos, Abuja, Port Harcourt, etc.)
- **Realistic Scenarios**: Complete booking workflows with payments and reviews
- **Cultural Context**: Properties and descriptions reflecting Nigerian hospitality and locations

## Data Structure
The seed data includes:
- **Users**: 15 diverse users (guests, hosts, admins) with Nigerian names
- **Properties**: 10 properties across Nigeria with local descriptions
- **Bookings**: 8 realistic bookings with proper date ranges
- **Payments**: Corresponding payments for confirmed bookings
- **Reviews**: Authentic reviews reflecting Nigerian hospitality
- **Messages**: Communication between hosts and guests

## Usage
To populate the database:
```sql
-- Ensure schema is created first
source database-script-0x01/schema.sql;

-- Then run the seeding script
source database-script-0x02/seed.sql;
```

## Data Relationships
The sample data maintains referential integrity:
- All bookings reference valid users and properties
- All payments reference valid bookings
- All reviews reference valid users and properties
- All messages reference valid sender/recipient users

Created by: James Eghievha
Date: 31 August 2025
