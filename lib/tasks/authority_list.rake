#Rake.application.options.trace = true

namespace :authority_list do

  desc "Export taxonomy"
  task :export => :environment do
    AuthorityList::Exporter.new(true).export 'data/output'
  end

end
