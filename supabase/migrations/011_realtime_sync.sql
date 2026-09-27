-- ==========================================================
-- 011 — Realtime Multi-Device Sync for Customers & Transactions
-- Run this in Supabase SQL Editor
-- ==========================================================

-- Enable FULL replica identity so Realtime receives all record columns on INSERT/UPDATE/DELETE
ALTER TABLE public.customers REPLICA IDENTITY FULL;
ALTER TABLE public.transactions REPLICA IDENTITY FULL;
ALTER TABLE public.profiles REPLICA IDENTITY FULL;

-- Add tables to the supabase_realtime publication for instant cross-device broadcast
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.customers;
        ALTER PUBLICATION supabase_realtime ADD TABLE public.transactions;
        ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
    END IF;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;
