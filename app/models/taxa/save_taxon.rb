# This class is responsible for saving taxa from `TaxaController` (from the edit form).

class Taxa::SaveTaxon
  include UndoTracker

  def initialize taxon
    @taxon = taxon
  end

  # `previous_combination` will be a pointer to a species or subspecies if non-nil.
  def save_from_form params, previous_combination = nil
    @taxon.save_initiator = true

    Taxon.transaction do
      update_name                params.delete :name_attributes
      update_parent              params.delete :parent_name_attributes
      update_current_valid_taxon params.delete :current_valid_taxon_name_attributes
      update_homonym_replaced_by params.delete :homonym_replaced_by_name_attributes
      update_protonym            params.delete :protonym_attributes
      update_type_name           params.delete :type_name_attributes
      update_name_status_flags   params

      # we might want to get smarter about this
      change_type = if @taxon.new_record? then :create else :update end
      change = setup_change @taxon, change_type

      @taxon.save!

      # PaperTrail is dumb. When a new object is created, it has no "object".
      # So, if you undo the first change, and try to reify the previous one,
      # you end up with no object! touch_with_version gives us one, but
      # Just for the taxa, not the protonym or other changable objects.
      # TODO move to an `after_create` callback.
      @taxon.touch_with_version if change_type == :create

      # TODO: The below may not be being used
      # `UndoTracker#setup_change` already does this, but it looks like
      # we need this at least in tests, so let's keep it until we know more.
      if change_type == :create
        change.user_changed_taxon_id = @taxon.id
        change.save
      end

      if previous_combination
        Taxa::HandlePreviousCombination.new(@taxon).handle_it! previous_combination
      end
    end
  end

  private
    def update_name name_attributes
      attributes = name_attributes

      attributes[:name_id] = attributes.delete :id
      gender = attributes.delete :gender
      @taxon.name.gender = gender.blank? ? nil : gender
      @taxon.attributes = attributes
    end

    def update_parent parent_name_attributes
      return unless parent_name_attributes

      @taxon.update_parent Taxon.find_by(name_id: parent_name_attributes[:id])
    rescue Taxon::TaxonExists
      @taxon.errors[:base] = "This name is in use by another taxon"
      raise
    end

    def update_current_valid_taxon current_valid_taxon_name_attributes
      replacement_id = current_valid_taxon_name_attributes[:id]
      replacement = replacement_id.present? ? Taxon.find_by(name_id: replacement_id) : nil

      @taxon.current_valid_taxon = replacement
    end

    def update_homonym_replaced_by homonym_replaced_by_name_attributes
      replacement_id = homonym_replaced_by_name_attributes[:id]
      replacement = replacement_id.present? ? Taxon.find_by(name_id: replacement_id) : nil

      @taxon.homonym_replaced_by = replacement
    end

    def update_protonym protonym_attributes
      attributes = protonym_attributes

      attributes[:name_id] = attributes.delete(:name_attributes)[:id]
      update_protonym_authorship attributes.delete :authorship_attributes
      @taxon.protonym.attributes = attributes
    end

    def update_protonym_authorship authorship_attributes
      return unless @taxon.protonym.authorship

      attributes = authorship_attributes
      attributes[:reference_id] = attributes.delete(:reference_attributes)[:id]
      return if attributes[:reference_id].blank? and @taxon.protonym.authorship.reference.blank?

      if attributes[:notes_taxt]
        @taxon.protonym.authorship.notes_taxt = Taxt.from_editable attributes.delete :notes_taxt
      end
      @taxon.protonym.authorship.attributes = attributes
    end

    def update_type_name type_name_attributes
      attributes = type_name_attributes

      # ugly way to handle optional, but possibly pre-built, subobject
      if @taxon.type_name && @taxon.type_name.new_record? && (!attributes or attributes[:id] == '')
        @taxon.type_name = nil
        return
      end

      # Why do we hit this case?
      if attributes
        attributes[:type_name_id] = attributes.delete :id
        @taxon.attributes = attributes
      end
    end

    def update_name_status_flags params_after_initial_deletions
      attributes = params_after_initial_deletions

      # Why is this a special case but not the other attributes?
      attributes[:incertae_sedis_in] = nil unless attributes[:incertae_sedis_in].present?

      @taxon.attributes = attributes
      @taxon.headline_notes_taxt = Taxt.from_editable attributes.delete :headline_notes_taxt
      if attributes[:type_taxt]
        @taxon.type_taxt = Taxt.from_editable attributes.delete :type_taxt
      end
    end
end
