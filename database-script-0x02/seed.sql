-- ============================================================================
-- SAMPLE DATA INSERTS
-- ============================================================================

-- Insert sample users
INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'John', 'Doe', 'john.doe@example.com', 'hashed_password_1', '+1234567890', 'guest'),
  ('550e8400-e29b-41d4-a716-446655440002', 'Jane', 'Smith', 'jane.smith@example.com', 'hashed_password_2', '+1234567891', 'host'),
  ('550e8400-e29b-41d4-a716-446655440003', 'Admin', 'User', 'admin@example.com', 'hashed_password_3', '+1234567892', 'admin');

-- Insert sample properties
INSERT INTO Property (property_id, host_id, name, description, location, price_per_night) VALUES
  ('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Cozy Downtown Apartment', 'Beautiful 2-bedroom apartment in the heart of the city', 'New York, NY, USA', 150.00),
  ('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'Beach House Getaway', 'Stunning oceanfront property with private beach access', 'Miami, FL, USA', 300.00);

-- Insert sample bookings
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status) VALUES
  ('770e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '2024-08-01', '2024-08-05', 600.00, 'confirmed'),
  ('770e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', '2024-08-15', '2024-08-20', 1500.00, 'pending');

-- Insert sample reviews
INSERT INTO Review (review_id, property_id, user_id, rating, comment) VALUES
  ('880e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 5, 'Amazing place! Very clean and comfortable. Great location!');

-- Insert sample payments
INSERT INTO Payment (payment_id, booking_id, amount, payment_method, status) VALUES
  ('990e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440001', 600.00, 'credit_card', 'completed');

-- Insert sample messages
INSERT INTO Message (message_id, sender_id, receiver_id, message_body) VALUES
  ('aa0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', );