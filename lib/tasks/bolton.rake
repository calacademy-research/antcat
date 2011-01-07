Rake.application.options.trace = true

namespace :bolton do

  namespace :import do
    desc "Import HTML files of references from Bolton"
    task :references => :environment do
      Bolton::Reference.delete_all
      Bolton::Bibliography.new(true).import_files Dir.glob 'data/bolton/NGC-REFS(*.htm'
    end
    desc "Import Bolton genus catalog documents"
    task :genera => :environment do
      catalog = Bolton::GenusCatalog.new(true)
      catalog.clear
      catalog.import_files Dir.glob 'data/bolton/NGC-GEN*.htm'
    end
    desc "Import Bolton species catalog documents"
    task :species => :environment do
      catalog = Bolton::SpeciesCatalog.new(true)
      catalog.clear
      catalog.import_files Dir.glob 'data/bolton/NGC-Sp*.htm'
    end
  end

  namespace :match do
    desc 'Match Bolton references to ours'
    task :references => :environment do
      Bolton::ReferencesMatcher.new(true).find_matches_for_all
    end
  end

  namespace :import_and_match do
    desc 'Import and match Bolton references'
    task :references => [':bolton:import:references', ':bolton:match:references']
  end

end
