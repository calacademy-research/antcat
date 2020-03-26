# frozen_string_literal: true

run "ln -nfs #{config.shared_path}/config/settings/production.yml #{config.release_path}/config/settings/production.yml"
