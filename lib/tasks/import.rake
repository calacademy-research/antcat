desc "Import HTML file of references"
task :import => :environment do
  Reference.delete_all
  Reference.import 'data/ANTBIB.htm'
end
