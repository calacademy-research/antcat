# coding: UTF-8
class TaxaController < ApplicationController
  before_filter :authenticate_catalog_editor
  skip_before_filter :authenticate_catalog_editor, if: :preview?

  def new
    @new_taxon_rank = params[:new_taxon_rank]
    @taxon = new_taxon
    @parent_id = params[:parent_id]
    create_object_web
    set_parent

    if @taxon.kind_of? SpeciesGroupTaxon
      parent = Taxon.find @parent_id
      @default_name_string = parent.name.name
    end

    render :edit
  end

  def create
    @new_taxon_rank = params[:new_taxon_rank]
    @taxon = new_taxon
    @parent_id = params[:parent_id]
    set_parent
    save
  end

  def edit
    @taxon = Taxon.find params[:id]
    @parent_id = @taxon.id
    set_rank_that_would_be_created_if_button_clicked
    @show_delete_taxon_button = @taxon.nontaxt_references.empty?
    create_object_web
    setup_edit_buttons
  end

  def update
    return elevate_to_species if params[:task_button_command] == 'elevate_to_species'
    return delete_taxon if params[:task_button_command] == 'delete_taxon'
    @taxon = Taxon.find params[:id]
    @parent_id = params[:parent_id]
    save
  end

  def set_rank_that_would_be_created_if_button_clicked
    @new_taxon_rank = child_rank @taxon.class
  end

  def elevate_to_species
    begin
      @taxon = Subspecies.find params[:id]
      old_species = @taxon.species
      @taxon.elevate_to_species
    rescue Subspecies::NoSpeciesForSubspeciesError
      @taxon.errors[:base] = "This subspecies doesn't have a species. Use the \"Assign species to subspecies\" button to fix, then you can elevate the subspecies to the species."
      render :edit and return
    end
    redirect_to catalog_url @taxon
  end

  def delete_taxon
    @taxon = Taxon.find params[:id]
    if @taxon.references.empty?
      @taxon.destroy
      redirect_to catalog_url get_parent
    else
      @taxon.errors[:base] = "This taxon has additional information attached to it. Please see Mark."
      render :edit and return
    end
  end

  ###################
  def new_taxon
    params[:new_taxon_rank].titlecase.constantize.new
  end

  def set_parent
    @taxon.parent = @parent_id
  end

  def get_parent
    @taxon.parent
  end

  def child_rank rank
    rank = rank.to_s
    case rank
    when 'Subfamily' then 'genus'
    when 'Genus'     then 'species'
    when 'Species'   then 'subspecies'
    end
  end

  ###################
  def setup_edit_buttons
    @show_elevate_to_species_button = @taxon.kind_of? Subspecies
    @show_convert_to_subspecies_button = @taxon.kind_of? Species

    string = child_rank @taxon.class
    @add_taxon_button_text = "Add #{string}" if string
  end

  def save
    begin
      create_object_web
      update_taxon params[:taxon]
    rescue ActiveRecord::RecordInvalid
      render :edit and return
    end
    redirect_to catalog_url @taxon
  end

  def create_object_web
    @taxon.build_name unless @taxon.name
    @taxon.build_protonym unless @taxon.protonym
    @taxon.protonym.build_name unless @taxon.protonym.name
    @taxon.protonym.build_authorship unless @taxon.protonym.authorship
    @taxon.build_type_name unless @taxon.type_name
  end

  def update_taxon attributes
    Taxon.transaction do
      name_attributes                     = attributes.delete :name_attributes
      protonym_attributes                 = attributes.delete :protonym_attributes
      homonym_replaced_by_name_attributes = attributes.delete :homonym_replaced_by_name_attributes
      type_name_attributes                = attributes.delete :type_name_attributes

      update_name                 name_attributes
      update_name_status_flags    attributes
      update_homonym_replaced_by  homonym_replaced_by_name_attributes
      update_protonym             protonym_attributes
      update_type_name            type_name_attributes

      @taxon.save!
    end
  end

  def update_name_status_flags attributes
    attributes[:incertae_sedis_in] = nil unless attributes[:incertae_sedis_in].present?
    @taxon.attributes = attributes
    @taxon.headline_notes_taxt = Taxt.from_editable attributes.delete :headline_notes_taxt
    if attributes[:type_taxt]
      @taxon.type_taxt = Taxt.from_editable attributes.delete :type_taxt
    end
  end

  def update_name attributes
    attributes[:name_id] = attributes.delete :id
    @taxon.attributes = attributes
  end

  def update_homonym_replaced_by attributes
    replacement_id = attributes[:id]
    replacement = replacement_id.present? ? Taxon.find_by_name_id(replacement_id) : nil
    @taxon.homonym_replaced_by = replacement
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
    @taxon.protonym.authorship.attributes = attributes
  end

  def update_type_name attributes
    # ugly way to handle optional, but possibly pre-built, subobject
    if @taxon.type_name && @taxon.type_name.new_record? && !attributes
      @taxon.type_name = nil
      return
    end
    return unless attributes
    attributes[:type_name_id] = attributes.delete :id
    @taxon.attributes = attributes
  end

end
