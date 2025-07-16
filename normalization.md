# Normalization

The ER diagram in ERD/requirements.md, follows 1NF and 2NF, but it doesn't fully follow 3NF.

---

### Tables that fail to comply with 3NF:

- **User table**:

  - The **role** field stores role information directly in the User table. This creates a transitive dependency where user attributes depend on role, which depends on user_id

- **Property table**:

  - The **location** field stores location as a single VARCHAR field. If location contains structured data (city, state, country), it violates atomicity and could create dependencies

- **Payment table**:
  - The **payment_method** field stores payment_method information directly in the Payment table. This creates a transitive dependency where payment attributes depend on payment, which depends on payment_method

### How to fix:

- **User table**:

  - Creating a separate **Roles** table and reference it properly.

- **Property table**:

  - Creating a **Location** table and reference it properly.

- **Payment table**:
  - Creating a **PaymentMethod** table and reference it properly.

[View SVG Diagram](./assets/normalizied_er.png)
