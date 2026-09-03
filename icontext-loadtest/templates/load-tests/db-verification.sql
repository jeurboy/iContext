-- MOCK TEMPLATE ONLY. Replace every {{PLACEHOLDER}} from the target project's schema.
-- Keep verification read-only. Do not run until the owner approves the exact DB/environment/query.

SELECT '{{PRIMARY_TABLE}}' AS table_name, count(*) AS row_count FROM {{PRIMARY_TABLE}}
UNION ALL SELECT '{{RELATED_TABLE}}', count(*) FROM {{RELATED_TABLE}}
UNION ALL SELECT '{{SESSION_TABLE}}', count(*) FROM {{SESSION_TABLE}}
ORDER BY table_name;

-- Optional index evidence for a reviewed table/index.
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = current_schema()
  AND tablename = '{{TABLE_NAME}}'
  AND indexname = '{{INDEX_NAME}}';

-- Add project-specific read-only invariants here. Never include INSERT/UPDATE/DELETE/TRUNCATE.
