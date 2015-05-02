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

  desc "Get hol details for species not in antcat"
  task get_full_literature_records: :environment do
    Importers::Hol::HolLiterature.new.get_full_literature_records
  end

  desc "get hol taxon info json"
  task get_hol_json: :environment do
    Importers::Hol::GetHolTaxonInfo.new.get_json
  end

  desc "Expand hol json and make as many objects as possible without any fuzzy matching"
  task expand_hol_json: :environment do
    Importers::Hol::GetHolTaxonInfo.new.link_objects
  end

  desc "Get hol synonyms"
  task download_synonyms_from_hol: :environment do
    Importers::Hol::GetHolSynonyms.new.get_synonym_records
  end


  desc "Create hol synonyms"
  task create_hol_synonyms: :environment do
    Importers::Hol::HolSynonymLink.new.create_objects
  end

  desc "Fuzzy match taxon ids"
  task fuzzy_match_taxa: :environment do
    Importers::Hol::GetHolTaxonInfo.new.fuzzy_match_taxa
  end

end
