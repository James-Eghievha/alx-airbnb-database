-- =====================================================
-- Airbnb Clone Database Seeding Script
-- Nigerian-Themed Sample Data
-- =====================================================
-- This script populates the database with realistic sample data
-- representing Nigerian diversity and culture

USE airbnb_clone;

-- =====================================================
-- 1. SEED USER TABLE
-- =====================================================
-- Creating diverse users representing different Nigerian cultures

INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
-- Yoruba Users
('550e8400-e29b-41d4-a716-446655440001', 'Adebayo', 'Ogundimu', 'adebayo.ogundimu@gmail.com', 'hashed_password_123', '+2348123456789', 'host', '2024-01-15 10:00:00'),
('550e8400-e29b-41d4-a716-446655440002', 'Folake', 'Adeniran', 'folake.adeniran@yahoo.com', 'hashed_password_456', '+2348123456788', 'guest', '2024-01-20 14:30:00'),
('550e8400-e29b-41d4-a716-446655440003', 'Temitope', 'Bakare', 'temitope.bakare@outlook.com', 'hashed_password_789', '+2348123456787', 'host', '2024-02-01 09:15:00'),

-- Igbo Users
('550e8400-e29b-41d4-a716-446655440004', 'Chukwuemeka', 'Okafor', 'chukwuemeka.okafor@gmail.com', 'hashed_password_101', '+2348123456786', 'guest', '2024-02-05 16:45:00'),
('550e8400-e29b-41d4-a716-446655440005', 'Adaeze', 'Okwu', 'adaeze.okwu@gmail.com', 'hashed_password_102', '+2348123456785', 'host', '2024-02-10 11:20:00'),
('550e8400-e29b-41d4-a716-446655440006', 'Kelechi', 'Nwosu', 'kelechi.nwosu@yahoo.com', 'hashed_password_103', '+2348123456784', 'guest', '2024-02-15 13:00:00'),

-- Hausa Users
('550e8400-e29b-41d4-a716-446655440007', 'Usman', 'Mohammed', 'usman.mohammed@gmail.com', 'hashed_password_201', '+2348123456783', 'host', '2024-02-20 08:30:00'),
('550e8400-e29b-41d4-a716-446655440008', 'Amina', 'Abdullahi', 'amina.abdullahi@outlook.com', 'hashed_password_202', '+2348123456782', 'guest', '2024-02-25 15:45:00'),
('550e8400-e29b-41d4-a716-446655440009', 'Fatima', 'Yusuf', 'fatima.yusuf@gmail.com', 'hashed_password_203', '+2348123456781', 'host', '2024-03-01 12:10:00'),

-- Edo Users
('550e8400-e29b-41d4-a716-446655440010', 'Osaze', 'Eguavoen', 'osaze.eguavoen@gmail.com', 'hashed_password_301', '+2348123456780', 'guest', '2024-03-05 17:20:00'),
('550e8400-e29b-41d4-a716-446655440011', 'Eghosa', 'Odigie', 'eghosa.odigie@yahoo.com', 'hashed_password_302', '+2348123456779', 'host', '2024-03-10 14:55:00'),

-- English/Mixed Nigerian Names
('550e8400-e29b-41d4-a716-446655440012', 'Grace', 'Okonkwo', 'grace.okonkwo@gmail.com', 'hashed_password_401', '+2348123456778', 'guest', '2024-03-15 10:40:00'),
('550e8400-e29b-41d4-a716-446655440013', 'Emmanuel', 'Okafor', 'emmanuel.okafor@outlook.com', 'hashed_password_402', '+2348123456777', 'host', '2024-03-20 09:25:00'),
('550e8400-e29b-41d4-a716-446655440014', 'Blessing', 'Adamu', 'blessing.adamu@gmail.com', 'hashed_password_403', '+2348123456776', 'guest', '2024-03-25 16:15:00'),

-- Admin User
('550e8400-e29b-41d4-a716-446655440015', 'Michael', 'Ejiofor', 'admin@airbnb-ng.com', 'hashed_password_admin', '+2348123456775', 'admin', '2024-01-01 00:00:00');

-- =====================================================
-- 2. SEED PROPERTY TABLE
-- =====================================================
-- Properties across major Nigerian cities

INSERT INTO Property (property_id, host_id, name, description, location, pricepernight, created_at, updated_at) VALUES
-- Lagos Properties
('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Luxury Penthouse in Victoria Island', 'Beautiful 3-bedroom penthouse with stunning views of Lagos lagoon. Features modern amenities, 24/7 security, and proximity to business district. Perfect for business travelers and luxury seekers.', 'Victoria Island, Lagos', 75000.00, '2024-01-16 11:00:00', '2024-01-16 11:00:00'),

('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003', 'Cozy Apartment in Lekki Phase 1', 'Modern 2-bedroom apartment in the heart of Lekki. Close to beaches, restaurants, and nightlife. Fully furnished with air conditioning and reliable power supply.', 'Lekki Phase 1, Lagos', 35000.00, '2024-02-02 10:30:00', '2024-02-02 10:30:00'),

('650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440005', 'Family House in Surulere', 'Spacious 4-bedroom duplex perfect for families. Traditional Nigerian architecture with modern touches. Generator backup and secure parking available.', 'Surulere, Lagos', 28000.00, '2024-02-11 09:45:00', '2024-02-11 09:45:00'),

-- Abuja Properties
('650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440007', 'Executive Lodge in Maitama', 'Elegant 3-bedroom apartment in prestigious Maitama district. Close to government offices and embassies. Features swimming pool and gym facilities.', 'Maitama, Abuja', 55000.00, '2024-02-21 14:20:00', '2024-02-21 14:20:00'),

('650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440009', 'Modern Studio in Wuse 2', 'Contemporary studio apartment perfect for young professionals. Located in Wuse 2 business district with easy access to shopping malls and restaurants.', 'Wuse 2, Abuja', 22000.00, '2024-03-02 13:10:00', '2024-03-02 13:10:00'),

-- Port Harcourt Properties
('650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440011', 'Garden City Retreat in GRA', 'Beautiful 3-bedroom bungalow in Old GRA. Serene environment with lush gardens. Ideal for families and business executives visiting Port Harcourt.', 'Old GRA, Port Harcourt', 40000.00, '2024-03-11 15:30:00', '2024-03-11 15:30:00'),

-- Other Nigerian Cities
('650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440013', 'Heritage House in Ancient Kano', 'Traditional Hausa architecture meets modern comfort. 2-bedroom house near Kano Emir Palace. Experience authentic Northern Nigerian culture.', 'Sabon Gari, Kano', 18000.00, '2024-03-21 12:45:00', '2024-03-21 12:45:00'),

('650e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440001', 'University Town Apartment', 'Student-friendly 2-bedroom apartment near University of Ibadan. Affordable, safe, and well-connected to campus and city center.', 'Ibadan, Oyo State', 15000.00, '2024-03-26 11:15:00', '2024-03-26 11:15:00'),

('650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440005', 'Coal City Executive Suite', 'Modern executive suite in Enugu. Perfect for business travelers. Features conference room access and high-speed internet.', 'Independence Layout, Enugu', 32000.00, '2024-04-01 08:00:00', '2024-04-01 08:00:00'),

('650e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440007', 'Lakeside Villa in Kainji', 'Unique lakeside property perfect for weekend getaways. 3-bedroom villa with boat access and fishing opportunities. Experience Nigeria''s natural beauty.', 'Kainji Lake, Niger State', 45000.00, '2024-04-05 16:30:00', '2024-04-05 16:30:00');

-- =====================================================
-- 3. SEED BOOKING TABLE
-- =====================================================
-- Realistic bookings with proper date sequences

INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
-- Confirmed bookings (past and current)
('750e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', '2024-05-01', '2024-05-05', 300000.00, 'confirmed', '2024-04-15 10:30:00'),

('750e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', '2024-05-10', '2024-05-13', 105000.00, 'confirmed', '2024-04-20 14:15:00'),

('750e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440006', '2024-05-15', '2024-05-18', 165000.00, 'confirmed', '2024-04-25 09:20:00'),

('750e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', '2024-05-20', '2024-05-25', 140000.00, 'confirmed', '2024-05-01 16:45:00'),

-- Pending bookings (future)
('750e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440010', '2024-09-15', '2024-09-20', 200000.00, 'pending', '2024-08-20 11:30:00'),

('750e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440012', '2024-10-01', '2024-10-05', 72000.00, 'pending', '2024-08-25 13:15:00'),

-- Canceled booking
('750e8400-e29b-41d4-a716-446655440007', '650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440014', '2024-06-01', '2024-06-03', 44000.00, 'canceled', '2024-05-15 10:00:00'),

('750e8400-e29b-41d4-a716-446655440008', '650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440012', '2024-11-10', '2024-11-15', 160000.00, 'confirmed', '2024-08-30 15:20:00');

-- =====================================================
-- 4. SEED PAYMENT TABLE
-- =====================================================
-- Payments for confirmed bookings only

INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method) VALUES
-- Payments for confirmed bookings
('850e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440001', 300000.00, '2024-04-15 10:35:00', 'credit_card'),
('850e8400-e29b-41d4-a716-446655440002', '750e8400-e29b-41d4-a716-446655440002', 105000.00, '2024-04-20 14:20:00', 'paypal'),
('850e8400-e29b-41d4-a716-446655440003', '750e8400-e29b-41d4-a716-446655440003', 165000.00, '2024-04-25 09:25:00', 'stripe'),
('850e8400-e29b-41d4-a716-446655440004', '750e8400-e29b-41d4-a716-446655440004', 140000.00, '2024-05-01 16:50:00', 'credit_card'),
('850e8400-e29b-41d4-a716-446655440005', '750e8400-e29b-41d4-a716-446655440008', 160000.00, '2024-08-30 15:25:00', 'paypal');

-- =====================================================
-- 5. SEED REVIEW TABLE
-- =====================================================
-- Reviews reflecting Nigerian hospitality and culture

INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at) VALUES
-- Reviews for completed stays
('950e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 5, 'Amazing stay in VI! Adebayo was an excellent host. The apartment is exactly as described with beautiful lagoon views. The location is perfect for business meetings in Lagos. Highly recommended!', '2024-05-06 09:00:00'),

('950e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', 4, 'Very comfortable stay in Lekki. Temitope was very responsive and helpful. The apartment is clean and well-furnished. Only minor issue was occasional power outage, but the generator worked perfectly.', '2024-05-14 11:30:00'),

('950e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440006', 5, 'Exceptional hospitality from Usman! The property in Maitama is top-notch with excellent facilities. Perfect for my business trip to Abuja. Will definitely book again when I visit the capital.', '2024-05-19 14:45:00'),

('950e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', 4, 'Great family accommodation in Surulere. Adaeze made us feel very welcome. The house is spacious and perfect for our family reunion. Kids loved the compound space to play.', '2024-05-26 16:20:00'),

('950e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440010', 5, 'Outstanding experience in Port Harcourt! Eghosa went above and beyond to ensure our comfort. The GRA location is peaceful and secure. Property exceeded expectations!', '2024-06-01 10:15:00'),

('950e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440012', 3, 'Interesting cultural experience in Kano. The traditional architecture is beautiful and Emmanuel was knowledgeable about local attractions. Room was basic but clean and authentic.', '2024-06-10 12:30:00');

-- =====================================================
-- 6. SEED MESSAGE TABLE
-- =====================================================
-- Communication between hosts and guests

INSERT INTO Message (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
-- Pre-booking inquiries
('A50e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Hello Adebayo! I am interested in booking your Victoria Island penthouse for May 1-5. Is it available? Also, is airport pickup possible?', '2024-04-10 09:15:00'),

('A50e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Hello Folake! Yes, the penthouse is available for those dates. I can arrange airport pickup for an additional fee. The property has beautiful lagoon views perfect for relaxation after business meetings.', '2024-04-10 10:30:00'),

('A50e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440003', 'Sannu Temitope! I would like to book your Lekki apartment. Do you provide local recommendations for good Nigerian restaurants nearby?', '2024-04-18 16:45:00'),

('A50e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004', 'Sannu Chukwuemeka! Absolutely! There are excellent local restaurants within walking distance. I will provide a list of my favorites including the best suya spots and traditional Yoruba cuisine.', '2024-04-18 17:20:00'),

-- Post-booking coordination
('A50e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440007', 'Good evening Usman! We have arrived in Abuja. The Maitama property looks great! Could you please share the WiFi password?', '2024-05-15 18:30:00'),

('A50e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440006', 'Welcome to Abuja, Kelechi! Hope your journey was smooth. WiFi password is "AbujaBusiness2024". Please let me know if you need anything during your stay.', '2024-05-15 18:45:00'),

-- Thank you messages
('A50e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440009', 'Thank you so much Fatima! Our stay at your Wuse property was wonderful. Your hospitality truly reflects the warmth of Nigerian culture.', '2024-06-20 14:20:00'),

('A50e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440008', 'It was my pleasure hosting you, Amina! Thank you for being such respectful guests. You are welcome back anytime. Safe travels!', '2024-06-20 15:10:00');

-- =====================================================
-- DATA SEEDING COMPLETE
-- =====================================================
-- Database successfully populated with Nigerian-themed sample data:
-- ✅ 15 diverse users representing major Nigerian ethnic groups
-- ✅ 10 properties across major Nigerian cities
-- ✅ 8 bookings with various statuses (confirmed, pending, canceled)
-- ✅ 5 payments for confirmed bookings
-- ✅ 6 authentic reviews reflecting Nigerian hospitality
-- ✅ 8 messages showing host-guest communication patterns

-- Verify data integrity
SELECT 'Users created:' as info, COUNT(*) as count FROM User
UNION ALL
SELECT 'Properties created:', COUNT(*) FROM Property
UNION ALL
SELECT 'Bookings created:', COUNT(*) FROM Booking
UNION ALL
SELECT 'Payments created:', COUNT(*) FROM Payment
UNION ALL
SELECT 'Reviews created:', COUNT(*) FROM Review
UNION ALL
SELECT 'Messages created:', COUNT(*) FROM Message;
