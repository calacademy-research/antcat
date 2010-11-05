desc "Import Ward's HTML files into References"
task :import_ward => [:get_ward, :export_ward]

desc "Read Ward's HTML files"
task :get_ward => :environment do
  WardReference.delete_all
  WardBibliography.new('data/ward/ANTBIB_v1V.htm', true).import_file
  WardBibliography.new('data/ward/ANTBIB96_v1V.htm', true).import_file
end

desc "Export Ward's references into References"
task :export_ward => :environment do
  Reference.delete_all
  Author.delete_all
  Publisher.delete_all
  Journal.delete_all
  WardReference.export true
end
