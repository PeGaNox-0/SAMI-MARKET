-- ============================================
-- Database Functions
-- ============================================

-- Calculate a single customer's balance
-- Balance = SUM(debts) - SUM(payments) for non-deleted transactions
CREATE OR REPLACE FUNCTION get_customer_balance(p_customer_id UUID)
RETURNS NUMERIC(12, 2) AS $$
DECLARE
    v_balance NUMERIC(12, 2);
BEGIN
    SELECT COALESCE(
        SUM(CASE WHEN type = 'debt' THEN amount ELSE 0 END) -
        SUM(CASE WHEN type = 'payment' THEN amount ELSE 0 END),
        0
    ) INTO v_balance
    FROM transactions
    WHERE customer_id = p_customer_id
      AND is_deleted = FALSE;

    RETURN v_balance;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get dashboard statistics for a user
CREATE OR REPLACE FUNCTION get_dashboard_stats(p_user_id UUID)
RETURNS TABLE (
    total_outstanding_debt NUMERIC(12, 2),
    customers_with_debt BIGINT,
    payments_today NUMERIC(12, 2),
    debts_today NUMERIC(12, 2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        -- Total outstanding debt across all customers
        COALESCE((
            SELECT SUM(CASE WHEN t.type = 'debt' THEN t.amount ELSE -t.amount END)
            FROM transactions t
            JOIN customers c ON t.customer_id = c.id
            WHERE t.user_id = p_user_id
              AND t.is_deleted = FALSE
              AND c.is_active = TRUE
        ), 0::NUMERIC(12,2)) AS total_outstanding_debt,

        -- Number of customers with debt > 0
        COALESCE((
            SELECT COUNT(DISTINCT c.id)
            FROM customers c
            WHERE c.user_id = p_user_id
              AND c.is_active = TRUE
              AND get_customer_balance(c.id) > 0
        ), 0) AS customers_with_debt,

        -- Payments today
        COALESCE((
            SELECT SUM(t.amount)
            FROM transactions t
            WHERE t.user_id = p_user_id
              AND t.type = 'payment'
              AND t.is_deleted = FALSE
              AND t.created_at::date = CURRENT_DATE
        ), 0::NUMERIC(12,2)) AS payments_today,

        -- Debts today
        COALESCE((
            SELECT SUM(t.amount)
            FROM transactions t
            WHERE t.user_id = p_user_id
              AND t.type = 'debt'
              AND t.is_deleted = FALSE
              AND t.created_at::date = CURRENT_DATE
        ), 0::NUMERIC(12,2)) AS debts_today;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
