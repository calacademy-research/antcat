# Note: some of the comments here may be incorrect, as I'm still trying to
# understand what's going on.

class Taxa::HandlePreviousCombination
  include Service

  def initialize taxon, previous_combination
    @taxon = taxon # The new combination.
    @previous_combination = previous_combination
  end

  # The taxon that was just saved is a new combination. Update the
  # previous combination's status, associated it with the new
  # combination, and transfer all taxon history and synonyms.
  def call
    # Find all taxa that list `previous_combination.id` as
    # `current_valid_taxon_id`, and update them.
    Taxon.where(current_valid_taxon: previous_combination).each do |taxon_to_update|
      update_elements taxon_to_update, status_string_for_crazy(taxon_to_update)
    end

    # Since the previous doesn't have a pointer to `current_valid_taxon`,
    # it won't show up in the above search. If it's the protonym, set it propertly.
    new_status = status_string_for_previous_combination previous_combination
    update_elements previous_combination, new_status
  end

  private
    attr_reader :taxon, :previous_combination

    # TODO find proper name.
    def status_string_for_crazy taxon_to_update
      if taxon_to_update.status == Status::ORIGINAL_COMBINATION
        Status::ORIGINAL_COMBINATION
      else
        Status::OBSOLETE_COMBINATION
      end
    end

    def status_string_for_previous_combination previous_combination
      if previous_combination.id == taxon.protonym.id
        Status::ORIGINAL_COMBINATION
      else
        Status::OBSOLETE_COMBINATION
      end
    end

    # TODO see https://github.com/calacademy-research/antcat/issues/157
    #
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
      taxon_to_update.current_valid_taxon = taxon

      # The new status will be either 'original combination' or 'obsolete combination'.
      taxon_to_update.status = status_string

      # Transfer the original/obsolete combination's history items to `@taxon`.
      taxon_to_update.history_items.update_all taxon_id: taxon.id

      # Update the PC and Friends' junior synonyms (if there are any) to point to `@taxon`.
      # This makes sense, because taxa that are/were junior synonyms of PC and its
      # Friends are now junior synonyms of `@taxon`, so update.
      taxon_to_update.junior_synonyms_objects.update_all senior_synonym_id: taxon.id

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
      taxon_to_update.senior_synonyms_objects.update_all junior_synonym_id: taxon.id

      taxon_to_update.save
    end
end
