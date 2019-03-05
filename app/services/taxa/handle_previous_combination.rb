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

    create_new_usages_for_subspecies if previous_combination.is_a?(Species)
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

    # TODO: Quite possibly remove all code in the `if @previous_combination` branches in `TaxaController`, and along with
    # all related functionality, without replacing it with anything, because there are too many things here that do not work.
    #
    # Problem with `update_all senior_synonym_id: taxon.id` and `update_all junior_synonym_id: taxon.id`:
    # ---------------------------------------------------------------------------------------------
    # taxon: 508127 - Lasius fusca
    # previous_combination: 437477 - Formica fusca
    #
    # # Taxon.where(current_valid_taxon: previous_combination).each do |taxon_to_update|
    # #   # ...
    # # end;
    #
    # taxon_to_update: 437346 - Formica barbata
    # syn from senior_synonym_id / junior_synonym_id: 437477 / 437346
    # syn to   senior_synonym_id / junior_synonym_id: 437477 / 508127 <-- no exception because it's the first (soon-to-be) duplicate.
    #
    # taxon_to_update: 437459 - Formica flavipes
    # syn from senior_synonym_id / junior_synonym_id: 437477 / 437459
    # syn to   senior_synonym_id / junior_synonym_id: 437477 / 508127 <-- duplicate, raises `Mysql2::Error: Duplicate`
    # ---------------------------------------------------------------------------------------------
    # So it looks very much like the senior and junior are flipped in the `update_all`s, but it has always been like this AFAICT.
    def update_elements taxon_to_update, status_string
      taxon_to_update.current_valid_taxon = taxon
      taxon_to_update.status = status_string
      # TODO: Don't use `update_all` since it skips callbacks.
      taxon_to_update.history_items.update_all taxon_id: taxon.id
      taxon_to_update.junior_synonyms_objects.update_all senior_synonym_id: taxon.id
      taxon_to_update.senior_synonyms_objects.update_all junior_synonym_id: taxon.id
      taxon_to_update.save
    end

    # TODO this isn't tested.
    def create_new_usages_for_subspecies
      previous_combination.children.valid.each do |t|
        new_child = Subspecies.new
        new_child.parent = taxon
        Taxa::InheritAttributesForNewCombination[new_child, t, taxon]
        TaxonForm.new(new_child, Taxa::AttributesForNewUsage[new_child, t], t).save
      end
    end
end
