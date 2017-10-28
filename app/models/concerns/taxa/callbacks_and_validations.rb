# TODO validate status, can currently be set to anything.
# TODO add `before_destroy :check_not_referenced`, but allow suppressing it.

module Taxa::CallbacksAndValidations
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true
    validates :protonym, presence: true
    validates :biogeographic_region,
      inclusion: { in: BiogeographicRegion::REGIONS, allow_nil: true }

    before_validation :add_protocol_to_type_speciment_url

    before_create :build_default_taxon_state
    before_save :set_name_caches
    before_save { delete_synonyms if stopped_being_a_synonym? }

    # Additional callbacks for when `#save_initiator` is true (must be set manually).
    before_save { remove_auto_generated if save_initiator }
    before_save { set_taxon_state_to_waiting if save_initiator }
    before_save { save_children if save_initiator }

    strip_attributes only: [:incertae_sedis_in, :type_taxt, :headline_notes_taxt,
      :genus_species_header_notes_taxt, :verbatim_type_locality, :biogeographic_region,
      :type_specimen_repository, :type_specimen_code, :type_specimen_url], replace_newlines: true
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
      changes[:status].try(:first) == 'synonym'
    end

    def add_protocol_to_type_speciment_url
      return if type_specimen_url.blank? || type_specimen_url =~ %r{^https?://}
      self.type_specimen_url = "http://#{type_specimen_url}"
    end

    def remove_auto_generated
      self.auto_generated = false

      name.make_not_auto_generated!

      junior_synonyms_objects.auto_generated.each &:make_not_auto_generated!
      senior_synonyms_objects.auto_generated.each &:make_not_auto_generated!
    end

    def build_default_taxon_state
      build_taxon_state review_state: :waiting unless taxon_state
    end

    def set_taxon_state_to_waiting
      taxon_state.review_state = :waiting
      taxon_state.save
    end
end
