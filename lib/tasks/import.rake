Rake.application.options.trace = true

task :import_bibliography => [:import_ward, :import_hol_document_urls]

desc "Import HOL document URLs"
task :import_hol_document_urls => :environment do
  Reference.import_hol_document_urls true
end

