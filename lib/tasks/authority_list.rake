# coding: UTF-8
namespace :authority_list do

  desc "Export taxonomy"
  task :export => :environment do
    Exporters::AuthorityList::Exporter.new(true).export 'data/output'
  end

end
