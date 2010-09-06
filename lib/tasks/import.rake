desc "Import HTML files of references from Ward"
task :import_ward => :environment do
  WardReference.delete_all
  Reference.delete_all
  Book.delete_all
  WardBibliography.new.import_file 'data/ward/ANTBIB.htm', true
  WardBibliography.new.import_file 'data/ward/ANTBIB96.htm', true
end

desc "Import HTML files of references from Bolton"
task :import_bolton => :environment do
  BoltonReference.delete_all
  BoltonReference.import 'data/NGC-REFS_a-d.htm', true
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
