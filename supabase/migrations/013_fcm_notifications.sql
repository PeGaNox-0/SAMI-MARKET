-- ==========================================================
-- Migration 013: FCM Push Notifications & Customer Devices
-- ==========================================================

-- 1. Create Customer Devices Table
CREATE TABLE IF NOT EXISTS public.customer_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL,
    platform TEXT CHECK (platform IN ('android', 'ios')),
    device_name TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Constraints
    CONSTRAINT unique_customer_fcm_token UNIQUE (customer_id, fcm_token)
);

-- 2. Add updated_at trigger
CREATE TRIGGER update_customer_devices_updated_at
    BEFORE UPDATE ON public.customer_devices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3. Enable RLS on customer_devices
ALTER TABLE public.customer_devices ENABLE ROW LEVEL SECURITY;

-- Grant permissions
GRANT ALL ON TABLE public.customer_devices TO anon, authenticated, service_role;

-- RLS Policies
CREATE POLICY "Allow service_role full access to customer_devices"
    ON public.customer_devices
    TO service_role
    USING (true)
    WITH CHECK (true);

-- 4. Create SECURITY DEFINER functions for Customer Portal to Register/Unregister devices
CREATE OR REPLACE FUNCTION public.customer_register_device(
    p_customer_id UUID,
    p_pin TEXT,
    p_fcm_token TEXT,
    p_platform TEXT DEFAULT 'android',
    p_device_name TEXT DEFAULT ''
)
RETURNS JSONB AS $$
DECLARE
    v_acc RECORD;
BEGIN
    -- Verify the customer's PIN
    SELECT * INTO v_acc
    FROM public.customer_accounts
    WHERE customer_id = p_customer_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'CUSTOMER_NOT_FOUND');
    END IF;

    IF v_acc.pin_hash != extensions.crypt(p_pin, v_acc.pin_hash) THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'INVALID_PIN');
    END IF;

    -- Upsert the device token
    INSERT INTO public.customer_devices (customer_id, fcm_token, platform, device_name, is_active, updated_at)
    VALUES (p_customer_id, p_fcm_token, LOWER(p_platform), p_device_name, TRUE, now())
    ON CONFLICT (customer_id, fcm_token) DO UPDATE SET
        platform = EXCLUDED.platform,
        device_name = EXCLUDED.device_name,
        is_active = TRUE,
        updated_at = now();

    RETURN jsonb_build_object('success', TRUE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;

CREATE OR REPLACE FUNCTION public.customer_unregister_device(
    p_customer_id UUID,
    p_pin TEXT,
    p_fcm_token TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_acc RECORD;
BEGIN
    -- Verify the customer's PIN
    SELECT * INTO v_acc
    FROM public.customer_accounts
    WHERE customer_id = p_customer_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'CUSTOMER_NOT_FOUND');
    END IF;

    IF v_acc.pin_hash != extensions.crypt(p_pin, v_acc.pin_hash) THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'INVALID_PIN');
    END IF;

    -- Delete the token
    DELETE FROM public.customer_devices
    WHERE customer_id = p_customer_id AND fcm_token = p_fcm_token;

    RETURN jsonb_build_object('success', TRUE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;

-- Grant execution permissions
GRANT EXECUTE ON FUNCTION public.customer_register_device(UUID, TEXT, TEXT, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.customer_unregister_device(UUID, TEXT, TEXT) TO anon, authenticated;

-- 5. Trigger to invoke Edge Function when a new debt transaction is inserted
CREATE OR REPLACE FUNCTION public.handle_new_debt_transaction()
RETURNS TRIGGER AS $$
DECLARE
    v_payload JSONB;
    v_url TEXT := 'https://ckujyurulpzctuieknxt.supabase.co/functions/v1/send-fcm-notification';
    v_response_status INT;
BEGIN
    -- Only trigger for new debt transactions that are not deleted
    IF NEW.type = 'debt' AND NEW.is_deleted = FALSE THEN
        v_payload := jsonb_build_object(
            'transaction_id', NEW.id,
            'customer_id', NEW.customer_id,
            'amount', NEW.amount,
            'description', COALESCE(NEW.description, '')
        );
        
        -- Call Supabase Edge Function asynchronously using pg_net
        PERFORM net.http_post(
            url := v_url,
            headers := jsonb_build_object(
                'Content-Type', 'application/json',
                'Authorization', 'Bearer supabase-webhook-secret-token-3omar'
            ),
            body := v_payload
        );
    END IF;
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Prevent database operation failure if HTTP request fails
        RAISE WARNING 'FCM notification trigger failed: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER on_debt_transaction_created
    AFTER INSERT ON public.transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_debt_transaction();
