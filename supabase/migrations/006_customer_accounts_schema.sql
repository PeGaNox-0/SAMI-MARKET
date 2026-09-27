-- ==========================================================
-- Migration 006: Customer Accounts Schema
-- SAMI MARKET Role-Based Access & Customer Portal
-- ==========================================================

-- Enable pgcrypto for secure PIN hashing
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================================
-- 1. CUSTOMER ACCOUNTS TABLE
-- ==========================================================
CREATE TABLE IF NOT EXISTS public.customer_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL UNIQUE REFERENCES public.customers(id) ON DELETE CASCADE,
    auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL,
    customer_code TEXT NOT NULL UNIQUE,
    pin_hash TEXT NOT NULL,
    is_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    failed_attempts INT NOT NULL DEFAULT 0,
    locked_until TIMESTAMPTZ,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Constraints
    CONSTRAINT customer_code_format CHECK (char_length(trim(customer_code)) >= 3),
    CONSTRAINT pin_hash_not_empty CHECK (char_length(pin_hash) > 0)
);

-- ==========================================================
-- 2. INDEXES
-- ==========================================================
CREATE INDEX IF NOT EXISTS idx_customer_accounts_code 
    ON public.customer_accounts(customer_code);

CREATE INDEX IF NOT EXISTS idx_customer_accounts_auth_user 
    ON public.customer_accounts(auth_user_id);

CREATE INDEX IF NOT EXISTS idx_customer_accounts_customer 
    ON public.customer_accounts(customer_id);

-- ==========================================================
-- 3. UPDATED_AT TRIGGER
-- ==========================================================
CREATE TRIGGER update_customer_accounts_updated_at
    BEFORE UPDATE ON public.customer_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
