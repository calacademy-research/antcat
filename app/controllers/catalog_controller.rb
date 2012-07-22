# coding: UTF-8
class CatalogController < ApplicationController
  before_filter :get_parameters

  def show
    if @parameters[:q].present?
      @search_results = Taxon.find_name @parameters[:q], @parameters[:search_type]
      if @search_results.blank?
        @search_results_message = 'No results found'
      else
        @search_results = @search_results.map do |search_result|
          {name: search_result.name.html_name, id: search_result.id}
        end
      end
      if @parameters[:id].blank?
        @parameters[:id] = @search_results.first[:id]
        @parameters[:child] = nil
      end
    end
    setup_taxon_and_index
    render :show
  end

  def search
    if params[:commit] == 'Clear'
      @parameters[:q] = @parameters[:search_type] = nil
    elsif @parameters[:q].present?
      @search_results = Taxon.find_name @parameters[:q], @parameters[:search_type]
      if @search_results.blank?
        @search_results_message = 'No results found'
      else
        @search_results = @search_results.map do |search_result|
          {name: search_result.name.html_name, id: search_result.id}
        end
        @parameters[:id] = @search_results.first[:id]
        @parameters[:child] = nil
      end
    end
    setup_taxon_and_index
    render :show
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

      @tribes = @subfamily.tribes.ordered_by_name
      if @parameters[:child] == 'none'
        @tribe = 'none'
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
    @parameters[:search_type] = params[:search_type] if params[:search_type]
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
