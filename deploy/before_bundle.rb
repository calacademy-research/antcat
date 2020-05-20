# frozen_string_literal: true

# To copy local file to server:
# mkdir /data/antcat/shared/config/settings
# scp config/settings/production.secret.yml deploy@antcat.org:/data/antcat/shared/config/settings/production.secret.yml
# scp config/settings/staging.secret.yml deploy@$ANTCAT_STAGING_HOST:/data/antcat/shared/config/settings/staging.secret.yml

settings_file = "config/settings/#{config.environment}.secret.yml"
run "ln -nfs #{config.shared_path}/#{settings_file} #{config.release_path}/#{settings_file}"
