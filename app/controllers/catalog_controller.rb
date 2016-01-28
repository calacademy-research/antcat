class CatalogController < ApplicationController
  before_filter :handle_family_not_found, only: [:index]
  before_filter :get_parameters, except: [:search]

  def index
    taxon_id = Family.first.id
    setup_taxon_and_index taxon_id
    render 'show'
  end

  def show
    setup_taxon_and_index @id
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
    redirect_to_id @id
  end

  def hide_tribes
    session[:show_tribes] = false
    if @id.present?
      taxon = Taxon.find @id
      if taxon.kind_of? Tribe
        @id = taxon.subfamily.id
        @child = nil
      end
    end
    redirect_to_id @id
  end

  def show_unavailable_subfamilies
    session[:show_unavailable_subfamilies] = true
    redirect_to_id @id
  end

  def hide_unavailable_subfamilies
    session[:show_unavailable_subfamilies] = false
    redirect_to_id @id
  end

  def show_subgenera
    session[:show_subgenera] = true
    redirect_to_id @id
  end

  def hide_subgenera
    session[:show_subgenera] = false
    if @id.present?
      taxon = Taxon.find @id
      if taxon.kind_of? Subgenus
        @id = taxon.genus.id
        @child = nil
      end
    end
    redirect_to_id @id
  end

  private
    # Avoid blowing up if there's no family. Useful in test and dev.
    def handle_family_not_found
      family = Family.first
      render 'family_not_found' and return unless family
    end

    def redirect_to_id id
      parameters_string = @child ? "?child=#{@child}" : ''
      redirect_to "/catalog/#{id}#{parameters_string}"
    end

    # Among other thigs, this populates the lower half of the table
    # that is browsable (subfamiles, genera, [subgenera], species, [subspecies])
    def setup_taxon_and_index id
      @taxon = Taxon.find(id)

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
        @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
        setup_genus_parent_columns
        if session[:show_subgenera]
          @subgenera = @genus.subgenera.displayable.ordered_by_name
        else
          @specieses = @genus.species_group_descendants.displayable
        end

      when Subgenus
        @subgenus = @taxon
        @genus = @subgenus.genus
        @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
        session[:show_subgenera] = true
        @subgenera = @genus.subgenera.displayable.ordered_by_name
        setup_genus_parent_columns
        @specieses = @subgenus.species_group_descendants.displayable

      when Species
        @species = @taxon
        @genus = @species.genus
        @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
        setup_genus_parent_columns
        @specieses = @genus.species_group_descendants.displayable

      when Subspecies
        @species = @taxon
        @genus = @species.genus
        @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
        setup_genus_parent_columns
        @specieses = @genus.species_group_descendants.displayable
      end
    end

    def setup_genus_parent_columns
      if session[:show_tribes]
        @genera = @genus.siblings.ordered_by_name
        @tribe = @genus.tribe ? @genus.tribe : 'none'
        @tribes = @subfamily == 'none' ? nil : @subfamily.tribes.displayable.ordered_by_name
      else
        @genera = @subfamily == 'none' ? Genus.without_subfamily.ordered_by_name : @subfamily.genera.displayable.ordered_by_name
      end
    end

    def get_parameters
      @id = params[:id]
      @child = params[:child]
    end

    # TODO rename all occurrences of "st"
    def get_search_results qq, st = 'bw'
      return unless qq.present?
      search_selector_value = search_selector_value_in_english st

      Taxon.find_name(qq, search_selector_value)
    end

    def search_selector_value_in_english value
      { 'm' => 'matching', 'bw' => 'beginning with', 'c' => 'containing' }[value]
    end
end
