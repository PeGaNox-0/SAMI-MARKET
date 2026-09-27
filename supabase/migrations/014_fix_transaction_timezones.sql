-- Fix transaction timezones for old transactions
-- Subtract 3 hours from created_at, updated_at, and deleted_at for all transactions created before the fix
UPDATE transactions
SET
  created_at = created_at - INTERVAL '3 hours',
  updated_at = updated_at - INTERVAL '3 hours';

UPDATE transactions
SET
  deleted_at = deleted_at - INTERVAL '3 hours'
WHERE deleted_at IS NOT NULL;
