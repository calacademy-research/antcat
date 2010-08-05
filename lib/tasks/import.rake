desc "Import HTML files of references"
task :import => :environment do
  Reference.delete_all
  Reference.import 'data/ANTBIB.htm', true
  Reference.import 'data/ANTBIB96.htm', true
end
