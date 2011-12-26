# coding: UTF-8

$BOLTON_DATA_DIRECTORY = 'data/bolton'

namespace :bolton do

  namespace :import do
    desc "Import HTML files of references from Bolton"
    task :references => :environment do
      Bolton::Reference.delete_all
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
    desc "Import all taxa"
    task :taxa => ['bolton:import:subfamilies', 'bolton:import:species']
  end

  namespace :references do
    desc 'Match Bolton references to ours'
    task :match => :environment do
      Bolton::ReferencesMatcher.new(true).find_matches_for_all
    end

    desc 'Import and match Bolton references'
    task :import_and_match => ['bolton:import:references', 'bolton:references:match']
  end

end
