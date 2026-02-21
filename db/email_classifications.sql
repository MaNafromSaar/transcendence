-- Email Classifications Table
-- Store processed and AI-classified emails with extracted metadata

CREATE TABLE IF NOT EXISTS email_classifications (
    id SERIAL PRIMARY KEY,
    sender_name VARCHAR(255),
    sender_email VARCHAR(255),
    email_type VARCHAR(50) CHECK (email_type IN ('info', 'order', 'request', 'invoice', 'support_request', 'other')),
    topic VARCHAR(500),
    summary TEXT,
    date_deadline DATE,
    cost_amount DECIMAL(10, 2),
    phone_number VARCHAR(50),
    priority VARCHAR(20) CHECK (priority IN ('low', 'medium', 'high')),
    action_required VARCHAR(10) CHECK (action_required IN ('yes', 'no')),
    additional_info TEXT,
    original_email TEXT NOT NULL,
    received_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_by VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for common queries
CREATE INDEX idx_email_type ON email_classifications(email_type);
CREATE INDEX idx_priority ON email_classifications(priority);
CREATE INDEX idx_action_required ON email_classifications(action_required);
CREATE INDEX idx_received_at ON email_classifications(received_at DESC);
CREATE INDEX idx_sender_email ON email_classifications(sender_email);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_email_classifications_updated_at 
    BEFORE UPDATE ON email_classifications 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Sample query views for common use cases
CREATE OR REPLACE VIEW high_priority_emails AS
SELECT 
    id,
    sender_name,
    sender_email,
    email_type,
    topic,
    summary,
    date_deadline,
    cost_amount,
    action_required,
    received_at
FROM email_classifications
WHERE priority = 'high' AND action_required = 'yes'
ORDER BY received_at DESC;

CREATE OR REPLACE VIEW pending_invoices AS
SELECT 
    id,
    sender_name,
    topic,
    cost_amount,
    date_deadline,
    received_at,
    summary
FROM email_classifications
WHERE email_type = 'invoice' AND action_required = 'yes'
ORDER BY date_deadline ASC NULLS LAST;

COMMENT ON TABLE email_classifications IS 'AI-processed and classified emails with extracted metadata';
COMMENT ON COLUMN email_classifications.email_type IS 'Category: info, order, request, invoice, support_request, other';
COMMENT ON COLUMN email_classifications.priority IS 'AI-determined priority: low, medium, high';
COMMENT ON COLUMN email_classifications.action_required IS 'Whether email requires action: yes, no';
