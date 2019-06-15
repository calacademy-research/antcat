class TaxonForm
  def initialize taxon, taxon_params, taxon_name_string: nil, protonym_name_string: nil
    @taxon = taxon
    @params = taxon_params
    @taxon_name_string = taxon_name_string
    @protonym_name_string = protonym_name_string
  end

  def save
    save_taxon
  rescue Names::CreateNameFromString::UnparsableName => e
    taxon.errors.add :base, "Could not parse name #{e.message}"
    raise ActiveRecord::RecordInvalid
  end

  private

    attr_reader :taxon, :params, :taxon_name_string, :protonym_name_string

    def save_taxon
      taxon.save_initiator = true

      Taxon.transaction do
        # There is no `UndoTracker#get_current_change_id` at this point, so if
        # anything in the "update_*" methods triggers a save for any reason,
        # the versions' `change_id`s will be nil.
        subspecies_without_species_special_case

        if taxon_name_string
          taxon.name = Names::CreateNameFromString[taxon_name_string]
        end

        if params[:protonym_id].present?
          params.delete :protonym_attributes
        else
          if protonym_name_string
            taxon.protonym.name = Names::CreateNameFromString[protonym_name_string]
          end
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

    # TODO: remove once http://localhost:3000/database_scripts/subspecies_without_species has been cleared.
    def subspecies_without_species_special_case
      if taxon.is_a?(Subspecies) && !taxon.species && params[:species_id].present?
        taxon.update_parent Taxon.find(params[:species_id])
      end
    rescue Taxon::TaxonExists
      taxon.errors.add :base, "This name is in use by another taxon"
      raise
    end

    def save_and_create_change!
      if taxon.new_record?
        change = UndoTracker.setup_change taxon, :create
        taxon.save!
        change.update(taxon: taxon)
      else
        UndoTracker.setup_change taxon, :update
        taxon.save!
      end
    end
end
