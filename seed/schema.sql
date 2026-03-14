CREATE TABLE IF NOT EXISTS subscription_plans (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price_monthly NUMERIC(10, 2),
    is_student_plan BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS eligible_institutions (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    country TEXT,
    plan_id INT REFERENCES subscription_plans(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS companies (
    id SERIAL PRIMARY KEY,
    name TEXT,
    industry TEXT,
    country TEXT,
    plan_id INT REFERENCES subscription_plans(id),
    institution_id INT REFERENCES eligible_institutions(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    company_id INT,
    name TEXT,
    email TEXT,
    role TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    name TEXT,
    industry TEXT,
    size TEXT,
    email TEXT,
    payment_terms INT,
    risk_score INT
);

CREATE TABLE IF NOT EXISTS vendors (
    id SERIAL PRIMARY KEY,
    name TEXT,
    service_type TEXT,
    email TEXT
);

CREATE TABLE IF NOT EXISTS offers (
    id SERIAL PRIMARY KEY,
    client_id INT,
    amount NUMERIC,
    status TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS invoices (
    id SERIAL PRIMARY KEY,
    client_id INT,
    amount NUMERIC,
    status TEXT,
    issued_date DATE,
    due_date DATE
);

CREATE TABLE IF NOT EXISTS tickets (
    id SERIAL PRIMARY KEY,
    client_id INT,
    subject TEXT,
    priority TEXT,
    status TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);