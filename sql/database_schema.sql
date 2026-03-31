-- =========================
-- USERS (UPDATED)
-- =========================
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    phone TEXT,
    role TEXT CHECK(role IN ('tenant','owner','admin')) NOT NULL,

    profession TEXT,

    gov_id TEXT,        -- PDF file path
    profile_pic TEXT,   -- 🔥 REQUIRED

    rating REAL DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- =========================
-- PROPERTIES
-- =========================
CREATE TABLE properties (
    property_id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    address TEXT,
    city TEXT,
    postcode TEXT,
    price_per_month REAL,
    bedrooms INTEGER,
    bathrooms INTEGER,

    availability_status TEXT DEFAULT 'available',

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(owner_id) REFERENCES users(user_id)
);


-- =========================
-- PROPERTY MEDIA
-- =========================
CREATE TABLE property_media (
    media_id INTEGER PRIMARY KEY AUTOINCREMENT,
    property_id INTEGER NOT NULL,
    file_path TEXT NOT NULL,
    media_type TEXT CHECK(media_type IN ('image','video')),
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(property_id) REFERENCES properties(property_id)
);


-- =========================
-- VISITS
-- =========================
CREATE TABLE visits (
    visit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    property_id INTEGER NOT NULL,
    tenant_id INTEGER NOT NULL,

    requested_date DATE,
    scheduled_date DATE,

    visit_status TEXT DEFAULT 'requested',
    -- requested / accepted / rejected / completed

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(property_id) REFERENCES properties(property_id),
    FOREIGN KEY(tenant_id) REFERENCES users(user_id)
);


-- =========================
-- BOOKINGS
-- =========================
CREATE TABLE bookings (
    booking_id INTEGER PRIMARY KEY AUTOINCREMENT,
    property_id INTEGER NOT NULL,
    tenant_id INTEGER NOT NULL,
    visit_id INTEGER,

    booking_status TEXT DEFAULT 'confirmed',
    -- pending / confirmed / cancelled

    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_status TEXT DEFAULT 'pending',

    FOREIGN KEY(property_id) REFERENCES properties(property_id),
    FOREIGN KEY(tenant_id) REFERENCES users(user_id),
    FOREIGN KEY(visit_id) REFERENCES visits(visit_id)
);


-- =========================
-- AGREEMENTS
-- =========================
CREATE TABLE agreements (
    agreement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    booking_id INTEGER NOT NULL,

    agreement_file TEXT,
    agreement_status TEXT DEFAULT 'pending',

    signed_date DATE,

    FOREIGN KEY(booking_id) REFERENCES bookings(booking_id)
);


-- =========================
-- MAINTENANCE REQUESTS
-- =========================
CREATE TABLE maintenance_requests (
    request_id INTEGER PRIMARY KEY AUTOINCREMENT,
    booking_id INTEGER NOT NULL,
    tenant_id INTEGER NOT NULL,

    issue_description TEXT,

    request_status TEXT DEFAULT 'submitted',
    -- submitted / accepted / rejected / resolved

    owner_response TEXT,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME,

    FOREIGN KEY(booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY(tenant_id) REFERENCES users(user_id)
);


-- =========================
-- FEEDBACK SYSTEM
-- =========================
CREATE TABLE feedback (
    feedback_id INTEGER PRIMARY KEY AUTOINCREMENT,

    from_user INTEGER,
    to_user INTEGER,

    rating INTEGER CHECK(rating BETWEEN 1 AND 5),
    comments TEXT,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(from_user) REFERENCES users(user_id),
    FOREIGN KEY(to_user) REFERENCES users(user_id)
);


CREATE TABLE exit_requests (
    exit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    booking_id INTEGER,
    tenant_id INTEGER,
    owner_id INTEGER,

    reason TEXT,
    status TEXT DEFAULT 'pending',  -- pending / accepted / rejected

    owner_response TEXT,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(booking_id) REFERENCES bookings(booking_id)
);


ALTER TABLE visits ADD COLUMN owner_message TEXT;
ALTER TABLE visits ADD COLUMN visit_outcome TEXT;

CREATE UNIQUE INDEX one_active_exit 
ON exit_requests(tenant_id) 
WHERE status='pending';