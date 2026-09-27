-- ==========================================================
-- 010 — In-App Notifications
-- Run this in Supabase SQL Editor
-- ==========================================================

-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    market_owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_customer ON public.notifications(customer_id);
CREATE INDEX IF NOT EXISTS idx_notifications_owner ON public.notifications(market_owner_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(customer_id, is_read) WHERE is_read = FALSE;

-- RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- تمكين البث الفوري (Realtime) لجدول الإشعارات
ALTER TABLE public.notifications REPLICA IDENTITY FULL;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
    END IF;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;

-- الأدمن: يقرأ ويرسل ويحذف إشعارات زبائنه فقط
DROP POLICY IF EXISTS "Admin manage own notifications" ON public.notifications;
CREATE POLICY "Admin manage own notifications"
    ON public.notifications FOR ALL
    USING (market_owner_id = auth.uid())
    WITH CHECK (market_owner_id = auth.uid());

-- السماح للزبون (anon) باستقبال أحداث البث الفوري (Realtime)
DROP POLICY IF EXISTS "Allow public read notifications for realtime" ON public.notifications;
CREATE POLICY "Allow public read notifications for realtime"
    ON public.notifications FOR SELECT
    TO anon, authenticated
    USING (true);


-- الزبون: يقرأ إشعاراته فقط عبر الدوال
-- (لا يوجد Supabase auth للزبون فنستخدم RPC SECURITY DEFINER)

-- دالة: الأدمن يرسل إشعاراً لزبائن محددين أو للكل
CREATE OR REPLACE FUNCTION public.admin_send_notification(
    p_message TEXT,
    p_customer_ids UUID[] DEFAULT NULL  -- NULL = إرسال للكل
)
RETURNS JSONB AS $$
DECLARE
    v_owner_id UUID := auth.uid();
    v_count INT;
BEGIN
    IF v_owner_id IS NULL THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    IF char_length(trim(p_message)) = 0 THEN
        RAISE EXCEPTION 'Message cannot be empty';
    END IF;

    IF p_customer_ids IS NULL THEN
        -- إرسال للكل
        INSERT INTO public.notifications (market_owner_id, customer_id, message)
        SELECT v_owner_id, c.id, trim(p_message)
        FROM public.customers c
        WHERE c.user_id = v_owner_id AND c.is_active = TRUE;
    ELSE
        -- إرسال لمحددين (التحقق أن الزبائن ينتمون للأدمن)
        INSERT INTO public.notifications (market_owner_id, customer_id, message)
        SELECT v_owner_id, c.id, trim(p_message)
        FROM public.customers c
        WHERE c.id = ANY(p_customer_ids)
          AND c.user_id = v_owner_id
          AND c.is_active = TRUE;
    END IF;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'success', TRUE,
        'sent_count', v_count
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- دالة: الزبون يجلب إشعاراته
CREATE OR REPLACE FUNCTION public.customer_get_notifications(
    p_customer_id UUID,
    p_pin TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_acc RECORD;
    v_notifications JSONB;
    v_unread_count INT;
BEGIN
    -- التحقق من الهوية
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

    -- جلب الإشعارات
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', n.id,
            'message', n.message,
            'is_read', n.is_read,
            'created_at', n.created_at
        ) ORDER BY n.created_at DESC
    ), '[]'::jsonb)
    INTO v_notifications
    FROM public.notifications n
    WHERE n.customer_id = p_customer_id;

    SELECT COUNT(*) INTO v_unread_count
    FROM public.notifications
    WHERE customer_id = p_customer_id AND is_read = FALSE;

    RETURN jsonb_build_object(
        'success', TRUE,
        'notifications', v_notifications,
        'unread_count', v_unread_count
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;

-- دالة: الزبون يضع علامة "مقروء" على إشعار
CREATE OR REPLACE FUNCTION public.customer_mark_notification_read(
    p_customer_id UUID,
    p_notification_id UUID,
    p_pin TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_acc RECORD;
BEGIN
    SELECT * INTO v_acc FROM public.customer_accounts WHERE customer_id = p_customer_id;

    IF NOT FOUND OR v_acc.pin_hash != extensions.crypt(p_pin, v_acc.pin_hash) THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'UNAUTHORIZED');
    END IF;

    UPDATE public.notifications
    SET is_read = TRUE
    WHERE id = p_notification_id AND customer_id = p_customer_id;

    RETURN jsonb_build_object('success', TRUE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;

-- دالة: الزبون يضع "مقروء" على كل إشعاراته
CREATE OR REPLACE FUNCTION public.customer_mark_all_notifications_read(
    p_customer_id UUID,
    p_pin TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_acc RECORD;
BEGIN
    SELECT * INTO v_acc FROM public.customer_accounts WHERE customer_id = p_customer_id;

    IF NOT FOUND OR v_acc.pin_hash != extensions.crypt(p_pin, v_acc.pin_hash) THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'UNAUTHORIZED');
    END IF;

    UPDATE public.notifications
    SET is_read = TRUE
    WHERE customer_id = p_customer_id AND is_read = FALSE;

    RETURN jsonb_build_object('success', TRUE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, extensions;

-- صلاحيات التنفيذ
GRANT EXECUTE ON FUNCTION public.admin_send_notification(TEXT, UUID[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.customer_get_notifications(UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.customer_mark_notification_read(UUID, UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.customer_mark_all_notifications_read(UUID, TEXT) TO anon, authenticated;
