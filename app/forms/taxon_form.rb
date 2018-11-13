# TODO not really a form but we are getting there.

class TaxonForm
  # `previous_combination` will be a pointer to a species or subspecies if non-nil.
  def initialize taxon, taxon_params, previous_combination = nil
    @taxon = taxon
    @params = taxon_params
    @previous_combination = previous_combination
  end

  def save
    save_taxon
  end

  private

    attr_reader :taxon, :params, :previous_combination

    def save_taxon
      taxon.save_initiator = true

      Taxon.transaction do
        # There is no `UndoTracker#get_current_change_id` at this point, so if
        # anything in the "update_*" methods triggers a save for any reason,
        # the versions' `change_id`s will be nil.
        subspecies_without_species_special_case

        update_type_name params.delete :type_name_attributes

        params[:name_id] = params[:name_attributes][:id]
        params[:protonym_attributes][:name_id] = params[:protonym_attributes][:name_attributes][:id]

        taxon.attributes = params

        save_and_create_change!

        if previous_combination
          Taxa::HandlePreviousCombination[taxon, previous_combination]
        end
      end
    end

    # TODO: remove once http://localhost:3000/database_scripts/subspecies_without_species has been cleared.
    def subspecies_without_species_special_case
      if taxon.is_a?(Subspecies) && taxon.species.blank? && params[:species_id].present?
        taxon.update_parent Taxon.find(params[:species_id])
      end
    rescue Taxon::TaxonExists
      taxon.errors.add :base, "This name is in use by another taxon"
      raise
    end

    def update_type_name type_name_attributes
      attributes = type_name_attributes

      if taxon.type_name && taxon.type_name.new_record? && (!attributes || (attributes[:id] == ''))
        taxon.type_name = nil
        return
      end

      if attributes
        attributes[:type_name_id] = attributes.delete :id
        taxon.attributes = attributes
      end
    end

    def save_and_create_change!
      if taxon.new_record?
        change = UndoTracker.setup_change taxon, :create
        taxon.save!
        change.update taxon: taxon
      else
        UndoTracker.setup_change taxon, :update
        taxon.save!
      end
    end
end
