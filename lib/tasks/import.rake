task :import_bibliography => [:import_ward, :import_hol_document_urls]

desc "Import HTML files of references from Bolton"
task :import_bolton_references => :environment do
  Bolton::Reference.delete_all
  Bolton::Bibliography.new(true).import_files Dir.glob 'data/bolton/NGC-REFS(*.htm'
end

desc 'Match Bolton references to ours'
task :match_bolton_references => :environment do
  Bolton::ReferencesMatcher.new(true).find_matches_for_all
end

desc 'Import and match Bolton references'
task :import_and_match_bolton_references => [:import_bolton_references, :match_bolton_references]

desc "Import HOL document URLs"
task :import_hol_document_urls => :environment do
  Reference.import_hol_document_urls true
end

desc "Import Bolton species catalog documents"
task :import_species => :environment do
  catalog = Bolton::SpeciesCatalog.new(true)
  catalog.clear
  catalog.import_files Dir.glob 'data/bolton/NGC-Sp*.htm'
end
