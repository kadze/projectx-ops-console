# Secrets loader.
#
# At boot, pull secrets from AWS Secrets Manager and copy them into ENV
# so that downstream Rails config (database.yml, secret_key_base, etc.)
# can read them via ENV['...'] like normal.
#
# We do this here rather than relying on a sidecar / init container
# because the original deploy was straight-into-EC2 and the env-var
# pattern stuck around through the ECS migration.
#
# Secrets we pull (by canonical name → ENV):
#   routebox/<env>/DATABASE_URL          -> DATABASE_URL
#   routebox/<env>/INTERNAL_API_TOKEN    -> ROUTEBOX_INTERNAL_API_TOKEN
#   routebox/<env>/JWT_SIGNING_KEY       -> JWT_SIGNING_KEY
#   routebox/<env>/SMTP_PASSWORD         -> SMTP_PASSWORD
#
# Two more SHOULD be in Secrets Manager but aren't yet:
#   routebox/<env>/SECRET_KEY_BASE  — Rails session signing key. Today
#     we set it via the Jenkins build's task-def env (which means it
#     lives in the Jenkins credential store). TODO: move to
#     Secrets Manager so it's rotatable without a deploy.
#   routebox/<env>/REDIS_URL — Sidekiq's Redis. Today we hand-paste it
#     into the task-def env. TODO: same.
#
# This whole thing is a no-op in development and test (no creds, no
# need). It only runs in production.

if Rails.env.production? && ENV['SKIP_SECRETS_BOOTSTRAP'] != '1'
  require 'aws-sdk-secretsmanager'

  env_name = ENV.fetch('ROUTEBOX_ENV', 'prod')
  region   = ENV.fetch('AWS_REGION', 'us-east-1')

  SECRETS_TO_PULL = {
    "routebox/#{env_name}/DATABASE_URL"       => 'DATABASE_URL',
    "routebox/#{env_name}/INTERNAL_API_TOKEN" => 'ROUTEBOX_INTERNAL_API_TOKEN',
    "routebox/#{env_name}/JWT_SIGNING_KEY"    => 'JWT_SIGNING_KEY',
    # "routebox/#{env_name}/SMTP_PASSWORD"      => 'SMTP_PASSWORD',  # no mailer configured
  }.freeze

  client = Aws::SecretsManager::Client.new(region: region)

  SECRETS_TO_PULL.each do |secret_id, env_var|
    next if ENV[env_var].present? # don't clobber operator overrides
    begin
      resp = client.get_secret_value(secret_id: secret_id)
      ENV[env_var] = resp.secret_string
    rescue Aws::SecretsManager::Errors::ServiceError => err
      Rails.logger.error "secrets_loader: failed #{secret_id}: #{err.class}: #{err.message}"
      # Don't crash boot if a secret is missing in dev — but in real prod
      # the app will fail to talk to its dependencies, which is louder
      # than this message. So we proceed.
    end
  end
end
