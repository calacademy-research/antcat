# TODO add `before_destroy :check_not_referenced`, but allow suppressing it.

module Taxa::CallbacksAndValidations
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true
    validates :protonym, presence: true
    validates :status, inclusion: { in: Status::STATUSES }
    validates :biogeographic_region,
      inclusion: { in: BiogeographicRegion::REGIONS, allow_nil: true }
    validate :current_valid_taxon_validation

    before_create :build_default_taxon_state
    before_save :set_name_caches
    before_save { delete_synonyms if stopped_being_a_synonym? }

    # Additional callbacks for when `#save_initiator` is true (must be set manually).
    before_save { remove_auto_generated if save_initiator }
    before_save { set_taxon_state_to_waiting if save_initiator }
    before_save { save_children if save_initiator }

    strip_attributes only: [:incertae_sedis_in, :type_taxt, :headline_notes_taxt,
      :genus_species_header_notes_taxt, :biogeographic_region], replace_newlines: true

    strip_attributes only: [:primary_type_information, :secondary_type_information, :type_notes]
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

      name.make_not_auto_generated!

      junior_synonyms_objects.auto_generated.each &:make_not_auto_generated!
      senior_synonyms_objects.auto_generated.each &:make_not_auto_generated!
    end

    def build_default_taxon_state
      build_taxon_state review_state: TaxonState::WAITING unless taxon_state
    end

    def set_taxon_state_to_waiting
      taxon_state.review_state = TaxonState::WAITING
      taxon_state.save
    end

    def current_valid_taxon_validation
      if valid_taxon? && current_valid_taxon
        errors.add :current_valid_name, "can't be set for valid taxa"
      end

      if unavailable? && current_valid_taxon
        errors.add :current_valid_name, "can't be set for unavailable taxa"
      end
    end
end
