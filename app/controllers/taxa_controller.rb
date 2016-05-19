class TaxaController < ApplicationController
  before_filter :authenticate_editor, except: [:autocomplete]
  before_filter :authenticate_superadmin, only: [:destroy]

  before_filter :redirect_by_parent_name_id, only: :new

  before_filter :set_previous_combination, only: [:new, :create, :edit, :update]
  before_filter :set_taxon, except: [:new, :create, :show, :autocomplete]

  def new
    @taxon = get_taxon_for_create
    @default_name_string = default_name_string
    set_authorship_reference
  end

  def create
    @taxon = get_taxon_for_create
    save_taxon

    flash[:notice] = "Taxon was successfully added."

    show_add_another_species_link = @taxon.id && @taxon.is_a?(Species) && @taxon.genus
    if show_add_another_species_link
      link = view_context.link_to "Add another #{@taxon.genus.name_html_cache} species?".html_safe,
        new_taxa_path(rank_to_create: "species", parent_id: @taxon.genus.id)
      flash[:notice] += " <strong>#{link}</strong>".html_safe
    end

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
    if @taxon.id
      redirect_to catalog_path(@taxon)
    else
      redirect_to root_path
    end

  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :new
  end

  def edit
    @reset_epithet = reset_epithet
  end

  def update
    @reset_epithet = reset_epithet
    save_taxon

    # See #create for the raison d'etre of this nil check.
    # Note: Tests pass without this snippets.
    flash[:notice] = "Taxon was successfully updated."
    if @taxon.id
      @taxon.create_activity :update
      redirect_to catalog_path(@taxon)
    else
      Feed::Activity.create_activity :custom,
        parameters: { text: "updated an unknown taxon" }
      redirect_to root_path
    end

  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :edit
  end

  def destroy
    @taxon.delete_taxon_and_children

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

  # TODO move logic to model?
  def update_parent
    new_parent = Taxon.find(params[:new_parent_id])
    case new_parent
    when Species
      @taxon.species = new_parent
    when Genus
      @taxon.genus = new_parent
    when Subgenus
      @taxon.subgenus = new_parent
    when Subfamily
      @taxon.subfamily = new_parent
    when Family
      @taxon.family = new_parent
    end
    @taxon.save!
    redirect_to edit_taxa_path(@taxon)
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
    taxon_array = @taxon.delete_impact_list
    render json: taxon_array, status: :ok
  end

  def autocomplete
    q = params[:q] || ''
    search_results = Taxon.where("name_cache LIKE ?", "%#{q}%").take(10)

    respond_to do |format|
      format.json do
        results = search_results.map do |taxon|
          { name: taxon.name_html_cache,
            name_html_cache: taxon.name_html_cache,
            id: taxon.id,
            authorship: taxon.authorship_string,
            search_query: taxon.name_cache }
        end
        render json: results
      end
    end
  end

  private
    def set_previous_combination
      return unless params[:previous_combination_id].present?
      @previous_combination = Taxon.find(params[:previous_combination_id])
    end

    def set_taxon
      @taxon = Taxon.find(params[:id])
    end

    def get_taxon_for_create
      parent = Taxon.find(params[:parent_id])

      taxon = build_new_taxon(params[:rank_to_create])
      taxon.parent = parent

      # Radio button case - we got duplicates, and the user picked one
      # to resolve the problem.
      collision_resolution = params[:collision_resolution]
      if collision_resolution
        if collision_resolution == 'homonym' || collision_resolution == ""
          taxon.unresolved_homonym = true
          taxon.status = Status['homonym'].to_s
        else
          taxon.collision_merge_id = collision_resolution
          original_combination = Taxon.find(collision_resolution)
          Taxa::Utility.inherit_attributes_for_new_combination(original_combination, @previous_combination, parent)
        end
      end

      if @previous_combination
        Taxa::Utility.inherit_attributes_for_new_combination(taxon, @previous_combination, parent)
      end

      taxon
    end

    def save_taxon
      # collision_resolution will be the taxon ID number of the preferred taxon or "homonym"
      collision_resolution = params[:collision_resolution]
      if collision_resolution.blank? || collision_resolution == 'homonym'
        @taxon.save_taxon(params[:taxon], @previous_combination)
      else
        original_combination = Taxon.find(collision_resolution)
        original_combination.save_taxon(params[:taxon], @previous_combination)
      end

      if @previous_combination.is_a?(Species) && @previous_combination.children.any?
        create_new_usages_for_subspecies
      end
    end

    # TODO looks like this isn't tested
    def create_new_usages_for_subspecies
      @previous_combination.children.select { |t| t.status == 'valid' }.each do |t|
        new_child = Subspecies.new

        # Only building type_name because all other will be copied from 't'.
        # TODO Not sure why type_name is not copied?
        new_child.build_type_name
        new_child.parent = @taxon

        Taxa::Utility.inherit_attributes_for_new_combination(new_child, t, @taxon)

        new_child.save_taxon(Taxa::Utility.attributes_for_new_usage(new_child, t), t)
      end
    end

    def reset_epithet
      case @taxon
      when Family then @taxon.name.to_s
      when Species then @taxon.name.genus_epithet
      else ""
      end
    end

    def set_authorship_reference
      @taxon.protonym.authorship.reference ||= DefaultReference.get session
    end

    def default_name_string
      return unless @taxon.kind_of? SpeciesGroupTaxon
      parent = Taxon.find(params[:parent_id])
      parent.name.name
    end

    def redirect_by_parent_name_id
      return unless params[:parent_name_id]

      if parent = Taxon.find_by_name_id(params[:parent_name_id])
        hash = {
          parent_id: parent.id,
          rank_to_create: params[:rank_to_create],
          previous_combination_id: params[:previous_combination_id],
          collision_resolution: params[:collision_resolution]
        }
        redirect_to new_taxa_path(hash)
      end
    end

    def build_new_taxon rank
      taxon = "#{rank}".titlecase.constantize.new
      taxon.build_name
      taxon.build_type_name
      taxon.build_protonym
      taxon.protonym.build_name
      taxon.protonym.build_authorship
      taxon
    end

end
