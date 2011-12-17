# coding: UTF-8

$BOLTON_DATA_DIRECTORY = 'data/bolton'

namespace :bolton do

  namespace :import do
    desc "Import HTML files of references from Bolton"
    task :references => :environment do
      Bolton::Bibliography::Importer.new(true).import_files Dir.glob "#{$BOLTON_DATA_DIRECTORY}/NGC-REFS(*.htm"
    end
    desc "Import Bolton subfamily catalog"
    task :subfamilies => :environment do
      Bolton::Catalog::Subfamily::Importer.new(true).import_files Dir.glob "#{$BOLTON_DATA_DIRECTORY}/*.htm"
    end
    desc "Import Bolton species catalog documents"
    task :species => :environment do
      Bolton::Catalog::Species::Importer.new(true).import_files Dir.glob "#{$BOLTON_DATA_DIRECTORY}/NGC-Sp*.htm"
    end
    desc "Import Bolton species catalog documents deeply"
    task 'species:deep' => :environment do
      Bolton::Catalog::Species::DeepSpeciesImporter.new(:show_progress => true, :start_from_scratch => true).
        import_files Dir.glob "#{$BOLTON_DATA_DIRECTORY}/NGC-Sp*.htm"
    end
    desc "Import all taxa"
    task :taxa => ['bolton:import:subfamilies', 'bolton:import:species:deep']
  end

  namespace :references do
    desc 'Match Bolton references to ours'
    task :match => :environment do
      Bolton::ReferencesMatcher.new(true).find_matches_for_all
    end

    desc "Set author/year keys"
    task :set_keys => :environment do
      Bolton::Reference.set_key_caches
    end

    desc 'Import and match Bolton references'
    task :import_and_match => ['bolton:import:references', 'bolton:references:match']
  end

  namespace :references do
    desc 'Set bolton_reference match fields according to previous matching run'
    task :set_matches => :environment do
      Bolton::Reference.set_matches
    end
  end

end
