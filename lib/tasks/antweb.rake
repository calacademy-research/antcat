Rake.application.options.trace = true

namespace :antweb do

  namespace :export do
    desc "Import taxonomy from Antweb::Taxonomy"
    task :taxa => :environment do
      Antweb::Exporter.export true
    end
  end
end
