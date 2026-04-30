class WidenUsersEmailUniqueIndex < ActiveRecord::Migration[6.1]
  # We had a duplicate-email row land in prod (the lower(email) unique
  # index that existed didn't catch a trailing-whitespace case). Drop
  # and re-create with btrim. This is one of the migrations
  # strong_migrations would normally yell about because it briefly
  # leaves the table without an index — explicitly safety_assured here.

  disable_ddl_transaction!

  def up
    safety_assured do
      execute "DROP INDEX CONCURRENTLY IF EXISTS uniq_users_email_lower"
      execute <<~SQL
        CREATE UNIQUE INDEX CONCURRENTLY uniq_users_email_lower_btrim
          ON users (lower(btrim(email)))
      SQL
    end
  end

  def down
    safety_assured do
      execute "DROP INDEX CONCURRENTLY IF EXISTS uniq_users_email_lower_btrim"
      execute "CREATE UNIQUE INDEX CONCURRENTLY uniq_users_email_lower ON users (lower(email))"
    end
  end
end
