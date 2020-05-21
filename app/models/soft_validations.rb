# frozen_string_literal: true

class SoftValidations
  WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER = 0.2.seconds

  # These scripts do not 100% belong here since scripts are injected to avoid coupling.
  TAXA_DATABASE_SCRIPTS_TO_CHECK = [
    DatabaseScripts::CurrentValidTaxonChains,
    DatabaseScripts::ExtantTaxaInFossilGenera,
    DatabaseScripts::FossilTaxaWithNonFossilProtonyms,
    DatabaseScripts::NonFossilTaxaWithFossilProtonyms,
    DatabaseScripts::NonOriginalCombinationsWithSameNameAsItsProtonym,
    DatabaseScripts::NonValidTaxaWithACurrentValidTaxonThatIsNotValid,
    DatabaseScripts::NonValidTaxaWithJuniorSynonyms,
    DatabaseScripts::ObsoleteCombinationsWithDifferentFossilStatusThanItsCurrentValidTaxon,
    DatabaseScripts::ObsoleteCombinationsWithObsoleteCombinations,
    DatabaseScripts::ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym,
    DatabaseScripts::ObsoleteCombinationsWithVeryDifferentEpithets,
    DatabaseScripts::PassThroughNamesWithTaxts,
    DatabaseScripts::ReplacementNamesUsedForMoreThanOneTaxon,
    DatabaseScripts::SpeciesWithGeneraAppearingMoreThanOnceInItsProtonym,
    DatabaseScripts::SynonymGeneraWithSpeciesWithIncompatibleStauses,
    DatabaseScripts::SynonymsBelongingToTheSameProtonymAsItsCurrentValidTaxon,
    DatabaseScripts::SynonymSpeciesWithSubspeciesWithIncompatibleStauses,
    DatabaseScripts::TaxaWithNonModernCapitalization,
    DatabaseScripts::TaxaWithObsoleteCombinationsBelongingToDifferentProtonyms,
    DatabaseScripts::UnavailableUncategorizedTaxa,
    DatabaseScripts::ValidSubspeciesInInvalidSpecies
  ]
  PROTONYM_DATABASE_SCRIPTS_TO_CHECK = [
    DatabaseScripts::FossilProtonymsWithNonFossilTaxa,
    DatabaseScripts::NonFossilProtonymsWithFossilTaxa,
    DatabaseScripts::OrphanedProtonyms,
    DatabaseScripts::ProtonymsWithDuplicatedTaxa,
    DatabaseScripts::ProtonymsWithMoreThanOneOriginalCombination,
    DatabaseScripts::ProtonymsWithMoreThanOneSynonym,
    DatabaseScripts::ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems,
    DatabaseScripts::ProtonymsWithMoreThanOneValidTaxon,
    DatabaseScripts::ProtonymsWithTaxaWithMoreThanOneCurrentValidTaxon,
    DatabaseScripts::ProtonymsWithTaxaWithVeryDifferentEpithets
  ]
  ALL_DATABASE_SCRIPTS_TO_CHECK = TAXA_DATABASE_SCRIPTS_TO_CHECK + PROTONYM_DATABASE_SCRIPTS_TO_CHECK

  attr_private_initialize :record, :database_script_klasses

  def all
    @_all ||= database_script_klasses.map do |database_script_klass|
      SoftValidation.run(record, database_script_klass)
    end
  end

  def failed
    @_failed ||= all.select(&:failed?)
  end

  # TODO: Check lazily.
  def failed?
    failed.present?
  end

  def total_runtime
    @_total_runtime ||= all.map(&:runtime).sum
  end

  def warn_about_slow_runtime?
    total_runtime > WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER
  end
end
