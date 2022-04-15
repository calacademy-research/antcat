# frozen_string_literal: true

# To copy local file to server.
#
# On server, required only once:
# `mkdir /data/antcat/shared/config/settings`
#
# Production:
# `scp config/settings/production.secret.yml deploy@antcat.org:/data/antcat/shared/config/settings/production.secret.yml`
#
# Staging:
# `scp config/settings/staging.secret.yml deploy@$ANTCAT_STAGING_HOST:/data/antcat/shared/config/settings/staging.secret.yml`

# To backup secrets from production/staging:
# ```
# TIMESTAMP=$(date +"%Y_%m_%d__%H%M%S")
# scp deploy@antcat.org:/data/antcat/shared/config/settings/production.secret.yml "./production.secret.yml.backup_${TIMESTAMP}"
# scp deploy@$ANTCAT_STAGING_HOST:/data/antcat/shared/config/settings/staging.secret.yml "./staging.secret.yml.backup_${TIMESTAMP}"
# ```

settings_file = "config/settings/#{config.environment}.secret.yml"
run "ln -nfs #{config.shared_path}/#{settings_file} #{config.release_path}/#{settings_file}"
