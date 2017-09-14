# This class is responsible for saving taxa from `TaxaController` (from the edit form).

class Taxa::SaveFromForm
  include Service

  # `previous_combination` will be a pointer to a species or subspecies if non-nil.
  def initialize taxon, params, previous_combination = nil
    @taxon = taxon
    @params = params
    @previous_combination = previous_combination
  end

  def call
    taxon.save_initiator = true

    Taxon.transaction do
      # There is no `UndoTracker#get_current_change_id` at this point, so if
      # anything in the "update_*" methods triggers a save for any reason,
      # the versions' `change_id`s will be nil.
      update_name                params.delete :name_attributes
      update_parent              params.delete :parent_name_attributes
      update_current_valid_taxon params.delete :current_valid_taxon_name_attributes
      update_homonym_replaced_by params.delete :homonym_replaced_by_name_attributes
      update_protonym            params.delete :protonym_attributes
      update_type_name           params.delete :type_name_attributes
      update_name_status_flags   params

      # Different setup because non-persisted objects have no IDs,
      # so we must update the change after saving `@taxon`.
      if taxon.new_record?
        change = UndoTracker.setup_change taxon, :create
        taxon.save!

        # PaperTrail is dumb. When a new object is created, it has no "object".
        # So, if you undo the first change, and try to reify the previous one,
        # you end up with no object! touch_with_version gives us one, but
        # Just for the taxa, not the protonym or other changable objects.
        #
        # TODO move to an `after_create` callback, or we may want to not do
        # `touch_with_version` at all since it's not the PaperTrail way:
        #
        #   "This also means that PaperTrail does not waste space storing a
        #   version of the object as it currently stands. The versions method
        #   gives you previous versions; to get the current one just call a
        #   finder on your Widget model as usual."
        taxon.touch_with_version

        change.update user_changed_taxon_id: taxon.id
      else
        UndoTracker.setup_change taxon, :update
        taxon.save!
      end

      if previous_combination
        Taxa::HandlePreviousCombination[taxon, previous_combination]
      end
    end
  end

  private
    attr_reader :taxon, :params, :previous_combination

    def update_name name_attributes
      attributes = name_attributes

      attributes[:name_id] = attributes.delete :id
      gender = attributes.delete :gender
      taxon.name.gender = gender.blank? ? nil : gender
      taxon.attributes = attributes
    end

    def update_parent parent_name_attributes
      return unless parent_name_attributes

      taxon.update_parent Taxon.find_by(name_id: parent_name_attributes[:id])
    rescue Taxon::TaxonExists
      taxon.errors[:base] = "This name is in use by another taxon"
      raise
    end

    def update_current_valid_taxon current_valid_taxon_name_attributes
      replacement_id = current_valid_taxon_name_attributes[:id]
      replacement = replacement_id.present? ? Taxon.find_by(name_id: replacement_id) : nil

      taxon.current_valid_taxon = replacement
    end

    def update_homonym_replaced_by homonym_replaced_by_name_attributes
      replacement_id = homonym_replaced_by_name_attributes[:id]
      replacement = replacement_id.present? ? Taxon.find_by(name_id: replacement_id) : nil

      taxon.homonym_replaced_by = replacement
    end

    def update_protonym protonym_attributes
      attributes = protonym_attributes

      attributes[:name_id] = attributes.delete(:name_attributes)[:id]
      update_protonym_authorship attributes.delete :authorship_attributes
      taxon.protonym.attributes = attributes
    end

    def update_protonym_authorship authorship_attributes
      return unless taxon.protonym.authorship

      attributes = authorship_attributes
      attributes[:reference_id] = attributes.delete(:reference_attributes)[:id]
      return if attributes[:reference_id].blank? and taxon.protonym.authorship.reference.blank?

      if attributes[:notes_taxt]
        taxon.protonym.authorship.notes_taxt = TaxtConverter[attributes.delete :notes_taxt].from_editor_format
      end
      taxon.protonym.authorship.attributes = attributes
    end

    def update_type_name type_name_attributes
      attributes = type_name_attributes

      # ugly way to handle optional, but possibly pre-built, subobject
      if taxon.type_name && taxon.type_name.new_record? && (!attributes or attributes[:id] == '')
        taxon.type_name = nil
        return
      end

      # Why do we hit this case?
      if attributes
        attributes[:type_name_id] = attributes.delete :id
        taxon.attributes = attributes
      end
    end

    def update_name_status_flags params_after_initial_deletions
      attributes = params_after_initial_deletions

      # Why is this a special case but not the other attributes?
      attributes[:incertae_sedis_in] = nil unless attributes[:incertae_sedis_in].present?

      taxon.attributes = attributes
      taxon.headline_notes_taxt = TaxtConverter[attributes.delete :headline_notes_taxt].from_editor_format
      if attributes[:type_taxt]
        taxon.type_taxt = TaxtConverter[attributes.delete :type_taxt].from_editor_format
      end
    end
end
