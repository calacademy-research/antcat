task :import_bibliography => [:import_ward, :import_hol_document_urls]

desc "Import HTML files of references from Bolton"
task :import_bolton => :environment do
  Bolton::Reference.delete_all
  bibliography = Bolton::Bibliography.new 'data/bolton/NGC-REFS_a-d.htm', true
  bibliography.import_file
end

desc 'Match Bolton against Ward'
task :match_bolton_against_ward => :environment do
  Bolton::ReferenceMatcher.new(true).find_matches_for_all
end

desc 'Import and match Bolton against Ward'
task :import_and_match_bolton => [:environment, :import_bolton, :match_bolton_against_ward]

desc "Import Bolton's genera"
task :import_genera => :environment do
  Bolton::Importer.new.get_subfamilies('data/bolton/subfamily_genus.html')
end

desc "Import HOL document URLs"
task :import_hol_document_urls => :environment do
  Reference.import_hol_document_urls true
end
