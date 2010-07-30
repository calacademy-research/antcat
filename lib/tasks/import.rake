desc "Import HTML file of references"
task :import => :environment do
  Reference.delete_all
  Reference.import 'data/ANTBIB.htm', true
end

desc "Import HTML file of journal names"
task 'import:journals' => :environment do
  Journal.delete_all
  Journal.import 'data/ANTBIB Serials.htm', true
end
