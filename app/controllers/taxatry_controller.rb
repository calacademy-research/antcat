require 'snake'

class TaxatryController < ApplicationController

  before_filter :search

  def show
    @subfamilies = Subfamily.all :order => :name

    return if @search_results.blank? && params[:id].blank?

    @taxon = Taxon.find params[:id]
    @taxonomic_history = @taxon.taxonomic_history

    case @taxon
    when Subfamily
      @selected_subfamily = @taxon
      @genera = @selected_subfamily.genera
      @selected_genera = nil
      @species = nil
      @selected_species = nil
    when Genus
      @selected_subfamily = @taxon.subfamily
      if @selected_subfamily
        @genera = @selected_subfamily.genera
        subfamily_name = @selected_subfamily.name + ' '
      else
        @genera = [@taxon]
        subfamily_name = ''
      end
      @selected_genus = @taxon
      @species = @taxon.species
      @selected_species = nil
      @taxon_header_name = subfamily_name + '<i>' + @taxon.name + '</i>'
    when Species
      @selected_subfamily = @taxon.genus.subfamily
      @genera = @selected_subfamily.genera
      @selected_genus = @taxon.genus
      @species = @taxon.genus.species
      @selected_species = @taxon
      @taxon_header_name = @taxon.genus.subfamily.name + ' ' + '<i>' + @taxon.genus.name + ' ' + @taxon.name + '</i>'
    end

    @taxon_header_name = @taxon.full_name
    @taxon_header_status = @taxon.status.gsub /_/, ' ' if @taxon.invalid?
  end

  def search
    if params['commit'] == 'Clear'
      params['q'] = params['search_type'] = nil
      return
    end

    if params['q'].present?
      params['id'] = nil if params['commit'] == 'Go'
      @search_results = Taxon.find_name params['q'], params['search_type']
      unless @search_results.present?
        @search_results_message = "No results found"
      else
        @search_results = @search_results.map do |search_result|
          {:name => search_result.full_name, :id => search_result.id}
        end.sort_by {|element| element[:name]}
        params['id'] = @search_results.first[:id] if params['id'].blank?
        show
        true
      end
    end
  end

end

