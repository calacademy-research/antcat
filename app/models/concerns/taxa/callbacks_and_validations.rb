# TODO add `before_destroy :check_not_referenced`, but allow suppressing it.

module Taxa::CallbacksAndValidations
  extend ActiveSupport::Concern

  BIOGEOGRAPHIC_REGIONS = %w[
    Nearctic Neotropic Palearctic Afrotropic Malagasy Indomalaya Australasia Oceania Antarctic
  ]
  WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER = 0.1.seconds
  DATABASE_SCRIPTS_TO_CHECK = [
    DatabaseScripts::ExtantTaxaInFossilGenera,
    DatabaseScripts::FossilTaxaWithBiogeographicRegions,
    DatabaseScripts::JuniorSynonymsListedAsAnotherTaxonsSenior,
    DatabaseScripts::NonHomonymsWithAHomonymReplacedById,
    DatabaseScripts::PassThroughNamesWithTaxts,
    DatabaseScripts::SubspeciesWithoutSpecies,
    DatabaseScripts::TaxaReferencingNonExistingTaxa,
    DatabaseScripts::TaxaWithBothJuniorAndSeniorSynonyms,
    DatabaseScripts::TaxaWithMoreThanOneSeniorSynonym,
    DatabaseScripts::ValidTaxaListedAsAnotherTaxonsJuniorSynonym
  ]

  included do
    validates :name, presence: true
    validates :protonym, presence: true
    validates :status, inclusion: { in: Status::STATUSES }
    validates :biogeographic_region, inclusion: { in: BIOGEOGRAPHIC_REGIONS, allow_nil: true }
    validate :current_valid_taxon_validation, :ensure_correct_name_type

    validation_scope :soft_validation_warnings do |scope|
      scope.validate :check_if_in_database_scripts_results
    end

    before_create :build_default_taxon_state
    before_save :set_name_caches
    before_save { delete_synonyms if stopped_being_a_synonym? }

    # Additional callbacks for when `#save_initiator` is true (must be set manually).
    before_save { remove_auto_generated if save_initiator }
    before_save { set_taxon_state_to_waiting if save_initiator }
    before_save { save_children if save_initiator }

    strip_attributes only: [:incertae_sedis_in, :type_taxt, :headline_notes_taxt,
      :biogeographic_region], replace_newlines: true

    strip_attributes only: [:primary_type_information, :secondary_type_information, :type_notes]

    # NOTE: Not private, see https://github.com/gtd/validation_scopes#dont-use-private-methods
    def check_if_in_database_scripts_results
      _check_if_in_database_scripts_results
    end
  end

  # Recursively save children, presumably to trigger callbacks and create
  # PaperTrail versions. Formicidae is excluded, probably for performance reasons?
  def save_children
    return if is_a? ::Family

    children.each &:save
    children.each &:save_children
  end

  private

    def set_name_caches
      self.name_cache = name.name
      self.name_html_cache = name.name_html
    end

    def delete_synonyms
      synonyms_as_junior.destroy_all
    end

    # When `changes` includes: `{ status: ["synonym", "<not synonym>"] }`
    def stopped_being_a_synonym?
      changes[:status].try(:first) == Status::SYNONYM
    end

    def remove_auto_generated
      self.auto_generated = false
      name.auto_generated = false
    end

    def build_default_taxon_state
      build_taxon_state review_state: TaxonState::WAITING unless taxon_state
    end

    def set_taxon_state_to_waiting
      taxon_state.review_state = TaxonState::WAITING
      taxon_state.save
    end

    def current_valid_taxon_validation
      if cannot_have_current_valid_taxon? && current_valid_taxon
        errors.add :current_valid_name, "can't be set for #{Status.plural(status)} taxa"
      end

      if requires_current_valid_taxon? && !current_valid_taxon
        errors.add :current_valid_name, "must be set for #{Status.plural(status)}"
      end
    end

    def cannot_have_current_valid_taxon?
      valid_taxon? || unavailable?
    end

    def requires_current_valid_taxon?
      synonym? || original_combination? || obsolete_combination?
    end

    def ensure_correct_name_type
      return if name.is_a? name_class
      return unless name_id_changed? # Make sure taxa already in this state can be saved.
      error_message = "Rank (`#{self.class}`) and name type (`#{name.class}`) must match."
      errors.add :base, error_message unless errors.added? :base, error_message
    end

    def _check_if_in_database_scripts_results
      start = Time.current

      DATABASE_SCRIPTS_TO_CHECK.each do |database_script_klass|
        next unless database_script_klass.taxon_in_results?(self)

        database_script = database_script_klass.new
        soft_validation_warnings.add :base, message: database_script.issue_description, database_script: database_script
      end

      render_duration = Time.current - start
      if render_duration > WARN_ON_DATABASE_SCRIPTS_RUNTIME_OVER
        soft_validation_warnings.add :base, message: "Script runtime: #{render_duration} seconds"
      end
    end
end
