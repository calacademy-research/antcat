# coding: UTF-8
class TaxaController < ApplicationController
  before_filter :authenticate_catalog_editor, :get_params, :create_mother
  skip_before_filter :authenticate_catalog_editor, if: :preview?

  def new
    get_taxon :create
    set_paths :create
    get_default_name_string
    set_authorship_reference
    render :edit
  end

  def create
    get_taxon :create
    set_paths :create
    save_taxon
  end

  def edit
    get_taxon :update
    set_paths :update
    setup_edit_buttons
  end

  def update
    get_taxon :update
    return elevate_to_species if @elevate_to_species
    return delete_taxon if @delete_taxon
    set_paths :update
    save_taxon
  end

  ###################
  def get_taxon create_or_update
    if create_or_update == :create
      @taxon = @mother.create_taxon @rank, Taxon.find(@parent_id)
    else
      @taxon = @mother.load_taxon
      @rank = Rank[@taxon].child
    end
  end

  def save_taxon
    @mother.save_taxon @taxon, @taxon_params
    redirect_to catalog_path @taxon
  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :edit and return
  end

  def set_paths create_or_update
    if create_or_update == :create
      @cancel_path = edit_taxa_path @parent_id
    else
      @add_taxon_path = new_taxa_path rank: @rank, parent_id: @taxon.id
      @cancel_path = catalog_path @taxon
      @convert_to_subspecies_path = new_taxa_convert_to_subspecies_path @taxon.id
      @parent_rank_selector =
        case @taxon
        when Species then :genera_only
        when Genus then :species_only
        end
    end
  end

  def set_authorship_reference
    @taxon.protonym.authorship.reference = DefaultReference.get session
  end

  def get_default_name_string
    if @taxon.kind_of? SpeciesGroupTaxon
      parent = Taxon.find @parent_id
      @default_name_string = parent.name.name
    end
  end

  def setup_edit_buttons
    @show_elevate_to_species_button = @taxon.kind_of? Subspecies
    @show_convert_to_subspecies_button = @taxon.kind_of? Species
    @show_delete_taxon_button = @taxon.nontaxt_references.empty?
    string = Rank[@taxon].child.try :string
    @add_taxon_button_text = "Add #{string}" if string
  end

  #####################
  def elevate_to_species
    @taxon.elevate_to_species
    redirect_to catalog_path @taxon
  rescue Subspecies::NoSpeciesForSubspeciesError
    @taxon.errors[:base] = "This subspecies doesn't have a species. Use the \"Assign species to subspecies\" button to fix, then you can elevate the subspecies to the species."
    render :edit and return
  end

  def delete_taxon
    if @taxon.references.empty?
      @taxon.destroy
    else
      @taxon.errors[:base] = "This taxon has additional information attached to it. Please see Mark."
      render :edit and return
    end
    redirect_to catalog_path @taxon.parent
  end

  #####################
  def get_params
    @id = params[:id]
    @rank = Rank[params[:rank]]
    @parent_id = params[:parent_id]
    @taxon_params = params[:taxon]
    @elevate_to_species = params[:task_button_command] == 'elevate_to_species'
    @delete_taxon = params[:task_button_command] == 'delete_taxon'
  end

  def create_mother
    @mother = TaxonMother.new @id
  end

end
