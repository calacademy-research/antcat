# `#save_taxon` saves a taxon and its children. It also does some other stuff
# such as creating a change, removing `auto_generated` etc.
#
# It expects params as formatted by the 'edit taxa form', which is why we need
# code such as `params[:name_attributes][:id]`, making it hard to use outside
# of `TaxaController`.

class Taxa::SaveTaxon
  include UndoTracker

  def initialize taxon
    @taxon = taxon
  end

  # TODO possibly rename.
  # `previous_combination` will be a pointer to the species taxon if non-nil.
  def save_taxon params, previous_combination = nil
    Taxon.transaction do
      update_name                params.delete :name_attributes
      update_parent              params.delete :parent_name_attributes
      update_current_valid_taxon params.delete :current_valid_taxon_name_attributes
      update_homonym_replaced_by params.delete :homonym_replaced_by_name_attributes
      update_protonym            params.delete :protonym_attributes
      update_type_name           params.delete :type_name_attributes
      update_name_status_flags   params

      # TODO move `taxon_state` stuff to a callback.
      if @taxon.new_record?
        @taxon.taxon_state = TaxonState.new
        @taxon.taxon_state.deleted = false
        @taxon.taxon_state.id = @taxon.id
      end
      @taxon.taxon_state.review_state = :waiting

      # we might want to get smarter about this
      change_type = if @taxon.new_record? then :create else :update end
      change = setup_change @taxon, change_type

      remove_auto_generated if @taxon.auto_generated

      @taxon.save!

      # paper_trail is dumb. When a new object is created, it has no "object".
      # So, if you undo the first change, and try to reify the previous one,
      # you end up with no object! touch_with_version gives us one, but
      # Just for the taxa, not the protonym or other changable objects.
      # TODO move to an `after_create` callback.
      if change_type == :create
        @taxon.touch_with_version
      end

      # TODO: The below may not be being used
      # UndoTracker#setup_change already does this.
      if change_type == :create
        change.user_changed_taxon_id = @taxon.id
        change.save
      end

      # for each taxon save, we need to have a change_id AND we need to create a new
      # transaction record
      # TODO move to a method.
      if previous_combination
        # the taxon that was just saved is a new combination. Update the
        # previous combination's status, associated it with the new
        # combination, and transfer all taxon history and synonyms

        # find all taxa that list previous_combination.id as
        # current_valid_taxon_id and update them
        Taxon.where(current_valid_taxon_id: previous_combination.id).each do |taxon_to_update|
          update_elements taxon_to_update, status_string_for_crazy(taxon_to_update)
        end

        # since the previous doesn't have a pointer to current_valid_taxon, it won't show up
        # in the above search. If it's the protonym, set it propertly.
        new_status = status_string_for_previous_combination previous_combination
        update_elements previous_combination, new_status
      end
      save_taxon_children @taxon
    end
  end

  private
    # TODO rename. Working title: `update_other_thing_and_some_of_its_associations`
    def update_elements taxon_to_update, status_string
      taxon_to_update.status = status_string
      taxon_to_update.current_valid_taxon = @taxon
      TaxonHistoryItem.where(taxon_id: taxon_to_update.id).update_all(taxon_id: @taxon.id)
      Synonym.where(senior_synonym_id: taxon_to_update.id).update_all(senior_synonym_id: @taxon.id)
      Synonym.where(junior_synonym_id: taxon_to_update.id).update_all(junior_synonym_id: @taxon.id)
      taxon_to_update.save
    end

    # TODO find proper name.
    def status_string_for_crazy taxon_to_update
      if Status[taxon_to_update] == Status['original combination']
        Status['original combination'].to_s
      else
        Status['obsolete combination'].to_s
      end
    end

    def status_string_for_previous_combination previous_combination
      if previous_combination.id == @taxon.protonym.id
        Status['original combination'].to_s
      else
        Status['obsolete combination'].to_s
      end
    end

    def update_name name_attributes
      attributes = name_attributes

      attributes[:name_id] = attributes.delete :id
      gender = attributes.delete :gender
      @taxon.name.gender = gender.blank? ? nil : gender
      @taxon.attributes = attributes
    end

    # A lot of stuff happens here and it looks like attributes are set
    # using four slightly different techniques?
    def update_name_status_flags params_after_initial_deletions
      attributes = params_after_initial_deletions

      attributes[:incertae_sedis_in] = nil unless attributes[:incertae_sedis_in].present?
      @taxon.attributes = attributes
      @taxon.headline_notes_taxt = Taxt.from_editable attributes.delete :headline_notes_taxt
      if attributes[:type_taxt]
        @taxon.type_taxt = Taxt.from_editable attributes.delete :type_taxt
      end
    end

    def update_parent parent_name_attributes
      return unless parent_name_attributes

      @taxon.update_parent Taxon.find_by(name_id: parent_name_attributes[:id])
    rescue Taxon::TaxonExists
      @taxon.errors[:base] = "This name is in use by another taxon"
      raise
    end

    def update_homonym_replaced_by homonym_replaced_by_name_attributes
      replacement_id = homonym_replaced_by_name_attributes[:id] # is this id the same as @taxon's id?
      replacement = replacement_id.present? ? Taxon.find_by(name_id: replacement_id) : nil

      @taxon.homonym_replaced_by = replacement
    end

    def update_current_valid_taxon current_valid_taxon_name_attributes
      replacement_id = current_valid_taxon_name_attributes[:id]
      replacement = replacement_id.present? ? Taxon.find_by(name_id: replacement_id) : nil

      @taxon.current_valid_taxon = replacement
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

    # TODO move to callback.
    def remove_auto_generated
      @taxon.auto_generated = false
      name = @taxon.name
      if name.auto_generated
        name.auto_generated = false
        name.save
      end

      # TODO get this from the @taxon.
      junior_synonyms = Synonym.where(senior_synonym_id: @taxon.id)
      junior_synonyms.each do |synonym|
        if synonym.auto_generated
          synonym.auto_generated = false
          synonym.save
        end
      end

      # TODO get this from the @taxon.
      senior_synonyms = Synonym.where(junior_synonym_id: @taxon.id)
      senior_synonyms.each do |synonym|
        if synonym.auto_generated
          synonym.auto_generated = false
          synonym.save
        end
      end
    end

    # Recursively saves children, presumably to trigger callbacks and create
    # PaperTrail versions. Do not include Formicidae (performance reasons?)
    # or Subspecies (they have no children).
    # TODO probably ignore the Subspecies check.
    def save_taxon_children taxon
      return if taxon.kind_of?(Family) || taxon.kind_of?(Subspecies)

      taxon.children.each do |child|
        child.save
        save_taxon_children child
      end
    end
end
