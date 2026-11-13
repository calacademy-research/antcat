# frozen_string_literal: true

# Development only: the `antcat:rubycritic` task, a code quality report of app/ and lib/ (cleanup code and
# development patches left out).
if Rails.env.development?
  require 'rubycritic/rake_task'

  RubyCritic::RakeTask.new do |task|
    task.name = 'antcat:rubycritic'

    excluded_files = [
      'app/database_scripts/**/*',
      'app/cleanup/**/*',
      'lib/dev_monkey_patches/**/*',
      'app/controllers/quick_and_dirty_fixes_controller.rb',
      '**/quick_and_dirty_fixes/*'
    ]

    task.paths = FileList['app/**/*.rb', 'lib/**/*.rb'].exclude(*excluded_files)
  end
end
