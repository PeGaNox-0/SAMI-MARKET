-- ============================================
-- Performance Indexes
-- ============================================

-- Customers indexes
CREATE INDEX IF NOT EXISTS idx_customers_user_id ON customers(user_id);
CREATE INDEX IF NOT EXISTS idx_customers_name ON customers(name);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_customers_active ON customers(user_id, is_active);

-- Transactions indexes
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_customer_id ON transactions(customer_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_transactions_customer_active
    ON transactions(customer_id, type)
    WHERE is_deleted = FALSE;

CREATE INDEX IF NOT EXISTS idx_transactions_user_date
    ON transactions(user_id, created_at DESC)
    WHERE is_deleted = FALSE;
