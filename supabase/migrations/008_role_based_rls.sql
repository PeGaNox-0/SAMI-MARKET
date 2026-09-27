-- ==========================================================
-- Migration 008: Role-Based Row Level Security (RLS)
-- SAMI MARKET Role-Based Access & Customer Portal
-- ==========================================================

-- Enable RLS on customer_accounts
ALTER TABLE public.customer_accounts ENABLE ROW LEVEL SECURITY;

-- ==========================================================
-- 1. CUSTOMER ACCOUNTS POLICIES
-- ==========================================================

-- Drop existing policies if any
DROP POLICY IF EXISTS "Admins can view customer accounts" ON public.customer_accounts;
DROP POLICY IF EXISTS "Admins can insert customer accounts" ON public.customer_accounts;
DROP POLICY IF EXISTS "Admins can update customer accounts" ON public.customer_accounts;
DROP POLICY IF EXISTS "Admins can delete customer accounts" ON public.customer_accounts;

-- Admin policies
CREATE POLICY "Admins can view customer accounts"
    ON public.customer_accounts FOR SELECT
    USING (
        customer_id IN (
            SELECT id FROM public.customers WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can insert customer accounts"
    ON public.customer_accounts FOR INSERT
    WITH CHECK (
        customer_id IN (
            SELECT id FROM public.customers WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can update customer accounts"
    ON public.customer_accounts FOR UPDATE
    USING (
        customer_id IN (
            SELECT id FROM public.customers WHERE user_id = auth.uid()
        )
    )
    WITH CHECK (
        customer_id IN (
            SELECT id FROM public.customers WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can delete customer accounts"
    ON public.customer_accounts FOR DELETE
    USING (
        customer_id IN (
            SELECT id FROM public.customers WHERE user_id = auth.uid()
        )
    );

-- ==========================================================
-- 2. SECURE ACCESS GRANTS FOR RPC FUNCTIONS
-- ==========================================================

-- Grant execution permissions for helper functions to authenticated and anon roles
GRANT EXECUTE ON FUNCTION public.admin_create_customer_account(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_reset_customer_pin(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_set_customer_access(UUID, BOOLEAN) TO authenticated;

-- Grant customer verification functions to anon and authenticated (needed for Customer PIN login)
GRANT EXECUTE ON FUNCTION public.customer_verify_login(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.customer_change_pin(UUID, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.customer_get_portal_data(UUID, TEXT) TO anon, authenticated;
