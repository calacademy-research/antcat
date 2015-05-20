# coding: UTF-8
namespace :hol do
  namespace :import do
    desc "Import HOL document URLs"
    task :document_urls => :environment do
      Reference.import_hol_document_urls true
    end
  end

  #
  #  Note - these steps never create journals, references, authors, protonyms or citations. We also
  # are not currently using citation matching; it didn't return any hits.
  #
  #  At the end of this run, it's possible that there are taxa that
  # have no synonyms which are ignored. A good next step would be identify and examine these
  # taxa. They could well be taxa that are new to antcat. The danger is that we don't want to
  # include any taxa because a chain of mis-identification caused us to fail to match something
  # antcat already has.
  #
  # Possibly create a manual process for researchers to review these orphans and either enter
  # manual overrides (currently we use hashes in lib/importers/hol/hol_*_matcher; these could
  # pre-seed out of a database table) or add new journals, authors, and references for things which
  # should match. For things which are new, we have no process at present.
  #
  # these steps can be reversed and re-run to get the latest hol data. Note that step 3 (downloading)
  # all hol data) can take 72 hours.
  #

  # Step 1  - pull basic HolDatum records
  desc "Compare taxa"
  task downlad_hol_taxa_hash: :environment do
    Importers::Hol::DownloadHolTaxa.new.downlad_hol_taxa_hash
  end

  # optional step 2, see comments in download_hol_taxa
  desc "Compare subspecies"
  task download_children_of_type: :environment do
    Importers::Hol::DownloadHolTaxa.new.download_children_of_type
  end


  # Step 3 - download all the json records and create initial rows in the hol_taxon_data
  # table. Populates only tnuid and json records.
  desc "get hol taxon info json"
  task get_hol_json: :environment do
    Importers::Hol::DownloadHolTaxaDetails.new.get_json
  end

  # Step 4 - makes loads of objects and does errorless matching up to antcat_taxon_id.
  # Populates most of the fields in this table
  desc "Expand hol json and link as many objects as possible without any fuzzy matching"
  task expand_hol_json: :environment do
    Importers::Hol::DownloadHolTaxaDetails.new.link_objects
  end

  # step 5- Meant to be run after initial import; this step will match as many bits as it can
  # to associate a hol taxa with an antcat taxa. Details in "match_antcat_taxon" routine.
  # More work (hieristics) could be done here. It's still pretty conservative.
  desc "Fuzzy match taxon ids"
  task fuzzy_match_taxa: :environment do
    Importers::Hol::DownloadHolTaxaDetails.new.fuzzy_match_taxa
  end

  # Step 6 - download hol synonyms. One query for each record generated in steps 1 and 2.
  desc "Get hol synonyms"
  task download_synonyms_from_hol: :environment do
    Importers::Hol::GetHolSynonyms.new.get_synonym_records
  end

  # Step 6.5 - Download json details for hol synonyms. Gets the details pulled in step 6.
  desc "Get hol synonym details"
  task get_hol_synonym_json: :environment do
    Importers::Hol::DownloadHolTaxaDetails.new.get_hol_synonym_json
  end

  # Step 7 - Creates records! finally. Uses the synonym records from step 6
  # to create new names, if needed, and new taxon records that point
  # to existing valid taxa.
  desc "Create hol synonyms"
  task create_hol_synonyms: :environment do
    Importers::Hol::LinkHolTaxa.new.create_objects
  end

  #
  # Wipe out all name and taxa imports that haven't been touched by a user
  # (which flips the "auto generated" flag)
  # Does not modify the data generated in step 4 (link_objects)
  #
  desc "Remove auto-generated"
  task remove_auto_generated: :environment do
    Importers::Hol::LinkHolTaxa.new.remove_auto_generated
  end

  # Wipe out "matched" fields on hol_taxon_data
  desc "remove hol links"
  task unlink_objects: :environment do
    Importers::Hol::DownloadHolTaxaDetails.new.unlink_objects
  end



  #===================================

  # Not part of main import sequence; this populates the
  # hol_literatures and hol_literature_pages tables.
  # Not used for subsequent matching at present.
  desc "Get hol details for species not in antcat"
  task get_full_literature_records: :environment do
    Importers::Hol::HolLiterature.new.get_full_literature_records
  end

  #======== debugging
  # Step 7 - Creates records! finally. Uses the synonym records from step 6
  # to create new names, if needed, and new taxon records that point
  # to existing valid taxa.
  desc "Create hol synonyms"
  task create_bad_case: :environment do
    Importers::Hol::LinkHolTaxa.new.create_bad_case
  end

  desc "Fuzzy match singe taxon"
  task fuzzy_match_single_taxon: :environment do
    Importers::Hol::DownloadHolTaxaDetails.new.test_single_taxon
  end


end
