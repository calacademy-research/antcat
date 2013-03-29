# coding: UTF-8
class TaxaController < ApplicationController
  before_filter :authenticate
  skip_before_filter :authenticate, if: :preview?

  def authenticate
    authenticate_user! && $Environment.user_can_edit_catalog?(current_user)
  end

  def new
  end

  def create
  end

  def edit
    @taxon = Taxon.find params[:id]
    @show_reverse_synonymy_button = @taxon.junior_synonyms.present? || @taxon.senior_synonyms.present?
    @show_elevate_to_species_button = @taxon.kind_of? Subspecies
  end

  def update
    return reverse_synonymy if params[:task_button_command] == 'reverse_synonymy'
    return elevate_to_species if params[:task_button_command] == 'elevate_to_species'

    @taxon = Taxon.find params[:id] 
    begin
      update_taxon params.dup[:taxon]
    rescue ActiveRecord::RecordInvalid
      render :edit and return
    end
    redirect_to catalog_url @taxon
  end

  def reverse_synonymy
    taxon = Taxon.find params[:id]
    if taxon.synonym?
      new_junior = taxon.senior_synonyms.first
      new_senior = taxon
    else
      new_senior = taxon.junior_synonyms.first
      new_junior = taxon
    end
    new_junior.become_junior_synonym_of new_senior
    ReverseSynonymyEdit.create! new_junior: new_junior, new_senior: new_senior, user: current_user
    redirect_to catalog_url taxon
  end

  def elevate_to_species
    subspecies = Subspecies.find params[:id]
    old_species = subspecies.species
    subspecies.elevate_to_species
    ElevateSubspeciesEdit.create! taxon: subspecies, old_species: old_species, user: current_user
    redirect_to catalog_url subspecies
  end

  ###################
  def update_taxon attributes
    Taxon.transaction do
      protonym_attributes = attributes.delete :protonym_attributes
      type_name_attributes = attributes.delete :type_name_attributes

      update_epithet_status_flags attributes
      update_protonym protonym_attributes
      update_type_name type_name_attributes if type_name_attributes
    end
  end

  def update_epithet_status_flags attributes
    add_name_or_create_homonym attributes.delete :name_attributes
    attributes[:incertae_sedis_in] = nil unless attributes[:incertae_sedis_in].present?
    @taxon.attributes = attributes
    # apparently can't just assign this value to the attribute in attributes
    @taxon.headline_notes_taxt = Taxt.from_editable attributes.delete :headline_notes_taxt
    if attributes[:type_taxt]
      @taxon.type_taxt = Taxt.from_editable attributes.delete :type_taxt
    end
    @taxon.save!
  end

  class PossibleHomonymSituation < NameError; end

  def add_name_or_create_homonym attributes
    #begin
      #original_name = @taxon.name
      #name = Name.import get_name_attributes attributes
      #if name != original_name
        #@possible_homonym = @taxon.would_be_homonym_if_name_changed_to? name unless params[:possible_homonym].present?
        #if @possible_homonym
          #@taxon.errors.add :base, "This name is in use by another taxon. To create a homonym, click \"Save Homonym\".".html_safe
          #@taxon.name.epithet = attributes[:epithet]
          #raise PossibleHomonymSituation
        #end
      #end
    #rescue ActiveRecord::RecordInvalid
      #@taxon.name.epithet = attributes[:epithet]
      #@taxon.errors.add :base, "Name can't be blank"
      #raise
    #rescue PossibleHomonymSituation
      #raise ActiveRecord::RecordInvalid.new @taxon
    #end
    #@taxon.update_attributes name: name
  end

  def get_name_attributes attributes
    {genus_name: attributes[:epithet]}
  end

  def update_protonym attributes
    attributes[:name_id] = attributes.delete(:name_attributes)[:id]
    update_protonym_authorship attributes.delete :authorship_attributes
    @taxon.protonym.update_attributes attributes
  end

  def update_protonym_authorship attributes
    return unless @taxon.protonym.authorship
    attributes[:reference_id] = attributes.delete(:reference_attributes)[:id]
    return if attributes[:reference_id].blank? and @taxon.protonym.authorship.reference.blank?
    @taxon.protonym.authorship.update_attributes attributes
  end

  def update_type_name attributes
    attributes[:type_name_id] = attributes.delete :id
    @taxon.update_attributes attributes
  end

end
