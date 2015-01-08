# coding: UTF-8

class TaxonMother
  # A TaxonMother is responsible for creating/saving
  # an object web of objects, starting with Taxon

  def initialize id = nil
    @id = id
  end

  def load_taxon
    @taxon = Taxon.find @id
    build_children
    @taxon
  end

  def create_taxon rank, parent
    @taxon = rank.string.titlecase.constantize.new
    @taxon.parent = parent
    build_children
    @taxon
  end

  def save_taxon taxon, params, previous_combination = nil
    Taxon.transaction do
      @taxon = taxon
      update_name params.delete :name_attributes
      update_parent params.delete :parent_name_attributes
      update_current_valid_taxon params.delete :current_valid_taxon_name_attributes
      update_homonym_replaced_by params.delete :homonym_replaced_by_name_attributes
      update_protonym params.delete :protonym_attributes
      update_type_name params.delete :type_name_attributes
      update_name_status_flags params

      @taxon.review_state = :waiting

      if @taxon.new_record?
        change_type = :new
      else
        # we might want to get smarter about this
        change_type = :update
      end
      change = save_change change_type
      change_id = change.id
      @taxon.save_with_transaction! change.id
      if(change_type == :new)
        change.user_changed_taxon_id = @taxon.id
        change.save
      end

      # for each taxon save, we need to have a change_id AND we need to create a new
      # transaction record
      if previous_combination
        # the taxon that was just saved is a new combination. Update the
        # previous combination's status, associated it with the new
        # combination, and transfer all taxon history and synonyms

        # find all taxa that list previous_combination.id as
        # current_valid_taxon_id and update them
        Taxon.where(current_valid_taxon_id: previous_combination.id).each do |taxon_to_update|
          update_elements(taxon, params, taxon_to_update, get_status_string(taxon_to_update), change_id)
        end

        # since the previous doesn't have a pointer to current_valid_taxon, it won't show up
        # in the above search. If it's the protonym, set it propertly.
        if (previous_combination.id == @taxon.protonym.id)
          update_elements(taxon, params, previous_combination, Status['original combination'].to_s, change_id)
        else
          update_elements(taxon, params, previous_combination, Status['obsolete combination'].to_s,  change_id)
        end
      end
      save_taxon_children @taxon, change_id
    end
  end

  def update_elements taxon, params, taxon_to_update, status_string, change_id
    taxon_to_update.status = status_string
    taxon_to_update.current_valid_taxon = @taxon
    TaxonHistoryItem.where({taxon_id: taxon_to_update.id}).
        update_all({taxon_id: @taxon.id})
    Synonym.where({senior_synonym_id: taxon_to_update.id}).
        update_all({senior_synonym_id: @taxon.id})
    Synonym.where({junior_synonym_id: taxon_to_update.id}).
        update_all({junior_synonym_id: @taxon.id})
    taxon_to_update.save_with_transaction! change_id
  end

  def get_status_string(taxon_to_update)
    update_status=nil
    if Status[taxon_to_update] == Status['original combination']
      update_status=Status['original combination'].to_s
    else
      update_status=Status['obsolete combination'].to_s
    end
    update_status
  end

  def save_change change_type
    change = Change.new
    change.change_type = change_type
    change.user_changed_taxon_id = @taxon.id
    change.save!
    change
  end



  ####################################
  def update_name attributes
    attributes[:name_id] = attributes.delete :id
    gender = attributes.delete :gender
    @taxon.name.gender = gender.blank? ? nil : gender
    @taxon.attributes = attributes
  end

  def update_name_status_flags attributes
    attributes[:incertae_sedis_in] = nil unless attributes[:incertae_sedis_in].present?
    @taxon.attributes = attributes
    @taxon.headline_notes_taxt = Taxt.from_editable attributes.delete :headline_notes_taxt
    if attributes[:type_taxt]
      @taxon.type_taxt = Taxt.from_editable attributes.delete :type_taxt
    end
  end

  def update_parent attributes
    return unless attributes
    @taxon.update_parent Taxon.find_by_name_id attributes[:id]
  rescue Taxon::TaxonExists
    @taxon.errors[:base] = "This name is in use by another taxon"
    raise
  end

  def update_homonym_replaced_by attributes
    replacement_id = attributes[:id]
    replacement = replacement_id.present? ? Taxon.find_by_name_id(replacement_id) : nil
    @taxon.homonym_replaced_by = replacement
  end

  def update_current_valid_taxon attributes
    replacement_id = attributes[:id]
    replacement = replacement_id.present? ? Taxon.find_by_name_id(replacement_id) : nil
    @taxon.current_valid_taxon = replacement
  end

  def update_protonym attributes
    attributes[:name_id] = attributes.delete(:name_attributes)[:id]
    update_protonym_authorship attributes.delete :authorship_attributes
    @taxon.protonym.attributes = attributes
  end

  def update_protonym_authorship attributes
    return unless @taxon.protonym.authorship
    attributes[:reference_id] = attributes.delete(:reference_attributes)[:id]
    return if attributes[:reference_id].blank? and @taxon.protonym.authorship.reference.blank?
    if attributes[:notes_taxt]
      @taxon.protonym.authorship.notes_taxt = Taxt.from_editable attributes.delete :notes_taxt
    end
    @taxon.protonym.authorship.attributes = attributes
  end

  def update_type_name attributes
    # ugly way to handle optional, but possibly pre-built, subobject
    if @taxon.type_name && @taxon.type_name.new_record? && (!attributes or attributes[:id] == '')
      @taxon.type_name = nil
      return
    end
    # Joe todo- why do we hit this case?
    if !attributes.nil?
      attributes[:type_name_id] = attributes.delete :id
      @taxon.attributes = attributes
    end
  end

  def build_children
    @taxon.build_name unless @taxon.name
    @taxon.build_protonym unless @taxon.protonym
    @taxon.protonym.build_name unless @taxon.protonym.name
    @taxon.protonym.build_authorship unless @taxon.protonym.authorship
    @taxon.build_type_name unless @taxon.type_name
  end

  private

  def save_taxon_children taxon, change_id
    return if taxon.kind_of?(Family) || taxon.kind_of?(Subspecies)
    taxon.children.each do |c|
      c.save_with_transaction! change_id
      save_taxon_children c, change_id
    end
  end
end
