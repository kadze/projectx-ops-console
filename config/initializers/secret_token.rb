# SECRET_KEY_BASE handling.
#
# Rails 6.1 expects either credentials.yml.enc OR ENV['SECRET_KEY_BASE'].
# We don't use credentials.yml.enc — Routebox keeps secrets in Secrets
# Manager (or env vars in dev/test). If SECRET_KEY_BASE is missing in
# non-prod we synthesize one so the app boots; in prod we let Rails
# raise the standard error.

Rails.application.config.tap do |c|
  next if Rails.env.production?
  ENV['SECRET_KEY_BASE'] ||= 'dev-secret-key-base-not-real-' + ('x' * 96)
end
