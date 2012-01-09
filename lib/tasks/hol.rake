# coding: UTF-8

require 'reference_utility'

namespace :hol do
  namespace :import do
    desc "Import HOL document URLs"
    task :document_urls => :environment do
      Reference.import_hol_document_urls true
    end
  end
end
