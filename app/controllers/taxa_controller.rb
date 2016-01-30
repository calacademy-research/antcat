class TaxaController < ApplicationController
  before_filter :authenticate_editor, :get_params, :create_mother
  before_filter :authenticate_superadmin, only: [:destroy]
  before_filter :redirect_by_parent_name_id, only: :new
  before_filter :set_taxon, only: [:elevate_to_species, :destroy_unreferenced]
  skip_before_filter :authenticate_editor, only: [:show, :autocomplete]

  def new
    get_taxon_for_create
    get_default_name_string
    set_authorship_reference
  end

  def create
    get_taxon_for_create
    save_taxon

    # Nil check to avoid showing 404 to the user and breaking the tests.
    # `change_parent.feature` fails without this, but it seems to work if the
    # steps are manually reproduced in the browser.
    #
    # The reason @taxon may be nil is has to do with saves made in TaxonMother
    # without updating the local instance variable.
    #
    # This imitates the previous behavior we had when CatalogController#show was
    # responsible for both the index and show actions, and nil ids were silently
    # redirected to Formicidae (nil are not allowed by routes.rb any longer).
    unless @taxon.id
      redirect_to root_path, notice: 'Taxon was successfully created.'
      return
    end

    redirect_to catalog_path(@taxon), notice: 'Taxon was successfully created.'

  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :new
  end

  def edit
    get_taxon_for_update
    set_update_view_variables
  end

  def update
    get_taxon_for_update
    set_update_view_variables
    save_taxon

    # See #create for the raison d'etre of this nil check.
    # Note: Tests pass without this snippets.
    unless @taxon.id
      redirect_to root_path, notice: 'Taxon was successfully updated.'
      return
    end

    redirect_to catalog_path(@taxon), notice: 'Taxon was successfully updated.'

  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :edit
  end

  # rest endpoint - get taxa/[id]
  def show
    begin
      taxa = Taxon.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render nothing: true, status: :not_found
      return
    end

    render json: taxa, status: :ok
  end

  def destroy
    delete_mother = TaxonMother.new params[:id]
    taxon = delete_mother.load_taxon
    delete_mother.delete_taxon taxon

    flash[:notice] = "Taxon was successfully deleted."

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  # "Light version" of #destroy (which is for superadmins only). This method
  # allows editors to delete a taxon if there are no [non-taxt] references to it.
  def destroy_unreferenced
    references = @taxon.references
    if references.empty?
      @taxon.destroy
    else
      redirect_to edit_taxa_path(@taxon), notice: <<-MSG.squish
        Other taxa refer to this taxon, so it can't be deleted.
        Please talk to Stan (sblum@calacademy.org) to determine a solution.
        The items referring to this taxon are: #{references}.
      MSG
      return
    end
    redirect_to catalog_path(@taxon.parent), notice: "Taxon was successfully deleted."
  end

  # The parent is updated via taxon_id.
  # params: taxon_id (int)
  # new_parent_taxon_id (int)
  def update_parent
    taxon = Taxon.find(params[:taxon_id])
    new_parent = Taxon.find(params[:new_parent_taxon_id])
    case new_parent
    when Species
      taxon.species = new_parent
    when Genus
      taxon.genus = new_parent
    when Subgenus
      taxon.subgenus = new_parent
    when Subfamily
      taxon.subfamily = new_parent
    when Family
      taxon.family = new_parent
    end
    taxon.save!
    redirect_to edit_taxa_path taxon
  end

  def elevate_to_species
    unless @taxon.kind_of? Subspecies
      redirect_to edit_taxa_path(@taxon), notice: "Not a subspecies"
      return
    end
    @taxon.elevate_to_species
    redirect_to catalog_path(@taxon), notice: "Subspecies was successfully elevated to a species."
  end

  # Return all the taxa that would be deleted if we delete this
  # particular ID, inclusive. Same as children, really.
  def delete_impact_list
    mother = TaxonMother.new(params[:id])
    mother.load_taxon
    taxon_array = mother.get_children

    render json: taxon_array, status: :ok
  end

  def autocomplete
    q = params[:q] || ''
    search_results = Taxon.where("name_cache LIKE ?", "%#{q}%").take(10)

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

  protected
    def get_params
      @parent_id = params[:parent_id]
      @previous_combination = params[:previous_combination_id].blank? ? nil : Taxon.find(params[:previous_combination_id])
      @taxon_params = params[:taxon]
      @collision_resolution = params[:collision_resolution]
    end

    def create_mother
      @mother = TaxonMother.new params[:id]
    end

  private
    def get_taxon_for_create
      parent = Taxon.find(@parent_id)
      rank_to_create = Rank[params[:rank_to_create]]
      @taxon = @mother.create_taxon rank_to_create, parent

      # Radio button case - we got duplicates, and the user picked one
      # to resolve the problem.
      if @collision_resolution
        if @collision_resolution == 'homonym' || @collision_resolution == ""
          @taxon[:unresolved_homonym] = true
          @taxon[:status] = Status['homonym'].to_s
        else
          @taxon[:collision_merge_id] = @collision_resolution
          @original_combination = Taxon.find(@collision_resolution)
          Taxon.inherit_attributes_for_new_combination(@original_combination, @previous_combination, parent)
        end
      end

      if @previous_combination
        Taxon.inherit_attributes_for_new_combination(@taxon, @previous_combination, parent)
      end
    end

    def get_taxon_for_update
      @taxon = @mother.load_taxon
    end

    def save_taxon
      # collision_resolution will be the taxon ID number of the preferred taxon or "homonym"
      if @collision_resolution.blank? || @collision_resolution == 'homonym'
        @mother.save_taxon @taxon, @taxon_params, @previous_combination
      else
        @original_combination = Taxon.find(@collision_resolution)
        @mother.save_taxon @original_combination, @taxon_params, @previous_combination
      end

      if @previous_combination.is_a?(Species) && @previous_combination.children.any?
        create_new_usages_for_subspecies
      end
    end

    def create_new_usages_for_subspecies
      @previous_combination.children.select { |t| t.status == 'valid' }.each do |t|
        mother = TaxonMother.new
        new_child = mother.create_taxon(Rank['subspecies'], @taxon)
        Taxon.inherit_attributes_for_new_combination(new_child, t, @taxon)
        mother.save_taxon(new_child, Taxon.attributes_for_new_usage(new_child, t), t)
      end
    end

    def set_update_view_variables
      @reset_epithet  = case @taxon
                        when Family then @taxon.name.to_s
                        when Species then @taxon.name.genus_epithet
                        else ""
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

    def redirect_by_parent_name_id
      parent_name_id = params.delete(:parent_name_id)
      if parent_name_id && parent = Taxon.find_by_name_id(parent_name_id)
        new_hash = {}
        # redirect_to doesn't want to work off of "params", security hole. enjoy.
        params.each { |p| new_hash[p[0]] = p[1] }

        unless parent.nil?
          new_hash[:parent_id] = parent.id
        end
        redirect_to new_hash
      end
    end

    def set_taxon
      @taxon = Taxon.find(params[:id])
    end
end
