# frozen_string_literal: true

# To copy local file to production:
# scp config/settings/production.secret.yml deploy@antcat.org:/data/antcat/shared/config/settings/production.secret.yml
run "ln -nfs #{config.shared_path}/config/settings/production.secret.yml #{config.release_path}/config/settings/production.secret.yml"
