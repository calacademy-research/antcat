# frozen_string_literal: true

# For managing config in 'config/settings/*.secret.yml', see ./scripts/secret_settings

# TODO: Make this manual step automatic.
# For brand new EngineYard environments, run this first (on remote server, required only once):
#   mkdir /data/antcat/shared/config/settings

settings_file = "config/settings/#{config.environment}.secret.yml"
run "ln -nfs #{config.shared_path}/#{settings_file} #{config.release_path}/#{settings_file}"
