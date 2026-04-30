# strong_migrations configuration.
#
# We're pinned to 0.7.x — the gem author has been quiet for ages. The
# 1.x line changed the API (the configuration block moved off
# StrongMigrations:: into a configure-style ancestry and a few helpers
# were renamed). Upgrading is bound up with the larger Rails-to-Flyway
# migration, which means it never gets done.
#
# Anything that needs to override safety here uses `safety_assured do
# ... end` inside the migration. Grep for it.

if defined?(StrongMigrations)
  StrongMigrations.start_after = 20210101000000
  StrongMigrations.target_version = 14   # postgres major

  # Lock timeout: we add a 5s lock_timeout in the safe-migrations runner
  # but the gem's own setting wins on conflict.
  StrongMigrations.lock_timeout = 10.seconds

  # We've added a few custom checks over time.
  if StrongMigrations.respond_to?(:safe_assume_safe_indexes_with_concurrent)
    StrongMigrations.safe_assume_safe_indexes_with_concurrent = true
  end
end
