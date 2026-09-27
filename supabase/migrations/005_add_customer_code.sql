-- ============================================
-- Add customer_code to customers table
-- ============================================

-- 1. إضافة عمود رقم/كود الزبون
ALTER TABLE public.customers 
ADD COLUMN IF NOT EXISTS customer_code TEXT DEFAULT '';

-- 2. فهرس لتسريع البحث برقم الزبون
CREATE INDEX IF NOT EXISTS idx_customers_code 
ON public.customers(user_id, customer_code);
