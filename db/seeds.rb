# This data can be loaded with `rake db:seed` (or created alongside the db with db:setup).

tooltips_seed_file = Rails.root.join('db', 'seeds', 'tooltips.yml')
tooltips = YAML.load_file tooltips_seed_file
Tooltip.create! tooltips
