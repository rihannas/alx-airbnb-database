-- Roles Table
CREATE TABLE Role (
  role_type VARCHAR(50) UNIQUE NOT NULL
)

-- Users Table
CREATE TABLE User (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name VARCHAR(60) NOT NULL,
  last_name VARCHAR(60) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20),
  role VARCHAR(50) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  - Foreign key to Roles table
    FOREIGN KEY (role) REFERENCES Roles(role_type) ON UPDATE CASCADE

);

-- Create indexes for User table
CREATE INDEX idx_user_email ON User(email);

-- Property Table
REATE TABLE Property (
  property_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  host_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  location VARCHAR(500) NOT NULL,
  price_per_night DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  -- Foreign key to User table (host)
  FOREIGN KEY (host_id) REFERENCES User(user_id) ON DELETE CASCADE,
  
  -- Constraints
  CONSTRAINT chk_price_positive CHECK (price_per_night > 0)
);

-- Create indexes for Property table
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_price ON Property(price_per_night);

-- Booking Table
CREATE TABLE Booking (
  booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL,
  user_id UUID NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  status ENUM('pending', 'confirmed', 'cancelled') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  -- Foreign keys
  FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,

  -- Constraints
  CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
  CONSTRAINT chk_total_price_positive CHECK (total_price > 0)
);

-- Create indexes for Booking table
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_status ON Booking(status);

-- Review Table
CREATE TABLE Review (
  review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL,
  user_id UUID NOT NULL,
  rating INTEGER NOT NULL,
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign keys
  FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
  
  -- Constraints
  CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
  
  -- Prevent duplicate reviews from same user for same property
  UNIQUE(property_id, user_id)
);

- Create indexes for Review table
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);


-- PaymentMethod Table
CREATE TABLE PaymentMethod (
  id SERIAL PRIMARY KEY,
  payment_method VARCHAR(50) UNIQUE NOT NULL,
);



-- Payment Table
CREATE TABLE Payment (
  payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  payment_method INT NOT NULL,
  transaction_id VARCHAR(255),
  status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign key
  FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE CASCADE,
  FOREIGN KEY (payment_method_id) REFERENCES PaymentMethod(id) ON UPDATE CASCADE
  
  -- Constraints
  CONSTRAINT chk_payment_amount_positive CHECK (amount > 0)
);

-- Create indexes for Payment table
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_status ON Payment(status);
CREATE INDEX idx_payment_date ON Payment(payment_date);


-- Messages Table
CREATE TABLE Message (
  message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL,
  receiver_id UUID NOT NULL,
  message_body TEXT NOT NULL,
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Foreign keys
  FOREIGN KEY (sender_id) REFERENCES User(user_id) ON DELETE CASCADE,
  FOREIGN KEY (receiver_id) REFERENCES User(user_id) ON DELETE CASCADE,
  
  -- Constraint to prevent self-messaging
  CONSTRAINT chk_no_self_message CHECK (sender_id != receiver_id)
);

-- Create indexes for Message table
CREATE INDEX idx_message_receiver_id ON Message(receiver_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);
CREATE INDEX idx_message_read_at ON Message(read_at);