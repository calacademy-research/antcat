# frozen_string_literal: true

if Rails.env.development?
  require "rubycritic/rake_task"

  RubyCritic::RakeTask.new do |task|
    task.name = 'rubycritic'

    excluded_files = [
      'app/database_scripts/**/*',
      'lib/dev_monkey_patches/**/*',
      'app/controllers/quick_and_dirty_fixes_controller.rb',
      '**/quick_and_dirty_fixes/*'
    ]

    task.paths = FileList['app/**/*.rb', 'lib/**/*.rb'].exclude(*excluded_files)
  end
end
