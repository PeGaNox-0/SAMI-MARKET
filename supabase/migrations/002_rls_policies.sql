-- ============================================
-- Row Level Security Policies
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- =====================
-- PROFILES POLICIES
-- =====================
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- =====================
-- CUSTOMERS POLICIES
-- =====================
CREATE POLICY "Users can view own customers"
    ON customers FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own customers"
    ON customers FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own customers"
    ON customers FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own customers"
    ON customers FOR DELETE
    USING (auth.uid() = user_id);

-- =====================
-- TRANSACTIONS POLICIES
-- =====================
CREATE POLICY "Users can view own transactions"
    ON transactions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions"
    ON transactions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own transactions"
    ON transactions FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own transactions"
    ON transactions FOR DELETE
    USING (auth.uid() = user_id);
