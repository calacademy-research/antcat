# coding: UTF-8
class TaxaController < ApplicationController
  before_filter :authenticate_editor, :get_params, :create_mother
  before_filter :redirect_by_parent_name_id, only: :new
  skip_before_filter :authenticate_editor, if: :preview?
  skip_before_filter :authenticate_editor, only: [:show, :autocomplete]

  NUMBER_OF_AUTOCOMPLETE_SUGGESTIONS = 10

  helper ReferenceHelper

  # TODO make more RESTful
  def new
    get_taxon :create
    set_view_variables :create
    get_default_name_string
    set_authorship_reference
    render :edit
  end

  def create
    get_taxon :create
    set_view_variables :create
    save_taxon
  end

  def edit
    get_taxon :update
    set_view_variables :update
    setup_edit_buttons
  end

  def update
    get_taxon :update
    set_view_variables :update
    return elevate_to_species if @elevate_to_species
    return delete_taxon if @delete_taxon
    save_taxon
  end

  # rest endpoint - get taxa/[id]
  def show
    cur_id = params[:id]
    begin
      taxa = Taxon.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render :nothing => true, status: :not_found
      return
    end

    render json: taxa, status: :ok
  end

  def delete
    @user = current_user
    delete_mother = TaxonMother.new params[:taxa_id]

    taxon = delete_mother.load_taxon

    delete_mother.delete_taxon taxon
    redirect_to root_url
  end

  # The parent is updated via taxon id.
  # params: taxon_id (int)
  # new_parent_taxon_id (int)
  def update_parent
    taxon = Taxon.find(params[:taxon_id])
    new_parent = Taxon.find(params[:new_parent_taxon_id])
    case new_parent.rank
    when "species"
      taxon.species_id = new_parent.id
    when "genus"
      taxon.genus_id = new_parent.id
    when "subgenus"
      taxon.subgenus_id = new_parent.id
    when "subfamily"
      taxon.subfamily_id = new_parent.id
    when "family"
      taxon.family_id = new_parent.id
    end
    taxon.save!
    redirect_to edit_taxa_path taxon
  end

  ###################
  def get_taxon create_or_update
    if create_or_update == :create
      parent = Taxon.find(@parent_id)
      # Radio button case - we got duplicates, and the user picked one
      # to resolve the problem.
      @taxon = @mother.create_taxon @rank_to_create, parent

      if !@collision_resolution.nil?
        if @collision_resolution == 'homonym' or @collision_resolution == ""
          @taxon[:unresolved_homonym] = true
          @taxon[:status] = Status['homonym'].to_s
        else
          @taxon[:collision_merge_id] = @collision_resolution
          @original_combination = Taxon.find(@collision_resolution)
          Taxon.inherit_attributes_for_new_combination(@original_combination, @previous_combination, parent)
        end

      end
      # if !@collision_resolution.nil?
      #   @taxon = @mother.create_taxon @rank_to_create, parent
      # else
      #   #  it might be that we just switch parent with collision_resolution_id, and then
      #   # go ahead and call "create taxon".
      #   # then, in the secondary homonuym case, we post facto(here) mark it as a secondary.
      #   @taxon = @mother.create_taxon_collision @rank_to_create, parent, @collision_resolution
      # end
      if @previous_combination
        Taxon.inherit_attributes_for_new_combination(@taxon, @previous_combination, parent)
      end
    else
      @taxon = @mother.load_taxon
      @rank_to_create = Rank[@taxon].child
    end
  end

  def save_taxon
    # collision_resolution will be the taxon ID number of the preferred taxon or "homonym"

    if @collision_resolution.nil? or @collision_resolution == "" or @collision_resolution == 'homonym'
      @mother.save_taxon @taxon, @taxon_params, @previous_combination
    else
      @original_combination = Taxon.find(@collision_resolution)
      @mother.save_taxon @original_combination, @taxon_params, @previous_combination
    end

    if @previous_combination && @previous_combination.is_a?(Species) && @previous_combination.children.any?
      create_new_usages_for_subspecies
    end
    redirect_to catalog_path @taxon
  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :edit and return
  end

  def create_new_usages_for_subspecies
    @previous_combination.children.select { |t| t.status == 'valid' }.each do |t|
      mother = TaxonMother.new
      new_child = mother.create_taxon(Rank['subspecies'], @taxon)
      Taxon.inherit_attributes_for_new_combination(new_child, t, @taxon)
      mother.save_taxon(new_child, Taxon.attributes_for_new_usage(new_child, t), t)
    end
  end

  def set_view_variables create_or_update
    @user = current_user
    if create_or_update == :create
      @cancel_path = edit_taxa_path @parent_id
    else
      if @collision_resolution.nil?

        @add_taxon_path = new_taxa_path rank_to_create: @rank_to_create, parent_id: @taxon.id
      else
        @add_taxon_path = new_taxa_path rank_to_create: @rank_to_create, parent_id: @taxon.id, collision_resolution: @collision_resolution
      end

      @add_tribe_path = new_taxa_path rank_to_create: Tribe, parent_id: @taxon.id
      @cancel_path = catalog_path @taxon
      @convert_to_subspecies_path = new_taxa_convert_to_subspecies_path @taxon.id
      if (@taxon.is_a? (Family))
        @reset_epithet = @taxon.name.to_s
      elsif (@taxon.is_a? (Species))
        @reset_epithet = @taxon.name.genus_epithet
      else
        @reset_epithet = ""
      end
    end
  end

  def set_authorship_reference
    @taxon.protonym.authorship.reference ||= DefaultReference.get session
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
    @add_tribe_button_text = "Add tribe" if @taxon.kind_of? Subfamily
  end

  #####################
  def elevate_to_species
    @taxon.elevate_to_species
    redirect_to catalog_path @taxon
  rescue Subspecies::NoSpeciesForSubspeciesError
    @taxon.errors[:base] = <<-MSG.squish
      This subspecies doesn't have a species. Use the "Assign species to subspecies"
      button to fix, then you can elevate the subspecies to the species.
    MSG
    render :edit and return
  end

  def delete_taxon
    references = @taxon.references
    if references.empty?
      @taxon.destroy
    else
      @taxon.errors[:base] = <<-MSG.squish
          Other taxa refer to this taxon, so it can't be deleted.
          Please talk to Stan (sblum@calacademy.org) to determine a solution.
          The items referring to this taxon are: #{references.to_s}.
      MSG
      render :edit and return
    end
    redirect_to catalog_path @taxon.parent
  end

  #####################
  def get_params
    @id = params[:id]
    @rank_to_create = Rank[params[:rank_to_create]]
    @parent_id = params[:parent_id]
    @previous_combination = params[:previous_combination_id].blank? ? nil : Taxon.find(params[:previous_combination_id])
    @taxon_params = params[:taxon]
    @elevate_to_species = params[:task_button_command] == 'elevate_to_species'
    @delete_taxon = params[:task_button_command] == 'delete_taxon'
    @collision_resolution = params[:collision_resolution]
  end

  def create_mother
    @mother = TaxonMother.new @id
  end

  def redirect_by_parent_name_id
    parent_name_id = params.delete(:parent_name_id)
    if parent_name_id && parent = Taxon.find_by_name_id(parent_name_id)
      # params[:parent_id] = parent.id
      # action = params[:action]
      # controller = params[:controller]
      # parent_id = params[:parent_id]
      # rank_to_create = params[:rank_to_create]
      # previous_combination_id = params[:previous_combination_id]
      # redirect_to action: action, controller: controller, parent_id: parent_id, rank_to_create: rank_to_create, previous_combination_id: previous_combination_id
      new_hash = {}
      # recirect_to doesn't want to work off of "params", security hole. enjoy.
      params.each do |p|
        new_hash[p[0]] = p[1]
      end
      unless parent.nil?
        new_hash[:parent_id] = parent.id
      end
      redirect_to new_hash
    end
  end

  def autocomplete
    q = params[:q] || ''
    search_results = Taxon.where("name_cache LIKE ?", "%#{q}%").take NUMBER_OF_AUTOCOMPLETE_SUGGESTIONS

    respond_to do |format|
      format.json do
        results = search_results.map do |taxon|
          {
            name: taxon.name_html_cache,
            authorship: taxon.authorship_string,
            search_query: taxon.name_cache
          }
        end
        render json: results
      end
    end
  end

end