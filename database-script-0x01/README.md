# Readme

## schema.sql

### Table Overview

| Table Name   | Description                                                                                             |
| ------------ | ------------------------------------------------------------------------------------------------------- |
| **Roles**    | Stores user role definitions (guest, host, admin) that define system permissions and access levels      |
| **User**     | Contains user account information including personal details, authentication data, and role assignments |
| **Property** | Stores property listings with details like name, description, location, pricing, and host information   |
| **Booking**  | Records booking transactions linking users to properties with dates, pricing, and status information    |
| **Review**   | Contains user reviews and ratings for properties, enabling feedback and quality assessment              |
| **Payment**  | Tracks payment transactions for bookings including amounts, methods, and payment status                 |
| **Message**  | Facilitates communication between users through a messaging system for inquiries and coordination       |

---

### Database Indexing Strategy

**What is an Index?**
An index is a data structure that improves the speed of data retrieval operations on a database table. Think of it like an index in a book - instead of reading every page to find a topic, you can quickly jump to the right page.

**Trade-offs:**

- ✅ **Faster SELECT queries**
- ✅ **Faster WHERE, ORDER BY, GROUP BY operations**
- ❌ **Slower INSERT/UPDATE/DELETE operations**
- ❌ **Additional storage space required**

---

## 1. USER TABLE INDEXING

```sql
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);
```

### Email Index (`idx_user_email`)

**Purpose:** Optimize user authentication and lookups
**Reasoning:**

- **Login queries**: `SELECT * FROM User WHERE email = 'user@example.com'`
- **Email uniqueness checks**: Before inserting new users
- **Password reset**: Finding users by email
- **Frequency**: Very high - every login attempt

**Query Impact:**

```sql
-- Without index: Full table scan O(n)
-- With index: Direct lookup O(log n)
SELECT * FROM User WHERE email = 'john@example.com';
```

### Role Index (`idx_user_role`)

**Purpose:** Optimize role-based queries and admin functions
**Reasoning:**

- **Admin queries**: `SELECT * FROM User WHERE role = 'admin'`
- **Host listings**: Finding all hosts for management
- **Role-based permissions**: Filtering users by role
- **Frequency**: Medium - admin functions, role management

**Query Impact:**

```sql
-- Find all hosts
SELECT * FROM User WHERE role = 'host';

-- Count users by role
SELECT role, COUNT(*) FROM User GROUP BY role;
```

### Created At Index (`idx_user_created_at`)

**Purpose:** Optimize temporal queries and reporting
**Reasoning:**

- **Registration analytics**: Users registered in date ranges
- **Sorting by registration date**: `ORDER BY created_at DESC`
- **Admin dashboards**: Recent user activity
- **Frequency**: Medium - reporting and analytics

**Query Impact:**

```sql
-- Recent users
SELECT * FROM User WHERE created_at > '2024-01-01' ORDER BY created_at DESC;

-- Monthly registration report
SELECT DATE_TRUNC('month', created_at), COUNT(*) FROM User GROUP BY 1;
```

---

## 2. PROPERTY TABLE INDEXING

```sql
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_price ON Property(price_per_night);
CREATE INDEX idx_property_created_at ON Property(created_at);
```

### Host ID Index (`idx_property_host_id`)

**Purpose:** Optimize host-related queries
**Reasoning:**

- **Host dashboard**: `SELECT * FROM Property WHERE host_id = 'uuid'`
- **Host property count**: Number of properties per host
- **Foreign key performance**: JOINs with User table
- **Frequency**: Very high - every host management action

**Query Impact:**

```sql
-- Host viewing their properties
SELECT * FROM Property WHERE host_id = '550e8400-e29b-41d4-a716-446655440002';

-- Properties with host info (JOIN optimization)
SELECT p.name, u.first_name FROM Property p
JOIN User u ON p.host_id = u.user_id;
```

### Location Index (`idx_property_location`)

**Purpose:** Optimize location-based searches
**Reasoning:**

- **Property search**: `SELECT * FROM Property WHERE location LIKE '%New York%'`
- **Location filtering**: Main user search functionality
- **Geographic queries**: Properties in specific areas
- **Frequency**: Very high - primary search feature

**Query Impact:**

```sql
-- Search properties by location
SELECT * FROM Property WHERE location LIKE '%Miami%';

-- Properties in specific city
SELECT * FROM Property WHERE location = 'New York, NY, USA';
```

### Price Index (`idx_property_price`)

**Purpose:** Optimize price-based filtering and sorting
**Reasoning:**

- **Price range searches**: `WHERE price_per_night BETWEEN 100 AND 200`
- **Price sorting**: `ORDER BY price_per_night ASC`
- **Budget filtering**: Common user search criteria
- **Frequency**: High - price is a primary filter

**Query Impact:**

```sql
-- Properties within budget
SELECT * FROM Property WHERE price_per_night BETWEEN 100 AND 300;

-- Cheapest properties first
SELECT * FROM Property ORDER BY price_per_night ASC;
```

### Created At Index (`idx_property_created_at`)

**Purpose:** Optimize temporal queries and newest listings
**Reasoning:**

- **Newest properties**: `ORDER BY created_at DESC`
- **Recent listings**: Properties added in timeframe
- **Analytics**: Property creation trends
- **Frequency**: Medium - "newest" sorting is common

---

## 3. BOOKING TABLE INDEXING

```sql
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_created_at ON Booking(created_at);
```

### Property ID Index (`idx_booking_property_id`)

**Purpose:** Optimize property-related booking queries
**Reasoning:**

- **Property availability**: Check existing bookings for a property
- **Host analytics**: Bookings for host's properties
- **Booking calendar**: Display property's booking schedule
- **Frequency**: Very high - availability is checked constantly

**Query Impact:**

```sql
-- Check if property is available
SELECT * FROM Booking WHERE property_id = 'uuid' AND status = 'confirmed';

-- Property booking history
SELECT * FROM Booking WHERE property_id = 'uuid' ORDER BY start_date;
```

### User ID Index (`idx_booking_user_id`)

**Purpose:** Optimize user booking history and profile
**Reasoning:**

- **User booking history**: `SELECT * FROM Booking WHERE user_id = 'uuid'`
- **User dashboard**: Personal booking management
- **Customer analytics**: User booking patterns
- **Frequency**: High - users frequently view their bookings

**Query Impact:**

```sql
-- User's booking history
SELECT * FROM Booking WHERE user_id = '550e8400-e29b-41d4-a716-446655440001';

-- User's upcoming bookings
SELECT * FROM Booking WHERE user_id = 'uuid' AND start_date > CURRENT_DATE;
```

### Dates Composite Index (`idx_booking_dates`)

**Purpose:** Optimize date range queries and availability checks
**Reasoning:**

- **Availability checking**: Finding overlapping bookings
- **Date range searches**: Bookings within specific periods
- **Calendar queries**: Complex date-based filtering
- **Frequency**: Very high - core booking functionality

**Query Impact:**

```sql
-- Check for overlapping bookings
SELECT * FROM Booking
WHERE property_id = 'uuid'
AND start_date <= '2024-08-05'
AND end_date >= '2024-08-01';

-- Bookings in date range
SELECT * FROM Booking WHERE start_date >= '2024-08-01' AND end_date <= '2024-08-31';
```

### Status Index (`idx_booking_status`)

**Purpose:** Optimize status-based filtering
**Reasoning:**

- **Pending bookings**: `WHERE status = 'pending'`
- **Confirmed bookings**: Active reservation queries
- **Status reports**: Analytics by booking status
- **Frequency**: High - status is frequently filtered

### Created At Index (`idx_booking_created_at`)

**Purpose:** Optimize temporal booking queries
**Reasoning:**

- **Recent bookings**: `ORDER BY created_at DESC`
- **Booking analytics**: Time-based reports
- **Admin monitoring**: Recent booking activity
- **Frequency**: Medium - reporting and monitoring

---

## 4. REVIEW TABLE INDEXING

```sql
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);
```

### Property ID Index (`idx_review_property_id`)

**Purpose:** Optimize property review display
**Reasoning:**

- **Property reviews**: `SELECT * FROM Review WHERE property_id = 'uuid'`
- **Average rating calculation**: Aggregate functions on reviews
- **Review display**: Showing all reviews for a property
- **Frequency**: Very high - reviews displayed on every property page

**Query Impact:**

```sql
-- Get all reviews for a property
SELECT * FROM Review WHERE property_id = 'uuid' ORDER BY created_at DESC;

-- Calculate average rating
SELECT AVG(rating) FROM Review WHERE property_id = 'uuid';
```

### User ID Index (`idx_review_user_id`)

**Purpose:** Optimize user review history
**Reasoning:**

- **User review history**: Reviews written by a user
- **Review management**: User editing their reviews
- **User profile**: Display user's review activity
- **Frequency**: Medium - user profile and review management

### Rating Index (`idx_review_rating`)

**Purpose:** Optimize rating-based queries and sorting
**Reasoning:**

- **High-rated properties**: `WHERE rating >= 4`
- **Rating distribution**: Analytics on rating patterns
- **Quality filtering**: Properties with good ratings
- **Frequency**: Medium - rating-based filtering

**Query Impact:**

```sql
-- Properties with high ratings
SELECT p.* FROM Property p
JOIN Review r ON p.property_id = r.property_id
WHERE r.rating >= 4;

-- Rating distribution
SELECT rating, COUNT(*) FROM Review GROUP BY rating;
```

### Created At Index (`idx_review_created_at`)

**Purpose:** Optimize temporal review queries
**Reasoning:**

- **Recent reviews**: `ORDER BY created_at DESC`
- **Review timeline**: Chronological review display
- **Review analytics**: Time-based patterns
- **Frequency**: Medium - reviews often sorted by date

---

## 5. PAYMENT TABLE INDEXING

```sql
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_status ON Payment(status);
CREATE INDEX idx_payment_method ON Payment(payment_method);
CREATE INDEX idx_payment_date ON Payment(payment_date);
CREATE INDEX idx_payment_transaction_id ON Payment(transaction_id);
```

### Booking ID Index (`idx_payment_booking_id`)

**Purpose:** Optimize booking-payment relationship queries
**Reasoning:**

- **Payment history**: `SELECT * FROM Payment WHERE booking_id = 'uuid'`
- **Booking details**: JOINs between Booking and Payment
- **Financial tracking**: Payments for specific bookings
- **Frequency**: High - payment info accessed frequently

**Query Impact:**

```sql
-- Get payments for a booking
SELECT * FROM Payment WHERE booking_id = 'uuid';

-- Booking with payment info
SELECT b.*, p.amount, p.status FROM Booking b
JOIN Payment p ON b.booking_id = p.booking_id;
```

### Status Index (`idx_payment_status`)

**Purpose:** Optimize payment status queries
**Reasoning:**

- **Failed payments**: `WHERE status = 'failed'`
- **Pending payments**: Payment processing queries
- **Financial reports**: Status-based analytics
- **Frequency**: High - payment status is critical

**Query Impact:**

```sql
-- Find failed payments
SELECT * FROM Payment WHERE status = 'failed';

-- Payment status report
SELECT status, COUNT(*), SUM(amount) FROM Payment GROUP BY status;
```

### Payment Method Index (`idx_payment_method`)

**Purpose:** Optimize payment method analytics
**Reasoning:**

- **Method popularity**: Analytics on payment methods
- **Payment routing**: Method-specific processing
- **Business intelligence**: Payment method trends
- **Frequency**: Medium - analytics and reporting

### Payment Date Index (`idx_payment_date`)

**Purpose:** Optimize temporal payment queries
**Reasoning:**

- **Date range reports**: Payments within timeframes
- **Financial analytics**: Revenue by time period
- **Sorting by date**: `ORDER BY payment_date DESC`
- **Frequency**: High - financial reporting

**Query Impact:**

```sql
-- Monthly revenue
SELECT DATE_TRUNC('month', payment_date), SUM(amount)
FROM Payment WHERE status = 'completed' GROUP BY 1;

-- Recent payments
SELECT * FROM Payment ORDER BY payment_date DESC;
```

### Transaction ID Index (`idx_payment_transaction_id`)

**Purpose:** Optimize transaction lookup and reconciliation
**Reasoning:**

- **Transaction lookup**: Finding payments by external ID
- **Reconciliation**: Matching with payment processor records
- **Dispute resolution**: Quick transaction reference
- **Frequency**: Medium - support and reconciliation

---

## 6. MESSAGE TABLE INDEXING

```sql
CREATE INDEX idx_message_sender_id ON Message(sender_id);
CREATE INDEX idx_message_receiver_id ON Message(receiver_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);
CREATE INDEX idx_message_read_at ON Message(read_at);
```

### Sender ID Index (`idx_message_sender_id`)

**Purpose:** Optimize sent message queries
**Reasoning:**

- **Sent messages**: `SELECT * FROM Message WHERE sender_id = 'uuid'`
- **Message history**: User's sent message archive
- **Conversation threads**: Building message chains
- **Frequency**: Medium - messaging functionality

### Receiver ID Index (`idx_message_receiver_id`)

**Purpose:** Optimize received message queries
**Reasoning:**

- **Inbox queries**: `SELECT * FROM Message WHERE receiver_id = 'uuid'`
- **Unread messages**: Critical for user experience
- **Message notifications**: Real-time message checking
- **Frequency**: High - inbox is frequently accessed

**Query Impact:**

```sql
-- User's inbox
SELECT * FROM Message WHERE receiver_id = 'uuid' ORDER BY sent_at DESC;

-- Unread messages
SELECT * FROM Message WHERE receiver_id = 'uuid' AND read_at IS NULL;
```

### Sent At Index (`idx_message_sent_at`)

**Purpose:** Optimize temporal message queries
**Reasoning:**

- **Message chronology**: `ORDER BY sent_at DESC`
- **Conversation threading**: Time-based message ordering
- **Message search**: Finding messages by time
- **Frequency**: High - messages always sorted by time

### Read At Index (`idx_message_read_at`)

**Purpose:** Optimize read status queries
**Reasoning:**

- **Unread messages**: `WHERE read_at IS NULL`
- **Read receipts**: Tracking message read status
- **Message statistics**: Read/unread analytics
- **Frequency**: High - read status is frequently checked

---

## INDEXING BEST PRACTICES APPLIED

### 1. **Composite Indexes**

```sql
-- Date range queries benefit from composite index
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
```

### 2. **Covering Indexes** (Future Optimization)

```sql
-- Include frequently selected columns
CREATE INDEX idx_user_email_covering ON User(email) INCLUDE (first_name, last_name);
```

### 3. **Partial Indexes** (Future Optimization)

```sql
-- Index only unread messages
CREATE INDEX idx_message_unread ON Message(receiver_id) WHERE read_at IS NULL;
```

### 4. **Foreign Key Indexes**

All foreign key columns are indexed to optimize JOINs and maintain referential integrity performance.

---

## PERFORMANCE IMPACT ANALYSIS

### High-Impact Indexes (Critical for Performance):

- `idx_user_email` - Authentication
- `idx_property_location` - Property search
- `idx_booking_property_id` - Availability checking
- `idx_booking_dates` - Date range queries
- `idx_review_property_id` - Review display

### Medium-Impact Indexes (Important for Features):

- `idx_payment_status` - Payment processing
- `idx_message_receiver_id` - Messaging
- `idx_property_price` - Price filtering

### Low-Impact Indexes (Analytics and Reporting):

- `idx_user_created_at` - Registration analytics
- `idx_review_rating` - Rating analysis
- `idx_payment_method` - Payment method analytics

---

## MAINTENANCE CONSIDERATIONS

### Index Monitoring:

- Monitor index usage with database statistics
- Drop unused indexes to improve INSERT/UPDATE performance
- Update index statistics regularly

### Growth Considerations:

- Indexes become more valuable as data grows
- Monitor index size vs. performance benefit
- Consider partitioning for very large tables

### Query Optimization:

- Use EXPLAIN ANALYZE to verify index usage
- Adjust queries to leverage existing indexes
- Consider query-specific indexes for complex operations

This indexing strategy balances query performance with maintenance overhead, focusing on the most common access patterns in a property booking system.

---
