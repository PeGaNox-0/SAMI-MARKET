-- ==========================================================
-- Migration 007: Customer Authentication & Management Functions
-- SAMI MARKET Role-Based Access & Customer Portal
-- ==========================================================

-- Enable pgcrypto in extensions schema (default for Supabase)
CREATE EXTENSION IF NOT EXISTS "pgcrypto" SCHEMA extensions;

-- ==========================================================
-- 1. ADMIN: CREATE OR UPDATE CUSTOMER ACCESS
-- ==========================================================
CREATE OR REPLACE FUNCTION public.admin_create_customer_account(
    p_customer_id UUID,
    p_customer_code TEXT,
    p_pin TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_customer_exists BOOLEAN;
    v_clean_code TEXT;
    v_pin_hash TEXT;
BEGIN
    -- Verify caller is the owner of the customer
    SELECT EXISTS (
        SELECT 1 FROM public.customers
        WHERE id = p_customer_id AND user_id = auth.uid()
    ) INTO v_customer_exists;

    IF NOT v_customer_exists THEN
        RAISE EXCEPTION 'Unauthorized: You do not own this customer record or it does not exist.';
    END IF;

    -- Validate PIN (must be 4 to 8 digits)
    IF char_length(p_pin) < 4 OR char_length(p_pin) > 8 THEN
        RAISE EXCEPTION 'PIN must be between 4 and 8 digits.';
    END IF;

    v_clean_code := UPPER(TRIM(p_customer_code));
    v_pin_hash := extensions.crypt(p_pin, extensions.gen_salt('bf'::text, 8));

    -- Update customer_code in customers table
    UPDATE public.customers
    SET customer_code = v_clean_code
    WHERE id = p_customer_id;

    -- Upsert customer_accounts
    INSERT INTO public.customer_accounts (
        customer_id,
        customer_code,
        pin_hash,
        is_enabled,
        failed_attempts,
        locked_until
    )
    VALUES (
        p_customer_id,
        v_clean_code,
        v_pin_hash,
        TRUE,
        0,
        NULL
    )
    ON CONFLICT (customer_id) DO UPDATE SET
        customer_code = EXCLUDED.customer_code,
        pin_hash = EXCLUDED.pin_hash,
        is_enabled = TRUE,
        failed_attempts = 0,
        locked_until = NULL,
        updated_at = now();

    RETURN jsonb_build_object(
        'success', TRUE,
        'customer_id', p_customer_id,
        'customer_code', v_clean_code
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;

-- ==========================================================
-- 2. ADMIN: RESET CUSTOMER PIN
-- ==========================================================
CREATE OR REPLACE FUNCTION public.admin_reset_customer_pin(
    p_customer_id UUID,
    p_new_pin TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_customer_exists BOOLEAN;
    v_pin_hash TEXT;
BEGIN
    -- Verify ownership
    SELECT EXISTS (
        SELECT 1 FROM public.customers
        WHERE id = p_customer_id AND user_id = auth.uid()
    ) INTO v_customer_exists;

    IF NOT v_customer_exists THEN
        RAISE EXCEPTION 'Unauthorized: You do not own this customer record.';
    END IF;

    IF char_length(p_new_pin) < 4 OR char_length(p_new_pin) > 8 THEN
        RAISE EXCEPTION 'PIN must be between 4 and 8 digits.';
    END IF;

    v_pin_hash := extensions.crypt(p_new_pin, extensions.gen_salt('bf'::text, 8));

    UPDATE public.customer_accounts
    SET pin_hash = v_pin_hash,
        failed_attempts = 0,
        locked_until = NULL,
        updated_at = now()
    WHERE customer_id = p_customer_id;

    RETURN jsonb_build_object('success', TRUE, 'customer_id', p_customer_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;

-- ==========================================================
-- 3. ADMIN: SET CUSTOMER ACCESS (ENABLE / DISABLE)
-- ==========================================================
CREATE OR REPLACE FUNCTION public.admin_set_customer_access(
    p_customer_id UUID,
    p_enabled BOOLEAN
)
RETURNS JSONB AS $$
DECLARE
    v_customer_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM public.customers
        WHERE id = p_customer_id AND user_id = auth.uid()
    ) INTO v_customer_exists;

    IF NOT v_customer_exists THEN
        RAISE EXCEPTION 'Unauthorized: You do not own this customer record.';
    END IF;

    UPDATE public.customer_accounts
    SET is_enabled = p_enabled,
        updated_at = now()
    WHERE customer_id = p_customer_id;

    RETURN jsonb_build_object('success', TRUE, 'is_enabled', p_enabled);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;

-- ==========================================================
-- 4. CUSTOMER: VERIFY LOGIN (CUSTOMER CODE + PIN)
-- ==========================================================
CREATE OR REPLACE FUNCTION public.customer_verify_login(
    p_customer_code TEXT,
    p_pin TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_acc RECORD;
    v_cust RECORD;
    v_market RECORD;
    v_balance NUMERIC(12, 2);
    v_clean_code TEXT;
BEGIN
    v_clean_code := UPPER(TRIM(REPLACE(p_customer_code, '#', '')));

    -- Fetch account matching with or without SM- or # prefix
    SELECT * INTO v_acc
    FROM public.customer_accounts
    WHERE UPPER(TRIM(customer_code)) = v_clean_code
       OR UPPER(TRIM(customer_code)) = 'SM-' || v_clean_code
       OR 'SM-' || UPPER(TRIM(customer_code)) = v_clean_code
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'NOT_FOUND');
    END IF;

    -- Check if locked due to brute-force attempts
    IF v_acc.locked_until IS NOT NULL AND v_acc.locked_until > now() THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'error', 'ACCOUNT_LOCKED',
            'locked_until', v_acc.locked_until
        );
    END IF;

    -- Check if disabled by Admin
    IF NOT v_acc.is_enabled THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'ACCOUNT_DISABLED');
    END IF;

    -- Verify PIN hash
    IF v_acc.pin_hash = extensions.crypt(p_pin, v_acc.pin_hash) THEN
        -- Successful verification: reset failed attempts & update last login
        UPDATE public.customer_accounts
        SET failed_attempts = 0,
            locked_until = NULL,
            last_login_at = now()
        WHERE id = v_acc.id;

        -- Get customer info & market profile
        SELECT * INTO v_cust FROM public.customers WHERE id = v_acc.customer_id;
        SELECT * INTO v_market FROM public.profiles WHERE id = v_cust.user_id;
        v_balance := public.get_customer_balance(v_cust.id);

        RETURN jsonb_build_object(
            'success', TRUE,
            'customer_id', v_cust.id,
            'customer_code', v_acc.customer_code,
            'customer_name', v_cust.name,
            'phone', COALESCE(v_cust.phone, ''),
            'market_name', COALESCE(v_market.market_name, 'SAMI MARKET'),
            'balance', v_balance
        );
    ELSE
        -- Failed verification: increment attempts
        UPDATE public.customer_accounts
        SET failed_attempts = failed_attempts + 1,
            locked_until = CASE 
                WHEN failed_attempts + 1 >= 5 THEN now() + INTERVAL '15 minutes'
                ELSE NULL
            END
        WHERE id = v_acc.id;

        RETURN jsonb_build_object(
            'success', FALSE,
            'error', 'INVALID_PIN',
            'attempts_remaining', GREATEST(0, 5 - (v_acc.failed_attempts + 1))
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;

-- ==========================================================
-- 5. CUSTOMER: CHANGE OWN PIN
-- ==========================================================
CREATE OR REPLACE FUNCTION public.customer_change_pin(
    p_customer_id UUID,
    p_current_pin TEXT,
    p_new_pin TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_acc RECORD;
    v_new_hash TEXT;
BEGIN
    SELECT * INTO v_acc
    FROM public.customer_accounts
    WHERE customer_id = p_customer_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'NOT_FOUND');
    END IF;

    IF NOT v_acc.is_enabled THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'ACCOUNT_DISABLED');
    END IF;

    -- Verify current PIN
    IF v_acc.pin_hash != extensions.crypt(p_current_pin, v_acc.pin_hash) THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'INVALID_CURRENT_PIN');
    END IF;

    IF char_length(p_new_pin) < 4 OR char_length(p_new_pin) > 8 THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'INVALID_PIN_LENGTH');
    END IF;

    v_new_hash := extensions.crypt(p_new_pin, extensions.gen_salt('bf'::text, 8));

    UPDATE public.customer_accounts
    SET pin_hash = v_new_hash,
        updated_at = now()
    WHERE id = v_acc.id;

    RETURN jsonb_build_object('success', TRUE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;

-- ==========================================================
-- 6. CUSTOMER: GET PORTAL DATA (LIVE DATA & TRANSACTIONS)
-- ==========================================================
CREATE OR REPLACE FUNCTION public.customer_get_portal_data(
    p_customer_id UUID,
    p_pin TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_acc RECORD;
    v_cust RECORD;
    v_market RECORD;
    v_balance NUMERIC(12, 2);
    v_total_debts NUMERIC(12, 2);
    v_total_payments NUMERIC(12, 2);
    v_transactions JSONB;
BEGIN
    SELECT * INTO v_acc
    FROM public.customer_accounts
    WHERE customer_id = p_customer_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'NOT_FOUND');
    END IF;

    IF NOT v_acc.is_enabled THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'ACCOUNT_DISABLED');
    END IF;

    IF v_acc.pin_hash != extensions.crypt(p_pin, v_acc.pin_hash) THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'INVALID_PIN');
    END IF;

    SELECT * INTO v_cust FROM public.customers WHERE id = p_customer_id;
    SELECT * INTO v_market FROM public.profiles WHERE id = v_cust.user_id;

    -- Financial calculations
    SELECT 
        COALESCE(SUM(CASE WHEN type = 'debt' THEN amount ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN type = 'payment' THEN amount ELSE 0 END), 0)
    INTO v_total_debts, v_total_payments
    FROM public.transactions
    WHERE customer_id = p_customer_id AND is_deleted = FALSE;

    v_balance := v_total_debts - v_total_payments;

    -- Recent / all transactions
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', t.id,
            'type', t.type,
            'amount', t.amount,
            'description', t.description,
            'created_at', t.created_at
        ) ORDER BY t.created_at DESC
    ), '[]'::jsonb)
    INTO v_transactions
    FROM public.transactions t
    WHERE t.customer_id = p_customer_id AND t.is_deleted = FALSE;

    RETURN jsonb_build_object(
        'success', TRUE,
        'customer_id', v_cust.id,
        'customer_code', v_acc.customer_code,
        'customer_name', v_cust.name,
        'phone', COALESCE(v_cust.phone, ''),
        'market_name', COALESCE(v_market.market_name, 'SAMI MARKET'),
        'balance', v_balance,
        'total_debts', v_total_debts,
        'total_payments', v_total_payments,
        'transactions', v_transactions
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;
