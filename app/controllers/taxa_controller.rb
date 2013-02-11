# coding: UTF-8
class TaxaController < ApplicationController
  def new
  end

  def create
  end

  def edit
    @taxon = Taxon.find params[:id]
  end

  def update
    @taxon = Taxon.find params[:id] 
    begin
      key = get_name_key params
      update_taxon params.dup[key]
    rescue
      render :edit and return
    end
    redirect_to catalog_url @taxon
  end

  def get_name_key params
    params.keys.map(&:to_sym).find do |e|
      [:family, :subfamily, :tribe, :genus, :subgenus, :species, :subspecies].
        include? e
    end
  end

  ###################
  def update_taxon attributes
    Taxon.transaction do
      protonym_attributes = attributes.delete :protonym_attributes
      type_name_attributes = attributes.delete :type_name_attributes

      update_epithet_status_flags attributes
      update_protonym protonym_attributes
      update_type_name type_name_attributes
    end
  end

  def update_epithet_status_flags attributes
    update_name attributes.delete :name_attributes
    @taxon.attributes = attributes
    # apparently can't just assign this value to the attribute in attributes
    @taxon.headline_notes_taxt = Taxt.from_editable attributes.delete :headline_notes_taxt
    @taxon.save!
  end

  def update_name attributes
    begin
      name = Name.import get_name_attributes attributes
      @possible_homonym = @taxon.would_be_homonym_if_name_changed_to? name unless params[:possible_homonym].present?
      if @possible_homonym
        @taxon.errors.add :base, "This name is in use by another taxon. To create a homonym, click \"Save Homonym\"".html_safe
        @taxon.name.epithet = attributes[:epithet]
        raise
      end
    rescue ActiveRecord::RecordInvalid
      @taxon.name.epithet = attributes[:epithet]
      @taxon.errors.add :base, "Name can't be blank"
      raise
    end
    @taxon.update_attributes name: name
  end

  def get_name_attributes attributes
    {genus_name: attributes[:epithet]}
  end

  def update_protonym attributes
    update_protonym_name attributes.delete :name_attributes
    update_protonym_authorship attributes.delete :authorship_attributes
    @taxon.protonym.update_attributes attributes
  end

  def update_protonym_name attributes
  end

  def update_protonym_authorship attributes
    attributes.delete :reference
    @taxon.protonym.authorship.update_attributes attributes
  end

  def update_type_name attributes
  end

end
