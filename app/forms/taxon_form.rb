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
        update_name                 params.delete :name_attributes
        update_parent               params.delete :parent_name_attributes
        update_protonym             params.delete :protonym_attributes
        update_type_name            params.delete :type_name_attributes

        taxon.attributes = params

        save_and_create_change!

        if previous_combination
          Taxa::HandlePreviousCombination[taxon, previous_combination]
        end
      end
    end

    def update_name name_attributes
      attributes = name_attributes

      attributes[:name_id] = attributes.delete :id
      taxon.name.gender = attributes.delete :gender
      taxon.attributes = attributes
    end

    def update_parent parent_name_attributes
      return unless parent_name_attributes

      taxon.update_parent Taxon.find_by(name_id: parent_name_attributes[:id])
    rescue Taxon::TaxonExists
      taxon.errors[:base] = "This name is in use by another taxon"
      raise
    end

    def update_protonym protonym_attributes
      attributes = protonym_attributes

      attributes[:name_id] = attributes.delete(:name_attributes)[:id]
      taxon.protonym.attributes = attributes
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

        taxon.paper_trail.touch_with_version

        change.update taxon: taxon
      else
        UndoTracker.setup_change taxon, :update
        taxon.save!
      end
    end
end
