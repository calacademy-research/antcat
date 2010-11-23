task :import_bibliography => [:import_ward, :import_hol_source_urls]

desc "Import HTML files of references from Bolton"
task :import_bolton => :environment do
  BoltonReference.delete_all
  BoltonReference.import 'data/bolton/NGC-REFS_a-d.htm', true
end

desc 'Match Bolton against Ward'
task :match_bolton_against_ward => :environment do
  BoltonReference.match_against_ward true
end

desc 'Import and match Bolton against Ward'
task :import_and_match_bolton => [:environment, :import_bolton, :match_bolton_against_ward]

desc "Import Bolton's genera"
task :import_genera => :environment do
  BoltonImporter.new.get_subfamilies('data/bolton/subfamily_genus.html')
end

desc "Import HOL source URLs"
task :import_hol_source_urls => :environment do
  Reference.import_hol_source_urls true
end
