# coding: UTF-8
class CatalogController < ApplicationController
  before_filter :get_parameters

  def show
    if @parameters[:id].blank?
      @parameters[:id] = Family.first.id
      @show_short_taxon = true
    end
    do_search
    setup_taxon_and_index
  end

  def search
    if params[:commit] == 'Clear'
      clear_search
    else
      do_search
      set_id_parameter @search_results.first[:id] if @search_results.present?
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
    if @parameters[:id].present?
      taxon = Taxon.find @parameters[:id]
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
    taxon = Family.first
    redirect_to_id
  end

  def show_subgenera
    session[:show_subgenera] = true
    redirect_to_id
  end

  def hide_subgenera
    session[:show_subgenera] = false
    if @parameters[:id].present?
      taxon = Taxon.find @parameters[:id]
      set_id_parameter taxon.genus.id if taxon.kind_of? Subgenus
    end
    redirect_to_id
  end

  def redirect_to_id
    id = @parameters.delete :id
    id_string = "/#{id}"
    parameters_string = @parameters.empty? ? '' : "?#{@parameters.to_query}"
    redirect_to "/catalog#{id_string}#{parameters_string}"
  end

  ##########################
  def setup_taxon_and_index
    @taxon = Taxon.find_by_id(@parameters[:id]) || Family.first

    if session[:show_unavailable_subfamilies]
      @subfamilies = ::Subfamily.ordered_by_name
    else
      @subfamilies = ::Subfamily.ordered_by_name.where "status != 'unavailable'"
    end

    case @taxon

    when Family
      if @parameters[:child] == 'none'
        @subfamily = 'none'
        @genera = Genus.without_subfamily.ordered_by_name
      end

    when Subfamily
      @subfamily = @taxon

      if session[:show_tribes]
        @tribes = @subfamily.tribes.ordered_by_name
        if @parameters[:child] == 'none'
          @tribe = 'none'
          @genera = @subfamily.genera.without_tribe.ordered_by_name
        end
      else
        @genera = @subfamily.genera.ordered_by_name
      end

    when Tribe
      @tribe = @taxon
      @subfamily = @tribe.subfamily

      session[:show_tribes] = true
      @tribes = @tribe.siblings.ordered_by_name
      @genera = @tribe.genera.ordered_by_name

    when Genus
      @genus = @taxon
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      unless session[:show_subgenera]
        @specieses = @genus.species_group_descendants
      else
        @subgenera = @genus.subgenera.ordered_by_name
      end

    when Subgenus
      @subgenus = @taxon
      @genus = @subgenus.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      session[:show_subgenera] = true
      @subgenera = @genus.subgenera.ordered_by_name
      setup_genus_parent_columns
      @specieses = @subgenus.species_group_descendants

    when Species
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species_group_descendants

    when Subspecies
      @species = @taxon
      @genus = @species.genus
      @subfamily = @genus.subfamily ? @genus.subfamily : 'none'
      setup_genus_parent_columns
      @specieses = @genus.species_group_descendants

    end
  end

  def setup_genus_parent_columns
    if session[:show_tribes]
      @genera = @genus.siblings.ordered_by_name
      @tribe = @genus.tribe ? @genus.tribe : 'none'
      @tribes = @subfamily == 'none' ? nil : @subfamily.tribes.ordered_by_name
    else
      @genera = @subfamily == 'none' ? Genus.without_subfamily.ordered_by_name : @subfamily.genera.ordered_by_name
    end
  end

  ##########################
  def do_search
    return unless @parameters[:qq].present?
    search_selector_value = translate_search_selector_value_to_english @parameters[:st]
    @search_results = Taxon.find_name @parameters[:qq], search_selector_value
    if @search_results.blank?
      @search_results_message = "No results found for name #{search_selector_value} '#{@parameters[:qq]}'"
    else
      @search_results = @search_results.map do |search_result|
        {name: search_result.name.name_html, id: search_result.id}
      end
    end
  end

  def clear_search
    @parameters.delete :qq
    @parameters.delete :st
  end

  def translate_search_selector_value_to_english value
    {'m' => 'matching', 'bw' => 'beginning with', 'c' => 'containing'}[value]
  end

  ##########################
  def get_parameters
    @parameters = HashWithIndifferentAccess.new
    @parameters[:id] = params[:id] if params[:id].present?
    @parameters[:child] = params[:child] if params[:child].present?
    # We get invalid UTF-8 sometimes. #present crashes in that case so first test nility, then validity
    if params[:qq]
      if params[:qq].valid_encoding?
        @parameters[:qq] = params[:qq].strip
      else
        # if it is invalid, don't use it as the search box's contents
        params[:qq] = ''
      end
    end
    @parameters[:st] = params[:st] if params[:st].present?
  end

  def set_id_parameter id, child = nil
    @parameters[:id] = id
    if child
      @parameters[:child] = child
    else
      @parameters.delete :child
    end
  end

end
