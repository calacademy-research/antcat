# coding: UTF-8
class CatalogController < ApplicationController

  def show
    @parameters = HashWithIndifferentAccess.new
    @parameters[:id] = params[:id] if params[:id]
    @parameters[:child] = params[:child] if params[:child]
    @parameters[:q] = params[:q].strip if params[:q]
    @parameters[:search_type] = params[:search_type] if params[:search_type]
    @parameters[:hide_tribes] = params[:hide_tribes] ? params[:hide_tribes] : true
    @parameters[:hide_subgenera] = params[:hide_subgenera] ? params[:hide_subgenera] : true

    if params[:commit] == 'Clear'
      @parameters[:q] = @parameters[:search_type] = nil
    elsif @parameters[:q].present?
      @parameters[:id] = nil if params[:is_search_form].present?
      @search_results = Taxon.find_name @parameters[:q], @parameters[:search_type]
      unless @search_results.present?
        @search_results_message = 'No results found'
      else
        @search_results = @search_results.map do |search_result|
          {name: search_result.name.html_name, id: search_result.id}
        end
        @parameters[:id] = @search_results.first[:id] if @parameters[:id].blank?
      end
    end

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
      if @parameters[:hide_tribes]
        @genera = @subfamily.genera.ordered_by_name
      else
        @tribes = @subfamily.tribes.ordered_by_name
      end

    when Tribe
      @tribe = @taxon
      @subfamily = @tribe.subfamily
      if @parameters[:hide_tribes]
        @taxon = @tribe.subfamily
        @parameters[:id] = @taxon.id
        @genera = @subfamily.genera.ordered_by_name
        @parameters[:hide_tribes] = false
      else
        @tribes = @tribe.siblings.ordered_by_name
        @genera = @tribe.genera.ordered_by_name
      end

    when Genus
      @genus = @taxon
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      if @parameters[:hide_subgenera]
        @specieses = @genus.species_group_descendants.includes(:name)
      else
        @subgenera = @genus.subgenera.ordered_by_name.includes(:name)
      end
      setup_genus_parent_columns

    when Subgenus
      @subgenus = @taxon
      @genus = @subgenus.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      @subgenera = @genus.subgenera.ordered_by_name.includes(:name)
      setup_genus_parent_columns
      @specieses = @subgenus.species_group_descendants.includes(:name)

    when Species
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species_group_descendants.includes(:name)

    when Subspecies
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species_group_descendants.includes(:name)

    end

    @parameters[:subfamily] = params[:subfamily] if params[:subfamily]
    @parameters[:tribe] = params[:tribe] if params[:tribe]
    @parameters[:genus] = params[:genus] if params[:genus]
    @parameters[:species] = params[:species] if params[:species]
  end

  def setup_genus_parent_columns
    if @parameters[:hide_tribes]
      @genera = @subfamily == 'none' ? Genus.without_subfamily.ordered_by_name : @subfamily.genera.ordered_by_name
    else
      @genera = @genus.siblings.includes(:name)
      @tribe = @genus.tribe ? @genus.tribe : 'none'
      @tribes = @subfamily == 'none' ? nil : @subfamily.tribes.ordered_by_name
    end
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
