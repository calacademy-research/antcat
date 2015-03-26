# coding: UTF-8
namespace :hol do
  namespace :import do
    desc "Import HOL document URLs"
    task :document_urls => :environment do
      Reference.import_hol_document_urls true
    end
  end

  desc "Compare taxa"
  task compare_with_antcat: :environment do
    Importers::Hol::Catalog.new.compare_with_antcat
  end

  desc "Compare subspecies"
  task compare_subspecies: :environment do
    Importers::Hol::Catalog.new.compare_subspecies
  end

end
