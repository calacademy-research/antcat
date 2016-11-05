# Note: some of the comments here may be incorrect, as I'm still trying to
# understand what's going on.
#
# `#save_taxon` (the only public method) is responsible for, in -ish this order:
#   1) Parse the `params` to prepare them for ActiveRecord's `#save`.
#   2) Update the `TaxonState`, or create it.
#   3) Create a `Change`.
#   4) Ask PaperTrail to create a version.
#   5) Remove `auto_generated` flags from various tables.
#   6) Run `Taxon#save`.
#   7) If `previous_combination` was passed in, that means we're have just saved a
#      new taxon with attributes inherited from that previous combination.
#      `#handle_previous_combination` will take care of updating the `previous_combination`
#      and transfer some of its associations to this new taxon.
#   8) Finally, call `#save_taxon_children`, which recursively saves all children
#      via ActiveRecord's `#save`, presumably to create new PaperTrail versions
#      and to trigger callbacks; for example if a species is saved with a different
#      genus, this makes sure that all the species' subspecies also are updated
#      so they belong to that genus.
#
# `#save_taxon` expects `params` as they are formatted by the 'edit taxa form',
# which is why we have code such as `params[:name_attributes][:id]` that must be
# parsed/modified up. Also, the `params` are not "pure", as in it's more like the
# method expects `params` from the form + changes JavaScripts made to them +
# stuff in `TaxaController` = it's hard to use this outside of `TaxaController`.

class Taxa::SaveTaxon
  include UndoTracker

  def initialize taxon
    @taxon = taxon
  end

  # TODO possibly rename.
  # `previous_combination` will be a pointer to a species or subspecies if non-nil.
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
        @taxon.taxon_state.deleted = false # TODO default to "false" in db.
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
      # `UndoTracker#setup_change` already does this, but it looks like
      # we need this at least in tests, so let's keep it until we know more.
      if change_type == :create
        change.user_changed_taxon_id = @taxon.id
        change.save
      end

      handle_previous_combination previous_combination if previous_combination

      save_taxon_children @taxon
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

    # TODO move to callback.
    def remove_auto_generated
      @taxon.auto_generated = false
      name = @taxon.name
      if name.auto_generated
        name.auto_generated = false
        name.save
      end

      @taxon.junior_synonyms_objects.where(auto_generated: true).each do |synonym|
        synonym.auto_generated = false
        synonym.save
      end

      @taxon.senior_synonyms_objects.where(auto_generated: true).each do |synonym|
        synonym.auto_generated = false
        synonym.save
      end
    end

    # TODO extract to a new class? I do not fully understand what's going on,
    # but I believe that if `TaxaController` decides that the taxon being saved
    # is a combination, then we get here without the actual taxon. Instead: 1) we get
    # a copy of it, 2) we do the `update_name` stuff etc and save it, resulting in a
    # taxon with a new id, 3) we update the passed in `previous_combination`, ie, update
    # its status, etc, and transfer its associated items to the new taxon id.
    #
    # The taxon that was just saved is a new combination. Update the
    # previous combination's status, associated it with the new
    # combination, and transfer all taxon history and synonyms.
    def handle_previous_combination previous_combination
      # Find all taxa that list `previous_combination.id` as
      # `current_valid_taxon_id`, and update them.
      Taxon.where(current_valid_taxon_id: previous_combination.id).each do |taxon_to_update|
        update_elements taxon_to_update, status_string_for_crazy(taxon_to_update)
      end

      # Since the previous doesn't have a pointer to `current_valid_taxon`,
      # it won't show up in the above search. If it's the protonym, set it propertly.
      new_status = status_string_for_previous_combination previous_combination
      update_elements previous_combination, new_status
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

    # TODO rename. Working name: `set_current_valid_taxon_to_the_current_taxon_and_update_stuff`
    # Or, move it to `SpeciesGroupTaxon` (only species and subspecies can be combinations).
    # And then somewhere: `Species#make_combination_of!(taxon)`. Would have private methods
    # such as `transfer_history_items` and `retarget_synonyms`.
    #
    # So, this method is called on the previous combination and any taxa where `current_valid_taxon`
    # is pointing to the previous combination. "PC and it's Friends", for short.
    # Some comments may make it sound like PC and Friends are updated at the same time,
    # but that's just me lying while trying to wrap my head around it.
    def update_elements taxon_to_update, status_string
      taxon_to_update.current_valid_taxon = @taxon

      # The new status will be either 'original combination' or 'obsolete combination'.
      taxon_to_update.status = status_string

      # Transfer the original/obsolete combination's history items to `@taxon`.
      taxon_to_update.history_items.update_all taxon_id: @taxon.id

      # Update the PC and Friends' junior synonyms (if there are any) to point to `@taxon`.
      # This makes sense, because taxa that are/were junior synonyms of PC and its
      # Friends are now junior synonyms of `@taxon`, so update.
      taxon_to_update.junior_synonyms_objects.update_all senior_synonym_id: @taxon.id

      # THIS IS THE TRICKY PART!!!
      # Take all synonym relationships where PC or one of its Friends is listed as
      # the `junior_synonym` (ie, ignore anything but senior synonyms of PC and Friends),
      # and change `junior_synonym` to point to `@taxon`.
      #
      # So, now our new `@taxon` may have senior synonyms that were transferred from
      # other taxa. This makes sense because........... trying to think... . ... .
      # .... ... so... I guess this case is for when the new `@taxon` is a synonym?
      # Then it would make sense to inherit the seniors. But is doesn't make sense
      # because setting PC and Friends' `current_valid_taxon` to point to `@taxon`
      # implies that `@taxon` is valid, no?
      #
      # A thought: all these "Friends", do they have PC as their senior synonym?
      #
      # Another train of thought: if any seniors were transferred, that implies that PC or
      # a Friend was a synonym of a third taxon that is valid, and that taxon is now
      # `@taxon`'s senior synonym, which means `@taxon` is a junior synonym of that
      # third taxon, which means PC and Friends' `current_valid_taxon` should not had
      # been changed to `@taxon`...
      #
      # I'm sure there's something I'm not seeing here, perhaps this can never happen,
      # and if it does due to incorrect data, this is less incorrect that not doing anything.
      taxon_to_update.senior_synonyms_objects.update_all junior_synonym_id: @taxon.id

      taxon_to_update.save
    end

    # Recursively saves children, presumably to trigger callbacks and create
    # PaperTrail versions. Do not include Formicidae (performance reasons?).
    def save_taxon_children taxon
      return if taxon.is_a? Family

      taxon.children.each do |child|
        child.save
        save_taxon_children child
      end
    end
end
