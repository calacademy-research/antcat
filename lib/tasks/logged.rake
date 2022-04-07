# frozen_string_literal: true

desc 'Log to STDOUT (example: `rake logged db:version`)'
task logged: :environment do
  ActiveRecord::Base.logger = Logger.new($stdout)
end
