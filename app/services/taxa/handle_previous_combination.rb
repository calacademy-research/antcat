class Taxa::HandlePreviousCombination
  include Service

  def initialize taxon, previous_combination
    @taxon = taxon # The new combination.
    @previous_combination = previous_combination
  end

  def call
    Taxon.where(current_valid_taxon: previous_combination).each do |taxon_to_update|
      update_elements taxon_to_update, status_string_for_crazy(taxon_to_update)
    end

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

    # TODO this passes only because taxa and protonyms created in tests happen to have the same ID.
    # `taxa.id` and `protonyms.id` will never be the same as protonym IDs are in a different range.
    def status_string_for_previous_combination previous_combination
      if previous_combination.id == taxon.protonym.id
        Status::ORIGINAL_COMBINATION
      else
        Status::OBSOLETE_COMBINATION
      end
    end

    def update_elements taxon_to_update, status_string
      taxon_to_update.current_valid_taxon = taxon
      taxon_to_update.status = status_string
      taxon_to_update.history_items.update_all taxon_id: taxon.id
      taxon_to_update.junior_synonyms_objects.update_all senior_synonym_id: taxon.id
      taxon_to_update.senior_synonyms_objects.update_all junior_synonym_id: taxon.id
      taxon_to_update.save
    end
end
