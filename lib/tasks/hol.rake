Rake.application.options.trace = true

namespace :hol do
  namespace :import do
    desc "Import HOL document URLs"
    task :document_urls => :environment do
      Reference.import_hol_document_urls true
    end
  end
end
