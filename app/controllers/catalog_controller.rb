class CatalogController < ApplicationController
  before_filter :handle_family_not_found, only: [:index]
  before_filter :set_taxon, except: [:index, :search]
  before_filter :set_child, except: [:index, :search]

  def index
    taxon = Family.first
    setup_taxon_and_index taxon
    params[:id] = taxon.id # because the show/hide links requires an id
    render 'show'
  end

  def show
    setup_taxon_and_index @taxon
  end

  def search
    @search_results = get_search_results(params[:qq], params[:st])

    # Single match --> skip search results and just show the match
    if @search_results.count == 1
      taxon = @search_results.first
      return redirect_to catalog_path(taxon)
    end

    @search_selector_value = search_selector_value_in_english(params[:st])
    render 'search_results'
  end

  def show_tribes
    session[:show_tribes] = true
    redirect_to_taxon @taxon
  end

  def hide_tribes
    session[:show_tribes] = false
    return redirect_to catalog_path(@taxon.subfamily) if @taxon.kind_of? Tribe
    redirect_to_taxon @taxon
  end

  def show_unavailable_subfamilies
    session[:show_unavailable_subfamilies] = true
    redirect_to_taxon @taxon
  end

  def hide_unavailable_subfamilies
    session[:show_unavailable_subfamilies] = false
    redirect_to_taxon @taxon
  end

  def show_subgenera
    session[:show_subgenera] = true
    redirect_to_taxon @taxon
  end

  def hide_subgenera
    session[:show_subgenera] = false
    return redirect_to catalog_path(@taxon.genus) if @taxon.kind_of? Subgenus
    redirect_to_taxon @taxon
  end

  private
    # Avoid blowing up if there's no family. Useful in test and dev.
    def handle_family_not_found
      render 'family_not_found' and return unless Family.first
    end

    def set_taxon
      @taxon = Taxon.find(params[:id])
    end

    def set_child
      @child = params[:child]
    end

    def redirect_to_taxon taxon
      redirect_to catalog_path(taxon, child: @child)
    end

    # Among other things, this populates the lower half of the table that is
    # browsable (subfamiles, [tribes], genera, [subgenera], species, [subspecies]).
    def setup_taxon_and_index taxon
      @taxon = taxon
      @family = Family.first # FIX Hard-coded because we only have a single family,
      # which is not really correct, but it's done like this in other parts of the code.

      if session[:show_unavailable_subfamilies]
        @subfamilies = Subfamily.displayable.ordered_by_name
      else
        @subfamilies = Subfamily.displayable.ordered_by_name.where.not(status: 'unavailable')
      end

      case @taxon
      when Family
        if @child == 'none'
          @subfamily = 'none'
          @genera = Genus.displayable.without_subfamily.ordered_by_name
        end

      when Subfamily
        @subfamily = @taxon

        if session[:show_tribes]
          @tribes = @subfamily.tribes.displayable.ordered_by_name
          if @child == 'none'
            @tribe = 'none'
            @genera = @subfamily.genera.displayable.without_tribe.ordered_by_name
          end
        else
          @genera = @subfamily.genera.displayable.ordered_by_name
        end

      when Tribe
        @tribe = @taxon
        @subfamily = @tribe.subfamily

        session[:show_tribes] = true
        @tribes = @tribe.siblings.displayable.ordered_by_name
        @genera = @tribe.genera.displayable.ordered_by_name

      when Genus
        @genus = @taxon
        setup_genus_parent_columns
        if session[:show_subgenera]
          @subgenera = @genus.subgenera.displayable.ordered_by_name
        else
          @specieses = @genus.species_group_descendants.displayable
        end

      when Subgenus
        @subgenus = @taxon
        @genus = @subgenus.genus
        session[:show_subgenera] = true
        @subgenera = @genus.subgenera.displayable.ordered_by_name
        setup_genus_parent_columns
        @specieses = @subgenus.species_group_descendants.displayable

      when Species
        @species = @taxon
        @genus = @species.genus
        setup_genus_parent_columns
        @specieses = @genus.species_group_descendants.displayable

      when Subspecies
        @species = @taxon
        @genus = @species.genus
        setup_genus_parent_columns
        @specieses = @genus.species_group_descendants.displayable
      end
    end

    def setup_genus_parent_columns
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      if session[:show_tribes]
        @genera = @genus.siblings.ordered_by_name
        @tribe = @genus.tribe ? @genus.tribe : 'none'
        @tribes = @subfamily == 'none' ? nil : @subfamily.tribes.displayable.ordered_by_name
      else
        @genera = @subfamily == 'none' ? Genus.without_subfamily.ordered_by_name : @subfamily.genera.displayable.ordered_by_name
      end
    end

    # TODO rename all occurrences of "st"
    def get_search_results qq, st = 'bw'
      return unless qq.present?
      search_selector_value = search_selector_value_in_english st

      Taxa::Search.find_name(qq, search_selector_value)
    end

    def search_selector_value_in_english value
      { 'm' => 'matching', 'bw' => 'beginning with', 'c' => 'containing' }[value]
    end
end
