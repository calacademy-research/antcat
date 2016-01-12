class CatalogController < ApplicationController
  before_filter :handle_family_not_found, only: [:show]
  before_filter :get_parameters

  def show
    if @id.blank?
      @id = Family.first.id
    end
    setup_taxon_and_index
  end

  # Return all the taxa that would be deleted if we delete this
  # particular ID, inclusive. Same as children, really.
  def delete_impact_list
    taxon_id = @id
    mother = TaxonMother.new(taxon_id)
    mother.load_taxon
    taxon_array = mother.get_children

    render json: taxon_array, status: :ok
  end

  def search
    if params[:commit] == "Go"
      @id = nil
      params.delete :id
    end

    do_search

    id = params[:id]
    @id = id if id
    @search_query = params[:qq] || ''
    @st = params[:st] || ''

    if @search_results.present? && @search_results.count == 1
      # sets taxon if a single match is found
      # explicitly picked ids are still displayed together with the list of matches
      # defaults to Formicidae unless there's a single match or an id is picked
      @id = @search_results.first[:id]
      return redirect_to_id
    end

    setup_taxon_and_index
    render :show
  end

  def show_tribes
    session[:show_tribes] = true
    redirect_to_id
  end

  def hide_tribes
    session[:show_tribes] = false
    if @id.present?
      taxon = Taxon.find @id
      set_id_parameter taxon.subfamily.id if taxon.kind_of? Tribe
    end
    redirect_to_id
  end

  def show_unavailable_subfamilies
    session[:show_unavailable_subfamilies] = true
    redirect_to_id
  end

  def hide_unavailable_subfamilies
    session[:show_unavailable_subfamilies] = false
    redirect_to_id
  end

  def show_subgenera
    session[:show_subgenera] = true
    redirect_to_id
  end

  def hide_subgenera
    session[:show_subgenera] = false
    if @id.present?
      taxon = Taxon.find @id
      set_id_parameter taxon.genus.id if taxon.kind_of? Subgenus
    end
    redirect_to_id
  end

  private
    # Avoid blowing up if there's no family. Useful in test and dev.
    def handle_family_not_found
      family = Family.first
      render 'family_not_found' and return unless family
    end

    def redirect_to_id
      id = @id
      id_string = "/#{id}"
      parameters_string = @child ? '' : "?child=#{@child}"
      redirect_to "/catalog#{id_string}#{parameters_string}"
    end

    def setup_taxon_and_index
      # Among other thigs, this populates the lower half of the table
      # that is browsable (subfamiles, genera, [subgenera], species, [subspecies])
      @taxon = Taxon.find_by_id(@id) || Family.first

      if session[:show_unavailable_subfamilies]
        @subfamilies = ::Subfamily.all.ordered_by_name.where "display != false"
      else
        @subfamilies = ::Subfamily.all.ordered_by_name.where "status != 'unavailable' and display != false"
      end

      case @taxon
      when Family
        if @child == 'none'
          @subfamily = 'none'
          @genera = Genus.where("display != false").without_subfamily.ordered_by_name
        end

      when Subfamily
        @subfamily = @taxon

        if session[:show_tribes]
          @tribes = @subfamily.tribes.where("display != false").ordered_by_name
          if @child == 'none'
            @tribe = 'none'
            @genera = @subfamily.genera.where("display != false").without_tribe.ordered_by_name
          end
        else
          @genera = @subfamily.genera.where("display != false").ordered_by_name
        end

      when Tribe
        @tribe = @taxon
        @subfamily = @tribe.subfamily

        session[:show_tribes] = true
        @tribes = @tribe.siblings.where("display != false").ordered_by_name
        @genera = @tribe.genera.where("display != false").ordered_by_name

      when Genus
        @genus = @taxon
        @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
        setup_genus_parent_columns
        unless session[:show_subgenera]
          @specieses = @genus.species_group_descendants.where("display != false")
        else
          @subgenera = @genus.subgenera.where("display != false").ordered_by_name
        end

      when Subgenus
        @subgenus = @taxon
        @genus = @subgenus.genus
        @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
        session[:show_subgenera] = true
        @subgenera = @genus.subgenera.where("display != false").ordered_by_name
        setup_genus_parent_columns
        @specieses = @subgenus.species_group_descendants.where("display != false")

      when Species
        @species = @taxon
        @genus = @species.genus
        @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
        setup_genus_parent_columns
        @specieses = @genus.species_group_descendants.where("display != false")

      when Subspecies
        @species = @taxon
        @genus = @species.genus
        @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
        setup_genus_parent_columns
        @specieses = @genus.species_group_descendants.where("display != false")
      end
    end

    def setup_genus_parent_columns
      if session[:show_tribes]
        @genera = @genus.siblings.ordered_by_name
        @tribe = @genus.tribe ? @genus.tribe : 'none'
        @tribes = @subfamily == 'none' ? nil : @subfamily.tribes.where("display != false").ordered_by_name
      else
        @genera = @subfamily == 'none' ? Genus.without_subfamily.ordered_by_name : @subfamily.genera.where("display != false").ordered_by_name
      end
    end

    def get_parameters # TODO refactor
      @id = params[:id] if params[:id].present?
      @child = params[:child] if params[:child].present?
    end

    def set_id_parameter id
      @id = id
      @child = nil
    end

    def do_search
      return unless params[:qq].present?

      st = params[:st] || 'bw'
      search_selector_value = translate_search_selector_value_to_english st

      @search_results = Taxon.find_name(params[:qq], search_selector_value).map do |search_result|
        { name: search_result.name.name_html, id: search_result.id }
      end

      if @search_results.blank?
        @search_results_message = "No results found for name #{search_selector_value} '#{params[:qq]}'"
      end
    end

    def translate_search_selector_value_to_english value
      { 'm' => 'matching', 'bw' => 'beginning with', 'c' => 'containing' }[value]
    end
end
