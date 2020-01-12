class TaxonForm
  def initialize taxon, taxon_params, taxon_name_string: nil, protonym_name_string: nil, user:
    @taxon = taxon
    @params = taxon_params
    @taxon_name_string = taxon_name_string
    @protonym_name_string = protonym_name_string
    @user = user
  end

  def save
    save_taxon
  end

  private

    attr_reader :taxon, :params, :taxon_name_string, :protonym_name_string, :user

    def save_taxon
      Taxon.transaction do
        # There is no `UndoTracker#current_change_id` at this point, so if
        # anything in the "update_*" methods triggers a save for any reason,
        # the versions' `change_id`s will be nil.

        if taxon_name_string
          taxon.name = Names::BuildNameFromString[taxon_name_string]
        end

        if params[:protonym_id].present?
          params.delete :protonym_attributes
        elsif protonym_name_string
          taxon.protonym.name = Names::BuildNameFromString[protonym_name_string]
        end

        taxon.attributes = params

        # TODO: I don't think this is 100% true, but the current code requires it.
        if taxon.is_a?(SpeciesGroupTaxon) && taxon.protonym.name.try(:genus_epithet).blank?
          taxon.errors.add :base, "Species and subspecies must have protonyms with species or subspecies names"
          raise ActiveRecord::RecordInvalid
        end

        save_and_create_change!
      end
    end

    def save_and_create_change!
      if taxon.new_record?
        change = UndoTracker.setup_change taxon, :create, user: user
        taxon.save!
        change.update(taxon: taxon)
      else
        UndoTracker.setup_change taxon, :update, user: user

        remove_auto_generated
        set_taxon_state_to_waiting

        taxon.save!
      end
    end

    def remove_auto_generated
      taxon.auto_generated = false
    end

    def set_taxon_state_to_waiting
      taxon.taxon_state.review_state = TaxonState::WAITING
    end
end
