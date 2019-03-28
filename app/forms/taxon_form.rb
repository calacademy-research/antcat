class TaxonForm
  def initialize taxon, taxon_params
    @taxon = taxon
    @params = taxon_params
  end

  def save
    save_taxon
  end

  private

    attr_reader :taxon, :params

    def save_taxon
      taxon.save_initiator = true

      Taxon.transaction do
        # There is no `UndoTracker#get_current_change_id` at this point, so if
        # anything in the "update_*" methods triggers a save for any reason,
        # the versions' `change_id`s will be nil.
        subspecies_without_species_special_case

        params[:name_id] = params[:name_attributes][:id]

        if params[:protonym_id].present?
          params.delete :protonym_attributes
        else
          params[:protonym_attributes][:name_id] = params[:protonym_attributes][:name_attributes][:id]
        end

        taxon.attributes = params

        save_and_create_change!
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
