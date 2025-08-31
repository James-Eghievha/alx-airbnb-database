# Airbnb Database ERD Requirements

## Project Overview
This Entity-Relationship Diagram (ERD) represents the database design for an Airbnb clone application. The design focuses on core functionalities including user management, property listings, bookings, payments, reviews, and messaging.

## Entities and Relationships

### 1. User Entity
- **Purpose**: Stores information about all users (guests, hosts, admins)
- **Primary Key**: user_id (UUID)
- **Key Attributes**: 
  - Personal info (first_name, last_name, email, phone_number)
  - Security (password_hash)
  - Authorization (role: guest/host/admin)
- **Relationships**:
  - One-to-many with Property (as host)
  - One-to-many with Booking (as guest)
  - One-to-many with Review (as reviewer)
  - One-to-many with Message (as sender and recipient)

### 2. Property Entity
- **Purpose**: Stores rental property information
- **Primary Key**: property_id (UUID)
- **Foreign Keys**: host_id → User(user_id)
- **Key Attributes**: name, description, location, pricepernight
- **Relationships**:
  - Many-to-one with User (host)
  - One-to-many with Booking
  - One-to-many with Review

### 3. Booking Entity
- **Purpose**: Manages property reservations
- **Primary Key**: booking_id (UUID)
- **Foreign Keys**: 
  - property_id → Property(property_id)
  - user_id → User(user_id)
- **Key Attributes**: start_date, end_date, total_price, status
- **Relationships**:
  - Many-to-one with Property
  - Many-to-one with User (guest)
  - One-to-one with Payment

### 4. Payment Entity
- **Purpose**: Tracks payment transactions
- **Primary Key**: payment_id (UUID)
- **Foreign Keys**: booking_id → Booking(booking_id)
- **Key Attributes**: amount, payment_date, payment_method
- **Relationships**:
  - One-to-one with Booking

### 5. Review Entity
- **Purpose**: Stores property reviews and ratings
- **Primary Key**: review_id (UUID)
- **Foreign Keys**: 
  - property_id → Property(property_id)
  - user_id → User(user_id)
- **Key Attributes**: rating (1-5), comment
- **Relationships**:
  - Many-to-one with Property
  - Many-to-one with User

### 6. Message Entity
- **Purpose**: Facilitates communication between users
- **Primary Key**: message_id (UUID)
- **Foreign Keys**: 
  - sender_id → User(user_id)
  - recipient_id → User(user_id)
- **Key Attributes**: message_body, sent_at
- **Relationships**:
  - Many-to-one with User (as sender)
  - Many-to-one with User (as recipient)

## Key Design Decisions

### Normalization
- Each entity has a single responsibility
- Foreign keys properly reference related entities
- No redundant data storage

### Data Integrity
- Primary keys ensure unique identification
- Foreign key constraints maintain referential integrity
- Check constraints validate data ranges (e.g., rating 1-5)
- ENUM constraints limit field values to valid options

### Performance Considerations
- Primary keys automatically indexed
- Additional indexes on frequently queried fields (email, property_id, booking_id)
- UUID primary keys ensure global uniqueness and scalability

## Business Rules Enforced

1. **User Management**: Unique emails prevent duplicate accounts
2. **Property Ownership**: Only users can own properties (host_id references User)
3. **Booking Logic**: Each booking links one guest to one property
4. **Payment Tracking**: Every booking has exactly one payment record
5. **Review System**: Users can review properties they've potentially stayed at
6. **Messaging**: Users can communicate with each other

## Created by:James Eghievha
## Date: 27 August 2025
## Project: ALX Airbnb Database Design

