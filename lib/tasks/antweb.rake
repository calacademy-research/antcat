Rake.application.options.trace = true

namespace :antweb do

  desc "Export taxonomy"
  task :export => :environment do
    Antweb::Exporter.new(true).export 'data/output'
  end

end
