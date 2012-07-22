# coding: UTF-8
class CatalogController < ApplicationController

  def show
    get_parameters
    do_search
    setup_taxon_and_index
    render :show
  end

  def search
    get_parameters
    if params[:commit] == 'Clear'
      clear_search
    else
      do_search
      if @search_results.present?
        @parameters[:id] = @search_results.first[:id]
        @parameters[:child] = nil
      end
    end
    setup_taxon_and_index
    render :show
  end

  def clear_search
    @parameters[:q] = @parameters[:st] = nil
  end

  def translate_search_selector_value_to_english value
    {'m' => 'matching', 'bw' => 'beginning with', 'c' => 'containing'}[value]
  end

  def do_search
    return unless @parameters[:q].present?
    @search_results = Taxon.find_name @parameters[:q], translate_search_selector_value_to_english(@parameters[:st])
    if @search_results.blank?
      @search_results_message = 'No results found'
    else
      @search_results = @search_results.map do |search_result|
        {name: search_result.name.html_name, id: search_result.id}
      end
    end
  end

  def setup_taxon_and_index
    @parameters[:id] = Family.first.id if @parameters[:id].blank?
    @taxon = Taxon.find @parameters[:id]

    @subfamilies = ::Subfamily.ordered_by_name

    case @taxon

    when Family
      if @parameters[:child] == 'none'
        @subfamily = 'none'
        @genera = Genus.without_subfamily.ordered_by_name
      end

    when Subfamily
      @subfamily = @taxon

      if @parameters[:show_tribes]
        @tribes = @subfamily.tribes.ordered_by_name
        if @parameters[:child] == 'none'
          @tribe = 'none'
          @genera = @subfamily.genera.ordered_by_name
        end
      else
        @genera = @subfamily.genera.ordered_by_name
      end

    when Tribe
      @tribe = @taxon
      @subfamily = @tribe.subfamily

      @tribes = @tribe.siblings.ordered_by_name
      @genera = @tribe.genera.ordered_by_name

    when Genus
      @genus = @taxon
      @tribe = @genus.tribe ? @genus.tribe : 'none'
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'

      @tribes = @subfamily.tribes.ordered_by_name unless @subfamily == 'none'
      @genera = @genus.siblings.ordered_by_name
      @subgenera = @genus.subgenera.ordered_by_name
      @specieses = @genus.species_group_descendants.ordered_by_name

    when Subgenus
      @subgenus = @taxon
      @genus = @subgenus.genus
      @tribe = @genus.tribe ? @genus.tribe : 'none'
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'

      @tribes = @subfamily.tribes.ordered_by_name unless @subfamily == 'none'
      @genera = @genus.siblings.ordered_by_name
      @subgenera = @genus.subgenera.ordered_by_name
      @specieses = @subgenus.species_group_descendants.ordered_by_name

    when Species
      @species = @taxon
      @genus = @species.genus
      @tribe = @genus.tribe ? @genus.tribe : 'none'
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'

      @tribes = @subfamily.tribes.ordered_by_name unless @subfamily == 'none'
      @genera = @genus.siblings.ordered_by_name
      @specieses = @genus.species_group_descendants.ordered_by_name

    when Subspecies
      @species = @taxon
      @genus = @species.genus
      @tribe = @genus.tribe ? @genus.tribe : 'none'
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'

      @tribes = @subfamily.tribes.ordered_by_name unless @subfamily == 'none'
      @genera = @genus.siblings.ordered_by_name
      @specieses = @genus.species_group_descendants.ordered_by_name

    end

  end

  def get_parameters
    @parameters = HashWithIndifferentAccess.new
    @parameters[:id] = params[:id] if params[:id]
    @parameters[:child] = params[:child] if params[:child]
    @parameters[:q] = params[:q].strip if params[:q]
    @parameters[:st] = params[:st] if params[:st]
    @parameters[:show_tribes] = false
  end

  def create
    tribe = Tribe.find params[:genus][:tribe]
    genus = Genus.new(
      name: params[:genus][:name],
      status: 'valid',
      tribe: tribe)
    genus.save

    json = {
      isNew: true,
      content: render_to_string(partial: 'catalog/taxon_form', locals: {genus: genus, tribe: tribe}),
      success: genus.errors.empty?
    }.to_json

    render json: json, content_type: 'text/html'
  end

end
