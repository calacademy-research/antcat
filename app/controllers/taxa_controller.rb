# coding: UTF-8
class TaxaController < ApplicationController
  before_filter :authenticate_catalog_editor
  skip_before_filter :authenticate_catalog_editor, if: :preview?

  def new
    @new_taxon_rank = params[:new_taxon_rank]
    @taxon = new_taxon
    create_object_web
    @parent_id = params[:parent_id]
    assign_parent_id
    render :edit
  end

  def create
    @new_taxon_rank = params[:new_taxon_rank]
    @taxon = new_taxon
    @parent_id = params[:parent_id]
    assign_parent_id
    save true
  end

  def edit
    @taxon = Taxon.find params[:id]
    create_object_web
    @parent_id = @taxon.id
    @show_elevate_to_species_button = @taxon.kind_of? Subspecies
    @add_taxon_button_text = 'Add Genus' if @taxon.kind_of? Subfamily
    set_new_taxon_rank
  def set_new_taxon_rank
    @new_taxon_rank =
    case @taxon
    when Subfamily then 'genus'
    when Genus then 'species'
    end
  end

  def update
    return elevate_to_species if params[:task_button_command] == 'elevate_to_species'
    @taxon = Taxon.find params[:id]
    @parent_id = params[:parent_id]
    save false
  end

  def elevate_to_species
    subspecies = Subspecies.find params[:id]
    old_species = subspecies.species
    subspecies.elevate_to_species
    redirect_to catalog_url subspecies
  end

  ###################
  def new_taxon
    case params[:new_taxon_rank]
    when 'genus' then Genus
    when 'species' then Species
    end.new
  end

  def assign_parent_id
    parent_fields = {
      Genus => :subfamily_id=,
      Species => :genus_id=
    }
    @taxon.send parent_fields[@taxon.class], @parent_id
  end

  def setup_edit_buttons
    @show_elevate_to_species_button = @taxon.kind_of? Subspecies
    @add_taxon_button_text = 'Add Genus' if @taxon.kind_of? Subfamily
    @add_taxon_button_text = 'Add Species' if @taxon.kind_of? Genus
  end

  ###################
  def save do_create_object_web
    begin
      create_object_web if do_create_object_web
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
    @taxon
  end

  def update_taxon attributes
    Taxon.transaction do
      name_attributes                     = attributes.delete :name_attributes
      protonym_attributes                 = attributes.delete :protonym_attributes
      homonym_replaced_by_name_attributes = attributes.delete :homonym_replaced_by_name_attributes
      type_name_attributes                = attributes.delete :type_name_attributes

      update_name                 name_attributes
      update_epithet_status_flags attributes
      update_homonym_replaced_by  homonym_replaced_by_name_attributes
      update_protonym             protonym_attributes
      update_type_name            type_name_attributes if type_name_attributes

      @taxon.save!
    end
  end

  def update_epithet_status_flags attributes
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
    @taxon.protonym.authorship.attributes = attributes
  end

  def update_type_name attributes
    attributes[:type_name_id] = attributes.delete :id
    @taxon.attributes = attributes
  end

end
