module Taxa
  module CallbacksAndValidations
    extend ActiveSupport::Concern

    BIOGEOGRAPHIC_REGIONS = %w[
      Nearctic Neotropic Palearctic Afrotropic Malagasy Indomalaya Australasia Oceania Antarctic
    ]
    INCERTAE_SEDIS_IN_RANKS = %w[family subfamily tribe genus]

    included do
      validates :name, presence: true
      validates :protonym, presence: true
      validates :status, inclusion: { in: Status::STATUSES }
      validates :incertae_sedis_in, inclusion: { in: INCERTAE_SEDIS_IN_RANKS, allow_nil: true }
      validates :homonym_replaced_by, absence: { message: "can't be set for non-homonyms" }, unless: -> { homonym? }

      validate :current_valid_taxon_validation, :ensure_correct_name_type, :biogeographic_region_validation

      before_save :set_name_caches

      # Additional callbacks for when `#save_initiator` is true (must be set manually).
      # TODO: Move or remove.
      before_save { remove_auto_generated if save_initiator }
      # TODO: Move or remove.
      before_save { set_taxon_state_to_waiting if save_initiator }

      strip_attributes only: [:incertae_sedis_in, :type_taxt, :headline_notes_taxt,
        :biogeographic_region], replace_newlines: true

      def soft_validation_warnings
        @soft_validation_warnings = Taxa::CheckIfInDatabaseResults[self]
      end
    end

    private

      def set_name_caches
        self.name_cache = name.name
        self.name_html_cache = name.name_html
      end

      def remove_auto_generated
        self.auto_generated = false
      end

      def set_taxon_state_to_waiting
        taxon_state.review_state = TaxonState::WAITING
        taxon_state.save
      end

      def biogeographic_region_validation
        if is_a?(SpeciesGroupTaxon) && !fossil?
          validates_inclusion_of :biogeographic_region, in: BIOGEOGRAPHIC_REGIONS, allow_nil: true
        else
          validates_absence_of :biogeographic_region
        end
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
        status.in? Status::CURRENT_VALID_TAXON_VALIDATION[:absence]
      end

      def requires_current_valid_taxon?
        status.in? Status::CURRENT_VALID_TAXON_VALIDATION[:presence]
      end

      def ensure_correct_name_type
        return if name.is_a? name_class
        return if name.class.name.in? Name::BROKEN_ISH_NAME_TYPES # Make sure taxa already in this state can be saved.
        error_message = "Rank (`#{self.class}`) and name type (`#{name.class}`) must match."
        errors.add :base, error_message unless errors.added? :base, error_message
      end
  end
end
