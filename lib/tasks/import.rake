desc "Import HTML files of references"
task :import => :environment do
  Reference.delete_all
  Reference.import 'data/ANTBIB.htm', true
  Reference.import 'data/ANTBIB96.htm', true
end

desc "Import HTML files of references from Bolton"
task :import_bolton => :environment do
  BoltonReference.delete_all
  BoltonReference.import 'data/NGC-REFS_a-d.htm', true
end

desc 'Match Bolton against Ward'
task :match_bolton_against_ward => :environment do
  BoltonReference.match_all true
end

desc 'Import and match Bolton against Ward'
task :import_and_match_bolton => [:environment, :import_bolton, :match_bolton_against_ward]
