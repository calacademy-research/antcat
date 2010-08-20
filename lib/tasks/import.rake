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
