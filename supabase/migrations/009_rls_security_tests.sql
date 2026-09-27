-- ==========================================================
-- Migration 009: Security & RLS Validation Tests
-- SAMI MARKET Role-Based Access
-- ==========================================================

/*
  How to test Customer Isolation & RLS Security:

  -- 1. Test Customer Verification Function
  SELECT public.customer_verify_login('SM-10001', '123456');

  -- 2. Test Customer Invalid PIN Rate Limiting
  SELECT public.customer_verify_login('SM-10001', '000000');

  -- 3. Test Admin Creating Customer Access
  SELECT public.admin_create_customer_account(
      '00000000-0000-0000-0000-000000000000'::uuid, 
      'SM-TEST1', 
      '654321'
  );

  -- 4. Test Customer Portal Read-only Data
  SELECT public.customer_get_portal_data(
      '00000000-0000-0000-0000-000000000000'::uuid,
      '654321'
  );

  -- 5. Test Customer Change PIN
  SELECT public.customer_change_pin(
      '00000000-0000-0000-0000-000000000000'::uuid,
      '654321',
      '112233'
  );
*/
